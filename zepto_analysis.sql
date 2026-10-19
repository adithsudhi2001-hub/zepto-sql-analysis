drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) not null,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outofstock BOOLEAN,
quantity INTEGER
);

--data exploration

--count of rows
select count(*) from zepto;

--sample data
select *from zepto
limit 10;

--null values
select* from zepto
where name is null
or
category is null
or
mrp is null
or
discountPercent is null
or
discountedSellingPrice is null
or
weightInGms is null
or
availableQuantity is null
or
outOfStock is null
or
quantity is null;


---different product categories
select distinct category 
from zepto
order by category;


--product in stock and out of stock
select outOfStock, count(sku_id)
from zepto
group by outOfStock;


--product name present multiple time
select name,count(sku_id) as "Number of SKUs"
from zepto
group by name
having count(sku_id)>1
order by count(sku_id) desc;


--data cleaning

--product with price = 0
select * from zepto
where mrp=0 or discountedSellingPrice=0;

delete from zepto 
where mrp=0;


--convert paise into rupees

update zepto 
set mrp=mrp/100.0,
discountedSellingPrice =discountedSellingPrice/100.0;

select mrp,discountedSellingPrice from zepto;

--top best value product based on the discount percentage
select distinct name, mrp, discountPercent
from zepto
order by discountPercent desc
limit 10;

--products with high mrp but out of stock
select distinct name,mrp
from zepto
where outOfStock= true and mrp>300
order by mrp desc;

--estimated revenue for each category
select category,
sum (discountedSellingPrice * availableQuantity) as total_revenue
from zepto
group by category
order by total_revenue;

--all product mrp greater than 500 and discount is less than 10%
select distinct name,mrp,discountPercent
from zepto
where mrp>500 and discountPercent<10
order by mrp desc, discountPercent desc;

--top 5 categories offerring the highest average discout
select category,
round(avg(discountPercent),2) as avg_discount
from zepto
group by category
order by avg_discount desc
limit 5;

--price per gram fro products above 100g and sort by best value
select distinct name,weightInGms,discountedSellingPrice,
round(discountedSellingPrice/weightInGms,2) as price_per_gram
from zepto
where weightInGms>=100
order by price_per_gram;

--grouping the product into categories like low medium bulk
select distinct name,weightInGms,
case when weightInGms<1000 then 'low'
     when weightInGms<5000 then 'medium'
	 else 'bulk'
	 end as weight_category
from zepto;


--total inventory weight per category 
select category,
sum(weightInGms*availableQuantity) as total_weight
from zepto
group by category
order by total_weight;