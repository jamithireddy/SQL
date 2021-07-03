use tsqlv4;

-- Practice
-- To return the number of distinct locations from where we have customers and eployees
SELECT country, COUNT(*) AS numlocations
FROM (SELECT country,region,city FROM HR.Employees
      UNION
      SELECT country,region,city FROM Sales.Customers) AS U
GROUP BY country;

--Return last 2 orders from Employee number 3 & 5
SELECT empid, orderid, orderdate
FROM (SELECT TOP(2) empid,orderid,orderdate
      FROM Sales.Orders
      WHERE empid=3
      ORDER BY orderdate DESC, orderid DESC) AS D1
UNION ALL
SELECT empid, orderid, orderdate
FROM (SELECT TOP(2) empid,orderid,orderdate
      FROM Sales.Orders
      WHERE empid=5
      ORDER BY orderdate DESC, orderid DESC) AS D2;

--Exercises

--Exercise 1: 
--Explain the diffrence between UNION ALL and UNION Operators. In what cases are two equivalent? when they are equivalent, which one should you use?

/*
Answer: UNION just gives the distinct values in the two sets A & B, removing all duplicate values. Where as UNION ALL returns the Duplicates as well. In case where there are no duplicate values in the sets A & B, UNION and UNION ALL shall return same result. Hence they shall be equivalent. In those cases we use UNION ALL to reduce the processing cost to find duplicates. 
*/

--Exercise 2:
--Write a query that generates a virtual auxilary table of 10 numbers in the range 1 through 10 without using looping construct. You dont need to gaurantee any order of the rows in the output of your solution:

SELECT 1 as n 
UNION ALL SELECT 2 as n 
UNION ALL SELECT 3 as n 
UNION ALL SELECT 4 as n 
UNION ALL SELECT 5 as n 
UNION ALL SELECT 6 as n 
UNION ALL SELECT 7 as n 
UNION ALL SELECT 8 as n 
UNION ALL SELECT 9 as n 
UNION ALL SELECT 10 as n;

--Exercise 3:
--Write a query that returns customer and employee pairs that had order activity in January 2016 but not in February 2016
SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20160101' and orderdate<'20160201'
EXCEPT
SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20160201' and orderdate<'20160301';

--Exercise 4:
--Write a Query that returns customer and employee pairs that had order activity in both January 2016 and February 2016
SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20160101' and orderdate<'20160201'
INTERSECT
SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20160201' and orderdate<'20160301';

--Exercise 5:
--Write a query that returns customer and employee pairs that had order activity in both January 2016 and February 2016 but not in 2015
(SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20160101' and orderdate<'20160201'
INTERSECT
SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20160201' and orderdate<'20160301')
EXCEPT
(SELECT custid,empid
FROM Sales.Orders
WHERE orderdate>='20150101' and orderdate<'20160101');

--Exercise 6:
/*
You are given the following query:

SELECT country,region,city
FROM Hr.employees
UNION ALL
SELECT country,region,city
FROM Production.Suppliers;

You are asked to add logic to the query so that it guarantees that the rows from Employees are returned in the output before the rows from Suppliers. Also, within each segment, the rows should be sorted by country,region and city:
*/

--Answer:
SELECT country,region,city
FROM (SELECT TOP (100) PERCENT country,region,city
      FROM Hr.employees
      ORDER BY country,region,city)AS E
UNION ALL
SELECT country,region,city
FROM (SELECT TOP (100) PERCENT country,region,city
      FROM Production.Suppliers
      ORDER BY country,region,city)AS S;\

--The above query gives sorted option when ran individual queries but doesnt give the desired output when ran together as Table expressions doesnt gaurantee order

SELECT country,region,city 
FROM (SELECT 1 AS sortcol,country,region,city FROM HR.Employees
      UNION ALL
      SELECT 2 AS sortcol,country,region,city FROM Production.Suppliers) AS C
ORDER BY sortcol,country,region,city;
