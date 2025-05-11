 
DECLARE 
    v_result NUMBER;
BEGIN
    v_result := CATALOGPKG.ADDCATEGORY('Reducere');
    v_result := CATALOGPKG.ADDCATEGORY('Laptopuri', 'Laptopuri pentru uz personal si profesional');
    v_result := CATALOGPKG.ADDCATEGORY('Telefoane', 'Telefoane mobile si smartphone-uri');
    v_result := CATALOGPKG.ADDCATEGORY('Telefoane IOS');
    v_result := CATALOGPKG.ADDCATEGORY('Telefoane Android');
    v_result := CATALOGPKG.ADDCATEGORY('Televizoare', 'Televizoare 4K, Smart TV, LED, OLED');
    v_result := CATALOGPKG.ADDCATEGORY('Tablete', 'Tablete Android si iOS');
    v_result := CATALOGPKG.ADDCATEGORY('Accesorii telefoane', 'Căști, huse, încărcătoare, suporturi');
    v_result := CATALOGPKG.ADDCATEGORY('Calculatoare', 'PC-uri desktop pentru gaming, birou, și studii');
    v_result := CATALOGPKG.ADDCATEGORY('Camere foto', 'Camere foto digitale, camere video și accesorii');
    v_result := CATALOGPKG.ADDCATEGORY('Monitoare', 'Monitoare LED, LCD pentru birou și gaming');
    v_result := CATALOGPKG.ADDCATEGORY('Smart Home', 'Produse pentru automatizarea locuinței');
    v_result := CATALOGPKG.ADDCATEGORY('Gaming', 'Produse pentru gaming');
    v_result := CATALOGPKG.ADDCATEGORY('Audio si Video', 'Produse pentru redare audio și video');
    v_result := CATALOGPKG.ADDCATEGORY('Office', 'Produse pentru birou și muncă de acasă');
    v_result := CATALOGPKG.ADDCATEGORY('Video', 'Echipamente pentru înregistrare și redare video');
    v_result := CATALOGPKG.ADDCATEGORY('Portabile', 'Dispozitive ușor de transportat');
    v_result := CATALOGPKG.ADDCATEGORY('Fitness', 'Gadgeturi pentru sport și sănătate');
    v_result := CATALOGPKG.ADDCATEGORY('Accesorii', 'Accesorii PC');
END;
/

COMMIT;

DECLARE
    v_prod_id NUMBER;
BEGIN
    
    v_prod_id := CATALOGPKG.ADDPRODUCT('iPhone 15', 'Smartphone Apple iPhone 15', 4999, 20, 'iphone15.jpg', 10);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Telefoane,Telefoane IOS');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Samsung Galaxy S24', 'Smartphone Samsung Galaxy S24', 4199, 15, 's24.jpg', 5);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Telefoane,Telefoane Android');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Asus ROG Strix', 'Laptop de gaming performant', 6899, 10, 'rog.jpg', 15);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Laptopuri,Gaming');

    v_prod_id := CATALOGPKG.ADDPRODUCT('MacBook Air', 'Laptop Apple pentru birou și personal', 5599, 12, 'macbook.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Laptopuri,Office');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Xiaomi Mi Band 7', 'Brățară fitness cu ecran AMOLED', 199, 30, 'miband7.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Fitness,Portabile');

    v_prod_id := CATALOGPKG.ADDPRODUCT('LG OLED C3', 'Televizor OLED 4K 55 inch', 6399, 8, 'lgc3.jpg', 20);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Televizoare,Audio si Video');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Canon EOS R50', 'Aparat foto mirrorless', 3599, 7, 'eosr50.jpg', 5);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Camere foto');

    v_prod_id := CATALOGPKG.ADDPRODUCT('iPad 10th Gen', 'Tabletă Apple iOS', 2999, 9, 'ipad10.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Tablete,Portabile');
    
    v_prod_id := CATALOGPKG.ADDPRODUCT('Razer Kraken V3', 'Căști de gaming cu sunet 7.1', 499, 25, 'kraken.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Accesorii telefoane,Gaming');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Google Nest Hub', 'Asistent smart home cu ecran', 599, 6, 'nesthub.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Smart Home,Audio si Video');

    v_prod_id := CATALOGPKG.ADDPRODUCT('HP OfficeJet Pro 9020', 'Imprimantă multifuncțională wireless', 899, 5, 'hp9020.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Office');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Dell UltraSharp 27', 'Monitor 27" QHD pentru birou', 1499, 10, 'dell27.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Monitoare,Office');

    v_prod_id := CATALOGPKG.ADDPRODUCT('GoPro Hero 12', 'Cameră video sport 5K', 2299, 10, 'gopro12.jpg', 10);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Camere foto,Video');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Lenovo Legion Tower', 'PC Desktop pentru gaming', 6999, 4, 'legion.jpg', 5);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Calculatoare,Gaming');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Samsung Galaxy Tab S9', 'Tabletă Android high-end', 3799, 6, 'tabs9.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Tablete,Telefoane Android');

    v_prod_id := CATALOGPKG.ADDPRODUCT('Logitech MX Master 3S', 'Mouse wireless ergonomic', 449, 18, 'mxmaster.jpg', 0);
    CATALOGPKG.ADDPRODUCTTOCATEGORIES(v_prod_id, 'Accesorii,Office');

END;
/
COMMIT;
 

SELECT * from CATEGORIES;


DECLARE
    v_customer_id INTEGER;
BEGIN
    -- v_customer_id := CustomerPkg.AddCustomer('Ion', 'Popescu', 'ion.popescu@example.com', 'parola123', '0712345678');
    v_customer_id := CustomerPkg.AddCustomer('Maria', 'Ionescu', 'maria.ionescu@example.com', 'mypass456', '0723456789');
    v_customer_id := CustomerPkg.AddCustomer('Andrei', 'Georgescu', 'andrei.g@example.com', 'secure789', '0734567890');
    v_customer_id := CustomerPkg.AddCustomer('Elena', 'Marin', 'elena.marin@example.com', 'elena123', '0745678901');
    
END;
/

COMMIT;

-- GRANT SELECT ON v_$session TO pbd_project;
-- GRANT CREATE TABLE TO pbd_project;
-- GRANT EXECUTE ON DBMS_LOCK TO pbd_project;

-- TRUNCATE TABLE PRODUCTS CASCADE;
-- SELECT * from CATEGORIES;
-- SELECT * FROM PRODUCTS;

-- SELECT * from CUSTOMER;


-- SELECT p.NAME
-- FROM Products p
-- JOIN ProductCategories pc ON p.ProductID = pc.Products_ProductID
-- JOIN Categories c ON c.CategoryID = pc.Categories_CategoryID  
-- WHERE c.Name = 'Office';

 