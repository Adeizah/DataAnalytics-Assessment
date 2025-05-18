-- Calculate the average number of transactions per customer per month and categorize them

SELECT  -- Outer query to reaggregate nested query based on the categories
	frequency_category, 
	count(frequency_category) as customer_count,
	round(avg(avg_monthly_transactions),1) as avg_transactions_per_month
FROM (
	SELECT   -- Nested query to first categorize the users into Low, Medium, and High Frequency users
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
