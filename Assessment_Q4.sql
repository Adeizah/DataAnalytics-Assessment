-- Estimate CLV based on account tenure and transaction volume (simplified model)

SELECT 
	owner_id, 
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