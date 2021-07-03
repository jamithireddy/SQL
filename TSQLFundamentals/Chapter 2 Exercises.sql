use tsqlv4;
-- Exercise 1
SELECT orderid, orderdate, custid, empid
from sales.Orders
where orderdate>='20150601' and orderdate<'20150701'

--Exercise 2
select orderid, orderdate, custid, empid
from sales.Orders
where orderdate=EOMONTH(orderdate);

-- Exercise 3

select empid, firstname, lastname
from HR.Employees
WHERE lastname LIKE N'%e%e%';

-- Exercise 4
SELECT orderid, sum(qty*unitprice) as totalvalue
from sales.OrderDetails
GROUP BY orderid
having sum(qty*unitprice)>10000
order BY totalvalue desc;

-- Exercise 5
select empid, lastname 
from HR.Employees
WHERE lastname COLLATE Latin1_General_CS_AS LIKE N'[abcdefghijklmnopqrstuvwxyz]%';

-- Exercise 6
/* Explain the difference between the two queries below*/
-- Query 1
SELECT empid, count(*) as numorders
FROM Sales.Orders
WHERE orderdate<'20160501'
GROUP BY empid;

--Query 2
SELECT empid, count(*) as numorders
FROM Sales.Orders
GROUP BY empid
HAVING MAX(orderdate)<'20160501';

/* 
Query 1 gives the number of orders handled by all the employees which were placed before 01/05/2016.

Query 2 gives the number of orders handled by the employees who havent placed any orders on or after 01/05/2016. It discards the data of the employees who placed orders on or after 01/05/2016.
*/

-- Exercise 7
select top(3) shipcountry, AVG(freight) as avgfreight
from Sales.Orders
where orderdate>='20150101'and orderdate<'20160101'
group by shipcountry
order by avgfreight desc;

-- Exercise 8
SELECT custid, orderdate, orderid,ROW_NUMBER() OVER (partition BY custid order by orderdate, orderid) as rownum
FROM Sales.Orders
order BY custid,orderdate,orderid

-- Exercise 9
SELECT empid, firstname, lastname, titleofcourtesy,
    CASE titleofcourtesy
        when 'Mr.' then 'Male'
        when 'Mrs.' then 'Female'
        when 'Ms.' then 'Female'
        when 'Dr.' then 'Unknown'
        else 'Unknown'
    END AS Gender
FROM HR.Employees;

-- Exercise 10
--Failed
SELECT custid, region 
from sales.Customers
WHERE region is not NULL
ORDER BY region
UNION
SELECT custid, region 
from sales.Customers
WHERE region is NULL
ORDER BY custid;
--from the book
SELECT custid, region
FROM sales.Customers
ORDER BY
  case when region is null then 1 else 0 end,region;