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