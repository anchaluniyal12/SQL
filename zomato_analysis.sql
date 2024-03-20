drop table if exists goldusers_signup;
create database zomato;
USE ZOMATO;
CREATE TABLE goldusers_signup (
    userid INTEGER,
   gold_signup_date DATE
); 
update goldusers_signup
set gold_signup_date=format(gold_signup_date,'DD/MM/YYYY')
WHERE 1=1;




INSERT INTO goldusers_signup(userid,gold_signup_date) 
 VALUES (1,'2017-09-22'),
(3,'2017-04-21');

drop table if exists users;
CREATE TABLE users(userid integer,signup_date date); 

INSERT INTO users(userid,signup_date) 
 VALUES (1,'2014-02-09'),
(2,'2015-01-12'),
(3,'2014-04-11');

drop table if exists sales;
CREATE TABLE sales(userid integer,created_date date,product_id integer); 

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (1,'2017-04-19',2),
(3,'2019-12-18',1),
(2,'2020-07-20',3),
(1,'2019-10-23',2),
(1,'2018-03-19',3),
(3,'2016-12-20',2),
(1,'2016-11-09',1),
(1,'2016-05-20',3),
(2,'2017-09-24',1),
(1,'2017-03-11',2),
(1,'2016-03-11',1),
(3,'2016-11-10',1),
(3,'2017-12-07',2),
(3,'2016-12-15',2),
(2,'2017-08-11',2),
(2,'2018-10-09',3);


drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

#1.what is total amount each customer spent on zomato ?
#2.How many days has each customer visited zomato?
#3.what was the first product purchased by each customer?
#4.what is most purchased item on menu & how many times was it purchased by all customers ?
#5.which item was most popular for each customer?
#6.which item was purchased first by customer after they become a member ?
#7. which item was purchased just before the customer became a member?
#8. what is total orders and amount spent for each member before they become a member?
#9. If buying each product generates points for eg 5rs=2 zomato point 
 # and each product has different purchasing points for eg for p1 5rs=1 zomato point,for p2 10rs=5zomato point and p3 5rs=1 zomato point  2rs =1zomato point for p2, calculate points collected by each customer and for which product most points have been given till now.
#10. In the first year after a customer joins the gold program (including the join date ) irrespective of what customer has purchased earn 5 zomato points for every 10rs spent who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs
#11. rnk all transaction of the customers
#12. rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na


select sum(product.price) as total,sales.userid as id
from product 
join sales on product.product_id=sales.product_id
group by id
order by total desc;


#2.How many days has each customer visited zomato?
select count(created_date) as days,product_id
from sales
group by product_id
order by product_id;

#3.what was the first product purchased by each customer?
WITH MY_CTE AS(
select  product_id, created_date,
ROW_NUMBER() OVER(partition by product_ID ORDER BY created_date) AS RNK
FROM sales
group by 1,2)


select product_id, created_date
from MY_CTE
where RNK=1;

#4.what is most purchased item on menu & how many times was it purchased by all customers ?
select userid,product_id,count(product_id) as num
from sales
where product_id=(SELECT  product_id from sales group by product_id order by
count(product_id) desc
 LIMIT 1)
group by userid,product_id;


select userid,product_id,count(product_id) as num
from sales
group by 1,2;
SELECT  product_id ,count(product_id) from sales group by product_id order by
count(product_id) desc
 limit 1;
 
 
#5.which item was most popular for each customer?
with MY_CTE AS(
SELECT  userid,product_id,count(product_id) as num,
row_number() OVER(PARTITION BY USERID ORDER BY COUNT(product_id) DESC)AS RNK
FROM sales
group by 1,2)

select userid,product_id ,num
from MY_CTE
WHERE RNK=1
;

#6.which item was purchased first by customer after they become a member ?
select sales.created_date,sales.product_id
from sales
join users on sales.userid=users.userid
where created_date>signup_date
order by created_date;

with my_cte as
(select sales.userid,sales.created_date,sales.product_id,
ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date) as rnk
from sales
join users on sales.userid=users.userid
where created_date>signup_date)

select userid,created_date,product_id
from my_cte
where rnk=1;

#7. which item was purchased just before the customer became a member?
#we will see this for gold membership
with my_cte as
(select sales.userid,sales.created_date,sales.product_id,
ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date desc) as rnk
from sales
join goldusers_signup on sales.userid=goldusers_signup.userid
where created_date<gold_signup_date)

select userid,created_date,product_id
from my_cte
where rnk=1;

#8. what is total orders and amount spent for each member before they become a member?
with my_cte as
(select sales.userid,sales.created_date,sales.product_id,sum(product.price) as total,
ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date desc) as rnk
from sales
join goldusers_signup on sales.userid=goldusers_signup.userid
join product on sales.product_id=product.product_id
where created_date<gold_signup_date
group by 1,2,3)

select userid,sum(total)
 from my_cte
 group by 1;

#9. If buying each product generates points for eg 5rs=2 zomato point 
 # and each product has different purchasing points for eg for p1 5rs=1 zomato point,for p2 10rs=5zomato point and p3 5rs=1 zomato point  2rs =1zomato point for p2, calculate points collected by each customer and for which product most points have been given till now.
 with my_cte as(
 select sales.userid as id,product.product_id as pro_id,sum(product.price) as amt,
 row_number() over(partition by sales.userid order by product.product_id) as rnk,
 CASE 
when product.product_id=1 then 5
when product.product_id=2 then 2
when product.product_id=3 then 5
else 0
end as points
from sales

join product on sales.product_id=product.product_id
group by userid,product.product_id)

select id,pro_id,(amt/points) as total_points
from my_cte;

#10. In the first year after a customer joins the gold program (including the join date ) irrespective of what customer has purchased earn 5 zomato points for every 10rs spent who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs
with my_cte as
(select sales.userid,sales.created_date,sales.product_id,product.price as price,goldusers_signup.gold_signup_date as gdate,
ROW_NUMBER() OVER(PARTITION BY userid ORDER BY created_date desc) as rnk,
CASE 
when product.product_id=1 then 2
when product.product_id=2 then 2
when product.product_id=3 then 2
else 0
end as points
from sales
join goldusers_signup on sales.userid=goldusers_signup.userid
join product on sales.product_id=product.product_id 

WHERE created_date>gold_signup_date and created_date<=DATE_ADD(gold_signup_date,INTERVAL 1 YEAR))

select userid,created_date,product_id,price,points,gdate
from my_cte
group by 1,2,3,4,5,6;

 #11. rnk all transaction of the customers
 with my_cte as(
 SELECT sales.userid as id,sales.product_id as pro_id,product.price as price,count(sales.product_id) as total,
 row_number() over(partition by userid order by price desc) as rnk
 from sales
 join product on sales.product_id=product.product_id
 group by 1,2,3)
 
 select id,sum(price)*sum(total) as trans
 from my_cte
 group by 1
 order by 2 desc;
 
 
# 11. rnk all transaction of the customers
select * , rank() over(partition by userid order by created_date) as rnk
from sales;


 