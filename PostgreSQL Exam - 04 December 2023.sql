---1.1---

CREATE TABLE countries(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE customers(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1),
    age INT NOT NULL,
    phone_number CHAR(10) NOT NULL,
    country_id INT REFERENCES countries ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    CONSTRAINT gender_check CHECK (gender IN ('M', 'F') OR gender IS NULL),
    CONSTRAINT age_check CHECK (age > 0)
);

CREATE TABLE products(
    id SERIAL PRIMARY KEY,
    name VARCHAR(25) NOT NULL,
    description VARCHAR(250),
    recipe TEXT,
    price NUMERIC(10, 2) NOT NULL,
    CONSTRAINT price_check CHECK (price > 0)
);

CREATE TABLE feedbacks(
    id SERIAL PRIMARY KEY,
    description VARCHAR(255),
    rate NUMERIC(4, 2),
    product_id INT REFERENCES products ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    customer_id INT REFERENCES customers ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    CONSTRAINT rate_check CHECK (rate BETWEEN 0 AND 10)
);

CREATE TABLE distributors(
    id SERIAL PRIMARY KEY,
    name VARCHAR(25) UNIQUE NOT NULL,
    address VARCHAR(30) NOT NULL,
    summary VARCHAR(200) NOT NULL,
    country_id INT REFERENCES countries ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE ingredients(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    description VARCHAR(200),
    country_id INT REFERENCES countries ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    distributor_id INT REFERENCES distributors ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE products_ingredients(
    product_id INT REFERENCES products ON DELETE CASCADE ON UPDATE CASCADE,
    ingredient_id INT REFERENCES ingredients ON DELETE CASCADE ON UPDATE CASCADE
);

---2.2---

CREATE TABLE gift_recipients(
    id SERIAL PRIMARY KEY,
    name VARCHAR(75),
    country_id INT NOT NULL ,
    gift_sent BOOLEAN DEFAULT FALSE
);

INSERT INTO
    gift_recipients (name, country_id, gift_sent)
SELECT
    concat(first_name, ' ', last_name),
    country_id,
    CASE
        WHEN country_id IN (7, 8, 14, 17, 26) THEN TRUE
        ELSE FALSE
    END
FROM
    customers;

---2.3---

UPDATE
    products
SET
    price = price * 1.10
WHERE
    id IN (
    SELECT
        product_id
    FROM
        feedbacks
    WHERE
        rate > 8
);

---2.4---

DELETE FROM distributors
WHERE
    name LIKE 'L%';

---3.5---

SELECT
    name,
    recipe,
    price
FROM
    products
WHERE
    price BETWEEN 10 AND 20
ORDER BY
    price DESC;

---3.6---

SELECT
    f.product_id,
    f.rate,
    f.description,
    f.customer_id,
    c.age,
    c.gender
FROM
    customers AS c
JOIN
    feedbacks AS f
    ON c.id = f.customer_id
WHERE
    f.rate < 5.0
        AND
    c.gender = 'F'
        AND
    c.age > 30
ORDER BY
    f.product_id DESC;

---3.7---

SELECT
    p.name AS product_name,
    ROUND(AVG(p.price), 2) AS average_price,
    COUNT(f.rate) AS total_feedbacks
FROM
    products AS p
JOIN
    feedbacks AS f
    ON p.id = f.product_id
WHERE
    p.price > 15
GROUP BY
    p.name
HAVING
    COUNT(f.rate) > 1
ORDER BY
    total_feedbacks,
    AVG(p.price) DESC;

---3.8---

SELECT
    i.name AS ingredient_name,
    p.name AS product_name,
    d.name AS distributor_name
FROM
    products AS p
JOIN
    products_ingredients AS pi
    ON p.id = pi.product_id
JOIN
    ingredients AS i
    ON pi.ingredient_id = i.id
JOIN
    distributors AS d
    ON i.distributor_id = d.id
WHERE
    i.name ILIKE '%Mustard%'
        AND
    d.country_id = 16
ORDER BY
    product_name;

---3.9---

SELECT
    d.name AS distributor_name,
    i.name AS ingredient_name,
    p.name AS product_name,
    AVG(f.rate) AS average_rate
FROM
    products AS p
JOIN
    products_ingredients AS pi
    ON p.id = pi.product_id
JOIN
    ingredients AS i
    ON pi.ingredient_id = i.id
JOIN
    distributors AS d
    ON i.distributor_id = d.id
JOIN
    feedbacks AS f
    ON p.id = f.product_id
GROUP BY
    d.name,
    i.name,
    p.name
HAVING
    AVG(f.rate) BETWEEN 5 AND 8
ORDER BY
    distributor_name,
    ingredient_name,
    product_name;

---4.10---

CREATE OR REPLACE FUNCTION
    fn_feedbacks_for_product(product_name VARCHAR(25))
RETURNS TABLE (
    customer_id INT,
    customer_name VARCHAR(75),
    feedback_description VARCHAR(255),
    feedback_rate NUMERIC(4, 2)
) AS
    $$
    BEGIN
        RETURN QUERY
        SELECT
            c.id,
            c.first_name,
            f.description,
            f.rate
        FROM
            products AS p
        JOIN
            feedbacks AS f
            ON p.id = f.product_id
        JOIN
            customers AS c
            ON f.customer_id = c.id
        WHERE
            p.name = product_name
        ORDER BY
            c.id;
    END;
    $$
LANGUAGE plpgsql;

---4.11---

CREATE OR REPLACE PROCEDURE sp_customer_country_name(
    IN customer_full_name VARCHAR(50),
    OUT country_name VARCHAR(50)
) AS
    $$
    BEGIN
        SELECT
            ct.name INTO country_name
        FROM
            customers AS cm
        JOIN
            countries AS ct
            ON cm.country_id = ct.id
        WHERE
            concat(cm.first_name, ' ', cm.last_name) = customer_full_name;
    END;
    $$
LANGUAGE plpgsql;
