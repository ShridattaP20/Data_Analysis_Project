create database orders;
use orders;

create table df_orders(
order_id int primary key,
order_date date,
ship_mode varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(20),
postal_code varchar(20),
region varchar(20),
category varchar(20),
sub_categoty varchar(20),
product_id varchar(50),
quantity int,
discount float,
sale_price float,
profit float
);

ALTER TABLE df_orders
RENAME COLUMN sub_categoty to sub_category;


select * from df_orders;

-- 1. Top 10 highest revenue generating products 
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc limit 10;

-- 2. Top 5 highest selling products in each region
with cte as (
select  region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id)
select * from (
select *, row_number() over(partition by region order by sales desc) as rn
from cte) a
where rn<=5
 ;
 
 -- 3. Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
 with cte as(
 select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
 from df_orders
 group by order_year, order_month)
 
 select order_month,
 sum(case when order_year=2022 then sales else 0 end) as sales_2022,
 sum(case when order_year=2023 then sales else 0 end) as sales_2023
 from cte
 group by order_month
 order by order_month;


-- 4. For each category which month had highest sales 

with cte as (
select category, date_format(order_date, "%Y%m") as order_year_month, sum(sale_price) as sales
from df_orders
group by category, order_year_month)

select * from(
select *, row_number() over(partition by category order by sales desc) as rnk
from cte) a
where rnk=1;



-- 5. Which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) as order_year,
sum(sale_price) as sales
from df_orders
group by sub_category,year(order_date)
	)
, cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
)
select *
,(sales_2023-sales_2022)
from  cte2
order by (sales_2023-sales_2022) desc limit 1;