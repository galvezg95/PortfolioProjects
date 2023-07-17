--select *
--From netpayment
--order by 3,4

--select *
--From cost
--order by 3,4

-- select data for use

--exploring data from net payment report from january 1 - may 30 2023

Select *
From netpayment
order by 3,2

-- Total appts ID vs total payments

Select apptid, proccode, chrpostdate, sum([net pmt]) as net_payment,sum([all chgs]) as all_charges
From netpayment
Where netreceivable = 0
Group BY apptid, chrpostdate, proccode


-- looking at reimbursment rate %

Select apptid, proccode, chrpostdate, sum([net pmt]) as net_payment,sum([all chgs]) as all_charges, sum(netreceivable) as net_rec, sum([net pmt])/Nullif(sum([all chgs]),0)*100 reimbursment_rate
From netpayment
Where netreceivable = 0
Group BY apptid, chrpostdate, proccode
Order by apptid desc


-- avg payment 

select proccode, avg(ABS([net pmt])) as averagepayment
from netpayment
where netreceivable = 0
Group BY proccode



-- max payment

select proccode, max(ABS([net pmt])) as maxpayment
from netpayment
where netreceivable = 0
Group BY proccode


-- by rndrng prvdr
select [rndrng prvdr], max(ABS([net pmt])) as maxpayment
from netpayment
where netreceivable = 0
Group BY [rndrng prvdr]


--- exploring cost

Select *
from cost

-- average cost

select proccode, avg(cost*-1) as averagecost
from cost
Group BY proccode


-- joining data set

select netpayment.apptid, netpayment.proccode, chrpostdate, chrpostmonth, #chg, ABS([net pmt]) as net_payment, Product, cost
from netpayment
join cost
	on netpayment.apptid = cost.apptid
where netreceivable = 0

-- monthly cost and payments

select netpayment.apptid, netpayment.proccode, chrpostdate, chrpostmonth, #chg, ABS([net pmt]) as net_payment, Product, cost
, sum([net pmt]) over (Partition by chrpostmonth) as monthly_payments
, sum(cost) over (Partition by chrpostmonth) as monthly_cost
from netpayment
join cost
	on netpayment.apptid = cost.apptid
where netreceivable = 0



-- use CTE

with costVsReceivables (apptid, proccode, chrpostdate, chrpostmonth, #chg, net_payment, product, cost, monthly_payments, monthly_cost)
as
(
select netpayment.apptid, netpayment.proccode, chrpostdate, chrpostmonth, #chg, ABS([net pmt]) as net_payment, Product, cost
, sum([net pmt]) over (Partition by chrpostmonth) as monthly_payments
, sum(cost) over (Partition by chrpostmonth) as monthly_cost
from netpayment
join cost
	on netpayment.apptid = cost.apptid
where netreceivable = 0
)

select apptid, proccode, chrpostdate, chrpostmonth, #chg, net_payment, product, cost, monthly_payments, round(monthly_cost,2) as monthly_cost
from costVsReceivables


-- temp table
Drop Table if exists #CostvsChargeMonthly
create Table #CostvsChargeMonthly
(
apptid varchar(50),
proccode varchar(50), 
chrpostdate DATETIME,
chrpostmonth varchar(50), 
#chg numeric,
net_payment numeric,
product varchar(100),
cost numeric,
monthly_payments numeric,
monthly_cost numeric
)
Insert into #CostvsChargeMonthly
select netpayment.apptid, netpayment.proccode, chrpostdate, chrpostmonth, #chg, ABS([net pmt]) as net_payment, Product, cost
, sum([net pmt]) over (Partition by chrpostmonth) as monthly_payments
, sum(cost) over (Partition by chrpostmonth) as monthly_cost
from netpayment
join cost
	on netpayment.apptid = cost.apptid
where netreceivable = 0
Select *
From #CostvsChargeMonthly


-- creating view to store data for later visulizations

create view CostvsPaymentMonth as 
select netpayment.apptid, netpayment.proccode, chrpostdate, chrpostmonth, #chg, ABS([net pmt]) as net_payment, Product, cost
, sum([net pmt]) over (Partition by chrpostmonth) as monthly_payments
, sum(cost) over (Partition by chrpostmonth) as monthly_cost
from netpayment
join cost
	on netpayment.apptid = cost.apptid
where netreceivable = 0