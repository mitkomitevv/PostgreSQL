---1---

CREATE TABLE addresses(
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE categories(
    id SERIAL PRIMARY KEY,
    name VARCHAR(10) NOT NULL
);

CREATE TABLE clients(
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(20) NOT NULL
);

CREATE TABLE drivers(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    age INT CHECK (age > 0) NOT NULL,
    rating NUMERIC(2) DEFAULT 5.5
);

CREATE TABLE cars(
    id SERIAL PRIMARY KEY,
    make VARCHAR(20) NOT NULL,
    model VARCHAR(20),
    year INT DEFAULT 0 CHECK (year > 0) NOT NULL,
    mileage INT DEFAULT 0 CHECK ( mileage > 0 ),
    condition CHAR(1) NOT NULL,
    category_id INT REFERENCES categories ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE courses(
    id SERIAL PRIMARY KEY,
    from_address_id INT REFERENCES addresses ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    start TIMESTAMP NOT NULL,
    bill NUMERIC(10, 2) DEFAULT 10 CHECK ( bill > 0 ),
    car_id INT REFERENCES cars ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    client_id INT REFERENCES clients ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE cars_drivers(
    car_id INT REFERENCES cars ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    driver_id INT REFERENCES drivers ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

---2---

INSERT INTO
    clients(full_name, phone_number)
SELECT
    concat(first_name, ' ', last_name) AS full_name,
    concat('(088) 9999', 2 * id)
FROM
    drivers
WHERE
    id BETWEEN 10 AND 20;

---3---

UPDATE
    cars
SET condition = 'C'
WHERE
    (mileage >= 800000 OR mileage IS NULL)
        AND
    year <= 2010
        AND
    make <> 'Mercedes-Benz';

---4---

DELETE FROM
    clients
WHERE
    LENGTH(full_name) > 3
		AND
	id NOT IN (
		SELECT
			client_id
		FROM
			courses
	);

---5---

SELECT
    make,
    model,
    condition
FROM
    cars;

---6---

SELECT
    d.first_name,
    d.last_name,
    c.make,
    c.model,
    c.mileage
FROM
    drivers AS d
JOIN
    cars_drivers AS cd
    ON d.id = cd.driver_id
JOIN
    cars AS c
    ON cd.car_id = c.id
WHERE
    c.mileage IS NOT NULL
ORDER BY
    c.mileage DESC,
    d.first_name;

---7---

SELECT
    ca.id AS car_id,
    ca.make,
    ca.mileage,
    COUNT(co.id) AS count_of_courses,
    ROUND(AVG(co.bill), 2) AS average_bill
FROM
    cars AS ca
LEFT JOIN
    courses AS co
    ON ca.id = co.car_id
GROUP BY
    ca.id,
    ca.make,
    ca.mileage
HAVING
    COUNT(co.id) <> 2
ORDER BY
    count_of_courses DESC,
    car_id;

---8---

SELECT
    cl.full_name,
    COUNT(co.car_id) AS count_of_cars,
    SUM(co.bill) AS total_sum
FROM
    clients AS cl
JOIN
    courses AS co
    ON cl.id = co.client_id
GROUP BY
    cl.full_name
HAVING
    cl.full_name LIKE '_a%'
        AND
    COUNT(co.car_id) > 1
ORDER BY
    cl.full_name;

---9---

SELECT
    a.name AS address,
    CASE
        WHEN
            extract('hour' FROM co.start) >=6 AND extract('hour' FROM co.start) <= v20 THEN 'Day'
         -- WHEN EXTRACT(HOUR FROM c.start) BETWEEN 6 AND 20 THEN 'Day'
        ELSE 'Night'
    END AS day_time,
    co.bill,
    cl.full_name,
    ca.make,
    ca.model,
    cat.name
FROM
    categories AS cat
JOIN
    cars AS ca
    ON cat.id = ca.category_id
JOIN
    courses AS co
    ON ca.id = co.car_id
JOIN
    addresses AS a
    ON co.from_address_id = a.id
JOIN
    clients AS cl
    ON co.client_id = cl.id
ORDER BY
    co.id;

---10---

CREATE OR REPLACE FUNCTION
    fn_courses_by_client(phone_num VARCHAR(20))
RETURNS INT
AS
    $$
    DECLARE
        count_of_courses INT;
    BEGIN
        SELECT
            COUNT(co.client_id)
        INTO
            count_of_courses
        FROM
            clients AS cl
        JOIN
            courses AS co
            ON cl.id = co.client_id
        WHERE
            cl.phone_number = phone_num;
        RETURN count_of_courses;
    END;
    $$
LANGUAGE plpgsql;

---11---

CREATE TABLE search_results (
    id SERIAL PRIMARY KEY,
    address_name VARCHAR(50),
    full_name VARCHAR(100),
    level_of_bill VARCHAR(20),
    make VARCHAR(30),
    condition CHAR(1),
    category_name VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE
    sp_courses_by_address(address_name VARCHAR(100))
AS
    $$
    BEGIN
        TRUNCATE search_results;

        INSERT INTO search_results(
            address_name,
            full_name,
            level_of_bill,
            make,
            condition,
            category_name
        )
        SELECT
            a.name AS address_name,
            cl.full_name,
            CASE
                WHEN co.bill <= 20 THEN 'Low'
                WHEN co.bill <= 30 THEN 'Medium'
                ELSE 'High'
            END AS level_of_bill,
            ca.make,
            ca.condition,
            cat.name AS category_name
        FROM
             addresses AS a
        JOIN
            courses AS co
            ON a.id = co.from_address_id
        JOIN
            clients AS cl
            ON co.client_id = cl.id
        JOIN
            cars AS ca
            ON co.car_id = ca.id
        JOIN
            categories AS cat
            ON ca.category_id = cat.id
        WHERE
            a.name = address_name
        ORDER BY
            ca.make,
            cl.full_name;
    END;
    $$
LANGUAGE plpgsql;
