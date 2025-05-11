

 
DECLARE
    v_customer_id NUMBER;
    v_product_id NUMBER;
BEGIN
    v_customer_id := CustomerPkg.AddCustomer('Ion', 'Popescu', 'ion.popescu@example.com', 'parola123', '0712345678');
    v_product_id  := CATALOGPKG.ADDPRODUCT('Lenovo Legion 5 16IRX91', 'Laptop Gaming', 7799.99, 20, 'Lenovo-Legion-5-16IRX9.jpg', 5);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_product_id, 'Laptopuri,Gaming,Reducere');
END;
/


-- adaugarea unor produse in cos atunci cand cosul inca nu a fost creat (cosul trebuie sa se creeze automat)
-- se va afisa : Info: A fost creat cosul cu id = 1 (CreateCart)
--               Info: A fost adaugat in cos un produs cu id = 17 si cantitate = 5 (AddItem)


DECLARE 
    v_customer_id NUMBER := 4; -- luate de mai sus
    v_product_id NUMBER := 17;
BEGIN
    SAVEPOINT before_insert;

    CARTPKG.ADDITEM(v_customer_id, v_product_id, 5);    

    ROLLBACK to before_insert;
END;    
/

-- adaugarea unui produs in cos atunci cand el deja exista in cos (va creste cantitatea)
-- se va afisa : Info: A fost adaugat in cos un produs cu id = 17 si cantitate = 5 (AddItem)

DECLARE 
    v_customer_id NUMBER := 4; 
    v_product_id NUMBER := 17;
    v_items CartPkg.ProductList;
    v_temp NUMBER;
BEGIN
    SAVEPOINT before_insert;

    CARTPKG.ADDITEM(v_customer_id, v_product_id, 5);    
    CARTPKG.ADDITEM(v_customer_id, v_product_id, 5);
    CARTPKG.ADDITEM(v_customer_id, 2, 1);

    v_items := CartPkg.GetItems(4);
    
    DBMS_OUTPUT.PUT_LINE('Produsele din cosul clientului:');
    DBMS_OUTPUT.PUT_LINE('Nr | Id |      Nume      | Cantitate');
    FOR i IN 1..v_items.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(i || ': ' || v_items(i).id || ' - ' || v_items(i).nume || ' - ' || v_items(i).cantitate);
    END LOOP;

    ROLLBACK to before_insert;
END;    
/

-- adaugarea unui produs in cos cu o cantitate mai mare decat cea existenta in stoc  
-- se va afisa :Eroare: Stocul produsului 17 este mai mic decat cantitatea dorita pentru adaugare in cos (AddItem) si nu il va adauga

-- adaugarea unui produs care nu mai exista
-- se va afisa: Eroare: Produsul nu exista
DECLARE 
    v_customer_id NUMBER := 4; 
    v_product_id NUMBER := 17;
    v_items CartPkg.ProductList;
    v_temp NUMBER;
BEGIN
    CARTPKG.ADDITEM(v_customer_id, v_product_id, 123);    
    CARTPKG.ADDITEM(v_customer_id, 99999, 1);
 
    v_items := CartPkg.GetItems(4);
    
    DBMS_OUTPUT.PUT_LINE('Produsele din cosul clientului:');
    DBMS_OUTPUT.PUT_LINE('Nr | Id |      Nume      | Cantitate');
    FOR i IN 1..v_items.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(i || ': ' || v_items(i).id || ' - ' || v_items(i).nume || ' - ' || v_items(i).cantitate);
    END LOOP;

    ROLLBACK;

END;    
/

-- stergerea din catalog a unui produs existent
-- se va afisa: 
--      Info: Se initializeaza stergerea produsului: 21 - Lenovo Legion 5 16IRX912
--      Info: Produs marcat ca indisponibil: 21
--      Info: Produsul a fost sters cu succes
DECLARE
    v_product_id NUMBER;
BEGIN
    v_product_id := CATALOGPKG.ADDPRODUCT('Lenovo Legion 5 16IRX912', 'Laptop Gaming', 7799.99, 20, 'Lenovo-Legion-5-16IRX92.jpg', 5);
    CATALOGPKG.REMOVEPRODUCT(v_product_id);
    ROLLBACK;
END;
/

-- stergerea din catalog a unui produs inexistent
-- se va afisa: Eroare: Produsul cu id = -232 nu exista
DECLARE
    v_product_id NUMBER := -232;
BEGIN
    CATALOGPKG.REMOVEPRODUCT(v_product_id);
END;
/

-- stergerea unui produs care este daugat in cos (va fi sters si din cos)

DECLARE
    v_customer_id  Customer.CUSTOMERID%TYPE;
    v_product_id NUMBER;
BEGIN
    v_customer_id := CustomerPkg.AddCustomer('Ion', 'Popescu', 'ion.popescu@example.com', 'parola123', '0712345678');
    v_product_id := CATALOGPKG.ADDPRODUCT('Lenovo Legion 5 16IRX91', 'Laptop Gaming', 7799.99, 20, 'Lenovo-Legion-5-16IRX9.jpg', 5);
    CARTPKG.ADDITEM(v_customer_id, v_product_id, 1);

    CATALOGPKG.REMOVEPRODUCT(v_product_id);
    
    ROLLBACK;
END;
/

truncate table CartItems;
TRUNCATE TABLE CART;
DELETE FROM PRODUCTS WHERE Name = 'Lenovo Legion 5 16IRX91';
DELETE FROM CUSTOMER where FIRSTNAME = 'Ion';

SELECT * FROM CART;
 



-- ALTER SYSTEM KILL SESSION 'sid,serial#' IMMEDIATE;

TRUNCATE TABLE CartItems;
TRUNCATE TABLE CART;

SELECT * FROM CART;

SELECT * FROM PRODUCTS;
SELECT * FROM CUSTOMER;

 SELECT COUNT(*)  FROM CARTITEMS
            WHERE CART_CARTID = 2 AND PRODUCTS_PRODUCTID = 1;