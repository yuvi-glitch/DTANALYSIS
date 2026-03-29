--1 (window function ex rank each order based on sales and also provide additional details 
use database salesdb;

    select 
        ORDERID,
        orderstatus,
        rank() over(order by sales DESC)
    from public.orders;
    -- group by all;

    --2  select the sum of any metric and use window function to generate rolling month on month sum (Frameex )
    select 
        date_trunc('month', orderdate) as month,
        sum(sales) as monthly_sales,
        sum(sum(sales)) over(
            order by date_trunc('month', orderdate)
            rows between unbounded preceding and current row
        ) as cumulative_sales
    from orders
    group by date_trunc('month', orderdate)
    order by month;

/* Note - when using order by always try to use frame*/

/*Problem 3
Rank all employees by salary from highest to lowest. Show firstname, department, salary and the rank.*/

select 
    firstname,
    department,  
    rank() over(order by sum(salary) DESC) 
from employees group by all;

/*Problem 4
Assign a row number to each order placed by each customer, ordered by orderdate. Show customerid, orderid, orderdate and the row number.*/
/*didnt knowabout the row_number function*/

select customerid,orderid,orderdate, row_number()over( partition by orderid  , customerid order by orderdate) rank from orders ;

-- more accurate solution
select customerid,orderid,orderdate ,row_number() over(partition by customerid order by orderdate) rank  from orders;


/*Problem 5
Show each product's price and the average price of all products in the same category alongside it.*/

select product , price , avg(price) over( partition by category) from products;

/*Problem 6
For each department find the highest paid employee. Show only that one employee per department — no other rows.*/

select employeeid, department , max(salary) over(partition by department) as max_sal from employees;

-- more specific solution
select
    firstname,
    department,
    salary
    from employees
    qualify rank() over(partition by department order by salary DESC) = 1;
    
/*missed to type () in  the rank function and added the qualify rank before from instead of after*/

/*Problem 7
Show each order's sales value, the previous order's sales value and the next order's sales value for each customer. Order by orderdate.*/
-- MISSED THE SYNATX FOR FOLLOWING ENTERED FOLLOWING 1 INSTEAD OF 1 FOLLOWING 
select
    customerid ,
    sum(sales) over( order by orderdate
    rows between current row and 1 following ) result from orders;

-- more appropriate solution using the lead lag functions
select 
    customerid,
    orderid,
    orderdate,
    orderstatus,
    LAG(sales)over(partition by customerid order by orderdate)  as prev_sales,
    LEAD(sales)over(partition by customerid order by orderdate)  as next_sales
from orders;

/*Problem 8
Show the running total of sales across all orders ordered by orderdate. 
So each row should show the cumulative sales up to that point.*/

-- ❌ WRONG
-- Mistake: PARTITION BY orderid resets the running total for every row
-- because orderid is unique — each partition has only 1 row
-- so you just get each order's own sales value, not a cumulative total
SELECT 
    orderid,
    orderdate,
    sales,
    SUM(sales) OVER (
        PARTITION BY orderid  -- this is the mistake
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total
FROM orders
ORDER BY orderdate;

-- ✅ CORRECT
-- Fix: Remove PARTITION BY entirely
-- A running total across ALL orders means one continuous calculation
-- across the whole table with no grouping or reset
SELECT 
    orderid,
    orderdate,
    sales,
    SUM(sales) OVER (
        ORDER BY orderdate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total
FROM orders
ORDER BY orderdate;

/*Problem 9
Find employees who earn more than the average salary of their own department. Show their firstname, department, salary and department average.*/




/*Problem 10
For each customer show their most recent order details. Only show the latest order per customer — no duplicates.*/


/*Problem 11
Show each order's sales and what percentage that order contributes to the total sales of that customer. Round to 2 decimal places.*/

/*Problem 12
Find the difference in sales between each order and the very first order ever placed by that same customer. Show customerid, orderid, orderdate, sales and the difference.*/