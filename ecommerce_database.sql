USE ecommerce;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
USE ecommerce;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    stock INT DEFAULT 0 CHECK (stock >= 0)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    order_date DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT CHECK (quantity > 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
INSERT INTO users (name, email, password) VALUES
('Radhika', 'radhika@gmail.com', '1234'),
('Amit', 'amit@gmail.com', '1234'),
('Sneha', 'sneha@gmail.com', '1234');

INSERT INTO products (product_name, price, stock) VALUES
('Laptop', 50000, 10),
('Mobile', 20000, 20),
('Headphones', 2000, 50);

INSERT INTO orders (user_id) VALUES
(1),
(2);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1,1,1),
(1,3,2),
(2,2,1);
SELECT 
    u.name AS Customer,
    p.product_name AS Product,
    oi.quantity AS Quantity,
    (p.price * oi.quantity) AS Total_Price
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
SELECT 
    u.name,
    SUM(p.price * oi.quantity) AS Total_Spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY u.name
ORDER BY Total_Spent DESC;
SELECT product_name, stock
FROM products
WHERE stock < 10;
DELIMITER //

CREATE TRIGGER reduce_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END //

DELIMITER ;
INSERT INTO order_items (order_id, product_id, quantity)
VALUES (1, 1, 1);
SELECT product_name, stock FROM products;
DELIMITER //

CREATE PROCEDURE GetCustomerOrders()
BEGIN
    SELECT 
        u.name,
        p.product_name,
        oi.quantity
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id;
END //

DELIMITER ;
CALL GetCustomerOrders();
SELECT 
    u.name,
    SUM(p.price * oi.quantity) AS Total_Spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY u.name
ORDER BY Total_Spent DESC
LIMIT 1;
SELECT 
    p.product_name,
    SUM(p.price * oi.quantity) AS Revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY Revenue DESC;
ALTER TABLE orders
ADD CONSTRAINT fk_user
FOREIGN KEY (user_id) REFERENCES users(user_id)
ON DELETE CASCADE;
CREATE VIEW Sales_Report AS
SELECT 
    u.name,
    p.product_name,
    oi.quantity,
    (p.price * oi.quantity) AS Total
FROM users u
JOIN orders o ON u.user_id = o.user_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;
SELECT * FROM Sales_Report;