CREATE DATABASE minions_db;

CREATE TABLE minions(
	id serial PRIMARY KEY,
	name VARCHAR(30),
	age INT
);

ALTER TABLE minions
RENAME TO minions_info;

ALTER TABLE minions_info
ADD COLUMN code CHAR(4),
ADD COLUMN task TEXT,
ADD COLUMN salary NUMERIC(8,3);

SELECT * FROM minions_info;

ALTER TABLE minions_info
RENAME COLUMN salary TO banana;

ALTER TABLE minions_info
ADD COLUMN email VARCHAR(20),
ADD COLUMN equipped BOOLEAN NOT NULL;

CREATE TYPE type_mood
AS ENUM (
	'happy',
	'relaxed',
	'stressed',
	'sad'
);

ALTER TABLE minions_info
ADD COLUMN mood type_mood;

ALTER TABLE minions_info
ALTER COLUMN age SET NOT NULL,
ALTER COLUMN age SET DEFAULT 0,
ALTER COLUMN name SET NOT NULL,
ALTER COLUMN name SET DEFAULT '',
ALTER COLUMN code SET NOT NULL,
ALTER COLUMN code SET DEFAULT '';

ALTER TABLE minions_info
ADD CONSTRAINT unique_containt UNIQUE (id, email),
ADD CONSTRAINT banana_check CHECK (banana > 0);

ALTER TABLE minions_info
ALTER COLUMN task TYPE VARCHAR(150);

ALTER TABLE minions_info
ALTER COLUMN equipped DROP NOT NULL;

ALTER TABLE minions_info
DROP COLUMN age;

CREATE TABLE minions_birthdays(
	id SERIAL NOT NULL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	date_of_birth DATE NOT NULL,
	age INT NOT NULL DEFAULT 0,
	present VARCHAR(100) NOT NULL DEFAULT '',
	party timestamptz NOT NULL
);

INSERT INTO minions_info(name, code, task, banana, email, equipped, mood)
values
	('Mark', 'GKYA', 'Graphing Points', 3265.265, 'mark@minion.com', FALSE, 'happy'),
	('Mel', 'HSK', 'Science Investigation', 54784.996, 'mel@minion.com', TRUE, 'stressed'),
	('Bob', 'HF', 'Painting', 35.652, 'bob@minion.com', TRUE, 'happy'),
	('Darwin', 'EHND', 'Create a Digital Greeting', 321.958, 'darwin@minion.com', FALSE, 'relaxed'),
	('Kevin', 'KMHD', 'Construct with Virtual Blocks', 35214.789, 'kevin@minion.com', False, 'happy'),
	('Norbert', 'FEWB', 'Testing', 3265.500, 'norbert@minion.com', TRUE, 'sad'),
	('Donny', 'L', 'Make a Map', 8.452, 'donny@minion.com', TRUE, 'happy');

SELECT name, task, email, banana
FROM minions_info;

TRUNCATE TABLE minions_info;

DROP TABLE minions_birthdays;