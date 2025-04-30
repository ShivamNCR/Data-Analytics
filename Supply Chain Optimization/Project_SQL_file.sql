SELECT TOP 5 * FROM SupplyChainDataset;

-- Datatype of each column...
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'SupplyChainDataset';

/*If the query returns a list of cities (e.g., Aachen, Aalen, Aalst, etc.), it means:

These cities do not have a single valid Order_Zipcode.
Every row for these cities in SupplyChainDataset has NULL in Order_Zipcode.*/

SELECT DISTINCT Order_City 
FROM SupplyChainDataset 
WHERE Order_Zipcode IS NULL
EXCEPT
SELECT DISTINCT Order_City 
FROM SupplyChainDataset 
WHERE Order_Zipcode IS NOT NULL;



/*Next Steps:
Since these cities have no valid zip code to copy from, you must use a fallback strategy, such as:
Assign the most common zip code in the dataset.
Assign a default placeholder (e.g., 000000).*/

SELECT COUNT(DISTINCT Order_City) AS Distinct_City_Count
FROM SupplyChainDataset;

--change the length of datatype
ALTER TABLE SupplyChainDataset
ALTER COLUMN Order_Zipcode VARCHAR(6);

--assigning '000000' for each null city 
UPDATE SupplyChainDataset
SET Order_Zipcode = '000000'
WHERE Order_Zipcode IS NULL;

select count(Customer_City)
from SupplyChainDataset
where Customer_Zipcode IS NULL;

-- checking the city which have only null customer_zipcode. The only city we got is CA with 3 entries

--- Similirarly for Customer Zipcode 
SELECT DISTINCT Customer_City 
FROM SupplyChainDataset 
WHERE Customer_Zipcode IS NULL
EXCEPT
SELECT DISTINCT Customer_City 
FROM SupplyChainDataset 
WHERE Customer_Zipcode IS NOT NULL;

-- chainging customer_zipcode 
ALTER TABLE SupplyChainDataset
ALTER COLUMN Customer_Zipcode VARCHAR(6);

-- assigning '000000' to null cells
UPDATE SupplyChainDataset
SET Customer_Zipcode = '000000'
WHERE Customer_Zipcode IS NULL;

--changing datatype for some columns 
 
ALTER TABLE SupplyChainDataset
ALTER COLUMN Amount_per_order MONEY;

ALTER TABLE SupplyChainDataset
ALTER COLUMN Order_Profit_Per_Order MONEY;

ALTER TABLE SupplyChainDataset
ALTER COLUMN Order_Item_Product_Price MONEY;

ALTER TABLE SupplyChainDataset
ALTER COLUMN Sales MONEY;

ALTER TABLE SupplyChainDataset
ALTER COLUMN Discount_per_order MONEY;

ALTER TABLE SupplyChainDataset
ALTER COLUMN Discount_per_order MONEY;


select  top 50 * from SupplyChainDataset;

SELECT CONVERT(DATETIME, '1/18/2018 12:27', 101);



-- some rows have float value and some have varchar in shipping_date_DateOrders column...
UPDATE SupplyChainDataset
SET shipping_date_DateOrders = 
    CASE 
        -- If numeric, convert from Excel serial to DATETIME
        WHEN TRY_CONVERT(FLOAT, shipping_date_DateOrders) IS NOT NULL 
        THEN CONVERT(VARCHAR, DATEADD(DAY, CAST(shipping_date_DateOrders AS FLOAT) - 2, '1899-12-30'), 120)

        -- If already a valid DATETIME string, convert directly
        WHEN TRY_CONVERT(DATETIME, shipping_date_DateOrders) IS NOT NULL 
        THEN CONVERT(VARCHAR, CONVERT(DATETIME, shipping_date_DateOrders), 120)

        -- Keep invalid values as they are (for manual review)
        ELSE shipping_date_DateOrders
    END
WHERE TRY_CONVERT(FLOAT, shipping_date_DateOrders) IS NOT NULL 
   OR TRY_CONVERT(DATETIME, shipping_date_DateOrders) IS NOT NULL;


ALTER TABLE SupplyChainDataset
ALTER COLUMN shipping_date_DateOrders DATETIME;

-- Similarly changing for Order_date_orders
UPDATE SupplyChainDataset
SET order_date_DateOrders = 
    CASE 
        -- If numeric, convert from Excel serial to DATETIME
        WHEN TRY_CONVERT(FLOAT, order_date_DateOrders) IS NOT NULL 
        THEN CONVERT(VARCHAR, DATEADD(DAY, CAST(order_date_DateOrders AS FLOAT) - 2, '1899-12-30'), 120)

        -- If already a valid DATETIME string, convert directly
        WHEN TRY_CONVERT(DATETIME, order_date_DateOrders) IS NOT NULL 
        THEN CONVERT(VARCHAR, CONVERT(DATETIME, order_date_DateOrders), 120)

        -- Keep invalid values as they are (for manual review)
        ELSE order_date_DateOrders
    END
WHERE TRY_CONVERT(FLOAT, order_date_DateOrders) IS NOT NULL 
   OR TRY_CONVERT(DATETIME, order_date_DateOrders) IS NOT NULL;


ALTER TABLE SupplyChainDataset
ALTER COLUMN order_date_DateOrders DATETIME;

--Changing some columns datatype...
ALTER TABLE SupplyChainDataset
ALTER COLUMN Order_Id VARCHAR;

ALTER TABLE SupplyChainDataset
ALTER COLUMN Order_Item_Id VARCHAR;


ALTER TABLE SupplyChainDataset
ALTER COLUMN Department_Id VARCHAR;


ALTER TABLE SupplyChainDataset
ALTER COLUMN Category_Id VARCHAR;

--- Calculating AvgDiscount_rate_per_order,Avg_Sales,Avg_Profit for each category for each customers segment 
SELECT 
    Category_Name, 
    Customer_Segment, 
    AVG(Discount_rate_per_order) AS AvgDiscount_rate_per_order, 
    AVG(Sales) AS Avg_Sales, 
    AVG(Order_Profit_Per_Order) AS Avg_Profit
FROM SupplyChainDataset
GROUP BY Category_Name, Customer_Segment
ORDER BY Category_Name, Customer_Segment;

SELECT Product_Name, COUNT(Order_Id) AS OrderCount
FROM SupplyChainDataset
GROUP BY Product_Name;

ALTER TABLE SupplyChainDataset ADD DiscountStrategy VARCHAR(50);

/* we are assigning the discount on the basis of profit/sales margin and order demand */
WITH OrderFrequency AS (
    SELECT Product_Name, COUNT(Order_Id) AS OrderCount
    FROM SupplyChainDataset
    GROUP BY Product_Name
)
UPDATE S
SET DiscountStrategy = 
    CASE 
        -- High Profit & High Order Frequency → Lower Discount
        WHEN (S.Order_Profit_Per_Order / NULLIF(S.Sales, 0)) * 100 > 30 AND O.OrderCount > 100 THEN 'Low Discount (5%)'

        -- Medium Profit & Medium Order Frequency → Moderate Discount
        WHEN (S.Order_Profit_Per_Order / NULLIF(S.Sales, 0)) * 100 BETWEEN 15 AND 30 AND O.OrderCount BETWEEN 50 AND 100 THEN 'Moderate Discount (10%)'

        -- Low Profit & Low Order Frequency → Higher Discount
        ELSE 'High Discount (20%)'
    END
FROM SupplyChainDataset S
JOIN OrderFrequency O ON S.Product_Name = O.Product_Name;


/* We assigned the discount on the basis of demand in a quarter  for each country to increase the sales*/

/* Creating table in which giving discount to each country on the quarter basis */
CREATE TABLE Quarterly_Discount_Analysis (
    Order_Country VARCHAR(255),
    QuarterNum INT,
    AvgQuarterlySales DECIMAL(18,2),
    AvgYearlySales DECIMAL(18,2),
    SalesTrend VARCHAR(50),
    AssignedDiscount VARCHAR(50)
);

-- Calculating QuarterlyAvgSales for each country
WITH QuarterlyAvgSales AS (
    -- Step 1: Calculate the average sales per quarter for each country
    SELECT 
        Order_Country,
        DATEPART(QUARTER, order_date_DateOrders) AS QuarterNum,
        AVG(Sales) AS AvgQuarterlySales
    FROM SupplyChainDataset
    GROUP BY Order_Country, DATEPART(QUARTER, order_date_DateOrders)
),

-- Calculating YearlyAvgSales for each country
YearlyAvgSales AS (
    -- Step 2: Calculate the yearly average sales for each country
    SELECT 
        Order_Country, 
        AVG(AvgQuarterlySales) AS AvgYearlySales
    FROM QuarterlyAvgSales
    GROUP BY Order_Country
)
INSERT INTO Quarterly_Discount_Analysis (Order_Country, QuarterNum, AvgQuarterlySales, AvgYearlySales, SalesTrend, AssignedDiscount)
SELECT 
    Q.Order_Country,
    Q.QuarterNum,
    Q.AvgQuarterlySales,
    Y.AvgYearlySales,
    -- Step 3: Compare each quarter’s avg sales with the yearly avg sales
    CASE 
        WHEN Q.AvgQuarterlySales > (Y.AvgYearlySales * 1.2) THEN 'Peak Sales Quarter'  
        WHEN Q.AvgQuarterlySales < (Y.AvgYearlySales * 0.8) THEN 'Low Sales Quarter'   
        ELSE 'Average Sales Quarter'
    END AS SalesTrend,
    -- Step 4: Assign discount based on quarterly trend
    CASE 
        WHEN Q.AvgQuarterlySales > (Y.AvgYearlySales * 1.2) THEN 'Low Discount (5%)'   
        WHEN Q.AvgQuarterlySales < (Y.AvgYearlySales * 0.8) THEN 'High Discount (20%)'  
        ELSE 'Moderate Discount (10%)'  
    END AS AssignedDiscount
FROM QuarterlyAvgSales Q
JOIN YearlyAvgSales Y ON Q.Order_Country = Y.Order_Country;

Select * from Quarterly_Discount_Analysis;

/* making tables based on the order_market so that we can analyze and make insights properly*/
SELECT * INTO SupplyChain_Africa 
FROM SupplyChainDataset 
WHERE Order_Market = 'Africa';

SELECT * INTO SupplyChain_LATAM 
FROM SupplyChainDataset 
WHERE Order_Market = 'LATAM';

SELECT * INTO SupplyChain_USCA 
FROM SupplyChainDataset 
WHERE Order_Market = 'USCA';

SELECT * INTO SupplyChain_PacificAsia 
FROM SupplyChainDataset 
WHERE Order_Market = 'Pacific Asia';

SELECT * INTO SupplyChain_Europe 
FROM SupplyChainDataset 
WHERE Order_Market = 'Europe';

Select top 5 * from SupplyChain_Europe;



-- Apply for Africa Market
DROP TABLE TopCustomers_Discount;

CREATE TABLE TopCustomers_Discount (
    Customer_Id INT,
    Customer_Name NVARCHAR(255),
    Customer_Market NVARCHAR(50),
    Customer_Country NVARCHAR(100),
    Total_Orders INT,
    Total_Sales DECIMAL(18,2)
);

ALTER TABLE TopCustomers_Discount
ALTER COLUMN Customer_Id VARCHAR;


-- Step 2: Use CTE to rank customers by order count within each market
WITH CustomerRanking AS (
    SELECT 
        Customer_Id, 
        Customer_Name,
        Order_Market,
        Customer_Country,
        COUNT(Order_Id) AS TotalOrders,
        SUM(TRY_CAST(Sales AS DECIMAL(18,2))) AS TotalSales,  -- Safer conversion
        RANK() OVER (PARTITION BY Order_Market ORDER BY COUNT(Order_Id) DESC) AS RankOrder
    FROM SupplyChainDataset
    GROUP BY Customer_Id, Customer_Name, Order_Market, Customer_Country
)

-- Step 3: Insert top 100 customers per market into the existing table
INSERT INTO TopCustomers_Discount (
    Customer_Id, 
    Customer_Name, 
    Customer_Market, 
    Customer_Country, 
    Total_Orders, 
    Total_Sales
)
SELECT 
    Customer_Id, 
    Customer_Name, 
    Order_Market, 
    Customer_Country, 
    TotalOrders, 
    TotalSales
FROM CustomerRanking
WHERE RankOrder <= 100;

-- Optional: View the data
SELECT * FROM TopCustomers_Discount;







SELECT 
    Customer_Id,
    Customer_name,
    COUNT(Order_Id) AS Canceled_Orders
FROM SupplyChainDataset
WHERE Order_Status = 'Canceled'
GROUP BY Customer_Id, Customer_name
ORDER BY Canceled_Orders DESC;

SELECT Customer_Id 
FROM SupplyChainDataset
WHERE TRY_CAST(Customer_Id AS INT) IS NULL;  -- Finds rows where Customer_Id is not a valid integer



--separate table of HighRisk_Customers and those customers will be considered a HighRisk who cancelled the product most
select * from SupplyChainDataset;

DROP TABLE IF EXISTS HighRisk_Customers;

CREATE TABLE HighRisk_Customers (
    Customer_Id NVARCHAR(50),
    Customer_Name NVARCHAR(255),
    Order_Market NVARCHAR(50),
    Order_Country NVARCHAR(100),
    Cancelled_Orders INT
);

WITH CancellationCount AS (
    SELECT 
        Customer_Id,
        Customer_Name,
        Order_Market,
        Order_Country,
        COUNT(Order_Id) AS Cancelled_Orders,
        RANK() OVER (PARTITION BY Order_Market ORDER BY COUNT(Order_Id) DESC) AS CancelRank
    FROM SupplyChainDataset
    WHERE Order_Status = 'CANCELED'
    GROUP BY Customer_Id, Customer_Name, Order_Market, Order_Country
)

INSERT INTO HighRisk_Customers (
    Customer_Id,
    Customer_Name,
    Order_Market,
    Order_Country,
    Cancelled_Orders
)
SELECT 
    Customer_Id,
    Customer_Name,
    Order_Market,
    Order_Country,
    Cancelled_Orders
FROM CancellationCount
WHERE CancelRank <= 50;

Select * from HighRisk_Customers;

Select * from SupplyChainDataset;

Select distinct Category_Name from SupplyChainDataset;

DROP TABLE IF EXISTS TrendingCategories_PerQuarter;


-- Seperate table Top trending product_category for each quarter...
CREATE TABLE TrendingCategories_PerQuarter (
    Order_Year INT,
    Quarter INT,
    Order_Market NVARCHAR(50),
    Product_Category NVARCHAR(100),
    Total_Sales DECIMAL(18,2),
    Order_Count INT,
    Rank_In_Quarter INT
);


WITH CategorySales AS (
    SELECT 
        YEAR(order_date_DateOrders) AS Order_Year,
        DATEPART(QUARTER, order_date_DateOrders) AS Quarter,
        Order_Market,
        Category_Name AS Product_Category,
        SUM(Sales) AS Total_Sales,
        COUNT(Order_Id) AS Order_Count,
        RANK() OVER (
            PARTITION BY Order_Market, YEAR(order_date_DateOrders), DATEPART(QUARTER, order_date_DateOrders)
            ORDER BY SUM(Sales) DESC
        ) AS Rank_In_Quarter
    FROM SupplyChainDataset
    GROUP BY 
        YEAR(order_date_DateOrders),
        DATEPART(QUARTER, order_date_DateOrders),
        Order_Market,
        Category_Name
)

INSERT INTO TrendingCategories_PerQuarter
SELECT 
    Order_Year,
    Quarter,
    Order_Market,
    Product_Category,
    Total_Sales,
    Order_Count,
    Rank_In_Quarter
FROM CategorySales
WHERE Rank_In_Quarter <= 1;  -- Top trending only


Select * from TrendingCategories_PerQuarter;

















