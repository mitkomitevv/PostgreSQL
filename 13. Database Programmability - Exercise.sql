CREATE OR REPLACE FUNCTION fn_full_name(
    first_name varchar, last_name varchar
)RETURNS VARCHAR
AS
    $$
    BEGIN
        IF first_name IS NULL AND last_name IS NULL THEN
            RETURN NULL;
        ELSIF last_name IS NULL THEN
            RETURN initcap(first_name);
        ELSIF first_name IS NULL THEN
            RETURN initcap(last_name);
        ELSE
            RETURN concat(initcap(first_name), ' ', initcap(last_name));
        END IF;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_calculate_future_value(
    initial_sum NUMERIC,
    yearly_interest_rate NUMERIC,
    number_of_years INT
) RETURNS NUMERIC
AS
    $$
    BEGIN
        RETURN TRUNC(initial_sum * POWER(1 + yearly_interest_rate, number_of_years), 4);
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_is_word_comprised(
    set_letters VARCHAR,
    word VARCHAR
) RETURNS BOOLEAN
AS
    $$
    BEGIN
        RETURN TRIM(LOWER(word), LOWER(set_letters)) = '';
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_is_game_over(
    is_game_over BOOLEAN
) RETURNS TABLE(                                    -- RETURNS TABLE
    name VARCHAR(50),
    game_type_id INT,
    is_finished BOOLEAN
) AS
    $$
    BEGIN
        RETURN QUERY
        SELECT
            g.name,
            g.game_type_id,
            g.is_finished
        FROM
            games AS g
        WHERE
            g.is_finished = is_game_over;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE FUNCTION fn_difficulty_level(
    level INT
) RETURNS VARCHAR
AS
    $$
    DECLARE
        diff_lvl VARCHAR;
    BEGIN
        IF level <= 40 THEN
            diff_lvl := 'Normal Difficulty';
        ELSIF level BETWEEN 41 AND 60 THEN
            diff_lvl :=  'Nightmare Difficulty';
        ELSIF level > 60 THEN
            diff_lvl :=  'Hell Difficulty';
        END IF;

        RETURN diff_lvl;
    END;
    $$
LANGUAGE plpgsql;

SELECT
    user_id,
    level,
    cash,
    fn_difficulty_level(level)
FROM
    users_games
ORDER BY
    user_id;

---

CREATE OR REPLACE FUNCTION fn_cash_in_users_games(
    game_name VARCHAR(50)
) RETURNS TABLE(
    total_cash NUMERIC
) AS
    $$
    BEGIN
        RETURN QUERY
        WITH ranked_games AS (
            SELECT
                cash,
                ROW_NUMBER() OVER (ORDER BY cash DESC) AS row_num
            FROM
                users_games AS ug
            JOIN
                games AS g
                ON ug.game_id = g.id
            WHERE
                g.name = game_name
        )

        SELECT
            ROUND(SUM(cash), 2) AS total_cash
        FROM
            ranked_games AS rg
        WHERE
            rg.row_num % 2 <> 0;
    END;
    $$
LANGUAGE plpgsql

---

CREATE OR REPLACE PROCEDURE sp_retrieving_holders_with_balance_higher_than(
    searched_balance NUMERIC
)
AS
    $$
    DECLARE
        holder_info RECORD;
    BEGIN
        FOR holder_info IN
            SELECT
                concat(ah.first_name, ' ', ah.last_name) AS full_name,
                SUM(a.balance) AS total_balance
            FROM
                account_holders AS ah
            JOIN
                accounts AS a
                ON ah.id = a.account_holder_id
            GROUP BY
                full_name
            HAVING
                SUM(a.balance) > searched_balance
            ORDER BY
                full_name
        LOOP
            RAISE NOTICE '% - %', holder_info.full_name, holder_info.total_balance;
        END LOOP;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_deposit_money(
    account_id INT,
    money_amount NUMERIC(4)
)
AS
    $$
    BEGIN
        UPDATE
            accounts
        SET
            balance = balance + money_amount
        WHERE
            id = account_id;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_withdraw_money(
    account_id INT,
    money_amount NUMERIC(4)
)
AS
    $$
    DECLARE
        money_balance NUMERIC;
    BEGIN
        money_balance := (SELECT balance FROM accounts WHERE id = account_id);

        IF money_amount <= money_balance THEN
            UPDATE
                accounts
            SET
                balance = balance - money_amount
            WHERE
                id =  account_id;
        END IF;
    END;
    $$
LANGUAGE plpgsql;

---

CREATE OR REPLACE PROCEDURE sp_transfer_money(
    sender_id INT,
    receiver_id INT,
    amount NUMERIC(20, 4)
)
AS
    $$
        DECLARE
            money_left NUMERIC;
        BEGIN
            CALL sp_withdraw_money(sender_id, amount);
            CALL sp_deposit_money(receiver_id, amount);

            money_left = (SELECT balance FROM accounts WHERE id = sender_id);

            IF money_left < 0 THEN
                ROLLBACK;
            END IF;
        END;
    $$
LANGUAGE plpgsql;

---

DROP PROCEDURE sp_retrieving_holders_with_balance_higher_than

---

CREATE TABLE IF NOT EXISTS logs(
    id SERIAL PRIMARY KEY,
    account_id INT,
    old_sum NUMERIC,
    new_sum NUMERIC
);

CREATE OR REPLACE FUNCTION trigger_fn_insert_new_entry_into_logs()
RETURNS TRIGGER
AS
    $$
    BEGIN
        INSERT INTO
            logs(account_id, old_sum, new_sum)
        VALUES (
            old.id,
            old.balance,
            new.balance
        );
        RETURN new;
    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_account_balance_change
AFTER UPDATE ON accounts
FOR EACH ROW
-- WHEN
-- 	(NEW.balance <> OLD.balance)
EXECUTE PROCEDURE trigger_fn_insert_new_entry_into_logs();

---

CREATE TABLE IF NOT EXISTS notification_emails(
    id SERIAL PRIMARY KEY,
    recipient_id INT,
    subject VARCHAR,
    body TEXT
);

CREATE OR REPLACE FUNCTION trigger_fn_send_email_on_balance_change()
RETURNS TRIGGER
AS
    $$
    BEGIN
        INSERT INTO
            notification_emails(recipient_id, subject, body)
        VALUES (
            NEW.account_id,
            concat_ws(' ', 'Balance change for account: ', NEW.account_id),
            concat_ws(' ', 'On ', NOW(), ' your balance was changed from ', NEW.old_sum, NEW.new_sum)
        );
        RETURN new;
    END;
    $$
LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_send_email_on_balance_change
AFTER UPDATE ON logs
FOR EACH ROW
-- WHEN
-- 	(OLD.new_sum <> NEW.new_sum)
EXECUTE PROCEDURE trigger_fn_send_email_on_balance_change();
