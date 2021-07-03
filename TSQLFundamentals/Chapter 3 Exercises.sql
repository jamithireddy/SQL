
-- Exercise 1
select E.empid,E.firstname,E.lastname,Numbers.n 
FROM HR.Employees as E 
  CROSS JOIN dbo.Nums as Numbers
  WHERE n<6;

-- Exercise 1-2
SELECT E.empid,DATEADD(day,Nums.n-1,cast('20160612' as date)) as Dt
from hr.Employees as E
  CROSS JOIN dbo.Nums as Nums
  where n<=DATEDIFF(day,'20160612','20160616')+1
  order by empid;

-- Exercise 2
-- Explain what is wrong with the below query

select customers.custid, customers.companyname, orders.orderid, orders.orderdate
FROM sales.Customers as C 
  INNER JOIN Sales.Orders as O 
    ON Customers.custid=Orders.custid;

--Answer : The aliases referred were wrong

select C.custid, C.companyname, O.orderid, O.orderdate
FROM sales.Customers as C 
  INNER JOIN Sales.Orders as O 
    ON C.custid=O.custid;

-- Exercise 3
SELECT C.custid, count(O.orderid)as numorders,sum(OD.qty) as totalqty
FROM Sales.Customers as C
  INNER JOIN Sales.Orders as O 
  ON C.custid=O.custid
  INNER JOIN Sales.OrderDetails as OD 
  ON O.orderid=OD.orderid
  WHERE C.country='USA'
  group by C.custid


