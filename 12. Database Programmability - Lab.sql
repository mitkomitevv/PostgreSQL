CREATE OR REPLACE FUNCTION fn_count_employees_by_town(town_name VARCHAR(20))
RETURNS INT AS
    $$
    DECLARE
        count int;
    BEGIN
        SELECT INTO count
            COUNT(*)
        FROM
            employees
        JOIN
            addresses
            USING (address_id)
        JOIN
            towns
            USING (town_id)
        WHERE
            towns.name = town_name;
        RETURN count;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_increase_salaries(department_name varchar)
AS
    $$
    BEGIN
        UPDATE
            employees
        SET
            salary = salary * 1.05
        WHERE
            department_id = (
                SELECT
                    department_id
                FROM
                    departments
                WHERE
                    name = department_name
                );
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_increase_salary_by_id(id INT)
AS
    $$
    BEGIN
        IF (SELECT salary FROM employees WHERE employee_id = id) IS NULL THEN
            RETURN;
        END IF;
        UPDATE
            employees
        SET
            salary = salary * 1.05
        WHERE
            employee_id = id;
        COMMIT;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE TABLE deleted_employees(
    employee_id SERIAL PRIMARY KEY ,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    middle_name VARCHAR(20),
    job_title VARCHAR(50),
    department_id INT,
    salary NUMERIC(19, 4)
);

CREATE OR REPLACE FUNCTION fired_employees()
RETURNS TRIGGER
AS
    $$
    BEGIN
        INSERT INTO
            deleted_employees(first_name, last_name, middle_name, job_title, department_id, salary)
        VALUES (
            old.first_name,
            old.last_name,
            old.middle_name,
            old.job_title,
            old.department_id,
            old.salary
        );
        RETURN new;
    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER backup_employees
AFTER DELETE ON employees
FOR EACH ROW
EXECUTE PROCEDURE fired_employees();