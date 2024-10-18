show databases;
use employee;
show tables;
select*from orders1;
select order_id,ship_mode
from orders1
where ship_mode is null;
 -- select top 10 revenue generating product
select product_id,sum(sale_price) as sales
from orders1
group by product_id
order by sales desc
limit 10;

select product_id,region from orders1;
-- find top 5 highest selling products in each region
with cte as
(select product_id,region,sum(sale_price) as sales
from orders1
group by region,product_id)
select* from(
select*,row_number() over(partition by region order by sales desc) as rn from cte) as A
where rn<=5;

-- find month over month comparsion for sales for 2022 and 2023
select distinct year(order_date) from orders1;


with cte as 
(select year(order_date) as order_year,month(order_date) as order_month,sum(sale_price) as sales
from orders1
group by order_year,order_month
order by order_year,order_month)
select order_month
,round(sum(case when order_year=2022 then sales else 0 end),2) as sales_2022
,round(sum(case when order_year=2023 then sales else 0 end),2) as sales_2023 from cte
group by order_month
order by order_month;

-- find for each category which month had the  highest sales
with cte as
(select category,month(order_date) as order_month,year(order_date) as order_year,sum(sale_price) as sales
from orders1
group by category,order_month,order_year
order by category,order_month,order_year)
select category,order_month,order_year,sales from cte 
where (Category,sales) in (select category,max(sales) from cte group by category)
order by category;
   -- or below approach using both cte and window functions
with cte as
(select category,date_format(order_date,'%y%m') as order_ym,sum(sale_price) as sales
from orders1
group by category,order_ym
order by category,order_ym)
select * from
(select *,row_number() over (partition by category order by sales desc) as rn from cte) A
where rn=1;

-- find the sub-category with highest growth 2023 compared to 2022
with cte as
(select sub_category,year(order_date) as order_year,sum(sale_price) as sales
from orders1
group by sub_category,order_year
order by sub_category,order_year)
,cte2 as 
(select sub_category,sum(case when order_year=2022 then sales else 0 end) as sales_2022
,sum(case when order_year=2023 then sales else 0 end) as sales_2023 from cte
group by sub_category)
select *,(sales_2023-sales_2022)*100/sales_2022 as growth_per
from cte2
order by growth_per desc;

