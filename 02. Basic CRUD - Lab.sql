SELECT
	id,
	concat(first_name, ' ', last_name) as "Full Name",
	job_title as "Job Title"
FROM employees;

-

SELECT
	id,
	first_name,
	last_name,
	job_title,
	department_id,
	salary
FROM employees
WHERE salary >= 1000 and department_id = 4;

-

INSERT INTO employees (first_name, last_name, job_title, department_id, salary)
VALUES
	('Samantha', 'Young', 'Housekeeping', 4, 900),
	('Roger', 'Palmer', 'Waiter', 3, 928.33)
;

-

UPDATE employees
SET salary = salary + 100
WHERE job_title = 'Manager'
;

SELECT * FROM employees
WHERE job_title = 'Manager';

-

DELETE FROM employees
WHERE department_id IN (1, 2);

SELECT * FROM employees;

-

CREATE VIEW top_paid_employees AS
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 1
;