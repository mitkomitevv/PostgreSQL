-- SELECT --> FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY -->> LIMIT

-- id INT GENERATED ALWAYS AS IDENTITY        Best way when the id is INT

CREATE DATABASE minions_db;

CREATE TABLE minions(
	id serial PRIMARY KEY,
	name VARCHAR(30),
	age INT
);

ALTER TABLE minions
RENAME TO minions_info;

ALTER TABLE minions_info
ADD COLUMN code CHAR(4),
ADD COLUMN task TEXT,
ADD COLUMN salary NUMERIC(8,3);

SELECT * FROM minions_info;

ALTER TABLE minions_info
RENAME COLUMN salary TO banana;

ALTER TABLE minions_info
ADD COLUMN email VARCHAR(20),
ADD COLUMN equipped BOOLEAN NOT NULL;

CREATE TYPE type_mood
AS ENUM (
	'happy',
	'relaxed',
	'stressed',
	'sad'
);

ALTER TABLE minions_info
ADD COLUMN mood type_mood;

ALTER TABLE minions_info
ALTER COLUMN age SET NOT NULL,
ALTER COLUMN age SET DEFAULT 0,
ALTER COLUMN name SET NOT NULL,
ALTER COLUMN name SET DEFAULT '',
ALTER COLUMN code SET NOT NULL,
ALTER COLUMN code SET DEFAULT '';

ALTER TABLE minions_info
ADD CONSTRAINT unique_containt UNIQUE (id, email),
ADD CONSTRAINT banana_check CHECK (banana > 0);

ALTER TABLE minions_info
ALTER COLUMN task TYPE VARCHAR(150);

ALTER TABLE minions_info
ALTER COLUMN equipped DROP NOT NULL;

ALTER TABLE minions_info
DROP COLUMN age;

CREATE TABLE minions_birthdays(
	id SERIAL NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	date_of_birth DATE NOT NULL,
	age INT NOT NULL DEFAULT 0,
	present VARCHAR(100) NOT NULL DEFAULT '',
	party timestamptz NOT NULL
);

INSERT INTO minions_info(name, code, task, banana, email, equipped, mood)
values
	('Mark', 'GKYA', 'Graphing Points', 3265.265, 'mark@minion.com', FALSE, 'happy'),
	('Mel', 'HSK', 'Science Investigation', 54784.996, 'mel@minion.com', TRUE, 'stressed'),
	('Bob', 'HF', 'Painting', 35.652, 'bob@minion.com', TRUE, 'happy'),
	('Darwin', 'EHND', 'Create a Digital Greeting', 321.958, 'darwin@minion.com', FALSE, 'relaxed'),
	('Kevin', 'KMHD', 'Construct with Virtual Blocks', 35214.789, 'kevin@minion.com', False, 'happy'),
	('Norbert', 'FEWB', 'Testing', 3265.500, 'norbert@minion.com', TRUE, 'sad'),
	('Donny', 'L', 'Make a Map', 8.452, 'donny@minion.com', TRUE, 'happy');

SELECT name, task, email, banana
FROM minions_info;

TRUNCATE TABLE minions_info;

DROP TABLE minions_birthdays;

----------------------------------------------------------------------------------------------------------

SELECT
	id,
	concat(first_name, ' ', last_name) as "Full Name",
	job_title as "Job Title"
FROM employees;

---

SELECT
	id,
	first_name,
	last_name,
	job_title,
	department_id,
	salary
FROM employees
WHERE salary >= 1000 and department_id = 4;

---

INSERT INTO employees (first_name, last_name, job_title, department_id, salary)
VALUES
	('Samantha', 'Young', 'Housekeeping', 4, 900),
	('Roger', 'Palmer', 'Waiter', 3, 928.33)
;

---

UPDATE employees
SET salary = salary + 100
WHERE job_title = 'Manager'
;

SELECT * FROM employees
WHERE job_title = 'Manager';

---

DELETE FROM employees
WHERE department_id IN (1, 2);

SELECT * FROM employees;

---

CREATE VIEW top_paid_employees AS
SELECT * FROM employees
ORDER BY salary DESC
LIMIT 1
;

SELECT * FROM top_paid_employees;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT
	concat(name, ' ', state) AS cities_information,
	area AS area_km2
FROM cities;

---

SELECT DISTINCT ON (name)
	name,
	area AS area_km2
FROM cities
ORDER BY "name" DESC;

---

SELECT
	id,
	concat(first_name, ' ', last_name) AS full_name,
	job_title
FROM employees
ORDER BY first_name
LIMIT 50;

---

SELECT
	id AS id,
	concat_ws(' ', first_name, middle_name, last_name) AS full_name,
	hire_date
FROM employees
ORDER BY hire_date ASC
OFFSET 9;

---

SELECT
	id,
	concat(number, ' ', street) AS address,
	city_id
FROM addresses
WHERE id >= 20;

---

SELECT
	concat(number, ' ', street) AS address,
	city_id
FROM addresses
WHERE city_id > 0 and city_id % 2 = 0
ORDER BY city_id;

---

SELECT
	name,
	start_date,
	end_date
FROM projects
WHERE start_date >= '2016-06-01 07:00:00' AND end_date < '2023-06-04 00:00:00'
ORDER BY start_date;

---

SELECT
	number,
	street
FROM addresses
WHERE id BETWEEN 50 AND 100 or number < 1000;
-- WHERE (id >= 50 and id <= 100) or number < 1000;

---

SELECT
	employee_id,
	project_id
FROM employees_projects
WHERE employee_id IN (200, 250) AND project_id NOT IN (50, 100);

---

SELECT
	name,
	start_date
FROM projects
WHERE name IN ('Mountain', 'Road', 'Touring')
LIMIT 20;

---

SELECT
	concat(first_name, ' ', last_name) AS full_name,
	job_title,
	salary
FROM employees
WHERE salary IN (12500, 14000, 23600, 25000)
ORDER BY salary DESC;

---

SELECT
	id,
	first_name,
	last_name
FROM employees
WHERE middle_name IS NULL
LIMIT 3;

---

INSERT INTO departments (department, manager_id)
VALUES
	('Finance', 3),
	('Information Services', 42),
	('Document Control', 90),
	('Quality Assurance', 274),
	('Facilities and Maintenance', 218),
	('Shipping and Receiving', 85),
	('Executive', 109);
-- RETURNING *; Shows the table afterwards

---

-- CREATE TABLE IF NOT EXISTS company_chart AS
CREATE TABLE company_chart AS
SELECT
	concat(first_name, ' ', last_name) AS full_name,
	job_title,
	department_id,
	manager_id
FROM employees;

---

UPDATE projects
SET end_date = start_date + INTERVAL '5 months'
WHERE end_date IS NULL;

---

UPDATE employees
SET
	salary = salary + 1500,
	job_title = concat('Senior ', job_title)
WHERE
	hire_date BETWEEN '1998-01-01' AND '2000-01-05';
	-- hire_date >= '1998-01-01' AND hire_date <= '2000-01-05';

---

DELETE FROM addresses
WHERE city_id IN (5, 17, 20, 30);

---

-- CREATE OR REPLACE VIEW
CREATE VIEW view_company_chart AS
SELECT
	full_name,
	job_title
FROM company_chart
WHERE manager_id = 184;

---

CREATE VIEW view_addresses AS
SELECT
	concat(e.first_name, ' ', e.last_name) AS full_name,
	e.department_id,
	concat(a.number, ' ', a.street) AS address
FROM employees AS e
JOIN addresses AS a ON e.address_id = a.id
ORDER BY address;

-- CREATE VIEW view_addresses AS
-- SELECT
-- 	concat(e.first_name, ' ', e.last_name) AS full_name,
-- 	e.department_id,
-- 	concat(a.number, ' ', a.street) AS address
-- FROM employees AS e, addresses AS a
-- WHERE e.address_id = a.id
-- ORDER BY address;

---

ALTER VIEW view_addresses
RENAME TO view_employee_addresses_info;

---

DROP VIEW view_company_chart;

---

UPDATE projects
SET name = UPPER(name);

---

CREATE VIEW view_initials AS
SELECT
	LEFT(first_name, 2) AS initial,
	-- SUBSTRING(first_name, 1, 2) AS initial,
	last_name
FROM employees
ORDER BY last_name;

---

SELECT
	name,
	start_date
FROM projects
WHERE name LIKE 'MOUNT%'
ORDER BY id;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT
	title
FROM
	books
WHERE title LIKE 'The%';
-- WHERE LEFT(title, 3) = 'The'
-- WHERE SUBSTRING(title, 1, 3) = 'The'

---

SELECT
	REPLACE(title, LEFT(title, 3), '*** ') as "title"
	-- REPLACE(title, 'The', '***') as "title" This will replace every 'The' in the string, even if it's not in the beggining.
FROM
	books
WHERE LEFT(title, 3) = 'The';

---

SELECT
	id,
	(side * height) / 2 as area
FROM triangles;

---

SELECT
	title,
	trunc(cost, 3) as modified_price
	-- cost * 1.0 as modified_price
FROM books;

---

SELECT
	first_name,
	last_name,
	EXTRACT('year' FROM born) AS year
	-- date_part('year', born) AS year
FROM authors;

---

SELECT
	last_name,
	to_char(born, 'DD (Dy) Mon YYYY')
-- 	concat_ws(' ',
--     EXTRACT('day' FROM born),
--     concat('(', to_char(born, 'Dy'), ')'),                  The hard way :D
--     to_char(born, 'Mon'),
--     EXTRACT('year' FROM born)
-- ) AS "Date of Birth"
FROM authors

---

SELECT
	title
FROM
	books
WHERE title LIKE '%Harry Potter%'

----------------------------------------------------------------------------------------------------------------------------------------

CREATE VIEW view_river_info AS
SELECT
	concat_ws(' ', 'The river', river_name, 'flows into the', outflow, 'and is', "length", 'kilometers long.') AS "River Information"
FROM rivers
ORDER BY river_name;

---

CREATE VIEW view_continents_countries_currencies_details AS
SELECT
	concat(TRIM(c.continent_name), ': ', c.continent_code) AS continent_details,
	concat_ws(' - ', n.country_name, n.capital, n.area_in_sq_km, 'km2')	AS country_information,
	concat(m.description, ' (', m.currency_code, ')') AS currencies
FROM continents AS c
JOIN countries AS n ON c.continent_code = n.continent_code
JOIN currencies AS m ON n.currency_code = m.currency_code
-- FROM
	-- continents AS c
	-- countries AS n
	-- currencies AS m
-- WHERE c.continent_code = n.continent_code AND n.currency_code = m.currency_code
ORDER BY
	country_information,
	currencies;

---

ALTER TABLE countries
ADD COLUMN capital_code CHAR(2);

UPDATE countries
SET capital_code = LEFT(capital, 2);
-- SET capital_code = SUNSTRING(capital, 1, 2);             Something like slicing in Python

---

SELECT                                                   -- Something like slicing in Python
	SUBSTRING(description, 5)
FROM
	currencies;

---

SELECT
	SUBSTRING("River Information", '[0-9]{1,4)') AS river_length                  -- Regex solution easy. Only the first match
	-- (REGEXEXP_MATCHES("River Information", '[0-9]{1,4}')[1] AS river_length)      Regex solution hard. Multiple matches
FROM view_river_info

---

SELECT
	REPLACE(mountain_range, 'a', '@') AS replace_a,   		  -- Replaces entire string at a time. Returns string if no match found
	REPLACE(mountain_range, 'A', '$') AS "replace_A"
	-- TRANSLATE(mountain_range, 'aA', '@$') AS replace_a,    -- Replaces character one-to-one basis. Returns null if no match found
FROM mountains;

---

SELECT
	capital,
	TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou') AS translated_name
FROM
	countries;

---

SELECT
	continent_name,
	TRIM(continent_name) AS "trim"          -- TRIM can be LTRIM(Left Trim) and RTRIM(Right Trim)
FROM continents;

---

SELECT
	LTRIM(peak_name, 'M') AS left_trim,
	RTRIM(peak_name, 'm') AS right_trim
FROM peaks;

---

SELECT
	concat(m.mountain_range, ' ', p.peak_name) AS mountain_information,
 -- LENGTH(mountain_information) AS character_length             Can't use new column name from withn SELECT
	LENGTH(concat(m.mountain_range, ' ', p.peak_name)) AS character_length,   --LENGTH or CHAR_LENGTH
	BIT_LENGTH(concat(m.mountain_range, ' ', p.peak_name)) AS bits_of_a_tring
FROM mountains AS m
JOIN peaks AS p ON m."id" = p.mountain_id;

---

SELECT
	population,
	LENGTH(CAST(population AS VARCHAR)) AS "length"
 -- LENGTH(population::VARCHAR) AS "length"       another way to cast
FROM countries;

---

SELECT
	peak_name,
	LEFT(peak_name, 4) AS positive_left,         -- positive number first 4 characters, negative number every character but the last 4
	LEFT(peak_name, -4) AS negative_left
FROM peaks;

---

SELECT
	peak_name,
	RIGHT(peak_name, 4) AS positive_right,        -- positive number last 4 characters, negative number every character but the first 4
	RIGHT(peak_name, -4) AS negative_right
FROM peaks;

---

UPDATE countries
SET iso_code = UPPER(LEFT(country_name, 3))
WHERE iso_code is NULL;

---

UPDATE countries
SET country_code = LOWER(REVERSE(country_code));

---

SELECT
	concat(elevation, ' --->> ', peak_name) AS "Elevation --->> Peak Name"
 -- concat(elevation, ' ', REPEAT('-', 3), REPEAT('>', 2), ' ', peak_name) AS "Elevation --->> Peak Name"  With repeat, just for exercise
FROM peaks
WHERE elevation >= 4884;

---

CREATE TABLE bookings_calculation AS                          -- Shorter way
SELECT
	booked_for,
	CAST(booked_for * 50 AS NUMERIC) AS multiplication,
	CAST(booked_for % 50 AS NUMERIC) AS modulo
FROM bookings
WHERE apartment_id = 93;

-- ALTER TABLE bookings_calculation                              Longer way
-- ADD COLUMN multiplication NUMERIC,
-- ADD COLUMN modulo NUMERIC;

-- UPDATE bookings_calculation
-- SET multiplication = booked_for * 50;

-- UPDATE bookings_calculation
-- SET modulo = booked_for % 50;

---

SELECT
	latitude,
	ROUND(latitude, 2),
	TRUNC(latitude, 2)
FROM apartments;

---

SELECT
	longitude,
	ABS(longitude)
FROM apartments;

---

ALTER Table
	bookings
ADD COLUMN
	billing_day TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

SELECT
	to_char(billing_day, 'DD "Day" MM "Month" YYYY "Year" HH24:MI:SS') AS "Billing Day"
FROM
	bookings;

---

SELECT
	EXTRACT('year' FROM booked_at) AS "YEAR",
	EXTRACT('month' FROM booked_at) AS "MONTH",
	EXTRACT('day' FROM booked_at) AS "DAY",
	EXTRACT('hour' FROM booked_at AT TIME ZONE 'UTC') AS "HOUR",
	EXTRACT('minute' FROM booked_at) AS "MINUTE",
	CEIL(EXTRACT('second' FROM booked_at)) AS "SECOND"
FROM bookings;

---

SELECT
	user_id,
	AGE(starts_at, booked_at) AS early_birds
FROM
	bookings
WHERE
	starts_at - booked_at >= '10 MONTHS';

---

SELECT
	companion_full_name,
	email
FROM
	users
WHERE
	-- LOWER(companion_full_name) LIKE '%and%'
	LOWER(companion_full_name) ILIKE '%aNd%'     -- ILIKE = case insensitive
		AND
	email NOT LIKE '%@gmail';

---

SELECT
	LEFT(first_name, 2) AS initials,
	COUNT('initials') AS user_count
FROM
	users
GROUP BY
	initials
ORDER BY
	user_count DESC,
	initials;

---

SELECT
	SUM(booked_for)
FROM
	bookings
WHERE
	apartment_id = 90;

---

SELECT
	AVG(multiplication) AS average_value
FROM
	bookings_calculation;

----------------------------------------------------------------------------------------------------------------------------------------

SELECT
	department_id,
	COUNT('department_id') AS employee_count          -- We use '', when we order by the same thing
FROM
	employees
GROUP BY
	department_id
ORDER BY
	department_id;

---

SELECT
	department_id,                                -- We can use SUM, MAX, MIN, AVG and so on
	COUNT(salary) AS employee_count
FROM
	employees
GROUP BY
	department_id
ORDER BY
	department_id;

---

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

---

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

----------------------------------------------------------------------------------------------------------------------------------------

SELECT
	COUNT(*)
FROM
	wizard_deposits;

---

SELECT
	SUM(deposit_amount) AS total_amount
FROM
	wizard_deposits;

---

SELECT
	ROUND(AVG(magic_wand_size), 3)
FROM
	wizard_deposits;

---

SELECT
	MIN(deposit_charge)
FROM
	wizard_deposits;

---

SELECT
	MAX(age)
FROM
	wizard_deposits;

---

SELECT
	deposit_group,
	SUM(deposit_interest) AS deposit_interest
FROM
	wizard_deposits
GROUP BY
	deposit_group
ORDER BY
	deposit_interest DESC;

---

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

---

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

---

SELECT
	last_name,
	COUNT(notes) AS notes_with_dumbledore
FROM
	wizard_deposits
WHERE
	notes LIKE '%Dumbledore%'
GROUP BY
	last_name;

---

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

---

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

---

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

---

SELECT
    SUM(CASE WHEN department_id = 1 THEN 1 ELSE 0 END) AS Engineering,
    SUM(CASE WHEN department_id = 2 THEN 1 ELSE 0 END) AS Tool_Design,
    SUM(CASE WHEN department_id = 3 THEN 1 ELSE 0 END) AS Sales,
    SUM(CASE WHEN department_id = 4 THEN 1 ELSE 0 END) AS Marketing,
    SUM(CASE WHEN department_id = 5 THEN 1 ELSE 0 END) AS Purchasing,
    SUM(CASE WHEN department_id = 6 THEN 1 ELSE 0 END) AS Research_and_Development,
    SUM(CASE WHEN department_id = 7 THEN 1 ELSE 0 END) AS Production
FROM employees;

---

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

---

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

---

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

---

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

---

-- SELECT --> FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY -->> LIMIT

---

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

---

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

---

SELECT
    d.*,   -- or just '*'                                       -- JOIN everything from two or more TABLES
    e.*
FROM
    departments d
JOIN
    employees e ON d.id = e.department_id;

---------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE mountains(
	id serial PRIMARY KEY,
	name varchar(50)
);

CREATE TABLE peaks(                              -- FOREIGN KEY implementation
	id serial PRIMARY KEY,
	name VARCHAR(50),
	mountain_id int,
 -- mountain_id int REFERENCES mountains(id)       Short way without name
	CONSTRAINT fk_peaks_mountains			    -- Longer way with constraint name
		FOREIGN KEY(mountain_id)
			REFERENCES mountains(id)
);

---

SELECT
	v.driver_id,
	v.vehicle_type,
	concat(c.first_name, ' ', c.last_name) AS driver_name
FROM vehicles AS v
JOIN campers AS c
ON c.id = v.driver_id;

---

SELECT
	r.start_point,
	r.end_point,
	c.id,
	concat(c.first_name, ' ', c.last_name) AS leader_name
FROM routes as r
JOIN campers as c
ON c.id = r.leader_id;

---

CREATE TABLE mountains(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE peaks(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(50),
	mountain_id int,
	CONSTRAINT fk_mountain_id
		FOREIGN KEY(mountain_id)
			REFERENCES mountains(id)
				ON DELETE CASCADE
);

---------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE products(
	product_name VARCHAR(100)
);

INSERT INTO
	products
VALUES
	('Broccoli'),
	('Shampoo'),
	('Toothpaste'),
	('Candy');

ALTER TABLE products
ADD COLUMN
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY;

---

ALTER TABLE
	products
DROP CONSTRAINT
	products_pkey;

---

CREATE TABLE passports(
	id INT GENERATED ALWAYS AS IDENTITY (START WITH 100 INCREMENT 1) PRIMARY KEY,
	nationality VARCHAR(50)
);

INSERT INTO passports (nationality)
VALUES
	('N34FG21B'),
	('K65LO4R7'),
	('ZE657QP2');

CREATE TABLE people(
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	salary NUMERIC (10, 2),
	passport_id INT,

	CONSTRAINT fk_people_passports
	FOREIGN KEY (passport_id)
	REFERENCES passports(id)
);

INSERT INTO people (first_name, salary, passport_id)
VALUES
	('Roberto', 43300.0000, 101),
	('Tom', 56100.0000, 102),
	('Yana', 60200.0000, 100)

---

CREATE TABLE manufacturers(
	id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE models(
	id INT GENERATED ALWAYS AS IDENTITY (START WITH 1000 INCREMENT 1) PRIMARY KEY,
	model_name VARCHAR(50),
	manufacturer_id INT,

	CONSTRAINT fk_models_manufacturers
	FOREIGN KEY (manufacturer_id)
	REFERENCES manufacturers(id)
);

CREATE TABLE production_years(
	id SERIAL PRIMARY KEY,
	established_on DATE,
	manufacturer_id INT,

	CONSTRAINT fk_production_years_manufacturers
	FOREIGN KEY (manufacturer_id)
	REFERENCES manufacturers(id)
);

INSERT INTO
	manufacturers(name)
VALUES
	('BMW'),
	('Tesla'),
	('Lada');

INSERT INTO
	models(model_name, manufacturer_id)
VALUES
	('X1', 1),
	('i6', 1),
	('Model S', 2),
	('Model X', 2),
	('Model 3', 2),
	('Nova', 3);

INSERT INTO
	production_years(established_on, manufacturer_id)
VALUES
	('1916-03-01', 1),
	('2003-01-01', 2),
	('1966-05-01', 3);

---

CREATE TABLE customers(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(50),
	date DATE
);

CREATE TABLE photos(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	url VARCHAR(50),
	place VARCHAR(50),
	customer_id INT,

	CONSTRAINT fk_photos_customers
	FOREIGN KEY (customer_id)
	REFERENCES customers(id)
);

INSERT INTO
	customers(name, date)
VALUES
	('Bella', '2022-03-25'),
	('Philip', '2022-07-05');

INSERT INTO
	photos(url, place, customer_id)
VALUES
	('bella_1111.com', 'National Theatre', 1),
	('bella_1112.com', 'Largo', 1),
	('bella_1113.com', 'The View Restaurant', 1),
	('philip_1121.com', 'Old Town', 2),
	('philip_1122.com', 'Rowing Canal', 2),
	('philip_1123.com', 'Roman Theater', 2);

---

CREATE TABLE students (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	student_name VARCHAR(50)
);

CREATE TABLE exams (
	id INT GENERATED ALWAYS AS IDENTITY (START WITH 101 INCREMENT 1) PRIMARY KEY,
	exam_name VARCHAR(50)
);

CREATE TABLE study_halls (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	study_hall_name VARCHAR(50),
	exam_id INT,

	CONSTRAINT fk_study_halls_exams
	FOREIGN KEY (exam_id)
	REFERENCES exams(id)
);

CREATE TABLE students_exams (
	student_id INT,
	exam_id INT,

	CONSTRAINT pk_student_exam
	PRIMARY KEY (student_id, exam_id),

	CONSTRAINT fk_students_exams_students
	FOREIGN KEY (student_id)
	REFERENCES students(id),

	CONSTRAINT pk_students_exams_exams
	FOREIGN KEY (exam_id)
	REFERENCES exams(id)
);

INSERT INTO
	students(student_name)
VALUES
	('Mila'),
	('Toni'),
	('Ron');

INSERT INTO
	exams(exam_name)
VALUES
	('Python Advanced'),
	('Python OOP'),
	('PostgreSQL');

INSERT INTO
	study_halls(study_hall_name, exam_id)
VALUES
	('Open Source Hall', 102),
	('Inspiration Hall', 101),
	('Creative Hall', 103),
	('Masterclass Hall', 103),
	('Information Security Hall', 103);;

INSERT INTO
	students_exams
VALUES
	(1, 101),
	(1, 102),
	(2, 101),
	(3, 103),
	(2, 102),
	(2, 103);

---

CREATE TABLE item_types (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	item_type_name VARCHAR(50)
);

CREATE TABLE items (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	item_name VARCHAR(50),
	item_type_id INT,

	CONSTRAINT fk_items_item_types
	FOREIGN KEY (item_type_id)
	REFERENCES item_types(id)
);

CREATE TABLE cities (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	city_name VARCHAR(50)
);

CREATE TABLE customers (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_name VARCHAR(50),
	birthday DATE,
	city_id INT,

	CONSTRAINT fk_customers_cities
	FOREIGN KEY (city_id)
	REFERENCES cities(id)
);

CREATE TABLE orders (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_id INT,

	CONSTRAINT fk_orders_customers
	FOREIGN KEY (customer_id)
	REFERENCES customers(id)
);

CREATE TABLE order_items (
	order_id INT,
	item_id INT,

	CONSTRAINT pk_orders_items
	PRIMARY KEY (order_id, item_id),

	CONSTRAINT fk_order_items_orders
	FOREIGN KEY (order_id)
	REFERENCES orders(id),

	CONSTRAINT fk_order_items_items
	FOREIGN KEY (item_id)
	REFERENCES items(id)
);

---

ALTER TABLE
	countries
ADD CONSTRAINT
	fk_countries_continents
FOREIGN KEY
	(continent_code)
REFERENCES
	continents(continent_code)
ON DELETE CASCADE,

ADD CONSTRAINT
	fk_countries_currencies
FOREIGN KEY
	(currency_code)
REFERENCES
	currencies(currency_code)
ON DELETE CASCADE;

---

ALTER TABLE
	countries_rivers

ADD CONSTRAINT
	pk_countries_rivers
PRIMARY KEY
	(river_id, country_code),

ADD CONSTRAINT
	fk_countries_rivers_rivers
FOREIGN KEY
	(river_id)
REFERENCES
	rivers(id)
ON UPDATE CASCADE,

ADD CONSTRAINT
	fk_countries_rivers_countries
FOREIGN KEY
	(country_code)
REFERENCES
	countries(country_code)
ON UPDATE CASCADE;

---

CREATE TABLE customers (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	customer_name VARCHAR(50)
);

CREATE TABLE contacts (
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	contact_name VARCHAR(50),
	phone VARCHAR(50),
	email VARCHAR(50),
	customer_id INT,

	CONSTRAINT fk_customers_contacts
	FOREIGN KEY (customer_id)
	REFERENCES customers(id)
	ON DELETE SET NULL
	ON UPDATE CASCADE
);

INSERT INTO
	customers(customer_name)
VALUES
	('BlueBird Inc'),
	('Dolphin LLC');

INSERT INTO
	contacts(customer_id, contact_name, phone, email)
VALUES
	(1,'John Doe','(408)-111-1234','john.doe@bluebird.dev'),
    (1,'Jane Doe','(408)-111-1235','jane.doe@bluebird.dev'),
    (2,'David Wright','(408)-222-1234','david.wright@dolphin.dev');

DELETE FROM
	customers
WHERE
	id = 1;

---

SELECT
	m.mountain_range,
	p.peak_name,
	p.elevation
FROM
	mountains AS m
JOIN
	peaks AS p
ON
	m.id = p.mountain_id
WHERE
	TRIM(m.mountain_range) = 'Rila'
ORDER BY
	elevation DESC;

---

SELECT
	COUNT(*)
FROM
	countries
LEFT JOIN
	countries_rivers
USING                                -- USING - Can be used instead of ON when the JOIN is based on columns with the same name from two or more tables
	(country_code)
-- ON
-- 	country_code = country_code
WHERE
	river_id IS NULL;

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

------------------------------------------------------------------------------------------------------------------------

SELECT
    CONCAT(address, ' ', address_2) AS apartment_address,
    booked_for AS nights
FROM
    apartments AS a
JOIN
    bookings AS b
    USING (booking_id)
ORDER BY
    a.apartment_id;

---

SELECT
    name,
    country,
    booked_at::DATE   -- CAST
FROM
    apartments
LEFT JOIN
    bookings
    USING (booking_id)
LIMIT
    10;

---

SELECT
    booking_id,
    starts_at::DATE,   -- CAST
    apartment_id,
    CONCAT(first_name, ' ', last_name) AS customer_name
FROM
    bookings
RIGHT JOIN
    customers
    USING(customer_id)
ORDER BY
    customer_name
LIMIT
    10;

---

SELECT
    b.booking_id,
    a.name AS apartment_owner,
    a.apartment_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name
FROM
    customers AS c
FULL JOIN
    bookings AS b
    USING (customer_id)
FULL JOIN
    apartments AS a
    USING (booking_id)
ORDER BY
 -- 1, 2, 4                       Can use the position in the SELECT in ORDER BY
    booking_id, apartment_owner, customer_name;        

---

SELECT
	b.booking_id,
	c.first_name AS customer_name
FROM
	bookings AS b
CROSS JOIN
	customers AS c
-- FROM                            Both do the same thing and that is a CROSS JOIN
-- 	bookings AS b,
-- 	customers AS c
ORDER BY
	customer_name;

---

SELECT
	b.booking_id,
	b.apartment_id,
	c.companion_full_name
FROM 
	bookings AS b
JOIN
	customers AS c
	USING (customer_id)
WHERE
	b.apartment_id IS NULL;

---

SELECT
	b.apartment_id,
	b.booked_for,
	c.first_name,
	c.country
FROM 
	bookings AS b
JOIN
	customers AS c
	USING (customer_id)
WHERE
	c.job_type = 'Lead';

---

SELECT
	count(*)
FROM 
	bookings AS b
JOIN
	customers AS c
	USING (customer_id)
WHERE
	c.last_name = 'Hahn';

---

SELECT
	a.name,
	SUM(b.booked_for)
FROM
	apartments AS a
JOIN
	bookings AS b
	USING (apartment_id)
GROUP BY
	a.name
ORDER BY
	a.name;

---

SELECT
	a.country,
	COUNT(*) AS booking_count
FROM
	bookings AS b
JOIN
	apartments AS a
USING
	(apartment_id)
WHERE
	b.booked_at > '2021-05-18 07:52:09.904+03'
		AND
	b.booked_at < '2021-09-17 19:48:02.147+03' 
GROUP BY
	a.country
ORDER BY
	booking_count DESC;

---

SELECT
    mc.country_code,
    m.mountain_range,
    p.peak_name,
    p.elevation
FROM
    mountains AS m
JOIN
    peaks AS p
    ON
        m.id = p.mountain_id
JOIN
    mountains_countries AS mc
    ON
        mc.mountain_id = m.id
WHERE
    mc.country_code = 'BG'
        AND
    p.elevation > 2835
ORDER BY
    p.elevation DESC;

---

SELECT
    mc.country_code,
    COUNT(*) AS mountain_range_count
FROM
    mountains AS m
JOIN
    mountains_countries AS mc
ON
    m.id = mc.mountain_id
WHERE
    mc.country_code IN ('BG', 'US', 'RU')
GROUP BY
    mc.country_code
ORDER BY
    mountain_range_count DESC;

---

SELECT
    c.country_name,
    r.river_name
FROM
    countries AS c
LEFT JOIN
    countries_rivers AS cr
    USING (country_code)
LEFT JOIN
    rivers AS r
    ON
        cr.river_id = r.id
WHERE
    c.continent_code = 'AF'
ORDER BY
    c.country_name
LIMIT
    5;

---

SELECT
    MIN(avg_area) AS min_average_area
FROM (
    SELECT
        AVG(area_in_sq_km) AS avg_area
    FROM
        countries
    GROUP BY
        continent_code
    ) AS min_average_area;

---

SELECT
    COUNT(*)
FROM
    countries AS c
LEFT JOIN
    mountains_countries AS mc
    USING (country_code)
WHERE
    mc.mountain_id IS NULL;

---

CREATE TABLE monasteries(
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    monastery_name VARCHAR(255),
    country_code CHAR(2)
);

INSERT INTO
    monasteries (monastery_name, country_code)
VALUES
    ('Rila Monastery "St. Ivan of Rila"', 'BG'),
    ('Bachkovo Monastery "Virgin Mary"', 'BG'),
    ('Troyan Monastery "Holy Mother''s Assumption"', 'BG'),
    ('Kopan Monastery', 'NP'),
    ('Thrangu Tashi Yangtse Monastery', 'NP'),
    ('Shechen Tennyi Dargyeling Monastery', 'NP'),
    ('Benchen Monastery', 'NP'),
    ('Southern Shaolin Monastery', 'CN'),
    ('Dabei Monastery', 'CN'),
    ('Wa Sau Toi', 'CN'),
    ('Lhunshigyia Monastery', 'CN'),
    ('Rakya Monastery', 'CN'),
    ('Monasteries of Meteora', 'GR'),
    ('The Holy Monastery of Stavronikita', 'GR'),
    ('Taung Kalat Monastery', 'MM'),
    ('Pa-Auk Forest Monastery', 'MM'),
    ('Taktsang Palphug Monastery', 'BT'),
    ('Sümela Monastery', 'TR');

ALTER TABLE countries
ADD COLUMN
    three_rivers BOOLEAN DEFAULT FALSE;

UPDATE
    countries
SET three_rivers = (
    SELECT
        COUNT(*) >= 3
    FROM
        countries_rivers AS cr
    WHERE
        cr.country_code = countries.country_code
);

SELECT
	m.monastery_name,
	c.country_name
FROM
	monasteries AS m
JOIN
	countries AS c
USING
	(country_code)
WHERE
	NOT three_rivers
ORDER BY
	monastery_name;

---

UPDATE countries
SET
    country_name = 'Burma'
WHERE
    country_name = 'Myanmar';

INSERT INTO
    monasteries (monastery_name, country_code)
VALUES
    ('Hanga Abbey', 'TZ'),
    ('Myin-Tin-Daik', 'MM');

SELECT
    con.continent_name,
    cou.country_name,
    COUNT(*) AS num_monasteries
FROM
    continents AS con
JOIN
    countries AS cou
    USING (continent_code)              --- Not correct, needs more work
JOIN
    monasteries AS m
    USING (country_code)
WHERE
    NOT cou.three_rivers
GROUP BY
    con.continent_name, cou.country_name
ORDER BY
    num_monasteries DESC,
    cou.country_name;

---

SELECT
    tablename,
    indexname,
    indexdef
FROM
    pg_indexes
WHERE
    schemaname = 'public'
ORDER BY
    tablename,
    indexname;

---

CREATE VIEW continent_currency_usage
    AS
SELECT                                --- Not correct, needs more work
    ru.continent_code,
    ru.currency_code,
    ru.currency_usage
FROM (
    SELECT
        ct.continent_code,
        ct.currency_code,
        ct.currency_usage,
        DENSE_RANK() OVER (PARTITION BY ct.continent_code ORDER BY currency_usage DESC) AS ranked_usage
    FROM (
        SELECT
            continent_code,                   --- Ranking
            currency_code,
            COUNT(currency_code) AS currency_usage
        FROM
            countries
        GROUP BY
            continent_code,
            currency_code
        HAVING
            COUNT(*) > 1
        ORDER BY
            continent_code
    ) AS ct
) AS ru
WHERE
    ru.ranked_usage = 1
ORDER BY
    ru.currency_usage DESC,
	ru.continent_code,
	ru.currency_code;

---

WITH row_number AS (
    SELECT
        c.country_name,
        p.peak_name,
        p.elevation,
        m.mountain_range,
        ROW_NUMBER() OVER (PARTITION BY c.country_name ORDER BY p.elevation DESC) AS rn
    FROM
        countries AS c
    JOIN
        mountains_countries AS mc
        USING (country_code)
    JOIN
        mountains AS m
        ON mc.mountain_id = m.id
    JOIN
        peaks AS p
        ON m.id = p.mountain_id
)
SELECT
    country_name,
    COALESCE(peak_name, '(no highest peak)') AS highest_peak_name,
    COALESCE(elevation, 0) AS highest_peak_elevation,
    CASE
        WHEN peak_name IS NOT NULL THEN mountain_range
        ELSE '(no mountain)'
    END AS mountain
FROM (
    SELECT
        c.country_name,
        r.peak_name,
        r.elevation,
        r.mountain_range
    FROM
        countries AS c
    LEFT JOIN
        row_number r
        ON c.country_name = r.country_name AND r.rn = 1
) AS final_result
ORDER BY
    country_name,
    elevation DESC;

---

-- WITH row_number AS (
--     SELECT
--         c.country_name,
--         p.peak_name AS highest_peak_name,
--         p.elevation,
--         ROW_NUMBER() OVER (PARTITION BY c.country_name ORDER BY p.elevation DESC) AS highest_peak_rank,
--         m.mountain_range AS mountain
--     FROM
--         peaks AS p
--     RIGHT JOIN
--         mountains_countries AS mc
--     USING
--         (mountain_id)
--     FULL JOIN
--         countries AS c
--     USING
--         (country_code)
--     LEFT JOIN
--         mountains AS m
--     ON
--         mc.mountain_id = m.id
-- )
--
-- SELECT
--     country_name,
--     COALESCE(highest_peak_name,'(no highest peak)') AS highest_peak_name,
--     COALESCE(elevation, 0) AS highest_peak_elevation,
--     CASE
--         WHEN highest_peak_name IS NOT NULL THEN mountain
--         ELSE ('(no mountain)')
--     END
-- FROM
--     row_number
-- WHERE
--     highest_peak_rank = 1
-- ORDER BY
--     country_name,
--     highest_peak_elevation;

------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT AS
    $$
    DECLARE
        count int;
    BEGIN
        SELECT INTO count
            COUNT(*)
        FROM
            employees
        JOIN
            addresses
            USING (address_id)
        JOIN
            towns
            USING (town_id)
        WHERE
            towns.name = town_name;
        RETURN count;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_increase_salaries(department_name varchar)
AS
    $$
    BEGIN
        UPDATE
            employees
        SET
            salary = salary * 1.05
        WHERE
            department_id = (
                SELECT
                    department_id
                FROM
                    departments
                WHERE
                    name = department_name
                );
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_increase_salary_by_id(id INT)
AS
    $$
    BEGIN
        IF (SELECT salary FROM employees WHERE employee_id = id) IS NULL THEN
            RETURN;
        END IF;
        UPDATE
            employees
        SET
            salary = salary * 1.05
        WHERE
            employee_id = id;
        COMMIT;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE TABLE deleted_employees(
    employee_id SERIAL PRIMARY KEY ,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    middle_name VARCHAR(20),
    job_title VARCHAR(50),
    department_id INT,
    salary NUMERIC(19, 4)
);

CREATE OR REPLACE FUNCTION fired_employees()
RETURNS TRIGGER
AS
    $$
    BEGIN
        INSERT INTO
            deleted_employees(first_name, last_name, middle_name, job_title, department_id, salary)
        VALUES (
            old.first_name,
            old.last_name,
            old.middle_name,
            old.job_title,
            old.department_id,
            old.salary
        );
        RETURN new;
    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER backup_employees
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE PROCEDURE fired_employees();

------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_full_name(
    first_name varchar, last_name varchar
)RETURNS VARCHAR
AS
    $$
    BEGIN
        IF first_name IS NULL AND last_name IS NULL THEN
            RETURN NULL;
        ELSIF last_name IS NULL THEN
            RETURN initcap(first_name);
        ELSIF first_name IS NULL THEN
            RETURN initcap(last_name);
        ELSE
            RETURN concat(initcap(first_name), ' ', initcap(last_name));
        END IF;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_calculate_future_value(
    initial_sum NUMERIC,
    yearly_interest_rate NUMERIC,
    number_of_years INT
) RETURNS NUMERIC
AS
    $$
    BEGIN
        RETURN TRUNC(initial_sum * POWER(1 + yearly_interest_rate, number_of_years), 4);
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_is_word_comprised(
    set_letters VARCHAR,
    word VARCHAR
) RETURNS BOOLEAN
AS
    $$
    BEGIN
        RETURN TRIM(LOWER(word), LOWER(set_letters)) = '';
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_is_game_over(
    is_game_over BOOLEAN
) RETURNS TABLE(                                    -- RETURNS TABLE
    name VARCHAR(50),
    game_type_id INT,
    is_finished BOOLEAN
) AS
    $$
    BEGIN
        RETURN QUERY
        SELECT
            g.name,
            g.game_type_id,
            g.is_finished
        FROM
            games AS g
        WHERE
            g.is_finished = is_game_over;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_difficulty_level(
    level INT
) RETURNS VARCHAR
AS
    $$
    DECLARE
        diff_lvl VARCHAR;
    BEGIN
        IF level <= 40 THEN
            diff_lvl := 'Normal Difficulty';
        ELSIF level BETWEEN 41 AND 60 THEN
            diff_lvl :=  'Nightmare Difficulty';
        ELSIF level > 60 THEN
            diff_lvl :=  'Hell Difficulty';
        END IF;

        RETURN diff_lvl;
    END;
    $$
LANGUAGE plpgsql;

SELECT
    user_id,
    level,
    cash,
    fn_difficulty_level(level)
FROM
    users_games
ORDER BY
    user_id;

---

CREATE OR REPLACE FUNCTION fn_cash_in_users_games(
    game_name VARCHAR(50)
) RETURNS TABLE(
    total_cash NUMERIC
) AS
    $$
    BEGIN
        RETURN QUERY
        WITH ranked_games AS (
            SELECT
                cash,
                ROW_NUMBER() OVER (ORDER BY cash DESC) AS row_num
            FROM
                users_games AS ug
            JOIN
                games AS g
                ON ug.game_id = g.id
            WHERE
                g.name = game_name
        )

        SELECT
            ROUND(SUM(cash), 2) AS total_cash
        FROM
            ranked_games AS rg
        WHERE
            rg.row_num % 2 <> 0;
    END;
    $$
LANGUAGE plpgsql

---

CREATE OR REPLACE PROCEDURE sp_retrieving_holders_with_balance_higher_than(
    searched_balance NUMERIC
)
AS
    $$
    DECLARE
        holder_info RECORD;
    BEGIN
        FOR holder_info IN
            SELECT
                concat(ah.first_name, ' ', ah.last_name) AS full_name,
                SUM(a.balance) AS total_balance
            FROM
                account_holders AS ah
            JOIN
                accounts AS a
                ON ah.id = a.account_holder_id
            GROUP BY
                full_name
            HAVING
                SUM(a.balance) > searched_balance
            ORDER BY
                full_name
        LOOP
            RAISE NOTICE '% - %', holder_info.full_name, holder_info.total_balance;
        END LOOP;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_deposit_money(
    account_id INT,
    money_amount NUMERIC(4)
)
AS
    $$
    BEGIN
        UPDATE
            accounts
        SET
            balance = balance + money_amount
        WHERE
            id = account_id;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_withdraw_money(
    account_id INT,
    money_amount NUMERIC(4)
)
AS
    $$
    DECLARE
        money_balance NUMERIC;
    BEGIN
        money_balance := (SELECT balance FROM accounts WHERE id = account_id);

        IF money_amount <= money_balance THEN
            UPDATE
                accounts
            SET
                balance = balance - money_amount
            WHERE
                id =  account_id;
        END IF;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_transfer_money(
    sender_id INT,
    receiver_id INT,
    amount NUMERIC(20, 4)
)
AS
    $$
        DECLARE
            money_left NUMERIC;
        BEGIN
            CALL sp_withdraw_money(sender_id, amount);
            CALL sp_deposit_money(receiver_id, amount);

            money_left = (SELECT balance FROM accounts WHERE id = sender_id);

            IF money_left < 0 THEN
                ROLLBACK;
            END IF;
        END;
    $$
LANGUAGE plpgsql;

---

DROP PROCEDURE sp_retrieving_holders_with_balance_higher_than

---

CREATE TABLE IF NOT EXISTS logs(
    id SERIAL PRIMARY KEY,
    account_id INT,
    old_sum NUMERIC,
    new_sum NUMERIC
);

CREATE OR REPLACE FUNCTION trigger_fn_insert_new_entry_into_logs()
RETURNS TRIGGER
AS
    $$
    BEGIN
        INSERT INTO
            logs(account_id, old_sum, new_sum)
        VALUES (
            old.id,
            old.balance,
            new.balance
        );
        RETURN new;
    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_account_balance_change
AFTER UPDATE ON accounts
FOR EACH ROW
-- WHEN
-- 	(NEW.balance <> OLD.balance)
EXECUTE PROCEDURE trigger_fn_insert_new_entry_into_logs();

---

CREATE TABLE IF NOT EXISTS notification_emails(
    id SERIAL PRIMARY KEY,
    recipient_id INT,
    subject VARCHAR,
    body TEXT
);

CREATE OR REPLACE FUNCTION trigger_fn_send_email_on_balance_change()
RETURNS TRIGGER
AS
    $$
    BEGIN
        INSERT INTO
            notification_emails(recipient_id, subject, body)
        VALUES (
            NEW.account_id,
            concat_ws(' ', 'Balance change for account: ', NEW.account_id),
            concat_ws(' ', 'On ', NOW(), ' your balance was changed from ', NEW.old_sum, NEW.new_sum)
        );
        RETURN new;
    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_send_email_on_balance_change
AFTER UPDATE ON logs
FOR EACH ROW
-- WHEN
-- 	(OLD.new_sum <> NEW.new_sum)
EXECUTE PROCEDURE trigger_fn_send_email_on_balance_change();

------------------------------------------------------------------------------------------------------------------------

-- SELECT --> FROM --> WHERE --> GROUP BY --> HAVING --> ORDER BY -->> LIMIT




























