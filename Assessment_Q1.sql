-- Find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

WITH funded_plans as ( -- Creating CTE to retrieve funded savings and investment plans using plans and savings tables
	SELECT 
		plans.owner_id,
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
SELECT -- Making the calculated columns for full name, savings_count, investment_count, and total_deposits using users table and the CTE above
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
