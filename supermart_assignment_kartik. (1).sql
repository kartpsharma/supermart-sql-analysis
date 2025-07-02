-- Q1: Total Sales Amount by Region
-- In this query, I’m performing an inner join between the `sales` and `customer` tables using `customer_id`.
-- This allows me to associate each sale with its corresponding region.
-- Then, I group the data by `region` and calculate the total sales using `SUM()`.
-- Finally, I sort the result in descending order to identify which region generated the most revenue.

SELECT 
    c.region,
    ROUND(SUM(s.sales), 2) AS total_sales
FROM 
    sales s
JOIN 
    customer c ON s.customer_id = c.customer_id
GROUP BY 
    c.region
ORDER BY 
    total_sales DESC;


--  Q2: Top-Selling Products
-- This query joins the sales and product tables on product_id so we can match each sale to its product name.
-- We then GROUP BY product_name and use SUM() to calculate total sales for each product.
-- Finally, we ORDER BY total_sales DESC to find the best-selling products.

SELECT 
    p.product_name,
    ROUND(SUM(s.sales), 2) AS total_sales
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_sales DESC;



-- Q3: Discount Impact on Profit
-- We want to understand how different levels of discount affect the profit.
-- So we GROUP BY discount and then SUM the profit for each discount level.
-- This will help visualize whether higher discounts are reducing profits.

SELECT 
    discount,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    COUNT(*) AS number_of_orders
FROM 
    sales
GROUP BY 
    discount
ORDER BY 
    discount;


--  Q4: Sales by Customer Segment
-- This query joins the sales and customer tables using customer_id.
-- Then, we GROUP BY segment to calculate total sales for each customer type.
-- Helps answer: Which segment (Consumer, Corporate, Home Office) spends the most?

SELECT 
    c.segment,
    ROUND(SUM(s.sales), 2) AS total_sales,
    ROUND(AVG(s.sales), 2) AS avg_sales_per_order,
    COUNT(*) AS number_of_orders
FROM 
    sales s
JOIN 
    customer c ON s.customer_id = c.customer_id
GROUP BY 
    c.segment
ORDER BY 
    total_sales DESC;

--  Q5: Total Sales by Product Category
-- This query joins sales and product tables using product_id.
-- We group the data by category to calculate total revenue per product category.
-- Helps identify which broad category (e.g. Furniture, Technology, Office Supplies) earns the most.

SELECT 
    p.category,
    ROUND(SUM(s.sales), 2) AS total_sales,
    ROUND(AVG(s.sales), 2) AS avg_sales_per_order,
    COUNT(*) AS number_of_orders
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
GROUP BY 
    p.category
ORDER BY 
    total_sales DESC;


--  Q6: Number of Orders by Ship Mode
-- We use only the sales table here. Each row is one order line.
-- So we GROUP BY ship_mode and COUNT the number of records.
-- This shows the popularity and volume of different shipping methods.

SELECT 
    ship_mode,
    COUNT(*) AS number_of_orders
FROM 
    sales
GROUP BY 
    ship_mode
ORDER BY 
    number_of_orders DESC;



--  Q7: Monthly Sales Trend
-- We want to analyze how sales fluctuate over time — specifically by month.
-- So we EXTRACT the year and month from order_date.
-- Then we group and sum the sales to get monthly revenue insights.

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(*) AS number_of_orders
FROM 
    sales
GROUP BY 
    month
ORDER BY 
    month;

--  Q8: Number of Customers by State
-- We're using only the customer table here.
-- We group by state and count distinct customer IDs to avoid duplicates.
-- This shows how your customer base is distributed geographically.

SELECT 
    state,
    COUNT(DISTINCT customer_id) AS total_customers
FROM 
    customer
GROUP BY 
    state
ORDER BY 
    total_customers DESC;

--  Q9: Top 5 Customers by Total Sales
-- We join sales and customer tables on customer_id to get customer names.
-- Then we group by customer_id and name, and sum up their sales.
-- Finally, we sort by total_sales and limit to the top 5.

SELECT 
    c.customer_id,
    c.customer_name,
    ROUND(SUM(s.sales), 2) AS total_sales,
    ROUND(SUM(s.profit), 2) AS total_profit,
    COUNT(*) AS total_orders
FROM 
    sales s
JOIN 
    customer c ON s.customer_id = c.customer_id
GROUP BY 
    c.customer_id, c.customer_name
ORDER BY 
    total_sales DESC
LIMIT 5;


--  Q10: Total Sales by Product Sub-Category
-- We join sales and product tables on product_id to get sub-category info.
-- Then group by sub_category and calculate the total revenue.
-- This helps find out which product types (e.g., Phones, Chairs, Binders) are driving sales.

SELECT 
    p.sub_category,
    ROUND(SUM(s.sales), 2) AS total_sales,
    ROUND(SUM(s.profit), 2) AS total_profit,
    COUNT(*) AS total_orders
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
GROUP BY 
    p.sub_category
ORDER BY 
    total_sales DESC;

--  Q11: Rank Products by Sales Within Each Category
-- This query uses a window function (RANK) to assign a rank to each product.
-- It partitions the data by category, so ranking restarts within each category group.
-- We sum the sales and use RANK() OVER (...) to generate the rank.

SELECT 
    p.category,
    p.product_name,
    ROUND(SUM(s.sales), 2) AS total_sales,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(s.sales) DESC
    ) AS sales_rank_within_category
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
GROUP BY 
    p.category, p.product_name
ORDER BY 
    p.category, sales_rank_within_category;

--  Q12: Cumulative Sales by Product Over Time
-- We're calculating a running total (cumulative sales) for each product.
-- We use SUM() OVER (...) with PARTITION BY product_name and ORDER BY order_date.
-- This helps visualize sales performance over time like a revenue timeline for each product.

SELECT 
    p.product_name,
    s.order_date,
    ROUND(SUM(s.sales) OVER (
        PARTITION BY p.product_name
        ORDER BY s.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2) AS cumulative_sales
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
ORDER BY 
    p.product_name, s.order_date;



--  Q13: Top 3 Customers by Profit Within Each Region
-- Join sales and customer tables to get region and customer info.
-- Group by customer and region to calculate total profit.
-- Use RANK() OVER (...) to assign rankings per region and filter to top 3 using a subquery.

--  Q13: Top 3 Customers by Profit Within Each Region
-- Join sales and customer tables to get region and customer info.
-- Group by customer and region to calculate total profit.
-- Use RANK() OVER (...) to assign rankings per region and filter to top 3 using a subquery.

WITH ranked_customers AS (
    SELECT 
        c.region,
        c.customer_id,
        c.customer_name,
        ROUND(SUM(s.profit), 2) AS total_profit,
        RANK() OVER (
            PARTITION BY c.region
            ORDER BY SUM(s.profit) DESC
        ) AS profit_rank
    FROM 
        sales s
    JOIN 
        customer c ON s.customer_id = c.customer_id
    GROUP BY 
        c.region, c.customer_id, c.customer_name
)
SELECT 
    region,
    customer_id,
    customer_name,
    total_profit,
    profit_rank
FROM 
    ranked_customers
WHERE 
    profit_rank <= 3
ORDER BY 
    region, profit_rank;

--  Q14: Average Sales by Segment with Row Numbers
-- This query gives each customer a row number within their segment based on total sales.
-- It also calculates the average sales per segment using AVG() window function.
-- Great for benchmarking customers against segment norms.

WITH customer_sales AS (
    SELECT 
        c.segment,
        c.customer_id,
        c.customer_name,
        ROUND(SUM(s.sales), 2) AS total_sales
    FROM 
        sales s
    JOIN 
        customer c ON s.customer_id = c.customer_id
    GROUP BY 
        c.segment, c.customer_id, c.customer_name
)
SELECT 
    segment,
    customer_id,
    customer_name,
    total_sales,
    
    ROUND(AVG(total_sales) OVER (PARTITION BY segment), 2) AS avg_sales_per_segment,
    
    ROW_NUMBER() OVER (
        PARTITION BY segment
        ORDER BY total_sales DESC
    ) AS sales_rank_within_segment

FROM 
    customer_sales
ORDER BY 
    segment, sales_rank_within_segment;


	

-- Q15: Difference in Sales Between Consecutive Days for Each Product
-- Use LAG() to fetch the previous day's sales for each product.
-- Then subtract it from current day's sales to get the day-over-day difference.
-- This shows how sales are changing daily for each product — key for trend tracking.

SELECT 
    p.product_name,
    s.order_date,
    ROUND(s.sales, 2) AS current_day_sales,
    ROUND(
        s.sales - LAG(s.sales, 1, 0) OVER (
            PARTITION BY p.product_name
            ORDER BY s.order_date
        ), 2
    ) AS sales_difference
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
ORDER BY 
    p.product_name, s.order_date;




--  Q16: Percent of Total Sales by Region
-- First, we join sales and customer tables to get region info.
-- Then, we calculate total sales per region using GROUP BY.
-- Next, we use a window function to get the overall total sales (for all regions).
-- Finally, we divide region-wise total by global total and multiply by 100 to get percentage.

SELECT 
    c.region,
    ROUND(SUM(s.sales), 2) AS total_sales,
    ROUND(
        SUM(s.sales) * 100.0 / SUM(SUM(s.sales)) OVER (),
        2
    ) AS percent_of_total_sales
FROM 
    sales s
JOIN 
    customer c ON s.customer_id = c.customer_id
GROUP BY 
    c.region
ORDER BY 
    percent_of_total_sales DESC;


--  Q17: 3-Order Moving Average of Sales per Product
-- We use a window function with AVG() to compute the moving average of the last 3 orders.
-- Partitioning by product ensures each product has its own moving window.
-- The window moves one row at a time ordered by order_date.

SELECT 
    p.product_name,
    s.order_date,
    ROUND(s.sales, 2) AS current_sale,
    ROUND(
        AVG(s.sales) OVER (
            PARTITION BY p.product_name
            ORDER BY s.order_date
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS moving_avg_3_orders
FROM 
    sales s
JOIN 
    product p ON s.product_id = p.product_id
ORDER BY 
    p.product_name, s.order_date;

--  Q18: Largest and Smallest Order by Customer
-- For each order, we calculate the max and min order amount that customer has ever placed.
-- We use window functions so we keep row-level data while comparing against customer-level extremes.

SELECT 
    c.customer_id,
    c.customer_name,
    s.order_id,
    s.order_date,
    ROUND(s.sales, 2) AS order_sales,
    ROUND(MAX(s.sales) OVER (PARTITION BY c.customer_id), 2) AS max_order_by_customer,
    ROUND(MIN(s.sales) OVER (PARTITION BY c.customer_id), 2) AS min_order_by_customer
FROM 
    sales s
JOIN 
    customer c ON s.customer_id = c.customer_id
ORDER BY 
    c.customer_id, s.order_date;


--  Q19: Cumulative Profit by Customer Over Time
-- We're calculating a running total of profit for each customer, ordered by order date.
-- This shows how much total profit each customer has generated progressively.

SELECT 
    c.customer_id,
    c.customer_name,
    s.order_date,
    ROUND(s.profit, 2) AS order_profit,
    ROUND(
        SUM(s.profit) OVER (
            PARTITION BY c.customer_id
            ORDER BY s.order_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS cumulative_profit
FROM 
    sales s
JOIN 
    customer c ON s.customer_id = c.customer_id
ORDER BY 
    c.customer_id, s.order_date;


--  Q20: Dense Rank of Shipping Modes by Order Count
-- We count the number of orders per ship mode and use DENSE_RANK() to rank them.
-- If two modes have the same count, they get the same rank (no gaps in ranking).

WITH ship_counts AS (
    SELECT 
        ship_mode,
        COUNT(*) AS total_orders
    FROM 
        sales
    GROUP BY 
        ship_mode
)
SELECT 
    ship_mode,
    total_orders,
    DENSE_RANK() OVER (
        ORDER BY total_orders DESC
    ) AS shipping_rank
FROM 
    ship_counts;
