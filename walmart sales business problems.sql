SELECT count(*) FROM walmart limit 10;

select distinct city,branch from walmart;
select distinct category from walmart;

-- change column name 
ALTER TABLE walmart
CHANGE COLUMN `total price` `total_price` double;


select * from walmart;

select distinct payment_method from walmart group by payment_method;

select  payment_method,count(*) from walmart group by payment_method;

select max(quantity) from walmart;

select min(quantity) from walmart;

select count(distinct branch) from walmart;



-- Business Problems

-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

select  payment_method,count(*) AS no_of_payments,SUM(QUANTITY) as total_quantity from walmart group by payment_method;


 #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating

SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS r
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE r = 1;


-- q3-Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, transaction_count
FROM (
    SELECT branch, day_name, COUNT(*) AS transaction_count,
           RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS r
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_transactions
WHERE r = 1;





-- q4-calculate total quantity of items sold per payment method.list payment_method and total_quantity

SELECT  payment_method,SUM(QUANTITY) as total_quantity from walmart group by payment_method;


-- Q5-determine the average,minimum and maximum ratings of products for each city.list city,avearge rating and max rating.
select city,category,
max(rating) as max_rating,
min(rating) as min_rating,
avg(rating) as avg_rating
from walmart group by city,category;


-- q6-calculate the total profit for each category by considering total_profit as (unit_price*quantity*profit_margin).
-- list category and total_profit,ordered from highest to lowest profit

select category,sum(total_price*profit_margin) as total_profit from walmart group by category;

-- q7-determine the most common payment method for each branch.display branch and the preferred payment method.

select * from
(
select branch,payment_method,count(*) as total_transcation,
rank() over (partition by branch order by count(*) desc) as  r
from walmart group by branch,payment_method) as ranked
where r=1;


-- Q8-categorize  sales into 3 group morning,afternoon,evening.find out which of the shift and number of transcations.

SELECT 
    CASE
        WHEN CAST(SUBSTRING_INDEX(time, ':', 1) AS UNSIGNED) < 12 THEN 'Morning'
        WHEN CAST(SUBSTRING_INDEX(time, ':', 1) AS UNSIGNED) BETWEEN 12 AND 17 THEN 'Afternoon'
       ELSE  'Evening'
    END AS shift,
    COUNT(*) AS transaction_count
FROM walmart
GROUP BY shift
ORDER BY transaction_count DESC;


-- Q9-IDENTIFY 5 BRANCH WITH HIGHEST DECREASE RATIO IN REVENUE COMPARE TO LAST YEAR(CURRENT YEAR 2023 AND LAST YEAR 2022)
-- REVENUE DECREASED RATIO=(LAST YEAR REVENUE-CURRENT YEAR REVENUE/LAST YEAR REVENUE)*100

SELECT 
    branch, 
    SUM(CASE WHEN year = 2022 THEN total_price ELSE 0 END) AS revenue_2022,
    SUM(CASE WHEN year = 2023 THEN total_price ELSE 0 END) AS revenue_2023,
    ((SUM(CASE WHEN year = 2022 THEN total_price ELSE 0 END) - SUM(CASE WHEN year = 2023 THEN total_price ELSE 0 END)) 
     / SUM(CASE WHEN year = 2022 THEN total_price ELSE 0 END) * 100) AS revenue_decrease_ratio
FROM 
    walmart
GROUP BY 
    branch
HAVING 
    revenue_2022 > 0 -- To avoid division by zero
ORDER BY 
    revenue_decrease_ratio DESC
LIMIT 5;

