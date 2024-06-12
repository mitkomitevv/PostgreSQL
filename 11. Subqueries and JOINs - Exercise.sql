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
SELECT
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
            continent_code,
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