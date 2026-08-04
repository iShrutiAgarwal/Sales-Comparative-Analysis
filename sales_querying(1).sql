USE sales_analytics;

-- Creating the Customers table
CREATE TABLE customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Region VARCHAR(20),
    Segment VARCHAR(20),
    City VARCHAR(100),
    State VARCHAR(60),
    Country VARCHAR(100),
    Market VARCHAR(10),
    Market2 VARCHAR(50)
);
INSERT INTO customers (Customer_ID, Customer_Name, Region, Segment, City, State, Country, Market, Market2)
SELECT DISTINCT Customer_ID, Customer_Name, Region, Segment, City, State, Country, Market, Market2
FROM sales_data;
INSERT INTO customers (Customer_ID, Customer_Name, Region, Segment, City, State, Country, Market, Market2)
SELECT Customer_ID, MAX(Customer_Name), MAX(Region), MAX(Segment), MAX(City), MAX(State), MAX(Country), MAX(Market), MAX(Market2)
FROM sales_data
GROUP BY Customer_ID;
SELECT * FROM customers;

-- Creating the orders table
CREATE TABLE orders (
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(50),
    Customer_ID VARCHAR(20),
    Category VARCHAR(50),
    Sub_Category VARCHAR(30),
    Product_ID VARCHAR(50),
    Product_Name VARCHAR(200),
    Sales INT,
    Quantity INT,
    Profit DECIMAL(10,2),
    Discount DECIMAL(5,2),
    Ship_Mode VARCHAR(30),
    Shipping_Cost DECIMAL(10,2),
    Order_Priority VARCHAR(10),
    Year INT,
    weeknum INT,
    Week_Date DATE,
    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID)
);
INSERT INTO orders (Row_ID, Order_ID, Customer_ID, Category, Sub_Category, Product_ID, Product_Name,
                     Sales, Quantity, Profit, Discount, Ship_Mode, Shipping_Cost, Order_Priority,
                     Year, weeknum, Week_Date)
SELECT Row_ID, Order_ID, Customer_ID, Category, Sub_Category, Product_ID, Product_Name,
       Sales, Quantity, Profit, Discount, Ship_Mode, Shipping_Cost, Order_Priority,
       Year, weeknum, Week_Date
FROM sales_data;
SELECT * FROM orders;

-- Verifying everything matches
SELECT COUNT(*) FROM sales_data;   -- original row count
SELECT COUNT(*) FROM orders;       -- should match

SELECT COUNT(DISTINCT Customer_ID) FROM sales_data;  -- unique customers
SELECT COUNT(*) FROM customers;                      -- should match
SELECT o.Order_ID, o.Sales, c.Customer_Name, c.Region
FROM orders o
JOIN customers c ON o.Customer_ID = c.Customer_ID
LIMIT 10;
RENAME TABLE sales_data TO sales_data_staging;
show tables;

SELECT 
      o.Order_ID,
      o.Week_Date AS Order_Date,
      c.Customer_Name,
      c.Region,
      o.Category,
      o.Sales,
      o.Profit
FROM orders AS o
INNER JOIN customers AS c
ON o.Customer_ID = c.Customer_ID;

-- Calculating KPIs

-- 1. Total Sales by Region
SELECT
      c.Region,
      SUM(o.Sales) AS Total_Sales
FROM orders AS o
INNER JOIN customers AS c
ON o.Customer_ID = c.Customer_ID
GROUP BY c.Region;

-- 2. Profit Margin by Category
SELECT
      Category,
      ROUND((SUM(Profit)/SUM(Sales)),2) AS Profit_Margin
FROM orders
GROUP BY Category;

-- 3. Monthly Sales Trend
SELECT
      MONTH(Week_Date) AS Month,
      MONTHNAME(Week_Date) AS Month_Name,
      SUM(Sales) AS Monthly_Sales
FROM orders
GROUP BY Month, Month_Name
ORDER BY Month;

-- 4. Top 5 Customers by Revenue
SELECT
      c.Customer_Name,
      SUM(o.Sales) AS Total_Revenue
FROM orders AS o
INNER JOIN customers AS c
ON o.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Name
ORDER BY Total_Revenue DESC
LIMIT 5;
