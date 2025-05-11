CREATE OR REPLACE TRIGGER Products_Slug_TRG
BEFORE INSERT ON Products
FOR EACH ROW
DECLARE
    v_rand_str VARCHAR(10);
    v_slug Products.SLUG%TYPE;
BEGIN
    
    :NEW.slug := CATALOGPKG.GenerateSlug(:NEW.Name);
    
END;
/

CREATE OR REPLACE PACKAGE CatalogPkg 
IS
    FUNCTION AddProduct( 
        p_Name          NVARCHAR2, 
        p_Description   NVARCHAR2, 
        p_Price         NUMBER, 
        p_StockQuantity INTEGER, 
        p_ImageUrl      VARCHAR2, 
        p_Discount      NUMBER := 0
    ) RETURN NUMBER;

    FUNCTION GenerateSlug(
        p_Name  Products.NAME%TYPE
    ) RETURN VARCHAR2;

    FUNCTION AddCategory(
        p_Name          NVARCHAR2, 
        p_Description   NVARCHAR2 := '' 
    ) RETURN NUMBER;

    PROCEDURE AddProductToCategories (
        prod_id         PRODUCTS.PRODUCTID%TYPE,
        categories_list VARCHAR2
    );

    PROCEDURE RemoveProduct (
        p_id Products.PRODUCTID%TYPE
    );
END;
/

CREATE OR REPLACE  PACKAGE BODY CatalogPkg 
IS
    FUNCTION AddProduct (
        p_Name          NVARCHAR2, 
        p_Description   NVARCHAR2, 
        p_Price         NUMBER, 
        p_StockQuantity INTEGER, 
        p_ImageUrl      VARCHAR2, 
        p_Discount      NUMBER 
    )  RETURN NUMBER 
    IS
        v_id Products.PRODUCTID%TYPE;
    BEGIN 
        INSERT INTO Products (Name, Description, Price, StockQuantity, ImageUrl, DISCOUNT) 
            VALUES (p_Name, p_Description, p_Price, p_StockQuantity, p_ImageUrl, p_DISCOUNT)
            RETURNING ProductID INTO v_id;
        
        DBMS_OUTPUT.PUT_LINE('Info: A fost adaugat un produs cu id = ' || v_id || ' (Products)');
        RETURN v_id;        

        EXCEPTION 
            WHEN OTHERS THEN
                IF SQLCODE = -1 THEN
                    DBMS_OUTPUT.PUT_LINE('Eroare: Exista deja un produs cu acest nume' || ' (Products)');        
                    RETURN -1;
                ELSE 
                    RAISE;
                END IF; 
    END AddProduct;


    FUNCTION GenerateSlug(
        p_Name  Products.NAME%TYPE
    ) RETURN VARCHAR2
    IS
        v_slug Products.NAME%TYPE;
        v_rand_str VARCHAR2(8);
    BEGIN
        v_slug := p_Name;
        v_slug := LOWER(v_slug);
        v_slug := REPLACE(v_slug, ' ', '-');
        v_slug := REGEXP_REPLACE(v_slug, '[^a-z0-9\-]', '');

        SELECT DBMS_RANDOM.STRING('x', 8) INTO v_rand_str FROM DUAL;
        SELECT CONCAT(v_slug, CONCAT('-', v_rand_str))  INTO v_slug FROM DUAL;

     
        DBMS_OUTPUT.PUT_LINE('Info: A fost generat slug =' || v_slug || ' (GenerateSlug)');
        RETURN v_slug;
 
    END GenerateSlug;

    FUNCTION AddCategory(
        p_Name          NVARCHAR2, 
        p_Description   NVARCHAR2 := ''
    ) RETURN NUMBER
    IS
    
    BEGIN
        INSERT INTO Categories (Name, Description)
            VALUES(p_Name, p_Description);

        RETURN 0;        

        EXCEPTION
            WHEN OTHERS THEN
                IF SQLCODE = -1 THEN
                    DBMS_OUTPUT.PUT_LINE('Eroare: Exista deja o categorie cu acest nume' || ' (AddCategory)');        
                    RETURN -1;
                ELSE 
                    RAISE;
                END IF;     
    END AddCategory;

    PROCEDURE AddProductToCategories
    (
        prod_id PRODUCTS.PRODUCTID%TYPE,
        categories_list VARCHAR2 
    ) IS
        TYPE category_list IS TABLE OF PRODUCTS.PRODUCTID%TYPE INDEX BY PLS_INTEGER;
        v_categories category_list;

        v_index NUMBER := 1;
        v_cat_str VARCHAR(50); 
        
        INVALID_CATEGORY_FORMAT EXCEPTION;
        CATEGORY_NOT_FOUND EXCEPTION;
        PRODUCT_NOT_FOUND EXCEPTION;

        v_cat_name VARCHAR2(50);
        v_cat_id VARCHAR2(50);
        v_temp INTEGER(10);

    BEGIN
        LOOP 
            SELECT REGEXP_SUBSTR(categories_list, '[^,]+', 1, v_index) INTO v_cat_str FROM dual;
            EXIT WHEN v_cat_str is NULL;  

            BEGIN
                SELECT CATEGORYID INTO v_cat_id FROM CATEGORIES WHERE NAME = v_cat_str;
            
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                        RAISE CATEGORY_NOT_FOUND; 
                    WHEN OTHERS THEN
                        RAISE INVALID_CATEGORY_FORMAT;
            END;
            
            BEGIN
                SELECT prod_id INTO v_temp FROM PRODUCTS WHERE PRODUCTID = prod_id;
            
                EXCEPTION 
                    WHEN NO_DATA_FOUND THEN
                        RAISE PRODUCT_NOT_FOUND; 
                    WHEN OTHERS THEN
                        RAISE INVALID_CATEGORY_FORMAT;
            END;
            
            v_categories(v_index) := v_cat_id;
            v_index := v_index + 1;

        END LOOP;
        
        for i IN 1..v_categories.COUNT LOOP
                INSERT INTO ProductCategories (PRODUCTS_PRODUCTID, CATEGORIES_CATEGORYID) VALUES (prod_id, v_categories(i));
        END LOOP;

        EXCEPTION 
            WHEN INVALID_CATEGORY_FORMAT THEN
                DBMS_OUTPUT.PUT_LINE('Eroare: Categoriile pentru inserare nu au un format valid' || ' (AddProductToCategories)');
            WHEN CATEGORY_NOT_FOUND THEN 
                DBMS_OUTPUT.PUT_LINE('Eroare: Categoria nu exista' || ' (AddProductToCategories)');
            WHEN PRODUCT_NOT_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Eroare: Produsul nu exista' || ' (AddProductToCategories)');
        
    END AddProductToCategories;

   PROCEDURE RemoveProduct (
        p_id Products.PRODUCTID%TYPE
    ) IS
        v_product_name Products.NAME%TYPE;
        v_in_carts NUMBER := 0;
        
        PRODUCT_NOT_FOUND EXCEPTION;
        PRODUCT_ALREADY_INACTIVE EXCEPTION;

        -- PRAGMA AUTONOMOUS_TRANSACTION; -- pentru a putea face rollback din afara
    BEGIN
        
        -- Inceputul tranzactiei

        -- 1. Verifica existenta produsului
        BEGIN
            SELECT Name INTO v_product_name 
            FROM Products 
            WHERE ProductID = p_id;
            
            -- Verifica daca este deja indisponibil
            IF v_product_name LIKE '[INDISPONIBIL]%' THEN
                RAISE PRODUCT_ALREADY_INACTIVE;
            END IF;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE PRODUCT_NOT_FOUND;
        END;
        
        
        DBMS_OUTPUT.PUT_LINE('Info: Se initializeaza stergerea produsului: ' || p_id || ' - ' || v_product_name);
        
        -- 2. Verifica daca produsul este in cosuri
        SELECT COUNT(*) INTO v_in_carts
        FROM CartItems
        WHERE Products_ProductID = p_id;
        
        -- Salvare inanite de stergere
        SAVEPOINT before_changes;
        
        -- 3. Șterge din coșurile curente (dacă există)
        IF v_in_carts > 0 THEN
            DELETE FROM CartItems WHERE Products_ProductID = p_id;
            DBMS_OUTPUT.PUT_LINE('Info: A fost sters din ' || v_in_carts || ' cosuri');
        END IF;
        
        -- 4. Marcheaza produsul ca indisponibil
        UPDATE Products SET
            Name = '[INDISPONIBIL] ' || v_product_name,
            Description = ' [Produs indisponibil]',
            Price = 0,
            StockQuantity = 0,
            Discount = 0,               
            Rating = 0       
        WHERE ProductID = p_id;
        
        DBMS_OUTPUT.PUT_LINE('Info: Produs marcat ca indisponibil: ' || p_id);
        
        DBMS_OUTPUT.PUT_LINE('Info: Produsul a fost sters cu succes');
        
    EXCEPTION
        WHEN PRODUCT_NOT_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Eroare: Produsul cu id = ' || p_id || ' nu exista');
            ROLLBACK;
        WHEN PRODUCT_ALREADY_INACTIVE THEN
            DBMS_OUTPUT.PUT_LINE('Eroare: Produsul este deja marcat ca indisponibil');
            ROLLBACK;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Eroare nedefinita: ');
            ROLLBACK;
            RAISE;
    END RemoveProduct;
END;
/


CREATE OR REPLACE PACKAGE CartPkg 
IS
    FUNCTION CreateCart (
        c_id Customer.CustomerID%TYPE
    ) RETURN CART.CartID%TYPE;

    PROCEDURE AddItem(
        p_customer_id Customer.CustomerID%TYPE,
        p_product_id PRODUCTS.PRODUCTID%TYPE,
        p_quantity NUMBER
    );
    TYPE ProductRec IS RECORD (
        id          PRODUCTS.PRODUCTID%TYPE,
        nume        PRODUCTS.NAME%TYPE,
        cantitate   CARTITEMS.QUANTITY%TYPE
    );

    TYPE ProductList IS TABLE OF ProductRec INDEX BY PLS_INTEGER;

    FUNCTION GetItems(
        c_id CUSTOMER.CUSTOMERID%TYPE
    ) RETURN ProductList;
END;
/

CREATE OR REPLACE PACKAGE BODY CartPkg 
IS
    FUNCTION CreateCart (
        c_id Customer.CustomerID%TYPE
    ) RETURN CART.CartID%TYPE
    IS
        v_date DATE;
        v_id CART.CartID%TYPE;
    BEGIN

        SELECT SYSDATE INTO v_date FROM DUAL;

        INSERT INTO CART(CREATEDAT, CUSTOMERID) VALUES(v_date, c_id)
        RETURNING CartID INTO v_id;
        
        DBMS_OUTPUT.PUT_LINE('Info: A fost creat cosul cu id = ' || v_id || ' (CreateCart)');
        RETURN v_id; 

        EXCEPTION 
            WHEN OTHERS THEN
                IF SQLCODE = -1 THEN
                    DBMS_OUTPUT.PUT_LINE('Eroare: Clientul are deja un cos' || ' (CreateCart)');        
                    RETURN -1;
                ELSE 
                    RAISE;
                END IF; 
    END CreateCart;

    PROCEDURE AddItem(
        p_customer_id Customer.CustomerID%TYPE,
        p_product_id PRODUCTS.PRODUCTID%TYPE,
        p_quantity NUMBER
    ) IS
        v_cart_id CART.CARTID%TYPE;
        v_stock NUMBER;

        v_cnt NUMBER;

        CART_CREATE_ERROR EXCEPTION;
        INSUFFICIENT_STOCK EXCEPTION;
        PRODUCT_NOT_FOUND EXCEPTION;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM PRODUCTS where PRODUCTID = p_product_id;
        IF v_cnt = 0 THEN
            RAISE PRODUCT_NOT_FOUND;
        END IF;

        -- daca nu exista un cos asociat unui client atunci se va crea unul nou
        SELECT COUNT(*) INTO v_cnt FROM CART WHERE CUSTOMERID = p_customer_id;
        
        IF v_cnt = 0 THEN
            v_cart_id := CartPkg.CreateCart(p_customer_id);
            IF v_cart_id < 0 THEN
                RAISE CART_CREATE_ERROR;
            END IF;
        ELSE 
            SELECT CARTID INTO v_cart_id FROM CART WHERE CUSTOMERID = p_customer_id;
        END IF;
        
        SELECT PRODUCTS.STOCKQUANTITY INTO v_stock FROM PRODUCTS
            WHERE PRODUCTID = p_product_id;      
        IF v_stock < p_quantity THEN
            RAISE INSUFFICIENT_STOCK;
        END IF;     

        SELECT COUNT(*) INTO v_cnt FROM CARTITEMS
            WHERE CART_CARTID = v_cart_id AND PRODUCTS_PRODUCTID = p_product_id;
        
    
        IF v_cnt = 0 THEN
            INSERT INTO CARTITEMS(CART_CARTID, PRODUCTS_PRODUCTID, QUANTITY) 
                VALUES(v_cart_id, p_product_id, p_quantity);
           
            DBMS_OUTPUT.PUT_LINE('Info: A fost adaugat in cos un produs cu id = ' || p_product_id || ' si cantitate = ' || p_quantity || ' (AddItem)');
        ELSE 
            UPDATE CARTITEMS
            SET QUANTITY = QUANTITY + p_quantity
            WHERE CART_CARTID = v_cart_id AND PRODUCTS_PRODUCTID = p_product_id;
           
            DBMS_OUTPUT.PUT_LINE('Info: A fost modificat in cos un produs cu id = ' || p_product_id || ' si cantitate = ' || p_quantity || ' (AddItem)');
        END IF;
        

        EXCEPTION
            WHEN CART_CREATE_ERROR THEN
                DBMS_OUTPUT.PUT_LINE('Eroare: Cosul nu a putut fi creat' || ' (AddItem)');
            WHEN INSUFFICIENT_STOCK THEN
                DBMS_OUTPUT.PUT_LINE('Eroare: Stocul produsului ' || p_product_id || ' este mai mic decat cantitatea dorita pentru adaugare in cos' || ' (AddItem)');
            WHEN PRODUCT_NOT_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Eroare: Produsul nu exista' || ' (AddItem)');

    END ADDITEM;
    
    FUNCTION GetItems(
        c_id CUSTOMER.CUSTOMERID%TYPE
    ) RETURN ProductList IS
        v_cart_id CART.CARTID%TYPE;
        v_list ProductList;
        i INTEGER := 0;

        CURSOR cv_cartitems(p_cart_id CART.CARTID%TYPE) IS
            SELECT PRODUCTS_PRODUCTID, QUANTITY
            FROM CARTITEMS
            WHERE CART_CARTID = p_cart_id;

        v_prod_id PRODUCTS.PRODUCTID%TYPE;
        v_qty CARTITEMS.QUANTITY%TYPE;
        v_name PRODUCTS.NAME%TYPE;
    BEGIN

        SELECT CARTID INTO v_cart_id FROM CART WHERE CUSTOMERID = c_id;

        FOR v_row IN cv_cartitems(v_cart_id) LOOP
            v_prod_id := v_row.PRODUCTS_PRODUCTID;
            v_qty := v_row.QUANTITY;
            DBMS_OUTPUT.PUT_LINE('p_id = ' || v_prod_id);
            SELECT NAME INTO v_name FROM PRODUCTS WHERE PRODUCTID = v_prod_id;

            i := i + 1;
            v_list(i).id := v_prod_id;
            v_list(i).nume := v_name;
            v_list(i).cantitate := v_qty;
        END LOOP;

        RETURN v_list;
    END GetItems;
END;
/
 
 
CREATE OR REPLACE PACKAGE CustomerPkg
IS
    FUNCTION AddCustomer(
        p_FirstName        NVARCHAR2, 
        p_LastName         NVARCHAR2, 
        p_Email            VARCHAR2, 
        p_Password         VARCHAR2, 
        p_PhoneNumber      VARCHAR2 := '' 
    ) RETURN INTEGER;

END;
/

CREATE OR REPLACE PACKAGE BODY CustomerPkg
IS
    FUNCTION AddCustomer(
        p_FirstName        NVARCHAR2, 
        p_LastName         NVARCHAR2, 
        p_Email            VARCHAR2, 
        p_Password         VARCHAR2, 
        p_PhoneNumber      VARCHAR2 := '' 
    ) RETURN INTEGER
    IS 
        v_customer_id INTEGER;
        v_date DATE;
    BEGIN
        SELECT SYSDATE INTO v_date FROM DUAL;

        INSERT INTO CUSTOMER (FIRSTNAME, LASTNAME, EMAIL, PASSWORD, PHONENUMBER, REGISTRATIONDATE) 
            VALUES( p_FIRSTNAME, p_LASTNAME, p_EMAIL, p_PASSWORD, p_PHONENUMBER, v_date)
            RETURNING CUSTOMERID INTO v_customer_id;
        
        DBMS_OUTPUT.PUT_LINE('Info: A fost adaugat clinetul cu id = ' || v_customer_id || ' (AddCustomer)');
        RETURN v_customer_id;

    END AddCustomer;

END;
/

 