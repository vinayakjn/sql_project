/************************************************************************************************
Create new database
************************************************************************************************/
--SQL Basic Case Study

CREATE DATABASE db_Retail_Data_Analysis 

use db_Retail_Data_Analysis

/************************************************************************************************
Load table [dbo].[prod_cat_info]
************************************************************************************************/

select * from [dbo].[prod_cat_info]

alter table [dbo].[prod_cat_info]
alter column [prod_cat_code] int

alter table [dbo].[prod_cat_info]
alter column [prod_cat] varchar(20)

alter table [dbo].[prod_cat_info]
alter column [prod_sub_cat_code] int

alter table [dbo].[prod_cat_info]
alter column [prod_subcat] varchar(20)

/************************************************************************************************
Load table [dbo].[Customer]
************************************************************************************************/

select * from [dbo].[Customer]

alter table [dbo].[Customer]
alter column [customer_Id] varchar(6) not null

alter table [dbo].[Customer]
add primary key ([customer_Id]) 

alter table [dbo].[Customer]
alter column [DOB] char(10) 

alter table [dbo].[Customer]
alter column [Gender] char(1)

alter table [dbo].[Customer]
alter column [city_code] int

UPDATE [dbo].[Customer] 
SET [DOB] = FORMAT(CONVERT (date,[DOB],103),'yyyy-MM-dd')

/************************************************************************************************
Load table [dbo].[Transactions]
************************************************************************************************/

select * from [dbo].[Transactions]

alter table [dbo].[Transactions]
alter column [transaction_id] varchar(15) not null

alter table [dbo].[Transactions]
alter column [cust_id] varchar(6) not null

alter table [dbo].[Transactions]
add foreign key([cust_id]) references [dbo].[Customer]([customer_Id])

alter table [dbo].[Transactions]
alter column [tran_date] char(10)

UPDATE [dbo].[Transactions]
SET [tran_date] = FORMAT(CONVERT (date,[tran_date],103),'yyyy-MM-dd')

alter table [dbo].[Transactions]
alter column [prod_subcat_code] int 

alter table [dbo].[Transactions]
alter column [prod_cat_code] int

alter table [dbo].[Transactions]
alter column [Qty] float

alter table [dbo].[Transactions]
alter column [Rate] float

alter table [dbo].[Transactions]
alter column [Tax] float

alter table [dbo].[Transactions]
alter column [total_amt] float

alter table [dbo].[Transactions]
alter column [Store_type] varchar(15)

/************************************************************************************************
DATA PREPARATION AND UNDERSTANDING
************************************************************************************************/
--Q1--BEGIN

--create table Tab
--(Table_Name varchar (15), No_of_Rows int)
--insert into Tab values 
--('Customer', (select COUNT(*) from [dbo].[Customer] C)),
--('prod_cat_info', (select COUNT(*) from [dbo].[prod_cat_info] P)),
--('Transactions', (select COUNT(*) from [dbo].[Transactions] T))

select * from [dbo].[Tab]
order by No_of_Rows desc

--Q1--END

--Q2--BEGIN

select COUNT(*) as Total_Return from (
select [transaction_id], [Qty]  from [dbo].[Transactions] T
where [Qty]<0) as a

--Q2--END

--Q3--BEGIN

--Date formats have been changed above, after the tables are loaded from CSV to SQL.
--We can also use below query, to obtain correct date formats.
-- select convert(DATE, DOB, 103) from [dbo].[Customer]
-- select convert(DATE, tran_date, 103) from [dbo].[Transactions]

--Q3--END

--Q4--BEGIN

select DATEDIFF(DAY, MIN([tran_date]),MAX([tran_date])) as DAYS,
DATEDIFF(MONTH, MIN([tran_date]),MAX([tran_date])) as MONTHS, 
DATEDIFF(YEAR, MIN([tran_date]),MAX([tran_date])) as YEARS from [dbo].[Transactions] T

--Q4--END

--Q5--BEGIN

select [prod_cat] as Product_Category from [dbo].[prod_cat_info]
where [prod_subcat]='DIY'

--Q5--END

/************************************************************************************************
DATA ANALYSIS
************************************************************************************************/
--Q1--BEGIN 

select [Store_type] as Channel from
(select top 1 [Store_type], COUNT(*) as Total from [dbo].[Transactions] T
group by [Store_type]
order by Total desc ) as d

--Q1--END

--Q2--BEGIN 

select top 2 [Gender], COUNT(*) as Total from [dbo].[Customer]
group by [Gender]
order by Total desc

--Q2--END

--Q3--BEGIN 

select top 1 [city_code] as City, COUNT(*) as Total_Customers from [dbo].[Customer]
group by [city_code]
order by Total_Customers desc

--Q3--END

--Q4--BEGIN

select COUNT([prod_subcat]) as Total_Subcat from [dbo].[prod_cat_info]
where [prod_cat] = 'Books'

--Q4--END

--Q5--BEGIN

select MAX([Qty]) as Quantity_Ordered from [dbo].[Transactions]

--Q5--END

--Q6--BEGIN

select SUM(Net_Total_Revenue) as Net_Total_Revenue from
(select [prod_cat], round(sum([total_amt]),2) as Net_Total_Revenue from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on P.prod_cat_code=T.prod_cat_code and P.prod_sub_cat_code=T.prod_subcat_code
where [prod_cat] in ('Electronics', 'Books')
group by [prod_cat]) as NTR

--Q6--END

--Q7--BEGIN

select COUNT([cust_id]) as Total_Customers from
(select [cust_id], COUNT([transaction_id]) as Total_Tran from [dbo].[Transactions] T
where [Qty]>0
group by [cust_id]
having COUNT([transaction_id])>10) as e

--Q7--END

--Q8--BEGIN

select round(SUM([total_amt]),2) as Revenue from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.[prod_cat_code]=P.[prod_cat_code] and P.prod_sub_cat_code=T.prod_subcat_code
where [Store_type] = 'Flagship store' and [prod_cat] in ('Electronics','Clothing')

--Q8--END

--Q9--BEGIN

select P.[prod_subcat] as SubCategory, round(SUM([total_amt]),0) as Total_Revenue from [dbo].[Transactions] T
inner join [dbo].[Customer] C
on T.[cust_id]=C.[customer_Id] 
inner join [dbo].[prod_cat_info] P
on P.prod_sub_cat_code=T.prod_subcat_code and P.prod_cat_code=T.prod_cat_code
where [Gender] = 'M' and [prod_cat] = 'Electronics'
group by P.[prod_subcat]
order by Total_Revenue desc

--Q9--END

--Q10--BEGIN

select SP.[prod_subcat] as SubCategory, SP.Sales_Percentage, RP.Returns_Percentage from
(select [prod_subcat], 
concat((round(((SUM([Qty])*100) / (select SUM([Qty]) from [dbo].[Transactions] T where [Qty]>0)),2)),'%') as Sales_Percentage 
from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.prod_cat_code=P.prod_cat_code and T.prod_subcat_code=P.prod_sub_cat_code
where [Qty]>0
group by [prod_subcat] ) as SP

inner join

(select [prod_subcat],
concat((round(((SUM([Qty])*100) / (select SUM([Qty]) from [dbo].[Transactions] T where [Qty]<0)),2)),'%') as Returns_Percentage
from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.prod_cat_code=P.prod_cat_code and T.prod_subcat_code=P.prod_sub_cat_code
where [Qty]<0
group by [prod_subcat] ) as RP

on SP.prod_subcat=RP.prod_subcat

where SP.[prod_subcat] in (select SC.SubCategory from
(select top 5 P.prod_subcat as SubCategory, SUM([Qty]) as Total_Sales from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.prod_cat_code=P.prod_cat_code and T.prod_subcat_code=P.prod_sub_cat_code
group by P.prod_subcat
order by Total_Sales desc ) as SC )

order by SP.Sales_Percentage  

--Q10--END

--Q11--BEGIN

select SUM([total_amt]) as Net_Total_Revenue from
(select [total_amt], DATEDIFF(YEAR, [DOB], [tran_date]) as Age from 
(select *, DATEDIFF(DAY, [tran_date], (select max([tran_date]) from [dbo].[Transactions])) as diff from [dbo].[Transactions] T
where DATEDIFF(DAY,[tran_date], (select max([tran_date]) from [dbo].[Transactions]))<=29) as TBL1
inner join [dbo].[Customer] C
on C.customer_Id=TBL1.cust_id 
where DATEDIFF(YEAR, [DOB], [tran_date]) between '25' and '35') as TBL2

--Q11--END

--Q12--BEGIN

select TBL4.Category  from 
(select top 1 [prod_cat] as Category, SUM([Qty])*(-1) as Total_Returns from 
(select *, DATEDIFF(MONTH,[tran_date], (select max([tran_date]) from [dbo].[Transactions])) as diff from [dbo].[Transactions] T
where DATEDIFF(MONTH,[tran_date], (select max([tran_date]) from [dbo].[Transactions]))<=2 and [Qty]<0) as TBL3
inner join [dbo].[prod_cat_info] P
on P.prod_cat_code=TBL3.prod_cat_code and P.prod_sub_cat_code=TBL3.prod_subcat_code
group by [prod_cat]
order by Total_Returns desc ) as TBL4

--Q12--END


--Q13--BEGIN

select [Store_type] from
(select top 1 [Store_type], SUM([Qty]) as Quantity_Sold, round(SUM([total_amt]),0)  as Sales_Amount from [dbo].[Transactions]
group by [Store_type]
order by Sales_Amount desc) as ST

--Q13--END

--Q14--BEGIN

select Categories from
(select [prod_cat] as Categories, round(AVG([total_amt]),2) as Average_Revenue from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.[prod_cat_code]=P.[prod_cat_code]
group by [prod_cat]
having round(AVG([total_amt]),2) > (select AVG([total_amt]) from [dbo].[Transactions] T) ) as CT

--Q14--END

--Q15--BEGIN

select P.[prod_subcat] as Product_Sub_Category, round(AVG([total_amt]),2) as Average_Revenue, 
round(SUM([total_amt]),2) as Total_Revenue from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.prod_cat_code=P.prod_cat_code and T.prod_subcat_code=P.prod_sub_cat_code

where [prod_cat] in (Select TQ.Category from (select top 5 [prod_cat] as Category, SUM([Qty]) as Total_Quantity_Sold from [dbo].[Transactions] T
inner join [dbo].[prod_cat_info] P
on T.prod_cat_code=P.prod_cat_code and T.prod_subcat_code=P.prod_sub_cat_code
group by [prod_cat]
order by Total_Quantity_Sold desc ) as TQ )

group by P.[prod_subcat]  


--Q15--END