SELECT
	department_id,
	COUNT('department_id') AS employee_count          -- We use '', when we order by the same thing
FROM
	employees
GROUP BY
	department_id
ORDER BY
	department_id;

-

SELECT
	department_id,                                -- We can use SUM, MAX, MIN, AVG and so on
	COUNT(salary) AS employee_count
FROM
	employees
GROUP BY
	department_id
ORDER BY
	department_id;

-

SELECT
	department_id,
	SUM(salary) AS "Total Salary"
FROM                                           -- Using HAVING. We can't use "Total Salary" in WHERE, because it doesen't exist yet
	employees
GROUP BY									   -- SELECT --> FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY -->> LIMIT
	department_id
HAVING										   -- HAVING is only used in aggregate functions
    SUM(salary) < 4200
ORDER BY
	department_id;

-

SELECT
	id,
	first_name,
	last_name,
	ROUND(salary, 2) AS salary,
	department_id,
	CASE
		WHEN department_id = 1 THEN 'Management'
		WHEN department_id = 2 THEN 'Kitchen Staff'
		WHEN department_id = 3 THEN 'Service Staff'
		ELSE 'Other'
 -- CASE department_id
	-- 	WHEN 1 THEN 'Management'                             Simple expression
	-- 	WHEN 2 THEN 'Kitchen Staff'
	-- 	WHEN 3 THEN 'Service Staff'
	-- 	ELSE 'Other'
	END AS department_name
FROM
	employees;