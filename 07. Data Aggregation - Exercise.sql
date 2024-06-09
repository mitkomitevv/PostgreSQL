SELECT
	COUNT(*)
FROM
	wizard_deposits;

-

SELECT
	SUM(deposit_amount) AS total_amount
FROM
	wizard_deposits;

-

SELECT
	ROUND(AVG(magic_wand_size), 3)
FROM
	wizard_deposits;

-

SELECT
	MIN(deposit_charge)
FROM
	wizard_deposits;

-

SELECT
	MAX(age)
FROM
	wizard_deposits;

-

SELECT
	deposit_group,
	SUM(deposit_interest) AS deposit_interest
FROM
	wizard_deposits
GROUP BY
	deposit_group
ORDER BY
	deposit_interest DESC;

-

SELECT
	magic_wand_creator,
	MIN(magic_wand_size) AS minimum_wand_size
FROM
	wizard_deposits
GROUP BY
	magic_wand_creator
ORDER BY
	minimum_wand_size
LIMIT 5;

-

SELECT * FROM wizard_deposits;

SELECT
	deposit_group,
	is_deposit_expired,
	FLOOR(AVG(deposit_interest)) AS deposit_interest
FROM
	wizard_deposits
WHERE
	deposit_start_date > '1985-01-01'
GROUP BY
	is_deposit_expired, deposit_group
ORDER BY
	deposit_group DESC,
	is_deposit_expired;

-

SELECT
	last_name,
	COUNT(notes) AS notes_with_dumbledore
FROM
	wizard_deposits
WHERE
	notes LIKE '%Dumbledore%'
GROUP BY
	last_name;

-

CREATE OR REPLACE VIEW view_wizard_deposits_with_expiration_date_before_1983_08_17 AS
SELECT
	concat(first_name, ' ', last_name) AS wizard_name,
	deposit_start_date AS start_date,
	deposit_expiration_date AS expiration_date,
	deposit_amount AS amount
FROM wizard_deposits
WHERE
	deposit_expiration_date <= '1983-08-17'
GROUP BY
    wizard_name,
    start_date,
    expiration_date,
    amount
ORDER BY
	expiration_date;

-

SELECT
	magic_wand_creator,
	MAX(deposit_amount) AS max_deposit_amount
FROM
	wizard_deposits
GROUP BY
	magic_wand_creator
HAVING
	NOT BETWEEN 20000 AND 40000                     -- MAX(deposit_amount) < 20000 OR MAX(deposit_amount) > 40000
ORDER BY
	max_deposit_amount DESC
LIMIT 3;

-

-- SELECT
-- 	CASE
-- 		WHEN age BETWEEN 11 AND 20 THEN '[11-20]'                  Long solution, code repetition
-- 		WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
-- 		WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
-- 		WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
-- 		WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
-- 		WHEN age > 61 THEN '[61+]'
-- 	END AS age_group,
-- 	COUNT(CASE
--      WHEN age BETWEEN 11 AND 20 THEN '[11-20]'
-- 		WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
-- 		WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
-- 		WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
-- 		WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
-- 		ELSE '[61+]'
-- 	END)
-- FROM
-- 	wizard_deposits
-- GROUP BY
-- 	age_group
-- ORDER BY
-- 	age_group;

SELECT
	CASE
		WHEN age BETWEEN 11 AND 20 THEN '[11-20]'
		WHEN age BETWEEN 21 AND 30 THEN '[21-30]'
		WHEN age BETWEEN 31 AND 40 THEN '[31-40]'
		WHEN age BETWEEN 41 AND 50 THEN '[41-50]'
		WHEN age BETWEEN 51 AND 60 THEN '[51-60]'
		ELSE '[61+]'
	END AS age_group,
	COUNT(*)          -- or COUNT(age)          -- COUNT(*) counts the number of rows for each 'CASE'
FROM
	wizard_deposits
GROUP BY
	age_group
ORDER BY
	age_group;

-

SELECT
    SUM(CASE WHEN department_id = 1 THEN 1 ELSE 0 END) AS Engineering,
    SUM(CASE WHEN department_id = 2 THEN 1 ELSE 0 END) AS Tool_Design,
    SUM(CASE WHEN department_id = 3 THEN 1 ELSE 0 END) AS Sales,
    SUM(CASE WHEN department_id = 4 THEN 1 ELSE 0 END) AS Marketing,
    SUM(CASE WHEN department_id = 5 THEN 1 ELSE 0 END) AS Purchasing,
    SUM(CASE WHEN department_id = 6 THEN 1 ELSE 0 END) AS Research_and_Development,
    SUM(CASE WHEN department_id = 7 THEN 1 ELSE 0 END) AS Production
FROM employees;

-

-- UPDATE employees
-- SET salary = salary + 2500,
-- 	job_title = concat('Senior ', job_title)                 Old way of doing it
-- WHERE
-- 	hire_date < '2015-01-16';

-- UPDATE employees
-- SET salary = salary + 1500,
-- 	job_title = concat('Mid ', job_title)
-- WHERE
-- 	hire_date BETWEEN '2015-01-16' AND '2020-03-04';

UPDATE employees
SET
    salary =
		CASE                                                      -- Advanced and better way of doing it
			WHEN hire_date < '2015-01-16' THEN salary + 2500
			WHEN hire_date < '2020-03-04' THEN salary + 1500
			ELSE salary
		 END,
    job_title =
		CASE
			WHEN hire_date < '2015-01-16' THEN CONCAT('Senior ', job_title)
			WHEN hire_date < '2020-03-04' THEN CONCAT('Mid-', job_title)
			ELSE job_title
		 END;

-

SELECT
	job_title,
	CASE
		WHEN AVG(salary) > 45800 THEN 'Good'
		WHEN AVG(salary) BETWEEN 27500 AND 45800 THEN 'Medium'
		WHEN AVG(salary) < 27500 THEN 'Need Improvement'          -- Having can only return BOOLEAN and be used in aggregation
	END AS category
FROM
	employees
GROUP BY
	job_title
ORDER BY
	category, job_title;

-

SELECT
	project_name,
	CASE
		WHEN start_date IS NULL AND end_date IS NULL THEN 'Ready for development'
		WHEN start_date IS NOT NULL AND end_date IS NULL THEN 'In Progress'
		ELSE 'Done'
	END AS project_status
FROM
	projects
WHERE
	project_name LIKE '%Mountain%';

-

SELECT
	department_id,
	COUNT(department_id) AS num_employees,
	CASE
		WHEN AVG(salary) > 50000 THEN 'Above average'
		WHEN AVG(salary) <= 50000 THEN 'Below average'
	END AS salary_level
FROM
	employees
GROUP BY
	department_id
HAVING
	AVG(salary) > 30000
ORDER BY
	department_id;

-

-- SELECT --> FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY -->> LIMIT

-

CREATE OR REPLACE VIEW view_performance_rating AS
SELECT
	first_name,
	last_name,
	job_title,
	salary,
	department_id,
	CASE
		WHEN salary >= 25000 THEN                         -- Nested CASE structure
			CASE
				WHEN job_title LIKE 'Senior%' THEN 'High-performing Senior'
				ELSE 'High-performing Employee'
			END
		ELSE 'Average-performing'
	END AS performance_rating
FROM employees;

-

CREATE TABLE employees_projects (
    id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(id),
    project_id INT REFERENCES projects(id),

-- CREATE TABLE employees_projects (
--     id SERIAL PRIMARY KEY,
--     employee_id INT NOT NULL,
--     project_id INT NOT NULL,
--     FOREIGN KEY (employee_id) REFERENCES employees(id),
--     FOREIGN KEY (project_id) REFERENCES projects(id)
);

-

SELECT
    d.*,   -- or just '*'                                       -- JOIN everything from two or more TABLES
    e.*
FROM
    departments d
JOIN
    employees e ON d.id = e.department_id;