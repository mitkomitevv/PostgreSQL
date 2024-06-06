SELECT
	title
FROM
	books
WHERE title LIKE 'The%';
-- WHERE LEFT(title, 3) = 'The'
-- WHERE SUBSTRING(title, 1, 3) = 'The'

-

SELECT
	REPLACE(title, LEFT(title, 3), '*** ') as "title"
	-- REPLACE(title, 'The', '***') as "title" This will replace every 'The' in the string, even if it's not in the beggining.
FROM
	books
WHERE LEFT(title, 3) = 'The';

-

SELECT
	id,
	(side * height) / 2 as area
FROM triangles;

-

SELECT
	title,
	trunc(cost, 3) as modified_price
	-- cost * 1.0 as modified_price
FROM books;

-

SELECT
	first_name,
	last_name,
	EXTRACT('year' FROM born) AS year
	-- date_part('year', born) AS year
FROM authors;

-

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

-

SELECT
	title
FROM
	books
WHERE title LIKE '%Harry Potter%';