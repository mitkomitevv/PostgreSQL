CREATE TABLE mountains(
	id serial PRIMARY KEY,
	name varchar(50)
);

CREATE TABLE peaks(                              -- FOREIGN KEY implementation
	id serial PRIMARY KEY,
	name VARCHAR(50),
	mountain_id int,
 -- mountain_id int REFERENCES mountains(id)       Short way without name
	CONSTRAINT fk_peaks_mountains			    -- Longer way with constraint name
		FOREIGN KEY(mountain_id)
			REFERENCES mountains(id)
);

-

SELECT
	v.driver_id,
	v.vehicle_type,
	concat(c.first_name, ' ', c.last_name) AS driver_name
FROM vehicles AS v
JOIN campers AS c
ON c.id = v.driver_id;

-

SELECT
	r.start_point,
	r.end_point,
	c.id,
	concat(c.first_name, ' ', c.last_name) AS leader_name
FROM routes as r
JOIN campers as c
ON c.id = r.leader_id;

-

CREATE TABLE mountains(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(50)
);

CREATE TABLE peaks(
	id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	name VARCHAR(50),
	mountain_id int,
	CONSTRAINT fk_mountain_id
		FOREIGN KEY(mountain_id)
			REFERENCES mountains(id)
				ON DELETE CASCADE
);