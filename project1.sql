-- 1. Table Schema
CREATE TABLE IF NOT EXISTS "sales_data" (
  "Row ID" INTEGER,
  "Order ID" TEXT,
  "Order Date" TEXT,
  "Ship Date" TEXT,
  "Ship Mode" TEXT,
  "Customer ID" TEXT,
  "Customer Name" TEXT,
  "Segment" TEXT,
  "Country" TEXT,
  "City" TEXT,
  "State" TEXT,
  "Postal Code" INTEGER,
  "Region" TEXT,
  "Product ID" TEXT,
  "Category" TEXT,
  "Sub-Category" TEXT,
  "Product Name" TEXT,
  "Sales" REAL,
  "Quantity" INTEGER,
  "Discount" REAL,
  "Profit" REAL,
  profit_margin FLOAT
);

-- 2. Delete rows with missing Profit or Sales
DELETE FROM sales_data WHERE Profit IS NULL OR Sales IS NULL;

-- 3. Reformat Order Date to YYYY-MM-DD
UPDATE sales_data SET "Order Date" = substr("Order Date", 7, 4) || '-' || substr("Order Date", 1, 2) || '-' || substr("Order Date", 4, 2) WHERE length("Order Date") = 10;

-- 4. Reformat Ship Date to YYYY-MM-DD
UPDATE sales_data SET "Ship Date" = substr("Ship Date", 7, 4) || '-' || substr("Ship Date", 1, 2) || '-' || substr("Ship Date", 4, 2) WHERE length("Ship Date") = 10;

-- 5. Remove duplicate records
DELETE FROM sales_data WHERE ROWID NOT IN (
  SELECT MIN(ROWID)
  FROM sales_data
  GROUP BY "Order ID", "Product ID", "Sales", "Profit"
);

-- 6. Delete rows with future Order Dates
DELETE FROM sales_data WHERE "Order Date" > date('now');

-- 7. Remove invalid Discount values
DELETE FROM sales_data WHERE Discount < 0 OR Discount > 1;

-- 8. Sub-Category Profitability Analysis
SELECT Category, "Sub-Category", SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit, ROUND(AVG(Profit / Sales), 2) AS Avg_Profit_Margin
FROM sales_data
GROUP BY Category, "Sub-Category"
ORDER BY Avg_Profit_Margin ASC;

-- Output:
-- Office Supplies|Binders|87382.069|10172.1199|-0.18
-- Furniture|Tables|107768.445|-10723.9062|-0.16
-- Technology|Machines|75834.781|-1303.143|-0.16
-- Furniture|Bookcases|49787.3302|-1319.6149|-0.15
-- Office Supplies|Appliances|52673.396|11052.1385|-0.13
-- Furniture|Chairs|148227.621|12586.1863|0.05
-- Office Supplies|Supplies|11282.966|88.0157|0.09
-- Office Supplies|Storage|100248.452|10006.3527|0.1
-- Technology|Phones|143963.298|20373.1126|0.11
-- Furniture|Furnishings|42743.298|5514.8302|0.12
-- Technology|Accessories|77737.572|19391.0162|0.21
-- Office Supplies|Art|11544.688|2698.1617|0.24
-- Office Supplies|Fasteners|1560.982|498.593|0.3
-- Technology|Copiers|74929.208|30639.7119|0.34
-- Office Supplies|Envelopes|8187.074|3430.8479|0.42
-- Office Supplies|Labels|4981.26|2167.7276|0.43
-- Office Supplies|Paper|33901.206|14778.5664|0.43

-- 9. Profitability Index (Profit Margin × Sales)
SELECT Category, "Sub-Category", SUM(Sales) AS Total_Sales, ROUND(SUM(Profit / Sales), 2) AS Profit_Margin, ROUND(SUM(Sales) * AVG(Profit / Sales), 2) AS Profitability_Index
FROM sales_data
GROUP BY Category, "Sub-Category"
ORDER BY Profitability_Index ASC;

-- Output:
-- Furniture|Tables|107768.445|-24.03|-17147.01
-- Office Supplies|Binders|87382.069|-117.8|-15739.57
-- Technology|Machines|75834.781|-7.67|-11873.11
-- Furniture|Bookcases|49787.3302|-15.1|-7369.81
-- Office Supplies|Appliances|52673.396|-25.71|-6909.05
-- Office Supplies|Fasteners|1560.982|31.13|467.21
-- Office Supplies|Supplies|11282.966|6.64|1027.06
-- Office Supplies|Labels|4981.26|62.89|2160.58
-- Office Supplies|Art|11544.688|79.89|2820.42
-- Office Supplies|Envelopes|8187.074|50.31|3461.1
-- Furniture|Furnishings|42743.298|54.96|5291.41
-- Furniture|Chairs|148227.621|13.64|7193.39
-- Office Supplies|Storage|100248.452|35.52|9625.21
-- Office Supplies|Paper|33901.206|250.15|14571.11
-- Technology|Phones|143963.298|41.95|15367.07
-- Technology|Accessories|77737.572|75.65|16245.43
-- Technology|Copiers|74929.208|9.12|25300.17

-- 10. Monthly Profit by Category
SELECT strftime('%Y', "Order Date") AS Year, strftime('%m', "Order Date") AS Month, Category, SUM(Profit) AS Monthly_Profit
FROM sales_data
GROUP BY Year, Month, Category
ORDER BY Year, Month;

-- Output:
-- ||Furniture|6057.4954
-- ||Office Supplies|54892.5234
-- ||Technology|69100.6977
