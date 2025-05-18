# DataAnalytics-Assessment
## Question 1 (High-Value Customers with Multiple Products):
### Aim:  Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
### Approach: 
``` sql
WITH funded_plans as (
  SELECT plans.owner_id,
    plan_id,
    is_a_fund,
    is_regular_savings,
    confirmed_amount
  FROM plans_plan as plans
  JOIN savings_savingsaccount as savings
    ON plans.id = savings.plan_id
  WHERE (is_a_fund = 1 or is_regular_savings = 1)
    and confirmed_amount > 0
)
SELECT
  owner_id,
  concat(first_name," ",last_name) as name,
  count(distinct case when funded_plans.is_regular_savings = 1 then funded_plans.plan_id end) as savings_count,
  count(distinct case when funded_plans.is_a_fund = 1 then funded_plans.plan_id end) as investment_count,
  round(sum(confirmed_amount), 2) as total_deposits  
FROM users_customuser as users
JOIN funded_plans
  ON users.id = funded_plans.owner_id
GROUP BY owner_id
HAVING savings_count > 0 and investment_count > 0
ORDER BY total_deposits desc;
```
### Explanation:
First, I used a cte "funded plans", to retrieve the savings and investment plans that have been funded

I then used join statement to merge it with users table and grouped by the individual customer id, and calculated the number of savings and investment plans, as well as the total deposits.

## Question 2 (Transaction Frequency Analysis):
### Aim: Calculate the average number of transactions per customer per month and categorize them:
### Approach: 
``` sql
SELECT
  frequency_category,
  count(frequency_category) as customer_count,
  round(avg(avg_monthly_transactions),1) as avg_transactions_per_month
FROM (
  SELECT
    users.id as owner_id,
    (count(savings_id)/12) as avg_monthly_transactions,
    case
      when (count(users.id)/12) <= 2 then "Low Frequency"
      when (count(users.id)/12) <= 9 then "Medium Frequency"
      else "High Frequency"
    end as frequency_category
  FROM users_customuser as users
  JOIN savings_savingsaccount as savings
    ON users.id = savings.owner_id
  WHERE confirmed_amount > 0
  GROUP BY users.id
    ) as sub
GROUP BY frequency_category;
```
### Explanation: 
For this question, I used a subquery in the form clause to create a table that groups individual customer id into Low, Medium, or High Frequency by calculating their monthly average transactions

The outer query then groups by the categories, and calculates the average number of transactions.

## Question 3 (Account Inactivity Alert):
### Aim:  Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).
### Approach: 
``` sql
SELECT plans.id as plan_id, 
    plans.owner_id,
    case 
		when is_regular_savings = 1 then "Savings"
        else "Investment"
	end as type,
    max(transaction_date) as last_transaction_date,
    datediff(current_date(), max(transaction_date)) as inactivity_days
FROM plans_plan as plans
LEFT JOIN savings_savingsaccount as savings
	ON plans.id = savings.plan_id
WHERE (is_a_fund = 1 or is_regular_savings = 1)
	and is_deleted = 0
GROUP BY plans.id
HAVING inactivity_days > 365
ORDER BY inactivity_days desc;
```
### Explanation: 
## Question 4 (Customer Lifetime Value (CLV) Estimation):
### Aim:  For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate Account tenure (months since signup), Total transactions, Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction), Order by estimated CLV from highest to lowest
### Approach: 
``` sql
SELECT owner_id, 
    concat(first_name, " ", last_name) as name, 
    timestampdiff(Month, date_joined, current_date()) as tenure_months,
    round(sum(confirmed_amount),2) as total_transactions,
    round(sum(confirmed_amount) / timestampdiff(Month, date_joined, current_date()) * 12 * 0.1, 2) as CLV
FROM users_customuser as users
LEFT JOIN savings_savingsaccount as savings
	ON users.id = savings.owner_id
WHERE confirmed_amount > 0
GROUP BY owner_id
ORDER BY CLV desc;
```

