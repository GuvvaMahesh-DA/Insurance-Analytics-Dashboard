create database insurance_db;
use insurance_db;

select *from additional_fields;
select *from Policy_Details;
select *from payment_hist;
select *from cust_info;
select *from policy_claims;

# for TOTAL CUSTOMER--
select count(*) AS Total_Customers
FROM cust_info;

# FOR TOTAL NUMBER POLICIES--
select count(*) AS Total_Policies
FROM policy_details;

 # TOTAL CLAIM AMOUNT GENERATED--
describe policy_claims;
show columns FROM Policy_claims;
select round(sum(`Claim Amount`), 2) AS Total_Claim_Amount
FROM policy_claims; 
select avg(`Coverage Amount`) as average_coverage_amount
from policy_details;

#  Average coverage amount per policy -- 
select round(avg(`Coverage Amount`), 2) 
as average_coverage_amount 
from policy_details;

# Average premium amount collected per policy --
select round(avg(`Premium Amount`), 2) 
as average_premium_amount
from policy_details;

# Percentage of policies are currently active -- 	
select concat(round(sum(case when status = 'Active' 
then 1 else 0 end) * 100.0 / count(*),2),'%') 
as active_policy_percentage
from policy_details;
 
# Count Of Policy Status--
select Status,
count(*) as Policy_Count
from policy_details
group by Status;


#  Highest Number Of Policies By Status--
select status,
count(*) as Policy_Count from policy_details
group by status order by Policy_Count desc
limit 1;


#  Ratio of Active and Inactive Policies --
select sum(case when Status = 'Active' then 1 else 0 end) as Active_Policies,
sum(case when status in ('Lapsed', 'Terminated') then 1 else 0 end) as Inactive_Policies,
concat(sum(case when Status = 'Active' then 1 else 0 end),':',
sum(case when status in ('Lapsed', 'Terminated') then 1 else 0 end))as Active_Inactive_Ratio
from policy_details;

#  Age group has the highest number of policies
select case when age between 18 and 25 then '18-25'
			when age between 26 and 35 then '26-35'
			when age between 36 and 45 then '36-45'
			when age between 46 and 60 then '46-60'
            else 'Above 60' end as age,
count(*) as total_policies from cust_info group by age order by total_policies desc
limit 1;

#   Top three age groups by policy count -- 
select  case  when age between 18 and 60 then '18-25'
        when age between 26 and 35 then '26-35'
        when age between 36 and 45 then '36-45'
        when age between 46 and 60 then '46-60'
        when age between 61 and 75 then '61-75'else 'above 75' end as age,
        count(*) as policy_count from cust_info group by age order by policy_count desc
		limit 3;


#   Gender has the highest policy --
select gender, count(*) as policy_count  from cust_info 
group by gender order by policy_count desc 
limit 1;

#  DIFFERENCE BETWEEM MALE AND FEMALE POLICY COUNT --
describe cust_info;
show columns from cust_info;
select  sum(case when Gender = 'Male' then 1 else 0 end) as Male_Count,
    sum(case when Gender = 'Female' then 1 else 0 end) as Female_Count,
    sum(case when Gender = 'Male' then 1 else 0 end) - sum(case when Gender = 'Female' then 1 else 0 end) as Difference
    from cust_info;    
    
#   POLICY TYPE MAXIMUM POLICY COUNT --
select `Policy Type`, COUNT(*) as policy_count
from policy_details group by `Policy Type`
order by policy_count desc limit 1;

#   POLICY TYPE MINIMUM POLICY COUNT --
select `Policy Type`, COUNT(*) as policy_count
from policy_details
group by `Policy Type`
order by policy_count asc
limit 1;

#  Compare Auto and Health policy counts -- 
select sum(case when `Policy Type` = 'Health' then 1 else 0 end) as Health_Policies,
       sum(case when`Policy Type` = 'Auto' then 1 else 0 end) as Auto_Policies,
	   sum(case when `Policy Type` = 'Health' then 1 else 0 end)  - sum(case when`Policy Type` = 'Auto' then 1 else 0 end) as Difference
from policy_details;
    
# Total number of policies across all policy types -- 
select `Policy Type`,  count(*)  as total_policies   from policy_details
group by `Policy Type`;

select count(*) as total_policies
from policy_details;                 -- overall policies 


#    Average premium growth rate over all years --
with yearly_premium as (select year(str_to_date(`Policy Start Date`, '%Y-%m-%d')) as year,
        sum(`Premium Amount`) AS total_premium from policy_details
        group by year(str_to_date(`Policy Start Date`, '%Y-%m-%d'))),
        growth as (select year,total_premium,lag(total_premium)
        over (order by year) as previous_premium  from yearly_premium)
        select concat(round(avg(((total_premium - previous_premium) / previous_premium) * 100) / 100,2),'%')
        as average_premium_growth_rate from growth where previous_premium is not null;
        
#  	Is the premium growth trend increasing or decreasing over time ----
with yearly_premium  as (select year(`Policy Start Date`) as policy_year,
        sum(`Premium Amount`) as total_premium from policy_details
        group by year(`Policy Start Date`)),
        growth as ( select  policy_year, total_premium,
        lag(total_premium) over (order by policy_year) as previous_premium,
        round(((total_premium - lag(total_premium) over (order by policy_year)) / lag(total_premium) over (order by policy_year)) * 100, 2)
        as growth_rate  from yearly_premium) select policy_year, total_premium, growth_rate,case when growth_rate > 0 then 'Increasing'
        when growth_rate < 0 then 'Decreasing' else 'No Change' end as trend  from growth;
        
#   Difference between the highest and lowest premium growth rates ---
  with yearly_premium as ( select year(str_to_date(`Policy Start Date`, '%Y-%m-%d')) as policy_year,
   sum(`Premium Amount`) as total_premium  from policy_details
   group by year(str_to_date(`Policy Start Date`, '%Y-%m-%d'))),growth as (  select  policy_year,
   round( ((total_premium - lag(total_premium) over (order by policy_year)) / lag(total_premium) over (order by policy_year)) ,2)
   as growth_rate from yearly_premium)select concat(round(max(growth_rate) - min(growth_rate), 2), '%') as Difference
from growth where growth_rate is not null;
            
#    Yearly trend of policies ending from 2016 to 2034 -- 
select year(`Policy End Date`) as end_year,
    count(*) as policies_ended from policy_details
where year(`Policy End Date`) between 2016 and 2034
group by year(`Policy End Date`) ORDER BY end_year;
WITH yearly_end AS (SELECT YEAR(`Policy End Date`) AS end_year,
	COUNT(*) AS policies_ended  FROM policy_details
    WHERE YEAR(`Policy End Date`) BETWEEN 2016 AND 2034
    GROUP BY YEAR(`Policy End Date`))SELECT end_year,
    policies_ended, LAG(policies_ended) OVER (ORDER BY end_year) AS previous_year,CASE
        WHEN policies_ended > LAG(policies_ended) OVER (ORDER BY end_year) THEN 'Increasing'
        WHEN policies_ended < LAG(policies_ended) OVER (ORDER BY end_year) THEN 'Decreasing'
        ELSE 'No Change' END AS trend FROM yearly_end;
        
        

        
        
        
        
        
        
   