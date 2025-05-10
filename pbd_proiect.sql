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

exec CATALOGPKG.AddProductToCategories(2,'Reducere,Laptopuri');

SELECT * from PRODUCTCATEGORIES;

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
        
        RETURN v_id;        

        EXCEPTION 
            WHEN OTHERS THEN
                IF SQLCODE = -1 THEN
                    DBMS_OUTPUT.PUT_LINE('Eroare: Exista deja un produs cu acest nume');        
                    RETURN 1;
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

        DBMS_OUTPUT.PUT_LINE('a fost generat slug-ul: ' || v_slug);

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
                    DBMS_OUTPUT.PUT_LINE('Eroare: Exista deja o categorie cu acest nume');        
                    RETURN 1;
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
                DBMS_OUTPUT.PUT_LINE('INVALID_CATEGORY_FORMAT');
            WHEN CATEGORY_NOT_FOUND THEN 
                DBMS_OUTPUT.PUT_LINE('CATEGORY_NOT_FOUND');
            WHEN PRODUCT_NOT_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('PRODUCT_NOT_FOUND');
        
    END AddProductToCategories;

END;
/
 