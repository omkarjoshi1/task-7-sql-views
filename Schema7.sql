-- task7_views.sql
-- Task 7: Creating and Using Views
-- DB: ECommerceDB

USE ECommerceDB;

-- =========================
-- VIEWS (Definition Section)
-- =========================

-- 1) Products with Category (simple reusable projection + join)
CREATE OR REPLACE VIEW v_products_with_category AS
SELECT
  p.ProductID,
  p.Name       AS ProductName,
  p.Description,
  p.Price,
  p.Stock,
  c.CategoryID,
  c.CategoryName
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID;

-- 2) Orders with Customer and Payment (LEFT join to include unpaid orders)
CREATE OR REPLACE VIEW v_orders_with_customer_payment AS
SELECT
  o.OrderID,
  o.OrderDate,
  o.Status,
  o.TotalAmount,
  u.UserID,
  u.Name       AS CustomerName,
  u.Email,
  p.PaymentID,
  p.PaymentDate,
  p.Amount     AS PaidAmount,
  p.PaymentMethod
FROM Orders o
JOIN Users u      ON u.UserID = o.UserID
LEFT JOIN Payments p ON p.OrderID = o.OrderID;

-- 3) Order totals computed from items (aggregate view)
CREATE OR REPLACE VIEW v_order_totals_from_items AS
SELECT
  o.OrderID,
  SUM(oi.Quantity * oi.Price) AS ItemsTotal
FROM Orders o
JOIN OrderItems oi ON oi.OrderID = o.OrderID
GROUP BY o.OrderID;

-- 4) Customer order summary (count/sum/avg per user)
CREATE OR REPLACE VIEW v_customer_order_summary AS
SELECT
  u.UserID,
  u.Name AS Customer,
  COUNT(o.OrderID)               AS OrdersCount,
  COALESCE(SUM(o.TotalAmount),0) AS TotalSpent,
  COALESCE(AVG(o.TotalAmount),0) AS AvgOrderValue
FROM Users u
LEFT JOIN Orders o ON o.UserID = u.UserID
GROUP BY u.UserID, u.Name;

-- 5) Product sales summary (units + revenue from OrderItems)
CREATE OR REPLACE VIEW v_product_sales_summary AS
SELECT
  p.ProductID,
  p.Name AS Product,
  COALESCE(SUM(oi.Quantity), 0)                AS QtySold,
  COALESCE(SUM(oi.Quantity * oi.Price), 0)     AS Revenue
FROM Products p
LEFT JOIN OrderItems oi ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name;

-- 6) Unpaid orders (Orders without a Payment row)
CREATE OR REPLACE VIEW v_unpaid_orders AS
SELECT o.*
FROM Orders o
LEFT JOIN Payments p ON p.OrderID = o.OrderID
WHERE p.OrderID IS NULL;

-- 7) Updatable view with CHECK OPTION (only active products)
--    You can UPDATE/INSERT via this view but new values must keep the row "active".
CREATE OR REPLACE VIEW v_active_products AS
SELECT ProductID, Name, Price, Stock, CategoryID
FROM Products
WHERE Stock > 0 AND Price > 0
WITH CHECK OPTION;

-- 8) Category stats (how many products, total stock, average price)
CREATE OR REPLACE VIEW v_category_stats AS
SELECT
  c.CategoryID,
  c.CategoryName,
  COUNT(p.ProductID)                           AS ProductCount,
  COALESCE(SUM(p.Stock), 0)                    AS TotalStock,
  COALESCE(ROUND(AVG(p.Price), 2), 0)          AS AvgPrice
FROM Categories c
LEFT JOIN Products p ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID, c.CategoryName;

-- =========================
-- USAGE EXAMPLES (Run/Study)
-- =========================

-- A) Simple selects
SELECT * FROM v_products_with_category WHERE CategoryName = 'Electronics';
SELECT * FROM v_unpaid_orders;

-- B) Compare stored vs computed totals for each order
SELECT
  owc.OrderID,
  owc.CustomerName,
  owc.TotalAmount,
  ot.ItemsTotal,
  (owc.TotalAmount - ot.ItemsTotal) AS Diff
FROM v_orders_with_customer_payment owc
JOIN v_order_totals_from_items ot ON ot.OrderID = owc.OrderID
ORDER BY owc.OrderID;

-- C) Top 5 products by revenue (using the view)
SELECT ProductID, Product, Revenue
FROM v_product_sales_summary
ORDER BY Revenue DESC
LIMIT 5;

-- D) Which customers spent more than the average customer?
SELECT *
FROM v_customer_order_summary
WHERE TotalSpent > (SELECT AVG(TotalSpent) FROM v_customer_order_summary);

-- E) UPDATE through updatable view (works)
--    Increase stock for ProductID = 1
UPDATE v_active_products
SET Stock = Stock + 5
WHERE ProductID = 1;

-- F) UPDATE that should FAIL due to CHECK OPTION (Stock becomes 0 -> not active)
--    NOTE: This should raise an error and prevent the change.
-- UPDATE v_active_products SET Stock = 0 WHERE ProductID = 1;

-- G) INSERT through updatable view (allowed, product stays active)
-- INSERT INTO v_active_products (Name, Price, Stock, CategoryID)
-- VALUES ('USB Cable', 199, 50, 1);

-- H) Drop views (when cleaning up)
-- DROP VIEW IF EXISTS v_products_with_category, v_orders_with_customer_payment,
--  v_order_totals_from_items, v_customer_order_summary, v_product_sales_summary,
--  v_unpaid_orders, v_active_products, v_category_stats;
