
Select * from Store_data ;
---------------------------------
SELECT count(Distinct(Row_id)),count(Row_id) from Store_data ; -- 2120
select distinct Product_Name from Store_data -- 380
select count(distinct Order_ID) from Store_data -- 1764
select count (distinct Customer_Name) from Store_data -- 707
select count (distinct Customer_ID) from Store_data -- 707
select distinct Product_ID from Store_data -- 375
select distinct Sub_Category from Store_data -- 4
select min(Order_Date), max(Order_Date) from Store_data -- 4 years
select distinct Ship_Mode from Store_data -- 4
select distinct Segment from Store_data -- 3
select distinct State from Store_data -- 48
---------------------------------

---- Checking for if each Product_ID linked with another Product_Name
Select s1.Product_ID, s1.Product_Name
from Store_data s1 join Store_data s2
on s1.Product_ID = s2.Product_ID AND s1.Product_Name <> s2.Product_Name
Group by s1.Product_ID, s1.Product_Name
Order by Product_ID

---- Checking for if each Order_ID linked with another Customer_ID
Select s1.Order_ID, s1.Customer_ID
from Store_data s1 join Store_data s2
on s1.Order_ID = s2.Order_ID and s1.Customer_ID <> s2.Customer_ID


-- Checking And Removing Duplication 
with cte as
(
select * , rank() over(partition by [Order_ID],[Order_Date],[Ship_Date],[Ship_Mode],[Customer_ID],[Customer_Name]
,[Segment],[Country],[City],[State],[Postal_Code],[Region],[Product_ID],[Category],[Sub_Category],[Product_Name]
,[Sales],[Quantity],[Discount],[Profit] order by Row_ID) as duplicated
from Store_data)
delete from cte
where duplicated > 1;


-- Changing "Discount" column >>
Update Store_Data
Set Discount = Round(Discount*100,2);

EXEC sp_rename 'Store_Data.Discount','%_Discount','Column';

-- Changing "Region" column >>
Update Store_Data
set Region = 'North'
where Region = 'Central';


--                      ----------------------------------------------------------------------
//------------------------------------- KPIS REQUIREMENTS ----------------------------------//
----------------------------------------------------------------------                      --

--1)----- Total Sales --------
select cast(sum(Sales) as decimal(10,2)) as Total_Sales 
from Store_data; -- 741718.42

--2)----- Total Profit --------
select cast(sum(Profit) as decimal(10,2)) as Total_Sales 
from Store_data; -- 18463.33

--3)------ Shipping Rate --------
with ship as
(
		select distinct Order_ID, Order_Date, Ship_Date,
		datediff(day,Order_Date,Ship_Date) as day_date_difference
		from store_Data
)
select CEILING(sum(cast(day_date_difference as decimal))/count( Order_ID))  -- 4
from ship

--4)----- Avg Sales Per Order For Each Segment --------
select Segment, sum(Sales)/count(distinct Order_ID) Avg
from Store_data
group by Segment;

--5)----- Top 10 Selling Product Name  --------
select top 10 Product_Name, sum(Sales) as Sales
from Store_data
group by Product_Name
order by Sales desc;

--6)----- Segment Sales PCT --------
select Segment , sum(Sales)*100/(select sum(Sales) from Store_data) as PCT
from Store_data
group by Segment
order by PCT desc;

--7)----- Top 10 Profitable Product Name,Sub Category --------
select top 10 Product_Name,Sub_Category, sum(Profit) profit
from Store_data
group by Product_Name,Sub_Category
order by profit desc;

--8)----- Worst 10 Profitable Product Name,Sub Category --------
select top 10 Product_Name,Sub_Category, sum(Profit) profit
from store
group by Product_Name,Sub_Category
order by profit;

--9)----- Worst 10 Sales Product Name --------
select top 10 Product_Name, sum(Sales) as sales
from store
group by Product_Name
order by sales;

--10)----- Worst 10 Sales Cities --------
select top 10 City, sum(Sales) as sales
from store
group by City
order by sales;

--11)----- Top 10 Sales Cities --------
select top 10 City, sum(Sales) as sales
from store
group by City
order by sales desc;

--12)----- Top 10 Profit Cities --------
select top 10 City, sum(Profit) as sales
from store
group by City
order by sales desc;
