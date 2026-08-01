use bikes;
-- 1.	Find	the	total	number	of	products	sold	by	each	store	along	with	the	store	name;
select 
s.store_id,s.store_name, sum(oi.quantity) as total_products_sold from stores s 
join orders o on s.store_id = o.store_id 
join order_items oi on oi.order_id = o.order_id 
group by s.store_id ,s.store_name ;

-- 2.	Calculate	the	cumulative	sum	of	quantities	sold	for	each	product	over	time.
select 
oi.product_id , o.order_date , oi.quantity, sum(oi.quantity)
over (partition by oi.product_id order by o.order_id ) as cumulative_quantity from order_items oi 
join orders o on o.order_id = oi.order_id 
order by oi.product_id , o.order_date;

-- 3.	Find	the	product	with	the	highest	total	sales	(quantity	×	price)	for	each	category
with product_sales as (
select p.product_id, p.product_name, p.category_id , sum(oi.quantity*oi.list_price) as total_sales
 from products p 
 join order_items oi on oi.product_id=p.product_id 
 group by p.product_id, p.product_name, p.category_id ) ,
 
 ranked as (
 select ps.*,c.category_name, rank() over(partition by ps.category_id order by total_sales desc) as rnk 
 from product_sales ps join categories c on c.category_id=ps.category_id )
 
 select category_name, product_name , total_sales from ranked where rnk=1;

-- 4 .Find	the	customer	who	spent	the	most	money	on	orders
select c.customer_id , c.first_name , c.last_name ,sum(oi.quantity * oi.list_price * oi.discount) as total_spent from customers c 
join orders o on o.customer_id = c.customer_id 
join order_items oi on oi.order_id = o.order_id 
group by c.customer_id , c.first_name , c.last_name
order by total_spent desc 
limit 1;

-- 5.Find	the	highest-priced	product	for	each	category name
with ranked as (
select p.product_id ,p.product_name ,p.list_price ,c.category_name, 
rank() over(partition by p.category_id order by p.list_price desc ) as rnk 
from products p join categories c on c.category_id=p.category_id )

select category_name , product_name,list_price from ranked where rnk=1; 

-- 6.	Find	the	total	number	of	orders	placed	by	each	customer	per	store
 select o.customer_id ,c.first_name , c.last_name , s.store_id,s.store_name, count(o.order_id) as total_orders 
 from orders o join customers c on c.customer_id=o.customer_id 
 join stores s on s.store_=o.store_id 
 group by 
o.customer_id ,c.first_name , c.last_name , s.store_id,s.store_name ;

-- 7.	Find	the	names	of	staff	members	who	have	not	made	any	sales
select st.staff_id ,st.first_name ,st.last_name 
from staffs st 
left join orders o on o.staff_id =st.staff_id 
where o.order_id is null;

-- 8.	Find	the	top	3	most	sold	products	in	terms	of	quantity
select p.product_id,p.product_name , sum(oi.quantity) as total_quantity 
from products p join order_items oi on oi.product_id = p.product_id 
group by  p.product_id,p.product_name  order by total_quantity desc limit 3;

-- 9.	Find	the	median	value	of	the	price	list.
with ordered as (
select list_price ,row_number() over(order by list_price ) as rnk ,count(*) over() as total_rows from products )
select avg(list_price) as medain from ordered 
where rnk in (floor((total_rows+1)/2),ceil((total_rows+1)/2)) ;

-- 10.	List	all	products	that	have	never	been	ordered	(use	Exists)
select p.product_id,p.product_name from products p 
where not exists (
select 1 from order_items oi where oi.product_id=p.product_id );

-- 11.	List	the	names	of	staff	members	who	have	made	more	sales	than	the	average	number	of	sales	by	all	staff	members.
with staff_sales as (
select staff_id ,count(order_id) as total_sales  from orders group by staff_id )

select s.staff_id,s.first_name,s.last_name ,ss.total_sales from staff_sales ss join staffs s on s.staff_id=ss.staff_id
where ss.total_sales > (select avg(total_sales) from staff_sales);

-- 12.	Identify	the	customers	who	have	ordered	all	types	of	products	(i.e.,	from	every	category).
select c.customer_id,c.first_name ,c.last_name from customers c 
where not exists(
select cat.category_id from categories cat 
where not exists (select 1 from orders o 
join order_items oi on oi.order_id=o.order_id
join products p on p.product_id =oi.product_id 
where o.customer_id=c.customer_id 
and p.category_id = cat.category_id )
);



































































