
                       #DANNY'S DINNER

CREATE DATABASE dannys_diner;



CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  SELECT * FROM members;
  USE DANNYS_DINER;
  
  select * from menu;
  select * from sales;
  
  #quesetion 1) what is the total amount each customer spent at the restaurant?
  
  select sales.customer_id AS customer_id,count(sales.product_id),
  sum(menu.price) AS AMOUNT_SPENT
  FROM sales
  JOIN menu ON SALES.PRODUCT_ID=menu.PRODUCT_ID
  GROUP BY 1;
  
  
  select count(product_id),customer_id
  from sales
  group by customer_id;
  
  #question 2 ) how many days has each customer visited the restaurant
  SELECT DISTINCT ORDER_DATE,COUNT(ORDER_DATE) AS DAYS,CUSTOMER_ID
  FROM SALES
  GROUP BY 1, 3;
  
  SELECT DISTINCT CUSTOMER_ID,COUNT(DISTINCT ORDER_DATE)
  FROM SALES
  GROUP BY CUSTOMER_ID;
  
  
  
  #QUESTION 4) WHAT IS THE MOST PURCHASED ITEM IN MENU AND HOW MANY TIME WAS IT PURCHASED BY ALL CUSTOMERS
  SELECT MENU.PRODUCT_ID AS PRODUCT_ID,PRODUCT_NAME,
  COUNT(SALES.PRODUCT_ID)
  FROM SALES
  JOIN MENU ON SALES.PRODUCT_ID=MENU.PRODUCT_ID
  GROUP BY 1,2
  ORDER BY 3 DESC
  LIMIT 1;
  
  
  


#question 3) what was the first item from the menu purchased by each customer?
WITH MY_CTE AS(
select sales.customer_id,menu.product_id,SALES.ORDER_DATE,MENU.PRODUCT_NAME,
ROW_NUMBER() OVER(partition by CUSTOMER_ID ORDER BY ORDER_DATE) AS RNK
FROM MENU
join sales on sales.product_id=menu.product_id
group by 1,2,3,4)

SELECT CUSTOMER_ID,PRODUCT_ID,PRODUCT_NAME
FROM MY_CTE
WHERE RNK='1';

#QUESTION 5) WHICH ITEM WAS THE MOST POPULAR FOR EACH CUSTOMER

with item as(
SELECT sales.PRODUCT_ID,SALES.CUSTOMER_ID,MENU.PRODUCT_NAME,COUNT(*) AS Total,
Rank() OVER(PARTITION BY SALES.CUSTOMER_ID ORDER BY SALES.PRODUCT_ID) as rnk
FROM MENU
join sales on sales.product_id=menu.product_id
GROUP BY 1,2,3)

select product_id,product_name,customer_id
from item 
where rnk=1;

#question 6)which item became first after they became a memnber
WITH ITEM_2 AS(
Select sales.customer_id,sales.product_id,menu.product_name,SALES.ORDER_DATE,
rank() over (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE)  AS RNK
from MEMBERS
join sales on sales.CUSTOMER_id=MEMBERS.CUSTOMER_id
join MENU on sales.PRODUCT_id=MENU.product_id
where sales.order_date>=members.join_date)

SELECT CUSTOMER_ID,PRODUCT_NAME,ORDER_DATE,PRODUCT_ID
FROM ITEM_2
WHERE RNK ='1';

#QUESTION 7) WHICH ITEM WAS PURCHASED JUST BEFORE THE CUSTOMER BECAME MEMBER
WITH ITEM_3 AS(
SELECT SALES.CUSTOMER_ID,SALES.PRODUCT_ID,MENU.PRODUCT_NAME,SALES.ORDER_DATE,
rank() over (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE DESC)  AS RNK
from MEMBERS
join sales on sales.CUSTOMER_id=MEMBERS.CUSTOMER_id
join MENU on sales.PRODUCT_id=MENU.product_id
where sales.order_date<members.join_date)

SELECT * FROM ITEM_3
WHERE RNK='1';


#QUESTION 8) WHAT IS THE TOTAL ITEM AND AMOUNT SPENT BY EACH CUSTOMER BEFORE THEY BECAME MEMBER
WITH ITEM_4 AS(
SELECT SUM(MENU.PRICE) AS TOTAL_PRICE,SALES.CUSTOMER_ID,SALES.PRODUCT_ID,MENU.PRODUCT_NAME,SALES.ORDER_DATE,COUNT(MENU.PRODUCT_ID) AS NUM,
rank() over (PARTITION BY CUSTOMER_ID ORDER BY ORDER_DATE DESC)  AS RNK
from MEMBERS
join sales on sales.CUSTOMER_id=MEMBERS.CUSTOMER_id
join MENU on sales.PRODUCT_id=MENU.product_id

where sales.order_date<members.join_date
GROUP BY 2,3,4,5)

SELECT SUM(TOTAL_PRICE),CUSTOMER_ID,COUNT(NUM)
FROM ITEM_4
GROUP BY 2;

#question 9) if each $1 spent equates to 10 points and sushi have 2x points multiplier how many points would eac customer have?
use dannys_diner;
select customer_id ,
sum(case
when product_name='sushi' then price*10*2
else price*10
end )as points
from menu 
join sales on menu.product_id=sales.product_id
group by customer_id;

#10) IN THE FIRST WEEK AFTER A CUSTOMER JOINS THE PROGRAM (INCLUDING THEIR JOIN DATE THEY EARN 2X POINTS ON ALL ITEMS NOT JUST SUSHI)
#HOW MANY POINTS DO CUSTOMER A AND B HAVE AT THE END OF JANUARY?

select S.CUSTOMER_ID,
case
when M.ORDER_DATE BETWEEN MEM.JOIN_DATE AND DATEADD('DAY',6,MEM.JOIN_DATE) then price*10*2
WHEN PRODUCT_NAME='SUSHI' THEN PRICE*10*2
else price*10
end as points
FROM MENU AS M
INNER JOIN SALES AS S ON S.PRODUCT_ID=M.PRODUCT_ID
INNER JOIN MEMBERS AS MEM ON MEM.CUSTOMER_ID=S.CUSTOMER_ID

join sales on menu.product_id=sales.product_id
group by customer_id;







 


  
  
  