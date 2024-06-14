---1---

CREATE TABLE owners (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(50)
);

CREATE TABLE animal_types (
    id SERIAL PRIMARY KEY,
    animal_type VARCHAR(30) NOT NULL
);

CREATE TABLE cages (
    id SERIAL PRIMARY KEY,
    animal_type_id INT NOT NULL REFERENCES animal_types ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE animals (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL,
    birthdate DATE NOT NULL,
    owner_id INT REFERENCES owners ON DELETE CASCADE ON UPDATE CASCADE,
    animal_type_id INT NOT NULL REFERENCES animal_types ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE volunteers_departments (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(30) NOT NULL
);

CREATE TABLE volunteers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    address VARCHAR(50),
    animal_id INT REFERENCES animals ON DELETE CASCADE ON UPDATE CASCADE,
    department_id INT NOT NULL REFERENCES volunteers_departments ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE animals_cages (
    cage_id INT NOT NULL REFERENCES cages ON DELETE CASCADE ON UPDATE CASCADE,
    animal_id INT NOT NULL REFERENCES animals ON DELETE CASCADE ON UPDATE CASCADE
);

---2---

INSERT INTO
    volunteers(name, phone_number, address, animal_id, department_id)
VALUES
    ('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
    ('Dimitur Stoev', '0877564223', NULL, 42, 4),
    ('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
    ('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
    ('Boryana Mileva', '0888112233', NULL, 31, 5);

INSERT INTO
    animals(name, birthdate, owner_id, animal_type_id)
VALUES
    ('Giraffe', '2018-09-21', 21, 1),
    ('Harpy Eagle', '2015-04-17', 15, 3),
    ('Hamadryas Baboon', '2017-11-02', NULL, 1),
    ('Tuatara', '2021-06-30', 2, 4);

---3---

UPDATE
    animals
SET owner_id = (
    SELECT
        id
    FROM
        owners
    WHERE
        name = 'Kaloqn Stoqnov'
    )
WHERE
    owner_id IS NULL;

---4---

DELETE FROM
    volunteers_departments
WHERE
    department_name = 'Education program assistant';

---5---

SELECT
    name,
    phone_number,
    address,
    animal_id,
    department_id
FROM
    volunteers
ORDER BY
    name,
    animal_id,
    department_id;

---6---

SELECT
    a.name,
    at.animal_type,
    to_char(a.birthdate, 'DD.MM.YYYY')
FROM
    animals AS a
JOIN
    animal_types AS at
    ON a.animal_type_id = at.id
ORDER BY
    a.name;

---7---

SELECT
    o.name AS owner,
    COUNT(a.owner_id) AS count_of_animals
FROM
    owners AS o
JOIN
    animals AS a
    ON o.id = a.owner_id
GROUP BY
    owner
ORDER BY
    count_of_animals DESC,
    owner
LIMIT 5;

---8---

SELECT
    concat(o.name, ' - ', a.name),
    o.phone_number,
    ac.cage_id
FROM
    owners AS o
JOIN
    animals AS a
    ON o.id = a.owner_id
JOIN
    animal_types AS at
    ON a.animal_type_id = at.id
JOIN
    animals_cages AS ac
    ON a.id = ac.animal_id
WHERE
    at.animal_type = 'Mammals'
ORDER BY
    o.name,
    a.name DESC;

---9---

SELECT
    v.name AS volunteers,
    v.phone_number,
    TRIM(v.address, 'Sofia, ') AS address
FROM
    volunteers AS v
JOIN
    volunteers_departments AS vd
    ON v.department_id = vd.id
WHERE
    v.address LIKE '%Sofia%'
        AND
    vd.department_name = 'Education program assistant'
ORDER BY
    volunteers;

---10---

SELECT
    a.name AS animal,
    EXTRACT('year' FROM a.birthdate) AS birth_year,
    at.animal_type
FROM
    animals AS a
JOIN
    animal_types AS at
    ON a.animal_type_id = at.id
WHERE
    at.animal_type <> 'Birds'
        AND
    age('01/01/2022', a.birthdate) < '5 years'
        AND
    a.owner_id IS NULL
ORDER BY
    animal;

---11---

CREATE OR REPLACE FUNCTION
    fn_get_volunteers_count_from_department(searched_volunteers_department VARCHAR(30))
RETURNS INT
AS
    $$
    DECLARE
        count_volunteers INT;
    BEGIN
        SELECT INTO count_volunteers
            COUNT(v.department_id)
        FROM
            volunteers AS v
        JOIN
            volunteers_departments AS vd
            ON v.department_id = vd.id
        WHERE
            vd.department_name = searched_volunteers_department;
        RETURN count_volunteers;
    END;
    $$
LANGUAGE plpgsql;

---12---

CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not(
    IN animal_name VARCHAR(30),
    OUT owner_name VARCHAR(50)
) AS
    $$
    BEGIN
        SELECT
            o.name
        INTO
            owner_name
        FROM
            animals AS a
        JOIN
            owners AS o
            ON a.owner_id = o.id
        WHERE
            a.name = animal_name;

        IF owner_name IS NULL THEN
            owner_name := 'For adoption';
        END IF;
    END;
    $$
LANGUAGE plpgsql;

-- CREATE OR REPLACE PROCEDURE sp_animals_with_owners_or_not(
--     IN animal_name VARCHAR(30),
--     OUT owner_name VARCHAR(50)
-- ) AS                                    Not as intuitive solution, but it works
--     $$
--     BEGIN
--         SELECT
--             CASE
--                 WHEN o.name IS NULL THEN 'For adoption'
--                 ELSE o.name
--             END
--         INTO
--             owner_name
--         FROM
--             animals AS a
--         LEFT JOIN
--             owners AS o
--             ON a.owner_id = o.id
--         WHERE
--             a.name = animal_name;
--     END;
--     $$
-- LANGUAGE plpgsql;