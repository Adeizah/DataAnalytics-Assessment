-- Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days)

SELECT
	plans.id as plan_id, 
	plans.owner_id,
	case 
		when is_regular_savings = 1 then "Savings"
        	else "Investment"
	end as type,
	date(max(transaction_date)) as last_transaction_date,
	datediff(current_date(), max(transaction_date)) as inactivity_days
FROM plans_plan as plans
JOIN savings_savingsaccount as savings
	ON plans.id = savings.plan_id
WHERE (is_a_fund = 1 or is_regular_savings = 1)
	and is_deleted = 0
GROUP BY plans.id
HAVING inactivity_days > 365
ORDER BY inactivity_days desc;
