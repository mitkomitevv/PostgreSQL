SELECT
	t.town_id,
	t."name" AS town_name,
	a.address_text
FROM
	addresses AS a
JOIN
	towns AS t
USING
	(town_id)
WHERE
	t."name" IN ('San Francisco', 'Sofia', 'Carnation')
ORDER BY
	(town_id, address_id);

---

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    d.department_id,
    d.name AS department_name
FROM
    employees AS e
JOIN
    departments AS d
ON
    e.employee_id = d.manager_id
ORDER BY
    e.employee_id
LIMIT
    5;

---

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    p.project_id,
    p.name
FROM
    employees AS e
JOIN
    employees_projects AS ep
    USING (employee_id)
JOIN
    projects AS p
    USING (project_id)
WHERE
    p.project_id = 1;

---

SELECT
    COUNT(*)
FROM
    employees
WHERE
    salary > (SELECT AVG(salary) FROM employees);