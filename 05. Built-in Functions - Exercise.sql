CREATE VIEW view_river_info AS
SELECT
	concat_ws(' ', 'The river', river_name, 'flows into the', outflow, 'and is', "length", 'kilometers long.') AS "River Information"
FROM rivers
ORDER BY river_name;

-

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

-

ALTER TABLE countries
ADD COLUMN capital_code CHAR(2);

UPDATE countries
SET capital_code = LEFT(capital, 2);
-- SET capital_code = SUNSTRING(capital, 1, 2);             Something like slicing in Python

-

SELECT                                                   -- Something like slicing in Python
	SUBSTRING(description, 5)
FROM
	currencies;

-

SELECT
	SUBSTRING("River Information", '[0-9]{1,4)') AS river_length                  -- Regex solution easy. Only the first match
	-- (REGEXEXP_MATCHES("River Information", '[0-9]{1,4}')[1] AS river_length)      Regex solution hard. Multiple matches
FROM view_river_info

-

SELECT
	REPLACE(mountain_range, 'a', '@') AS replace_a,   		  -- Replaces entire string at a time. Returns string if no match found
	REPLACE(mountain_range, 'A', '$') AS "replace_A"
	-- TRANSLATE(mountain_range, 'aA', '@$') AS replace_a,    -- Replaces character one-to-one basis. Returns null if no match found
FROM mountains;

-

SELECT
	capital,
	TRANSLATE(capital, 'áãåçéíñóú', 'aaaceinou') AS translated_name
FROM
	countries;

-

SELECT
	continent_name,
	TRIM(continent_name) AS "trim"          -- TRIM can be LTRIM(Left Trim) and RTRIM(Right Trim)
FROM continents;

-

SELECT
	LTRIM(peak_name, 'M') AS left_trim,
	RTRIM(peak_name, 'm') AS right_trim
FROM peaks;

-

SELECT
	concat(m.mountain_range, ' ', p.peak_name) AS mountain_information,
 -- LENGTH(mountain_information) AS character_length             Can't use new column name from withn SELECT
	LENGTH(concat(m.mountain_range, ' ', p.peak_name)) AS character_length,   --LENGTH or CHAR_LENGTH
	BIT_LENGTH(concat(m.mountain_range, ' ', p.peak_name)) AS bits_of_a_tring
FROM mountains AS m
JOIN peaks AS p ON m."id" = p.mountain_id;

-

SELECT
	population,
	LENGTH(CAST(population AS VARCHAR)) AS "length"
 -- LENGTH(population::VARCHAR) AS "length"       another way to cast
FROM countries;

-

SELECT
	peak_name,
	LEFT(peak_name, 4) AS positive_left,         -- positive number first 4 characters, negative number every character but the last 4
	LEFT(peak_name, -4) AS negative_left
FROM peaks;

-

SELECT
	peak_name,
	RIGHT(peak_name, 4) AS positive_right,        -- positive number last 4 characters, negative number every character but the first 4
	RIGHT(peak_name, -4) AS negative_right
FROM peaks;

-

UPDATE countries
SET iso_code = UPPER(LEFT(country_name, 3))
WHERE iso_code is NULL;

-

UPDATE countries
SET country_code = LOWER(REVERSE(country_code));

-

SELECT
	concat(elevation, ' --->> ', peak_name) AS "Elevation --->> Peak Name"
 -- concat(elevation, ' ', REPEAT('-', 3), REPEAT('>', 2), ' ', peak_name) AS "Elevation --->> Peak Name"  With repeat, just for exercise
FROM peaks
WHERE elevation >= 4884;

-

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

-

SELECT
	latitude,
	ROUND(latitude, 2),
	TRUNC(latitude, 2)
FROM apartments;

-

SELECT
	longitude,
	ABS(longitude)
FROM apartments;

-

ALTER Table
	bookings
ADD COLUMN
	billing_day TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

SELECT
	to_char(billing_day, 'DD "Day" MM "Month" YYYY "Year" HH24:MI:SS') AS "Billing Day"
FROM
	bookings;

-

SELECT
	EXTRACT('year' FROM booked_at) AS "YEAR",
	EXTRACT('month' FROM booked_at) AS "MONTH",
	EXTRACT('day' FROM booked_at) AS "DAY",
	EXTRACT('hour' FROM booked_at AT TIME ZONE 'UTC') AS "HOUR",
	EXTRACT('minute' FROM booked_at) AS "MINUTE",
	CEIL(EXTRACT('second' FROM booked_at)) AS "SECOND"
FROM bookings;

-

SELECT
	user_id,
	AGE(starts_at, booked_at) AS early_birds
FROM
	bookings
WHERE
	starts_at - booked_at >= '10 MONTHS';

-

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

-

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

-

SELECT
	SUM(booked_for)
FROM
	bookings
WHERE
	apartment_id = 90;

-

SELECT
	AVG(multiplication) AS average_value
FROM
	bookings_calculation;