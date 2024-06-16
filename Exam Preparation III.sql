---1---

CREATE TABLE categories(
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE addresses(
    id SERIAL PRIMARY KEY,
    street_name VARCHAR(100) NOT NULL,
    street_number INT CHECK ( street_number > 0 ) NOT NULL,
    town VARCHAR(30) NOT NULL,
    country VARCHAR(50) NOT NULL,
    zip_code INT CHECK ( zip_code > 0 ) NOT NULL
    );

CREATE TABLE publishers(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    address_id INT REFERENCES addresses ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    website VARCHAR(40),
    phone VARCHAR(20)
);

CREATE TABLE players_ranges(
    id SERIAL PRIMARY KEY,
    min_players INT NOT NULL CHECK ( min_players > 0 ),
    max_players INT NOT NULL CHECK ( max_players > 0 )
);

CREATE TABLE creators(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(30) NOT NULL
);

CREATE TABLE board_games(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    release_year INT CHECK ( release_year > 0 ) NOT NULL,
    rating NUMERIC(2) NOT NULL,
    category_id INT REFERENCES categories ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    publisher_id INT REFERENCES publishers ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    players_range_id INT REFERENCES players_ranges ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

CREATE TABLE creators_board_games(
    creator_id INT REFERENCES creators ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    board_game_id INT REFERENCES board_games ON DELETE CASCADE ON UPDATE CASCADE NOT NULL
);

---2---

INSERT INTO
    board_games(name, release_year, rating, category_id, publisher_id, players_range_id)
VALUES
    ('Deep Blue', 2019, 5.67, 1, 15, 7),
    ('Paris', 2016, 9.78, 7, 1, 5),
    ('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
    ('Bleeding Kansas', 2020, 3.25, 3, 7, 4),
    ('One Small Step', 2019, 5.75, 5, 9, 2);

INSERT INTO
    publishers(name, address_id, website, phone)
VALUES
    ('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
    ('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
    ('BattleBooks', 13, 'www.battlebooks.com', '+12345678907');

---3---

UPDATE
    players_ranges
SET
    max_players = max_players + 1
WHERE
    min_players = 2
        AND
    max_players = 2;

UPDATE
    board_games
SET
    name = concat(name, ' V2')
WHERE
    release_year >= 2020;

---4---

DELETE FROM board_games
WHERE publisher_id IN (
    SELECT
        id
    FROM
        publishers
    WHERE address_id IN (
        SELECT
            id
        FROM
            addresses
        WHERE
            town LIKE 'L%'
    )
);

DELETE FROM publishers
WHERE address_id IN (
    SELECT
        id
    FROM
        addresses
    WHERE
        town LIKE 'L%'
);

DELETE FROM
    addresses
WHERE
    town LIKE 'L%';

---5---

SELECT
    name,
    rating
FROM
    board_games
ORDER BY
    release_year,
    name DESC;

---6---

SELECT
    bg.id,
    bg.name,
    bg.release_year,
    c.name
FROM
    board_games AS bg
JOIN
    categories AS c
    ON bg.category_id = c.id
WHERE
    c.name IN ('Strategy Games', 'Wargames')
ORDER BY
    bg.release_year DESC;

---7---

SELECT
    c.id,
    concat(first_name, ' ', last_name) AS creator_name,
    c.email
FROM
    creators AS c
LEFT JOIN
    creators_board_games AS cbg
    ON c.id = cbg.creator_id
WHERE
    c.id NOT IN(
        SELECT
            creator_id
        FROM
            creators_board_games
        )
ORDER BY
    creator_name;

---8---

SELECT
    bg.name,
    bg.rating,
    c.name AS category_name
FROM
    board_games AS bg
JOIN
    categories AS c
    ON bg.category_id = c.id
JOIN
    players_ranges AS pr
    ON bg.players_range_id = pr.id
WHERE
    (bg.rating > 7 AND bg.name ILIKE '%a%')
        OR
    (bg.rating > 7.5 AND pr.min_players >= 2 AND pr.max_players <= 5)
ORDER BY
    bg.name,
    bg.rating DESC
LIMIT 5;

---9---

SELECT
    concat(c.first_name, ' ', c.last_name) AS full_name,
    c.email,
    MAX(bg.rating)
FROM
    creators AS c
JOIN
    creators_board_games AS cbg
    ON c.id = cbg.creator_id
JOIN
    board_games AS bg
    ON cbg.board_game_id = bg.id
WHERE
    c.email LIKE '%.com'
GROUP BY
    full_name,
    c.email
ORDER BY
    full_name;

---10---

SELECT
    c.last_name,
    CEIL(AVG(bg.rating)) AS average_rating,
    p.name AS publisher_name
FROM
    creators AS c
JOIN
    creators_board_games AS cbg
    ON c.id = cbg.creator_id
JOIN
    board_games AS bg
    ON cbg.board_game_id = bg.id
JOIN
    publishers AS p
    ON bg.publisher_id = p.id
WHERE
    p.name = 'Stonemaier Games'
GROUP BY
    c.last_name,
    p.name
ORDER BY
    average_rating DESC;

---11---

CREATE OR REPLACE FUNCTION
    fn_creator_with_board_games(creator_first_name VARCHAR(30))
RETURNS INT
AS
    $$
    DECLARE
        games_created INT;
    BEGIN
        SELECT
            COUNT(cbg.creator_id)
        INTO
            games_created
        FROM
            creators AS c
        JOIN
            creators_board_games AS cbg
            ON c.id = cbg.creator_id
        WHERE
            c.first_name = creator_first_name;
        RETURN games_created;
    END;
    $$
LANGUAGE plpgsql;

---12---

CREATE TABLE search_results (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    release_year INT,
    rating FLOAT,
    category_name VARCHAR(50),
    publisher_name VARCHAR(50),
    min_players VARCHAR(50),
    max_players VARCHAR(50)
);

CREATE OR REPLACE PROCEDURE
    usp_search_by_category(category VARCHAR(50))
AS
    $$
    BEGIN
        TRUNCATE search_results;

        INSERT INTO search_results(
            name,
            release_year,
            rating,
            category_name,
            publisher_name,
            min_players,
            max_players
        )
        SELECT
            bg.name,
            bg.release_year,
            bg.rating,
            c.name,
            p.name,
            concat(pr.min_players, ' ', 'people'),
            concat(pr.max_players, ' ', 'people')
        FROM
            board_games AS bg
        JOIN
            players_ranges AS pr
            ON bg.players_range_id = pr.id
        JOIN
            categories AS c
            ON bg.category_id = c.id
        JOIN
            publishers AS p
            ON bg.publisher_id = p.id
        WHERE
            c.name = category
        ORDER BY
            p.name,
            bg.release_year DESC;
    END;
    $$
LANGUAGE plpgsql;
