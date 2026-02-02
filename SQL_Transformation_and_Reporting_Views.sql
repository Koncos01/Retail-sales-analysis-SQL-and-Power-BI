alter table east/west stb
add constraint foreign_name
foreign key (category, store,SP_ID, Product) references categories/stores/sellers/products(Category_ID/Store_ID/ID/Product_ID(


create view Beverages_Product as (
select p.Product_ID, p.Product,
 c.Category
from products as p
join categories as c
on p.Category_ID = c.Category_ID
where Category = "Beverages");

create table all_orders
select Order_ID, Order_DATE, Product, Store, Units_Sold, SP_ID, "East" as region
 from east
 union all
 select *, "West"
 from West
 union all
 select *, "South" from south
 union all
 select *, "North East" from north_east
 union all 
 select *, "North West" from north_west

create view Sold_products_by_seller as (
select sum(w.Units_Sold) as selled_products,
s.Sales_rep
from west as w
join sellers as s
on w.SP_ID = s.ID
group by w.sp_ID
order by selled_products desc);

select round(sum(s.Units_Sold * p.Price), 2) as Revenue
from south as s
join products as p
on s.Product = p.product_ID;

alter table all_orders
add column order_dates date;
set sql_safe_updates = 0;
update all_orders
set order_dates = str_to_date(Order_Date, '%d-%b-%y');

alter table east
add column order_dates date;
update east
set order_dates = str_to_date(Order_Date, '%d-%b-%y');

alter table west
add column order_dates date;
update west
set order_dates = str_to_date(Order_Date, '%d-%b-%y');

alter table north_east
add column order_dates date;
update north_east
set order_dates = str_to_date(Order_Date, '%d-%b-%y');

alter table north_west
add column order_dates date;
update north_west
set order_dates = str_to_date(Order_Date, '%d-%b-%y');

alter table south
add column order_dates date;
update south
set order_dates = str_to_date(Order_Date, '%d-%b-%y');

create view top_5_store_by_revenue as (
select s.Storee, 
sum(o.units_sold * p.price) as revenue_by_store
 from all_orders as o
 join products as p
 on o.Product = p.Product_ID
 join stores as s
 on o.store = s.Store_ID
 group by o.store
 order by revenue_by_store desc
 limit 0, 5);

create view cross_selling as (
select p.Product, 
c.category,
count(*) as occurence
 from all_orders as o
 join products as p
 on o.Product = p.product_ID
 join categories as c
 on p.Category_ID = c.Category_ID
 where units_sold > 100
 group by o.Product
 order by occurence desc
 limit 0, 3);

create view top_stores__in_region_by_revenue as (
with base as (
select  region, s.storee as stores, sum(o.Units_sold * p.price) as revenue,
rank() over(partition by region order by sum(o.Units_Sold * p.price) desc) as ranks
 from all_orders as o
 join stores as s
 on o.store = s.store_ID
 join products as p
 on o.product = p.product_ID
 group by region, stores)
 select * from base
 where ranks = 1
 order by revenue desc);

create view sales_and_customers_by_sellers as (
select sum(o.Units_sold) as sales_by_sellers, count(*) as all_customers_by_sellers
 from all_orders as o
 left join sellers as s
 on o.SP_ID = s.ID
 group by sales_rep
order by sales_by_sellers desc);

create view sellers_rank as (
select s.sales_rep as seller, sum(o.Units_sold) as sales_by_sellers, count(*) as all_customers_by_sellers,
rank() over(order by sum(o.units_sold) desc, count(*) desc) as ranks
 from all_orders as o
 left join sellers as s
 on o.SP_ID = s.ID
 group by seller);

CREATE VIEW PowerBI_Sales_Model AS
SELECT 
    o.Order_ID,
    o.order_dates as Order_Date,
    o.region,
    p.Product,
    c.Category,
    p.Price,
    o.Units_Sold,
    (o.Units_Sold * p.Price) AS Total_Revenue,
    s.storee AS Store_Name,
    r.Sales_rep AS Seller_Name
FROM all_orders AS o
LEFT JOIN products AS p ON o.Product = p.Product_ID
LEFT JOIN categories AS c ON p.Category_ID = c.Category_ID
LEFT JOIN stores AS s ON o.Store = s.Store_ID
LEFT JOIN sellers AS r ON o.SP_ID = r.ID;
 
set sql_safe_updates = 0;
update products
set Price = replace(Price, ',', '.');

alter table products
modify column Price decimal(10, 2);



 drop view revenue;
create view revenue as (
select sum(bi.units_sold * p.price) as revenue
from PowerBI_sales_model as bi
join products as p
on bi.product = p.product);
 








 
 

 
 








 
 
















