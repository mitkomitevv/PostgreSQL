---1---

CREATE TABLE accounts(
    id SERIAL PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    password VARCHAR(30) NOT NULL,
    email VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL, -- Constraint
    age INT NOT NULL,
    job_title VARCHAR(40) NOT NULL,
    ip VARCHAR(30) NOT NULL,

    CONSTRAINT gender_is_F_or_M
                     CHECK ( gender = 'M' OR gender = 'F' )
);

CREATE TABLE addresses(
    id SERIAL PRIMARY KEY,
    street VARCHAR(30) NOT NULL,
    town VARCHAR(30) NOT NULL,
    country VARCHAR(30) NOT NULL,
    account_id INT REFERENCES accounts ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE photos(
    id SERIAL PRIMARY KEY,
    description TEXT,
    capture_date TIMESTAMP NOT NULL,
    views INT DEFAULT 0 CHECK ( views >= 0 ) NOT NULL
);

CREATE TABLE comments(
    id SERIAL PRIMARY KEY,
    content VARCHAR(255) NOT NULL,
    published_on TIMESTAMP NOT NULL,
    photo_id INT REFERENCES photos ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE accounts_photos(
    account_id INT REFERENCES accounts ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    photo_id INT REFERENCES photos ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,

    CONSTRAINT pk_accounts_photos
    PRIMARY KEY (account_id, photo_id)
);

CREATE TABLE likes(
    id SERIAL PRIMARY KEY,
    photo_id INT REFERENCES photos ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    account_id INT REFERENCES accounts ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

---2---

INSERT INTO
    addresses(street, town, country, account_id)
SELECT
    username,
    password,
    ip,
    age
FROM
    accounts
WHERE
    gender = 'F';

---3---

UPDATE
    addresses
SET
    country =
        CASE
            WHEN country LIKE 'B%' THEN 'Blocked'
            WHEN country LIKE 'T%' THEN 'Test'
            WHEN country LIKE 'P%' THEN 'In Progress'
            ELSE country
        END;

---4---

DELETE FROM
    addresses
WHERE id % 2 = 0
        AND
    street ILIKE '%r%';

---5---

SELECT
    username,
    gender,
    age
FROM
    accounts
WHERE
    age >= 18
        AND
    length(username) > 9
ORDER BY
    age DESC,
    username;

---6---

SELECT
    p.id AS photo_id,
    p.capture_date,
    p.description,
    COUNT(c.photo_id) AS comments_count
FROM
    photos AS p
JOIN
    comments AS c
    ON p.id = c.photo_id
GROUP BY
    p.id,
    p.capture_date,
    p.description
HAVING
    p.description IS NOT NULL
ORDER BY
    comments_count DESC,
    photo_id
LIMIT 3;

---7---

SELECT
    concat(a.id, ' ', a.username) AS id_username,
    a.email
FROM
    accounts AS a
JOIN
    accounts_photos AS ap
    ON a.id = ap.account_id
WHERE
    ap.account_id = ap.photo_id
ORDER BY
    ap.account_id;

---8---

SELECT
    p.id AS photo_id,
    COUNT(DISTINCT l.id) AS likes_count,
    COUNT(DISTINCT c.id) AS comments_count
FROM
    photos AS p
LEFT JOIN
    comments AS c
    ON p.id = c.photo_id
LEFT JOIN
    likes AS l
    ON p.id = l.photo_id
GROUP BY
    p.id
ORDER BY
    likes_count DESC,
    comments_count DESC,
    photo_id;

---9---

SELECT
    concat(LEFT(description, 10), '...') AS summary,
    to_char(capture_date, 'DD.MM HH24:MI') AS date
FROM
    photos
WHERE
    EXTRACT('day' FROM capture_date) = 10
ORDER BY
    capture_date DESC;

---10---

CREATE OR REPLACE FUNCTION
    udf_accounts_photos_count(account_username VARCHAR(30))
RETURNS INT
AS
    $$
    DECLARE
        photos_count INT;
    BEGIN
        SELECT
            COUNT(ap.account_id)
        INTO
            photos_count
        FROM
            accounts AS a
        JOIN
            accounts_photos AS ap
            ON a.id = ap.account_id
        WHERE
            a.username = account_username;
        RETURN photos_count;
    END;
    $$
LANGUAGE plpgsql;

---11---

CREATE OR REPLACE PROCEDURE
    udp_modify_account(address_street VARCHAR(30), address_town VARCHAR(30))
AS
    $$
    BEGIN
        UPDATE
            accounts
        SET
            job_title = concat('(Remote) ', job_title)
        WHERE
            id = (
                SELECT
                    ac.id
                FROM
                    accounts AS ac
                JOIN
                    addresses AS ad
                    ON ac.id = ad.account_id
                WHERE
                    ad.town = address_town
                        AND
                    ad.street = address_street
                );
    END;
    $$
LANGUAGE plpgsql;
