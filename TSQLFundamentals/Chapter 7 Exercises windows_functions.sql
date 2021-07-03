USE TSQLV4;

--Practice
SELECT empid,
        ordermonth,
        val, 
        SUM(val) OVER (PARTITION BY empid
                      ORDER BY ordermonth
                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS runval
FROM Sales.EmpOrders;

SELECT orderid, custid, val,
  ROW_NUMBER() OVER(ORDER BY val) AS rownum,
  RANK() OVER(ORDER BY val) AS rank,
  DENSE_RANK() OVER( ORDER BY val) AS dense_rank,
  NTILE(10) OVER(ORDER BY val) AS n_tile
FROM Sales.OrderValues
ORDER BY val;

SELECT custid,orderid,val,
  LAG(val) OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS preval,
  LEAD(val) OVER(PARTITION BY custid ORDER BY orderdate, orderid) AS nextval
FROM Sales.OrderValues
ORDER BY custid, orderdate,orderid;

SELECT custid, orderid,val,
  FIRST_VALUE(val) OVER(PARTITION BY custid
                        ORDER BY orderdate,orderid
                        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Firstval,
  LAST_VALUE(val) OVER(PARTITION BY custid
                        ORDER BY orderdate,orderid
                        ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS lastval                     
FROM Sales.OrderValues
ORDER BY custid,orderdate,orderid;

SELECT orderid, custid, val,
        sum(val) OVER() AS total_value,
        sum(val) OVER(PARTITION BY custid) AS cust_total
FROM Sales.OrderValues;

SELECT orderid, custid,val,
        CAST(100.*val/SUM(val) OVER() AS DECIMAL(10,2)) AS pct_all ,
        CAST(100.*val/SUM(val) OVER(PARTITION BY custid) AS DECIMAL(10,2)) AS pct_cust
FROM Sales.OrderValues;


USE TSQLV4;

DROP TABLE IF EXISTS dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
  orderid   INT        NOT NULL,
  orderdate DATE       NOT NULL,
  empid     INT        NOT NULL,
  custid    VARCHAR(5) NOT NULL,
  qty       INT        NOT NULL,
  CONSTRAINT PK_Orders PRIMARY KEY(orderid)
);

INSERT INTO dbo.Orders(orderid, orderdate, empid, custid, qty)
VALUES
  (30001, '20140802', 3, 'A', 10),
  (10001, '20141224', 2, 'A', 12),
  (10005, '20141224', 1, 'B', 20),
  (40001, '20150109', 2, 'A', 40),
  (10006, '20150118', 1, 'C', 14),
  (20001, '20150212', 2, 'B', 12),
  (40005, '20160212', 3, 'A', 10),
  (20002, '20160216', 1, 'C', 20),
  (30003, '20160418', 2, 'B', 15),
  (30004, '20140418', 3, 'C', 22),
  (30007, '20160907', 3, 'D', 30);

SELECT * FROM dbo.Orders;

SELECT empid, custid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

-- Pivoting using a Grouped query
SELECT empid,
SUM(CASE WHEN custid = 'A' THEN qty END) AS A,
SUM(CASE WHEN custid = 'B' THEN qty END) AS B,
SUM(CASE WHEN custid = 'C' THEN qty END) AS C,
SUM(CASE WHEN custid = 'D' THEN qty END) AS D
FROM dbo.Orders
GROUP BY empid;
--Pivoting using PIVOT OPerator
SELECT empid, A,B,C,D
FROM( SELECT empid, custid,qty
      FROM dbo.Orders) AS D
      PIVOT(sum(qty)FOR custid IN(A,B,C,D)) AS P;
-- In the above, a table expression SELECT empid, custid,qty FROM dbo.Orders was used instead of the table directly is because there are other columns orderid, orderdate, which also acts for grouping the above data. Look at tha query below
SELECT empid, A,B,C,D
FROM dbo.Orders
PIVOT(sum(qty)FOR custid IN(A,B,C,D)) AS P
-- In the above query the Grouping is done by orderid,orderdate and then empid. Hence use a table expression for FROM whenever using a PIVOT.

--Pivoting on customer id and emp id
SELECT custid, [1],[2],[3],[4]
FROM( SELECT custid,empid,qty
      FROM dbo.Orders) AS O
      PIVOT(sum(qty)FOR empid IN([1],[2],[3],[4])) AS P;
-- In the above query, numbericals are in square brackets as the identifiers cannot start with numericals or space in-between.

USE TSQLV4;

DROP TABLE IF EXISTS dbo.EmpCustOrders;

CREATE TABLE dbo.EmpCustOrders
(
  empid INT NOT NULL
    CONSTRAINT PK_EmpCustOrders PRIMARY KEY,
  A VARCHAR(5) NULL,
  B VARCHAR(5) NULL,
  C VARCHAR(5) NULL,
  D VARCHAR(5) NULL
);

INSERT INTO dbo.EmpCustOrders(empid, A, B, C, D)
  SELECT empid, A, B, C, D
  FROM (SELECT empid, custid, qty
        FROM dbo.Orders) AS D
    PIVOT(SUM(qty) FOR custid IN(A, B, C, D)) AS P;

SELECT * FROM dbo.EmpCustOrders;

-- Not using an unpivot 
SELECT empid,custid,qty
FROM dbo.EmpCustOrders
CROSS APPLY (VALUES('A',A),('B',B),('C',C),('D',D)) AS C(custid,qty)
WHERE qty IS NOT NULL;

--Using UNPIVOT
SELECT empid,custid,qty
FROM dbo.EmpCustOrders
  UNPIVOT(qty FOR custid IN(A,B,C,D)) AS U;

DROP TABLE IF EXISTS dbo.EmpCustOrders;

--GROUPING SETS
SELECT empid, custid,SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid;

SELECT empid, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid;

SELECT  custid,SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid;

SELECT SUM(qty) AS sumqty
FROM dbo.Orders;

SELECT empid, custid,SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid, custid
UNION ALL
SELECT empid,NULL, SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY empid
UNION ALL
SELECT  NULL,custid,SUM(qty) AS sumqty
FROM dbo.Orders
GROUP BY custid
UNION ALL
SELECT NULL,NULL,SUM(qty) AS sumqty
FROM dbo.Orders;

SELECT empid,custid,SUM(qty) AS sumqty
FROm dbo.Orders
GROUP BY 
  GROUPING SETS
  (
    (empid,custid),
    (empid),
    (custid),
    ()
  );

SELECT empid,custid,SUM(qty) AS sumqty
FROm dbo.Orders
GROUP BY CUBE (empid, custid);

SELECT
  YEAR(orderdate) AS orderyear,
  MONTH(orderdate) AS ordermonth,
  DAY(orderdate) AS orderday,
  SUM(qty) As sumqty
FROM dbo.Orders
GROUP BY ROLLUP(YEAR(orderdate),MONTH(orderdate),DAY(orderdate));

--Exercise 1:

--Write a query against dbo.Orders that computes both a rank and a dense rank for each customer order, Partioned by custid and ordered by qty.
SELECT custid, orderid,qty,
  RANK() OVER(PARTITION BY custid ORDER BY qty) as rank,
  DENSE_RANK() OVER(PARTITION BY custid ORDER BY qty) as dense_rank
FROM dbo.Orders;

--Exercise 2:
--Return distinct values and their associated row numbers against Sales.OrderValues
WITH C AS
(
  SELECT DISTINCT val
  FROM Sales.OrderValues
)
SELECT val, ROW_NUMBER() OVER (ORDER BY val) as rownum
FROM C;
-- The same thing can be achieved using below query
SELECT val, ROW_NUMBER() OVER(ORDER BY val) as rownum
FROM Sales.OrderValues
GROUP BY val;

--Exercise 3:
--Write a query against dbo.Orders table that computes for each customer booth the difference between the current order quantity and the customer's previous order quantity and the difference between the current order quantity and the customer's next order quantity:

SELECT custid,orderid, qty,
(qty-LAG(qty) OVER(PARTITION BY custid ORDER BY orderdate)) as diffprev,
(qty-LEAD(qty) OVER(PARTITION BY custid ORDER BY orderdate)) as diffnext
FROM dbo.Orders
ORDER BY custid,orderdate;

--Exercise 4:
--Write a query against dbo.Orders that returns a row for each employee, a column for each orderyear, and the count of orders for each employee and order year.

select  empid, [2014],[2015],[2016]
FROM
    (SELECT empid,YEAR(orderdate) AS orderyear,orderid
    FROM dbo.Orders) AS D
  PIVOT( COUNT(orderid) FOR orderyear IN ([2014],[2015],[2016])) AS P;

--The same can be achieved using the following query
SELECT empid,
  COUNT(CASE WHEN orderyear=2014 THEN orderyear END) AS [2014],
  COUNT(CASE WHEN orderyear=2015 THEN orderyear END) AS [2015],
  COUNT(CASE WHEN orderyear=2016 THEN orderyear END) AS [2016]
FROM (SELECT empid,YEAR(orderdate) AS orderyear
      FROM dbo.Orders) AS D
GROUP BY empid;

--Exercise 5:
--Using the following tabLE AND CREATE A unpivot
USE TSQLV4;

DROP TABLE IF EXISTS dbo.EmpYearOrders;

CREATE TABLE dbo.EmpYearOrders
(
  empid INT NOT NULL
    CONSTRAINT PK_EmpYearOrders PRIMARY KEY,
  cnt2014 INT NULL,
  cnt2015 INT NULL,
  cnt2016 INT NULL
);

INSERT INTO dbo.EmpYearOrders(empid, cnt2014, cnt2015, cnt2016)
  SELECT empid, [2014] AS cnt2014, [2015] AS cnt2015, [2016] AS cnt2016
  FROM (SELECT empid, YEAR(orderdate) AS orderyear
        FROM dbo.Orders) AS D
    PIVOT(COUNT(orderyear)
          FOR orderyear IN([2014], [2015], [2016])) AS P;

SELECT * FROM dbo.EmpYearOrders;

/*
Write a query against the EmpYearOrders table that unpivots the data, returning a row for each employee and order year with the number of orders Exclude rows where the number of orders is 0 (in our example, employee 3 in year 2016)

-- Desired output:
empid       orderyear   numorders
----------- ----------- -----------
1           2014        1
1           2015        1
1           2016        1
2           2015        1
2           2015        2
2           2016        1
3           2014        2
3           2016        2
*/

SELECT empid, CAST(RIGHT(orderyear,4) AS INT) AS orderyear, numorders
FROM dbo.EmpYearOrders
UNPIVOT (numorders FOR orderyear IN(cnt2014,cnt2015,cnt2016)) AS U
WHERE numorders<>0;

--Alternate Solution
SELECT empid,orderyear,numorders
FROM dbo.EmpYearOrders
  CROSS APPLY (VALUES(2014, cnt2014),(2015,cnt2015),(2016,cnt2016)) AS A(orderyear,numorders)
  WHERE numorders<>0;

