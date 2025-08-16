# Task 7: Creating Views (SQL)

## 🎯 Objective
Build reusable SQL logic using `CREATE VIEW`, demonstrate usage, and show how views help with abstraction and security.

## 🧰 Tools
- MySQL Workbench

## 📚 What’s in this repo
- `task7_views.sql` — all view definitions + usage examples

## 🧩 Views included
- `v_products_with_category` — product + category details
- `v_orders_with_customer_payment` — orders + customer + payment (unpaid included)
- `v_order_totals_from_items` — computed order totals from OrderItems
- `v_customer_order_summary` — per-customer orders, total spent, average
- `v_product_sales_summary` — per-product units sold & revenue
- `v_unpaid_orders` — orders without payments
- `v_active_products` — updatable view (Stock>0 AND Price>0) with `WITH CHECK OPTION`
- `v_category_stats` — product count, stock, avg price per category

## 🔎 Usage examples
- Filter views: `SELECT * FROM v_products_with_category WHERE CategoryName='Electronics';`
- Compare stored vs computed totals: join `v_orders_with_customer_payment` with `v_order_totals_from_items`
- Update via updatable view: `UPDATE v_active_products SET Stock = Stock + 5 WHERE ProductID=1;`
- CHECK OPTION demo: trying to set `Stock=0` should fail

## ❓ Interview Q&A (quick)
1. **What is a view?** A saved SQL query that behaves like a virtual table.  
2. **Can we update via a view?** Yes, if it’s *updatable* (single table, no aggregates/distinct, etc.); `WITH CHECK OPTION` enforces the view’s filter on writes.  
3. **Materialized view?** Precomputed, stored result set (not native in MySQL; emulate with tables + refresh jobs).  
4. **View vs table?** View = virtual; data not stored (except materialized). Table = physically stored rows.  
5. **How to drop a view?** `DROP VIEW IF EXISTS view_name;`  
6. **Why use views?** Reuse complex logic, restrict columns/rows for security, simplify reporting.  
7. **Indexed views?** MySQL doesn’t support indexing a view directly; index underlying tables.  
8. **Secure data using views?** Grant users access to the view (limited columns/rows) instead of base tables.  
9. **Limitations of views?** Many views are read-only; ORDER BY often ignored in views; some features make a view non-updatable.  
10. **WITH CHECK OPTION?** Ensures inserts/updates through the view still satisfy the view’s WHERE condition.

## ✅ Outcome
You’ll understand how to package reusable SELECT logic and enforce simple security using SQL views.
