USE TSQLV4;

--Exercise 1
-- Correct the following query 
/*
SELECT orderid,orderdate, custid, empid,DATEFROMPARTS(YEAR(orderdate),12,31) as endofyear
FROM Sales.Orders
WHERE orderdate <>endofyear 
*/

--Without CTE
SELECT orderid,orderdate, custid, empid,DATEFROMPARTS(YEAR(orderdate),12,31) as endofyear
FROM Sales.Orders
WHERE orderdate <>DATEFROMPARTS(YEAR(orderdate),12,31);

--Using CTEs

WITH C AS
  (
  SELECT orderid,orderdate, custid, empid,DATEFROMPARTS(YEAR(orderdate),12,31) as endofyear
  FROM Sales.Orders
  )
  SELECT orderid,orderdate, custid, empid,endofyear
  FROM C
  WHERE orderdate <>endofyear;

-- Exercise 2-1

--Without using CTEs
SELECT DISTINCT empid ,orderdate
FROM Sales.Orders AS O1
WHERE orderdate=
  (SELECT max(O2.orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.empid=O1.empid)

select empid,max(orderdate) as maxorderdate
from Sales.Orders
group by empid;

--Exercise 2-2
Select O.empid, O.orderdate,O.orderid,O.custid 
FROM Sales.Orders as O
 INNER JOIN (select empid,max(orderdate) as maxorderdate
  from Sales.Orders
  group by empid)as D
ON O.empid=D.empid
AND O.orderdate=D.maxorderdate
