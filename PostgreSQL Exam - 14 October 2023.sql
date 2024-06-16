---1---

CREATE TABLE towns(
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL
);

CREATE TABLE stadiums(
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    capacity INT NOT NULL,
    town_id INT NOT NULL,

    CONSTRAINT positive_capacity
    CHECK (capacity > 0),

    CONSTRAINT fk_stadiums_towns
    FOREIGN KEY (town_id)
    REFERENCES towns(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE teams(
    id SERIAL PRIMARY KEY,
    name VARCHAR(45) NOT NULL,
    established DATE NOT NULL,
    fan_base INT DEFAULT 0 NOT NULL,
    stadium_id INT NOT NULL,

    CONSTRAINT fan_base_positive
    CHECK (fan_base >= 0),

    CONSTRAINT fk_teams_stadiums
    FOREIGN KEY (stadium_id)
    REFERENCES stadiums(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE coaches(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    salary NUMERIC(10, 2) DEFAULT 0 NOT NULL,
    coach_level INT DEFAULT 0 NOT NULL,

    CONSTRAINT salary_equals_or_greater_than_zero
                    CHECK (salary >= 0),
    CONSTRAINT coach_lvl_equals_or_greater_than_zero
                    CHECK (coach_level >= 0)
);

CREATE TABLE skills_data(
    id SERIAL PRIMARY KEY,
    dribbling INT DEFAULT 0 CHECK (dribbling >= 0),
    pace INT DEFAULT 0 CHECK (pace >= 0),
    passing INT DEFAULT 0 CHECK (passing >= 0),
    shooting INT DEFAULT 0 CHECK (shooting >= 0),
    speed INT DEFAULT 0 CHECK (speed >= 0),
    strength INT DEFAULT 0 CHECK (strength >= 0)
);

CREATE TABLE players(
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(10) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    age INT DEFAULT 0 NOT NULL CHECK (age >= 0),
    position CHAR(1) NOT NULL,
    salary NUMERIC(10, 2) DEFAULT 0 NOT NULL CHECK (salary >= 0),
    hire_date TIMESTAMP,
    skills_data_id INT NOT NULL REFERENCES skills_data ON DELETE CASCADE ON UPDATE CASCADE,
    team_id INT REFERENCES teams ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE players_coaches(
    player_id INT REFERENCES players ON DELETE CASCADE ON UPDATE CASCADE,
    coach_id INT REFERENCES coaches ON DELETE CASCADE ON UPDATE CASCADE
);

---2---

INSERT INTO
    coaches(first_name, last_name, salary, coach_level)
SELECT
    first_name,
    last_name,
    salary * 2,
    LENGTH(first_name)
FROM
    players AS p
WHERE
    p.hire_date < '2013-12-13 07:18:46';

---3---

UPDATE
    coaches
SET
    salary = salary * coach_level
WHERE
    first_name LIKE 'C%'
        AND
    id IN (
        SELECT
            coach_id
        FROM
            players_coaches
        );

---4---

DELETE FROM
    players
WHERE
    hire_date < '2013-12-13 07:18:46';

---5---

SELECT
    concat(first_name, ' ', last_name) AS full_name,
    age,
    hire_date
FROM
    players
WHERE
    first_name LIKE 'M%'
 -- SUBSTRING(first_name, 1, 1) = 'M'
ORDER BY
    age DESC,
    full_name;

---6---

SELECT
    p.id,
    concat(p.first_name, ' ', p.last_name) AS full_name,
    p.age,
    p.position,
    p.salary,
    sd.pace,
    sd.shooting
FROM
    players AS p
JOIN
    skills_data AS sd
    ON p.skills_data_id = sd.id
WHERE
    sd.pace + sd.shooting > 130
        AND
    p.position = 'A'
        AND
    p.team_id IS NULL;

---7---

SELECT
    t.id,
    t.name,
    COUNT(p.id) AS player_count,
    t.fan_base
FROM
    teams AS t
LEFT JOIN
    players AS p
    ON t.id = p.team_id
GROUP BY
    t.id,
    t.name,
    t.fan_base
HAVING
    t.fan_base > 30000
ORDER BY
    player_count DESC,
    t.fan_base DESC;

---8---

SELECT
    concat(c.first_name, ' ', c.last_name) AS coach_full_name,
    concat(p.first_name, ' ', p.last_name) AS player_full_name,
    t.name,
    sd.passing,
    sd.shooting,
    sd.speed
FROM
    players AS p
JOIN
    players_coaches AS pc
    ON p.id = pc.player_id
JOIN
    coaches AS c
    ON pc.coach_id = c.id
JOIN
    teams AS t
    ON p.team_id = t.id
JOIN
    skills_data AS sd
    ON p.skills_data_id = sd.id
ORDER BY
    coach_full_name,
    player_full_name DESC;

---9---

CREATE OR REPLACE FUNCTION
    fn_stadium_team_name(stadium_name VARCHAR(30))
RETURNS TABLE (
    team_name VARCHAR
) AS
    $$
    BEGIN
        RETURN QUERY
        SELECT
            t.name
        FROM
            teams AS t
        JOIN
            stadiums AS s
            ON t.stadium_id = s.id
        WHERE
            s.name = stadium_name
        ORDER BY
            t.name;
    END;
    $$
LANGUAGE plpgsql;

---10---

CREATE OR REPLACE PROCEDURE
    sp_players_team_name(
    IN player_name VARCHAR(50),
    OUT team_name VARCHAR(45)
) AS
    $$
    BEGIN
        SELECT
            CASE
            WHEN t.name IS NULL THEN 'The player currently has no team'
            ELSE t.name
        END
         -- COALESCE(t.name, 'The player currently has no team')
        INTO
            team_name
        FROM
            players AS p
        LEFT JOIN
            teams AS t
            ON p.team_id = t.id
        WHERE
            concat(p.first_name, ' ', p.last_name) = player_name;
    END;
    $$
LANGUAGE plpgsql;
