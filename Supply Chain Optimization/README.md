##📦 Supply Chain Optimization Project

##🧠 Objective:
To optimize sales performance, marketing effectiveness, and logistics efficiency using a large-scale supply chain dataset (~180K+ records). This project involved uncovering data-driven insights 
related to customer behavior, discount strategies, shipping delays, product performance, and regional market trends — enabling smarter business decisions and operational improvements.


🔧 Tools Used:
Microsoft Excel (Power Query): Data cleaning, merging, transformation

SQL Server Management Studio (SSMS): Advanced querying and data modeling

Excel Pivot Tables & Charts: Insight visualization and business storytelling

#🧹 Data Cleaning & Preparation:
Cleaned and prepared a dataset with over 180,000 records.

Merged data tables, resolved inconsistencies, standardized formats, and handled missing values.

Uploaded the cleaned dataset to SQL Server for deeper querying and analysis.


#🔍 Deep-Dive Analytics:
#1. 🎯 Category vs. Customer Segment Analysis
Analyzed every Category–Customer Segment pair for:

Avg. Discount Rate

Sales

Profit

Helped identify profitable combinations and areas needing revised discounting.

#2. 🧮 Dynamic Discount Strategy
Designed a discounting model based on:

Sales frequency

Profitability

Assigned discounts:

5% for high-performing products

10% for mid-range

20% for underperforming SKUs

#3. 🌍 Quarterly Discount per Country
Built Quarterly_Discount_Analysis using:

Yearly average sales vs. each quarter's performance per country.

Adjusted discounts to stimulate demand in off-peak quarters — a key marketing lever.

#4. 📦 Logistics Optimization – Delayed Shipping Regions
Calculated actual vs. scheduled shipping days.

Identified regions and markets with the longest average delivery times.

#Key Findings:

Africa and LATAM showed recurring delivery inefficiencies.

Supports better logistics partner selection and route management.

Created a focused DelayedShipping_Regions table for monitoring.

#5. 🧩 Segmentation by Market
Split the master dataset by Order_Market into dedicated market tables.

Enabled tailored strategies for marketing, product mix, and discounting.

#6. 👑 Top Customers (100 per Market)
Ranked customers by:

Number of orders

Total sales

Created TopCustomers_Discount table to support loyalty programs and targeted campaigns.

#7. ⚠️ High-Risk Customers – Frequent Cancellations
Identified top 50 customers per market with highest cancellation count.

Created HighRisk_Customers table for customer retention strategy and risk mitigation.

#8. 📈 Trending Product Categories by Quarter
Identified top-selling categories by quarter and year.

Used to guide seasonal inventory planning and campaign focus.


#📊 Visualizations (Excel Pivot Charts + Maps):
Bar Charts: Profit by product category, shipping delay by region

Pie Charts: Order volume distribution per market

Line Charts: Quarterly trends in sales, profit, and delivery time

Map Chart: Geographic visualization of high-risk customers based on frequent cancellations (color-coded by region and risk level)

Slicers/Filters: Interactive filtering by market, year, quarter, and discount strategy for deep drill-downs


#Visuals :

![Screenshot (34)](https://github.com/user-attachments/assets/40c01109-55a2-4662-84df-ced3c34f8cc4)

![Screenshot (36)](https://github.com/user-attachments/assets/fd517ca9-7ceb-43ec-bfe5-7dea95cee58d)

![Screenshot (35)](https://github.com/user-attachments/assets/0862f9e1-f39d-44a0-bf7a-a3c0590ca917)

![Screenshot (37)](https://github.com/user-attachments/assets/af2cb39d-0e18-4ea1-a054-5e7205b0230f)



#📈 Key Business Takeaways:
Sales Optimization: Dynamic discounting increased profit margins and boosted underperforming categories.

Marketing Optimization: Country- and segment-specific strategies increased campaign effectiveness and ROI.

Logistics Optimization: Identifying delayed regions helped address inefficiencies and improve delivery performance.

Customer Strategy: High-risk and high-value customer segmentation supported retention and personalization efforts.

Data-Driven Planning: Seasonal trends and market segmentation enabled more accurate forecasting and stocking.


#🚀 What Makes This Project Unique?
Combines real-world business challenges with practical data analysis skills.

Focuses on end-to-end supply chain optimization: sales, marketing, and logistics.

Demonstrates handling of big data (180K+ rows) using SQL and Excel efficiently.

Delivers actionable insights through a combination of analysis tables and interactive dashboards.

