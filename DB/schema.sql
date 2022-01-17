DROP TABLE IF EXISTS 
	departments, employees, health_declarations, juniors, bookers, 
	seniors, managers, meeting_rooms, meetings, attends, updates CASCADE;
	
DROP FUNCTION IF EXISTS approval_verify_manager_department, update_capacity_verify_manager_department,
	prevent_modification_after_approval, prevent_resigned_employees_booking, prevent_resigned_managers_approval,
	check_rooms_and_updates, booker_attends_own_meeting, check_booker_nofever, check_join_nofever, 
	seniors_covering_overlap_constraint, managers_covering_overlap_constraint, juniors_covering_overlap_constraint,
	booker_covering_overlap_constraint, approve_meeting_only_once, prevent_past_booking_and_approval, prevent_joining_past_meeting,
	check_meeting_capacity, prevent_change_past_capacity, delete_future_exceeded_bookings, delete_meeting_booker_leave, prevent_resign_twice;


CREATE TABLE departments (
    did INTEGER PRIMARY KEY,
    name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    email VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(50) NOT NULL,
    contact_no VARCHAR(20) NOT NULL,
    resignation_date DATE,
    did INTEGER NOT NULL,
    FOREIGN KEY (did) REFERENCES departments
	/*ISA relation for constriaint no. 12 & 13*/
    /*TODO: Decide on delete and on update*/
	/*Each employee must be one (and only one) -> Trigger*/
);

CREATE TABLE health_declarations (
    d_date DATE,
    eid INTEGER REFERENCES employees (id),
    temperature NUMERIC,
    PRIMARY KEY (eid, d_date),
	CHECK (temperature > 34.0 AND temperature < 43.0)
	/*Triggers for constraint no. 16 for those having fever*/
	/*When Booking a room for any employee, what is defined as the current temperature?*/
	/*Check 34-43 deg, Constraints no. 32*/
);

CREATE TABLE juniors (
    eid INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    PRIMARY KEY(eid)
);

CREATE TABLE bookers (
    eid INTEGER REFERENCES employees(id) ON DELETE CASCADE,
    PRIMARY KEY(eid)
);

CREATE TABLE seniors (
    eid INTEGER REFERENCES bookers(eid) ON DELETE CASCADE,
    PRIMARY KEY(eid)
);

CREATE TABLE managers (
    eid INTEGER REFERENCES bookers(eid) ON DELETE CASCADE,
    PRIMARY KEY(eid)
);

CREATE TABLE meeting_rooms (
    floor_no INTEGER,
    room_no INTEGER,
    name VARCHAR(50),
    did INTEGER NOT NULL,
    PRIMARY KEY(floor_no,room_no),
    FOREIGN KEY (did) REFERENCES departments(did) 
);

CREATE TABLE meetings (
    starttime INTEGER,
    mdate DATE,
    floor_no INTEGER,
    room_no INTEGER,
    booker_eid INTEGER NOT NULL,
    approver_eid INTEGER,
    PRIMARY KEY (starttime, mdate, floor_no, room_no),
    FOREIGN KEY(booker_eid) REFERENCES bookers (eid),
    FOREIGN KEY(approver_eid) REFERENCES managers (eid),
    FOREIGN KEY (floor_no, room_no) 
        REFERENCES meeting_rooms (floor_no, room_no),
	CHECK (starttime >= 0 AND starttime < 24)
	/*Every booking must be approved by a manager from the same department.->Triggers, Constrainst 20 & 21*/
	/*Constraints no. 23 -> Trigger on INSERT and DELETE*/
	/*What is today (how to get LocalDate?) Constriaints no. 25*/
	/*Constraints no. 34 -> Trigger*/
);

CREATE TABLE attends (
    eid INTEGER,
    starttime INTEGER,
    mdate DATE,
    floor_no INTEGER NOT NULL,
    room_no INTEGER NOT NULL,
    PRIMARY KEY (eid, starttime, mdate),
    FOREIGN KEY (starttime, mdate, floor_no, room_no) 
        REFERENCES meetings (starttime, mdate, floor_no, room_no) ON DELETE CASCADE
    /*Total participation from meeting_rooms not covered*/
	/*The person booking the meeting must default be attending->constraints*/
);

CREATE TABLE updates (
    floor_no INTEGER,
    room_no INTEGER,
    mid INTEGER NOT NULL,
    udate DATE,
    capacity INTEGER NOT NULL,
    PRIMARY KEY (floor_no,room_no,udate),
    FOREIGN KEY (floor_no, room_no) REFERENCES meeting_rooms,
    FOREIGN KEY (mid) REFERENCES managers (eid),
	CHECK (capacity >= 0)
    /*Total participation from meeting_rooms not covered->Using Triggers (Upon INSERTION & DELETION)*/
	/*First time of creating the meeting room (add_room) might result in error as there is no mid given*/
	/*Constraints no. 24->Trigger*/
);

CREATE OR REPLACE FUNCTION approval_verify_manager_department()
RETURNS TRIGGER AS $$
DECLARE
	manager_did INT;
	room_did INT;
BEGIN
	IF (NEW.approver_eid IS NOT NULL) THEN 
		SELECT e.did INTO manager_did
		FROM employees e
		WHERE NEW.approver_eid = e.id;
		
		SELECT m.did INTO room_did
		FROM meeting_rooms m
		WHERE m.floor_no = NEW.floor_no AND m.room_no = NEW.room_no;
		
		IF manager_did <> room_did THEN 
			RAISE NOTICE 'Only managers from the same department can approve a meeting';
			RETURN NULL;
		ELSE RETURN NEW;
		END IF;
	ELSE RETURN NEW; /* Prevent update to NULL */
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS verify_approval_manager ON meetings;
CREATE TRIGGER verify_approval_manager
BEFORE INSERT OR UPDATE ON meetings
FOR EACH ROW EXECUTE FUNCTION approval_verify_manager_department();

CREATE OR REPLACE FUNCTION update_capacity_verify_manager_department()
RETURNS TRIGGER AS $$
DECLARE
	manager_did INT;
	room_did INT;
BEGIN
	SELECT e.did INTO manager_did
	FROM employees e
	WHERE NEW.mid = e.id;
	
	SELECT m.did INTO room_did
	FROM meeting_rooms m
	WHERE m.floor_no = NEW.floor_no AND m.room_no = NEW.room_no;
	
	IF manager_did <> room_did THEN 
		RAISE NOTICE 'Only managers from the same department can update the capacity';
		RETURN NULL;
	ELSE RETURN NEW;
	END IF;

END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS verify_update_capacity_manager ON updates;
CREATE TRIGGER verify_update_capacity_manager
BEFORE INSERT OR UPDATE ON updates
FOR EACH ROW EXECUTE FUNCTION update_capacity_verify_manager_department();


CREATE OR REPLACE FUNCTION prevent_modification_after_approval()
RETURNS TRIGGER AS $$
DECLARE
	approver1 INT;
	approver2 INT;
BEGIN
	IF (TG_OP = 'INSERT') THEN
		SELECT approver_eid INTO approver1
		FROM meetings m
		WHERE m.starttime = NEW.starttime AND m.mdate = NEW.mdate
			AND m.floor_no = NEW.floor_no AND m.room_no = NEW.room_no;
		IF approver1 IS NOT NULL THEN
			RAISE NOTICE 'Meeting has already been approved';
			RETURN NULL;
		ELSE RETURN NEW;
		END IF;
	ELSIF (TG_OP = 'DELETE') THEN
		SELECT approver_eid INTO approver1
		FROM meetings m
		WHERE m.starttime = OLD.starttime AND m.mdate = OLD.mdate
			AND m.floor_no = OLD.floor_no AND m.room_no = OLD.room_no;
		IF approver1 IS NOT NULL THEN
			RAISE NOTICE 'Meeting has already been approved';
			RETURN NULL;
		ELSE RETURN OLD;
		END IF;
	ELSIF (TG_OP = 'UPDATE') THEN
		/** Trying to modify participants**/
		SELECT approver_eid INTO approver1
		FROM meetings m
		WHERE m.starttime = OLD.starttime AND m.mdate = OLD.mdate
			AND m.floor_no = OLD.floor_no AND m.room_no = OLD.room_no;
		/** Trying to add participants**/
		SELECT approver_eid INTO approver2
		FROM meetings m
		WHERE m.starttime = NEW.starttime AND m.mdate = NEW.mdate
			AND m.floor_no = NEW.floor_no AND m.room_no = NEW.room_no;
		IF (approver1 IS NOT NULL OR approver2 IS NOT NULL) THEN
			RAISE NOTICE 'Meeting has already been approved';
			RETURN NULL;
		ELSE RETURN NEW;
		END IF;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_participant_modification ON attends;
CREATE TRIGGER prevent_participant_modification
BEFORE INSERT OR UPDATE OR DELETE ON attends
FOR EACH ROW EXECUTE FUNCTION prevent_modification_after_approval();

CREATE OR REPLACE FUNCTION prevent_resigned_employees_booking()
RETURNS TRIGGER AS $$
DECLARE
employee_id INTEGER;
firedDate DATE := NULL;
BEGIN
	SELECT NEW.booker_eid INTO employee_id;

	SELECT e.resignation_date into firedDate
	FROM employees e
	WHERE e.id = employee_id;
	
	IF firedDate IS NULL THEN RETURN NEW;
	ELSE 
		RAISE NOTICE 'Only current employees can book a meeting!';
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS verify_booker ON meetings;
CREATE TRIGGER verify_booker
BEFORE INSERT OR UPDATE ON meetings
FOR EACH ROW EXECUTE FUNCTION prevent_resigned_employees_booking();

CREATE OR REPLACE FUNCTION prevent_resigned_managers_approval()
RETURNS TRIGGER AS $$
DECLARE
manager_id INTEGER;
firedDate DATE := NULL;
BEGIN
	SELECT NEW.approver_eid INTO manager_id;

	SELECT e.resignation_date into firedDate
	FROM employees e
	WHERE e.id = manager_id;
	
	IF firedDate IS NULL THEN RETURN NEW;
	ELSE 
		RAISE NOTICE 'Only current managers can approve a meeting!';
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS verify_approver ON meetings;
CREATE TRIGGER verify_approver
BEFORE INSERT OR UPDATE ON meetings
FOR EACH ROW EXECUTE FUNCTION prevent_resigned_managers_approval();

CREATE OR REPLACE FUNCTION check_rooms_and_updates()
RETURNS TRIGGER AS $$
DECLARE 
	tuple_count INTEGER;
BEGIN

	SELECT count(*) into tuple_count
	FROM updates u
	WHERE u.floor_no = NEW.floor_no
	AND u.room_no = NEW.room_no;

	IF tuple_count = 0 THEN RAISE EXCEPTION 'no matching tuples between updates and meeting_rooms';
	ELSE RETURN NEW;
	END IF;

END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS meeting_rooms ON meeting_rooms;
CREATE CONSTRAINT TRIGGER meeting_rooms_updates
AFTER INSERT OR UPDATE ON meeting_rooms
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rooms_and_updates();


CREATE OR REPLACE FUNCTION booker_attends_own_meeting()
RETURNS TRIGGER AS $$
DECLARE
	starttime1 INTEGER;
	mdate1 DATE;
	floor_no1 INTEGER;
	room_no1 INTEGER;
	booker_eid1 INTEGER;
BEGIN
	SELECT NEW.starttime into starttime1;
	SELECT NEW.mdate into mdate1;
	SELECT NEW.floor_no into floor_no1;
	SELECT NEW.room_no into room_no1;
	SELECT NEW.booker_eid into booker_eid1;

	INSERT INTO attends 
		VALUES (booker_eid1, starttime1, mdate1, floor_no1, room_no1);
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS booker_attends ON meetings;
CREATE TRIGGER booker_attends
AFTER INSERT ON meetings
FOR EACH ROW EXECUTE FUNCTION booker_attends_own_meeting();

/* Check that employee having fever cannot book a room */
/* Constriaint no. 16 from ER.pdf */
CREATE OR REPLACE FUNCTION check_booker_nofever()
RETURNS TRIGGER AS $$
DECLARE 
	currentDate DATE;
	currentTemp NUMERIC;
BEGIN
	SELECT CURRENT_DATE INTO currentDate; -- Confirm if this is ok?
	
	SELECT hd.temperature INTO currentTemp
	FROM health_declarations hd
	WHERE hd.eid = NEW.booker_eid 
		AND hd.d_date = currentDate;
	
	IF (currentTemp > 37.5) THEN 
		RAISE NOTICE 'You have fever, so you cannot book a meeting!'; 
		RETURN NULL;
	ELSIF (currentTemp IS NULL) THEN
		RAISE NOTICE 'You did not declare temperature!'; 
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS booker_nofever ON meetings;
CREATE TRIGGER booker_nofever
BEFORE INSERT ON meetings
FOR EACH ROW EXECUTE FUNCTION check_booker_nofever();

/* Check that employee joining a meeting has no fever */
/* Constriaint no. 19 from ER.pdf */
CREATE OR REPLACE FUNCTION check_join_nofever()
RETURNS TRIGGER AS $$
DECLARE 
	currentDate DATE;
	currentTemp NUMERIC;
BEGIN
	SELECT CURRENT_DATE INTO currentDate; -- Confirm if this is ok?
	
	SELECT hd.temperature INTO currentTemp
	FROM health_declarations hd
	WHERE hd.eid = NEW.eid 
		AND hd.d_date = currentDate;
	
	IF (currentTemp > 37.5) THEN 
		RAISE NOTICE 'You have fever, so you cannot join a meeting!'; 
		RETURN NULL;
	ELSIF (currentTemp IS NULL) THEN
		RAISE NOTICE 'You did not declare temperature!'; 
		RETURN NULL;
	ELSE 
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS join_nofever ON attends;
CREATE TRIGGER join_nofever
BEFORE INSERT ON attends
FOR EACH ROW EXECUTE FUNCTION check_join_nofever();

/* Check that employee can only be one of the three kinds of employees: junior, senior or manager */
/* Constriaint no. 12 from ER.pdf */
CREATE OR REPLACE FUNCTION seniors_covering_overlap_constraint()
RETURNS TRIGGER AS $$
DECLARE 
	count_juniors INTEGER := 0;
	count_seniors INTEGER := 0;
	count_managers INTEGER := 0;
BEGIN
	SELECT COUNT(*) INTO count_juniors
	FROM juniors j
	WHERE NEW.eid = j.eid;
	
	SELECT COUNT(*) INTO count_seniors
	FROM seniors s
	WHERE OLD.eid = s.eid;
	
	SELECT COUNT(*) INTO count_managers
	FROM managers m
	WHERE NEW.eid = m.eid;
	
	IF ((count_juniors = 0) AND (TG_OP = 'INSERT') AND (count_managers = 0)) THEN
		RAISE NOTICE 'Insertion to Senior Successfully!';
		RETURN NEW;
	ELSIF ((count_juniors = 0) AND (TG_OP = 'UPDATE') AND (count_managers = 0)) THEN
		RAISE NOTICE 'Update to Senior Successfully!';
		RETURN NEW;
	ELSE
		RAISE NOTICE 'You have updated or inserted a eid that has overlapping constraint!';
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS isa_seniors ON seniors;
CREATE TRIGGER isa_seniors
BEFORE INSERT OR UPDATE ON seniors
FOR EACH ROW EXECUTE FUNCTION seniors_covering_overlap_constraint();

CREATE OR REPLACE FUNCTION managers_covering_overlap_constraint()
RETURNS TRIGGER AS $$
DECLARE 
	count_juniors INTEGER := 0;
	count_seniors INTEGER := 0;
	count_managers INTEGER := 0;
BEGIN
	SELECT COUNT(*) INTO count_juniors
	FROM juniors j
	WHERE NEW.eid = j.eid;
	
	SELECT COUNT(*) INTO count_seniors
	FROM seniors s
	WHERE NEW.eid = s.eid;
	
	SELECT COUNT(*) INTO count_managers
	FROM managers m
	WHERE OLD.eid = m.eid;
	
	IF ((count_juniors = 0) AND (count_seniors = 0) AND (TG_OP = 'INSERT')) THEN
		RAISE NOTICE 'Insertion to Manager Successfully!';
		RETURN NEW;
	ELSIF ((count_juniors = 0) AND (count_seniors = 0) AND (TG_OP = 'UPDATE')) THEN
		RAISE NOTICE 'Update to Manager Successfully!';
		RETURN NEW;
	ELSE
		RAISE NOTICE 'You have updated or inserted a eid that has overlapping constraint!';
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS isa_managers ON managers;
CREATE TRIGGER isa_managers
BEFORE INSERT OR UPDATE ON managers
FOR EACH ROW EXECUTE FUNCTION managers_covering_overlap_constraint();

CREATE OR REPLACE FUNCTION juniors_covering_overlap_constraint()
RETURNS TRIGGER AS $$
DECLARE 
	count_bookers INTEGER := 0;
BEGIN
	SELECT COUNT(*) INTO count_bookers
	FROM bookers b
	WHERE NEW.eid = b.eid;
	
	IF ((TG_OP = 'INSERT') AND count_bookers = 0) THEN
		RAISE NOTICE 'Insertion to Junior Successfully!';
		RETURN NEW;
	ELSIF ((TG_OP = 'UPDATE') AND count_bookers = 0) THEN
		RAISE NOTICE 'Update to Junior Successfully!';
		RETURN NEW;
	ELSE
		RAISE NOTICE 'You have updated or inserted a eid that has overlapping constraint!';
		RETURN NULL;
	END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS isa_juniors ON juniors;
CREATE TRIGGER isa_juniors
BEFORE INSERT OR UPDATE ON juniors
FOR EACH ROW EXECUTE FUNCTION juniors_covering_overlap_constraint();


CREATE OR REPLACE FUNCTION booker_covering_overlap_constraint()
RETURNS TRIGGER AS $$
DECLARE
	count_juniors INTEGER;
BEGIN
	SELECT count(*) INTO count_juniors FROM juniors
	WHERE NEW.eid = eid;

		IF ((TG_OP = 'INSERT') AND count_juniors = 0) THEN 
			RAISE NOTICE 'Insertion to bookers Successfully!';
			RETURN NEW;
		ELSIF ((TG_OP = 'UPDATE') AND count_juniors = 0) THEN
			RAISE NOTICE 'Update to bookers Successfully!';
			RETURN NEW;
		ELSE
			RAISE NOTICE 'You have updated or inserted a eid that has overlapping constraint!';
			RETURN NULL;
	END IF;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS isa_booker ON bookers;
CREATE TRIGGER isa_booker
BEFORE INSERT OR UPDATE ON bookers
FOR EACH ROW EXECUTE FUNCTION booker_covering_overlap_constraint();

CREATE OR REPLACE FUNCTION approve_meeting_only_once()
RETURNS TRIGGER AS $$
BEGIN
	IF (OLD.approver_eid IS NOT NULL AND NEW.approver_eid IS NOT NULL) THEN	
		RAISE EXCEPTION 'Meetings can only be approved once';
	ELSE
		RETURN NEW;
	END IF;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS approval_only_once ON meetings;
CREATE TRIGGER approval_only_once
BEFORE UPDATE ON meetings
FOR EACH ROW EXECUTE FUNCTION approve_meeting_only_once();

CREATE OR REPLACE FUNCTION prevent_past_booking_and_approval()
RETURNS TRIGGER AS $$
DECLARE
	currentTime TIMESTAMP := date_trunc('hour', current_timestamp);
	meetingTime TIMESTAMP; 
BEGIN
	meetingTime := NEW.mdate + (NEW.starttime || ' hours')::interval;
	IF (meetingTime <= currentTime ) THEN
		RAISE EXCEPTION 'Cannot modify meeting in the past';
	ELSE
		RETURN NEW;
	END IF;	
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_past_booking_andapproval ON meetings;
CREATE TRIGGER prevent_past_booking_andapproval
BEFORE UPDATE OR INSERT ON meetings
FOR EACH ROW EXECUTE FUNCTION prevent_past_booking_and_approval();

CREATE OR REPLACE FUNCTION prevent_joining_past_meeting()
RETURNS TRIGGER AS $$
DECLARE
	currentTime TIMESTAMP := date_trunc('hour', current_timestamp);
	meetingTime TIMESTAMP; 
BEGIN
	
	meetingTime := NEW.mdate + (NEW.starttime || ' hours')::interval;
	IF (meetingTime <= currentTime ) THEN
		RAISE EXCEPTION 'Cannot join meeting in the past';
	ELSE
		RETURN NEW;
	END IF;	
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_join_past_meeting ON attends; 
CREATE TRIGGER prevent_join_past_meeting
BEFORE UPDATE OR INSERT ON attends
FOR EACH ROW EXECUTE FUNCTION prevent_joining_past_meeting();

CREATE OR REPLACE FUNCTION check_meeting_capacity()
RETURNS TRIGGER AS $$
DECLARE
	capacity INT;
	current_attendees INT;
BEGIN
	SELECT u.capacity INTO capacity
	FROM updates u
	WHERE NEW.floor_no = u.floor_no AND NEW.room_no = u.room_no AND u.udate < NEW.mdate
	ORDER BY u.udate DESC
	LIMIT 1; 
	
	SELECT COUNT(*) INTO current_attendees
	FROM attends a
	WHERE NEW.floor_no = a.floor_no AND NEW.room_no = a.room_no  
		AND NEW.mdate = a.mdate AND NEW.starttime = a.starttime;
	IF (current_attendees >= capacity) THEN
		RAISE NOTICE 'Meeting capacity reached';
		RETURN NULL;
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_join_maxed_meeting ON attends;
CREATE TRIGGER prevent_join_maxed_meeting
BEFORE UPDATE OR INSERT ON attends
FOR EACH ROW EXECUTE FUNCTION check_meeting_capacity();

CREATE OR REPLACE FUNCTION prevent_change_past_capacity()
RETURNS TRIGGER AS $$
DECLARE count_r INT;
BEGIN
	SELECT COUNT(*) INTO count_r
	FROM updates u
	WHERE u.room_no = NEW.room_no AND u.floor_no = NEW.floor_no;
	
	IF count_r = 0 THEN
		IF (NEW.udate = (CURRENT_DATE - INTERVAL '1 DAY')::DATE) THEN
			RETURN NEW;
		ELSE
			RAISE NOTICE 'Capacity of new rooms can only be set on 1 day before current date';
			RETURN NULL;
		END IF;
	END IF;
	
	IF NEW.udate < CURRENT_DATE THEN
		RAISE NOTICE 'Cannot change capacity in the past';
		RETURN NULL;
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_change_capacity_past ON updates;
CREATE TRIGGER prevent_change_capacity_past
BEFORE UPDATE OR INSERT ON updates
FOR EACH ROW EXECUTE FUNCTION prevent_change_past_capacity();

CREATE OR REPLACE FUNCTION delete_future_exceeded_bookings() 
RETURNS TRIGGER AS $$
DECLARE 
	attendee_no INT;
	curs CURSOR FOR (SELECT * 
			FROM meetings m
			WHERE m.mdate > NEW.udate AND m.floor_no = NEW.floor_no
				AND m.room_no = NEW.room_no);
	r1 record;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO r1;
		EXIT WHEN NOT FOUND;
		
		SELECT COUNT(*) INTO attendee_no
		FROM attends a
		WHERE a.mdate = r1.mdate AND a.starttime = r1.starttime
			AND a.floor_no = r1.floor_no AND a.room_no = r1.room_no;
		
		IF (attendee_no > NEW.capacity) THEN 
			DELETE FROM meetings m
			WHERE m.mdate = r1.mdate AND m.starttime = r1.starttime
			AND m.floor_no = r1.floor_no AND m.room_no = r1.room_no;
		END IF;
	END LOOP;
	CLOSE curs;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS delete_over_capacity_meetings ON updates;
CREATE TRIGGER delete_over_capacity_meetings
AFTER UPDATE OR INSERT ON updates
FOR EACH ROW EXECUTE FUNCTION delete_future_exceeded_bookings();

CREATE OR REPLACE FUNCTION delete_meeting_booker_leave()
RETURNS TRIGGER AS $$
DECLARE 
	booker_id INT; 
BEGIN
	SELECT m.booker_eid INTO booker_id
	FROM meetings m
	WHERE m.starttime = OLD.starttime AND m.mdate = OLD.mdate
		AND m.floor_no = OLD.floor_no AND m.room_no = OLD.room_no;
	
	IF (OLD.eid = booker_id) THEN
		DELETE FROM meetings m
		WHERE m.starttime = OLD.starttime AND m.mdate = OLD.mdate
			AND m.floor_no = OLD.floor_no AND m.room_no = OLD.room_no;
	END IF;
	RETURN NULL;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS delete_meeting_if_booker_leave ON attends;
CREATE TRIGGER delete_meeting_if_booker_leave
AFTER DELETE ON attends
FOR EACH ROW EXECUTE FUNCTION delete_meeting_booker_leave();

CREATE OR REPLACE FUNCTION prevent_resign_twice()
RETURNS TRIGGER AS $$
BEGIN
	IF (OLD.resignation_date IS NOT NULL) THEN
		RAISE NOTICE 'Employees can only resign once';
		RETURN NULL;
	END IF;
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS prevent_employee_resign_twice ON employees;
CREATE TRIGGER prevent_employee_resign_twice
BEFORE UPDATE ON employees
FOR EACH ROW EXECUTE FUNCTION prevent_resign_twice();
