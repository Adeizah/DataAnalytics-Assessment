-- Find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.

SELECT sub.*, round(sum(confirmed_amount),2) as total_deposits
FROM (
	SELECT 
		users.id as owner_id, 
		concat(first_name," ",last_name) as name, 
		sum(is_regular_savings) as savings_count, 
		sum(is_a_fund) as investment_count
	FROM users_customuser as users
	LEFT JOIN plans_plan as plans
		ON users.id = plans.owner_id
	GROUP BY users.id
	HAVING savings_count > 0 and investment_count > 0
) as sub
LEFT JOIN savings_savingsaccount as savings
	USING (owner_id)
WHERE confirmed_amount > 0
GROUP BY owner_id
HAVING total_deposits > 0
ORDER BY total_deposits desc;