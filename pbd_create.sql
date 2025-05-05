CREATE OR REPLACE TRIGGER Products_Slug_TRG
BEFORE INSERT ON Products
FOR EACH ROW
BEGIN
    :NEW.Slug := LOWER(:NEW.Slug);
    :NEW.Slug := REPLACE(:NEW.Slug, ' ', '-');
    :NEW.Slug := REGEXP_REPLACE(:NEW.Slug, '[^a-z0-9\-]', '');
END;
/

INSERT INTO Categories (Name, Description) VALUES ('Audio', 'Speakers, headphones, and audio accessories');
INSERT INTO Categories (Name, Description) VALUES ('Televisions', 'Smart TVs and related products');
INSERT INTO Categories (Name, Description) VALUES ('Computers', 'Laptops, desktops, and accessories');
INSERT INTO Categories (Name, Description) VALUES ('Accessories', 'Cables, adapters, and miscellaneous items');

INSERT INTO Products (ProductID, Name, Description, Price, StockQuantity, ImageUrl, Discount)
VALUES 
(1, 'Wireless Bluetooth Headphones', 'Noise-cancelling over-ear headphones with 40 hours battery life.', 89.99, 50, 'https://example.com/images/headphones.jpg', 10.00),
(2, 'Smart LED TV 55"', 'Ultra HD 4K Smart TV with built-in streaming apps and voice control.', 499.99, 20, 'https://example.com/images/tv.jpg', 15.00),
(3, 'Portable Bluetooth Speaker', 'Waterproof speaker with deep bass and 12 hours of playtime.', 59.99, 30, 'https://example.com/images/speaker.jpg', NULL),
(4, 'Gaming Laptop', 'High-performance laptop with NVIDIA RTX graphics and 16GB RAM.', 1299.00, 10, 'https://example.com/images/laptop.jpg', 7.50),
(5, 'USB-C Charging Cable (2m)', 'Durable USB-C cable compatible with fast charging.', 12.49, 100, 'https://example.com/images/cable.jpg', NULL);