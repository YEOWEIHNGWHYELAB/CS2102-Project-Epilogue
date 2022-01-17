DROP FUNCTION IF EXISTS search_room, contact_tracing, non_compliance, view_booking_report,
view_future_meeting, view_manager_report;

DROP PROCEDURE IF EXISTS add_department, remove_department, add_room,
change_capacity, add_employee, remove_employee, book_room, unbook_room,
join_meeting, leave_meeting, approve_meeting, declare_health;


/*Basic*/
/*1.*/
CREATE OR REPLACE PROCEDURE add_department(IN did INT, IN d_name VARCHAR(50))
AS $$

INSERT INTO departments VALUES (did, d_name);

$$ LANGUAGE sql;

/*2.*/
CREATE OR REPLACE PROCEDURE remove_department(IN d_id INT)
AS $$

DELETE FROM departments
WHERE did = d_id;

$$ LANGUAGE sql;

/*3.*/
CREATE OR REPLACE PROCEDURE add_room
(IN floor_number INT, IN room_number INT, IN room_name VARCHAR(50), IN department_id INT, IN capacity INT, IN manager_id INT)
AS $$

INSERT INTO meeting_rooms VALUES 
(floor_number, room_number, room_name, department_id);

INSERT INTO updates VALUES
(floor_number, room_number, manager_id, (CURRENT_DATE - INTERVAL '1 DAY')::date, capacity);


$$ LANGUAGE sql;

/*4.*/
CREATE OR REPLACE PROCEDURE change_capacity
	(IN floor_number INT, IN room_number INT, IN new_capacity INT, IN date DATE, IN manager_id INT) AS 
$$
BEGIN
	/* CHECK IF THE DATE IS LESS THAN TODAY PLEASE ROLLBACK! */
	INSERT INTO updates VALUES (floor_number, room_number, manager_id, date, new_capacity);
	/**force today?*/
END;
$$ LANGUAGE plpgsql;

/*5.*/
/* The employee and email must be generated automatically by the system. */
/* We could think of a better way to implement the automatic generation of id and email. For 
	now it is just 1, 2, 3,... 1@gmail.com, 2@gmail.com, 3@gmail.com */
CREATE OR REPLACE PROCEDURE add_employee
	(IN employee_name VARCHAR(50), IN contact_number VARCHAR(20), IN kind VARCHAR(10), IN department_id INT) AS 
$$
DECLARE 
	maxID INTEGER := 0;
	email VARCHAR(50);
BEGIN
	SELECT MAX(id) INTO maxID
	FROM employees;
	
	IF (maxID IS NULL) THEN
		INSERT INTO employees (id, email, name, contact_no, resignation_date, did)
			VALUES (1, '1@gmail', employee_name, contact_number, NULL, department_id);
		
		IF (kind = 'managers') THEN
			INSERT INTO bookers (eid) VALUES (1);
			INSERT INTO managers (eid) VALUES (1);
		ELSIF (kind = 'seniors') THEN 
			INSERT INTO bookers (eid) VALUES (1);
			INSERT INTO seniors (eid) VALUES (1);
		ELSIF (kind = 'juniors') THEN
			INSERT INTO juniors (eid) VALUES (1);
		ELSE 
			RAISE NOTICE 'Can only be a kind of managers or juniors or seniors';
			ROLLBACK; 
		END IF;
		
	ELSE 
		maxID := maxID + 1;
		SELECT CONCAT(maxID, '@gmail') INTO email;
		INSERT INTO employees (id, email, name, contact_no, resignation_date, did)
			VALUES (maxID, email, employee_name, contact_number, NULL, department_id);
		
		IF (kind = 'managers') THEN
			INSERT INTO bookers (eid) VALUES (maxID);
			INSERT INTO managers (eid) VALUES (maxID);
		ELSIF (kind = 'seniors') THEN 
			INSERT INTO bookers (eid) VALUES (maxID);
			INSERT INTO seniors (eid) VALUES (maxID);
		ELSIF (kind = 'juniors') THEN
			INSERT INTO juniors (eid) VALUES (maxID);
		ELSE 
			RAISE NOTICE 'Can only be a kind of managers or juniors or seniors';
			ROLLBACK; 
		END IF;
		
	END IF;
END;
$$ LANGUAGE plpgsql;

/*6.*/
/* Must ensure that employee cannot book or approve any meetings rooms. Additionally, 
	any future records (e.g., future meetings) are removed.*/
/* prevent_resigned_employees_booking functon enforced the first sentence. */
CREATE OR REPLACE PROCEDURE remove_employee
	(IN employee_id INT, IN new_resignation_date DATE) AS 
$$
BEGIN
	UPDATE employees 
	SET resignation_date = new_resignation_date
	WHERE id = employee_id;
	
	/* Needs on delete cascade on the FK of attends*/
	/* If there is any issue caused by adding "ON DELETE CASCADE" to attends FK for meetings */
	/* Then please change this to a loop instead */
	/* For future meetings where that fired employee is booker or approver, those meetings are deleted */
	DELETE FROM meetings 
	WHERE booker_eid = employee_id 
		AND mdate >= new_resignation_date; -- Should it be > instead?
	
	ALTER TABLE meetings DISABLE TRIGGER prevent_past_booking_andapproval;
	UPDATE meetings
	SET approver_eid = NULL 
	WHERE approver_eid = employee_id 
		AND mdate >= new_resignation_date; -- Should it be > instead?
	ALTER TABLE meetings ENABLE TRIGGER prevent_past_booking_andapproval;
	
	/* Remove fired attendees in future meetings */
	ALTER TABLE attends DISABLE TRIGGER prevent_participant_modification;
	DELETE FROM attends 
	WHERE eid = employee_id
		AND mdate >= new_resignation_date; -- Should it be > instead?
	ALTER TABLE attends ENABLE TRIGGER prevent_participant_modification;
	
END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
/*Core*/
/*1.*/
CREATE OR REPLACE FUNCTION search_room
  (cap INT, search_date DATE, start_hour INT, end_hour INT)
RETURNS TABLE(floor_number INT, room_number INT, dept_id INT, cap_no INT) AS $$
BEGIN
	IF (end_hour <= start_hour) THEN
		RAISE EXCEPTION 'End hour has to be later than start hour';
	END IF;
	IF (search_date < CURRENT_DATE) THEN
		RAISE EXCEPTION 'Cannot search for rooms in the past';
	END IF;
	RETURN QUERY SELECT floor_no, room_no, did, capacity
	FROM meeting_rooms NATURAL JOIN (
		SELECT floor_no, room_no, capacity
		FROM updates
		WHERE (floor_no, room_no, udate) IN (
			SELECT u.floor_no, u.room_no, MAX(u.udate) AS max_udate
			FROM updates u
			WHERE u.udate < search_date
			GROUP BY u.floor_no, u.room_no)
		) AS room_capacities(floor_no, room_no, capacity)
	WHERE (floor_no, room_no) NOT IN (
		SELECT floor_no, room_no
		FROM meetings
		WHERE mdate = search_date
		AND starttime >= start_hour
		AND starttime < end_hour)
	AND capacity >= cap
	ORDER BY capacity ASC;
END
$$ LANGUAGE plpgsql;

/*2.*/
CREATE OR REPLACE PROCEDURE book_room
  (floor_number INT, room_number INT, book_date DATE, start_hour INT, end_hour INT, emp_id INT)
AS $$
DECLARE
  is_booker INT;
  num_meetings INT;
BEGIN
  IF book_date < CURRENT_DATE THEN
    RAISE NOTICE 'Cannot book meetings in the past';
    RETURN;
  END IF;

  -- Check if employee is a booker
  SELECT COUNT(*) INTO is_booker
  FROM bookers
  WHERE eid = emp_id;

  IF is_booker = 0 THEN
    RAISE NOTICE 'Employee is not a booker';
    RETURN;
  END IF;

  -- Check if there are any meetings
  SELECT COUNT(*) INTO num_meetings
  FROM meetings
  WHERE floor_no = floor_number
  AND room_no = room_number
  AND mdate = book_date
  AND starttime >= start_hour
  AND starttime < end_hour;

  IF num_meetings > 0 THEN
    RAISE NOTICE 'Room not available';
    RETURN;
  END IF;

  WHILE start_hour < end_hour LOOP
    INSERT INTO meetings VALUES (start_hour, book_date, floor_number, room_number, emp_id, NULL);
    -- INSERT INTO attends VALUES (eid, start_hour, book_date, floor_number, room_number);
    -- above is covered by trigger
    start_hour := start_hour + 1;
  END LOOP;
END
$$ LANGUAGE plpgsql;
/*3.*/
CREATE OR REPLACE PROCEDURE unbook_room
  (floor_number INT, room_number INT, book_date DATE, start_hour INT, end_hour INT, emp_id INT)
AS $$
DECLARE 
  num_meetings INT;
BEGIN
  -- Check if the unbooking is valid
  SELECT COUNT(*) INTO num_meetings
  FROM meetings
  WHERE floor_no = floor_number
  AND room_no = room_number
  AND mdate = book_date
  AND starttime >= start_hour
  AND starttime < end_hour
  AND booker_eid = emp_id;

  IF num_meetings <> (end_hour - start_hour) THEN
    RAISE NOTICE 'Unauthorized or Invalid meeting';
    RETURN;
  END IF;

  -- Delete meetings
  DELETE
  FROM meetings
  WHERE floor_no = floor_number
  AND room_no = room_number
  AND mdate = book_date
  AND starttime >= start_hour
  AND starttime < end_hour;
END
$$ LANGUAGE plpgsql;

/*4.*/
CREATE OR REPLACE PROCEDURE join_meeting
	(IN floor_number INT , IN room_number INT, IN date DATE, IN start_hour INT, IN end_hour INT, IN employee_id INT) AS
$$
DECLARE 
	meeting_count INT := NULL;
	approver_eid INT := NULL;
BEGIN
	LOOP
		EXIT WHEN start_hour >= end_hour;
		
		/*Find if meeting exists*/
		SELECT COUNT(*) INTO meeting_count
		FROM meetings m
		WHERE m.floor_no = floor_number AND m.room_no = room_number AND m.mdate = date AND m.starttime = start_hour;
		
		/*Find if meeting is approved*/
		SELECT m.approver_eid INTO approver_eid
		FROM meetings m
		WHERE m.floor_no = floor_number AND m.room_no = room_number AND m.mdate = date AND m.starttime = start_hour;
		
		/*Insert */
		IF (meeting_count > 0 AND approver_eid IS NULL) THEN
			INSERT INTO attends (eid, starttime, mdate, floor_no, room_no) VALUES (employee_id, start_hour, date, floor_number, room_number);
		ELSIF (approver_eid IS NOT NULL) THEN /*Redundant? Already covered by triggers*/
			RAISE EXCEPTION 'Unable to join meeting as meeting has already been approved';
		ELSE 
			RAISE EXCEPTION 'Meeting does not exists';
		END IF;
		start_hour := start_hour + 1;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

/*5.*/
CREATE OR REPLACE PROCEDURE leave_meeting
	(IN floor_number INT , IN room_number INT, IN date DATE, IN start_hour INT, IN end_hour INT, IN employee_id INT) AS
$$
DECLARE 
	attends_count INT := NULL;
	approver_eid INT := NULL;
BEGIN
	LOOP
		EXIT WHEN start_hour >= end_hour;
		
		/*Find if attendee exists*/
		SELECT COUNT(*) INTO attends_count
		FROM attends a
		WHERE a.floor_no = floor_number AND a.room_no = room_number AND a.mdate = date AND a.starttime = start_hour AND a.eid = employee_id;
		
		/*Find if meeting is approved*/
		SELECT m.approver_eid INTO approver_eid
		FROM meetings m
		WHERE m.floor_no = floor_number AND m.room_no = room_number AND m.mdate = date AND m.starttime = start_hour;
		 
		IF (attends_count > 0 AND approver_eid IS NULL) THEN
			DELETE FROM attends a
			WHERE a.floor_no = floor_number AND a.room_no = room_number AND a.mdate = date AND a.starttime = start_hour AND a.eid = employee_id;
		ELSIF (approver_eid IS NOT NULL) THEN /*Redundant? Already covered by triggers*/
			RAISE EXCEPTION 'Unable to leave meeting as meeting has already been approved';
		ELSE 
			RAISE EXCEPTION 'Attendee does not exists';
		END IF;
		start_hour := start_hour + 1;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

/*6.*/
CREATE OR REPLACE PROCEDURE approve_meeting
(IN floor_number INT, IN room_number INT, IN m_date DATE, IN start_time INT, IN end_time INT, IN manager_id INT)
AS $$
BEGIN
    LOOP

    EXIT WHEN start_time >= end_time;
    UPDATE meetings
    SET approver_eid = manager_id
    WHERE mdate = m_date
    AND floor_no = floor_number
    AND room_no = room_number
    AND starttime = start_time;

    start_time := start_time + 1;

    END LOOP;
END;
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
/*HEALTH*/
/*1.*/
/* This part concerns the health_declarations table. Just insert Employee ID,
	Date and Temperature. */
/* ATTACH TRIGGER */
CREATE OR REPLACE PROCEDURE declare_health
	(IN employee_id INT, IN date DATE, IN temperature NUMERIC) AS 
$$
DECLARE 
	declarations_count INT := 0;
BEGIN
	SELECT COUNT(*) INTO declarations_count
	FROM health_declarations
	WHERE d_date = date 
		AND eid = employee_id;
	
	/* Decide further on what to do for this... For now if the temperature is 
		declared, it prevents further insertion. So should we overwrite or allow
		a yes or no question to ask user if they want to overwrite their inputs? */
	IF (declarations_count = 0) THEN
		INSERT INTO health_declarations (d_date, eid, temperature)
			VALUES (date, employee_id, temperature);
		RAISE NOTICE 'You have declared your temperature successfully!';
	ELSE 
		RAISE NOTICE 'You have already declare your temparature!';
		ROLLBACK; 
	END IF;
	
END;
$$ LANGUAGE plpgsql;

/*2.*/
/* Need to return a list of employee id that come into close contact with the person
	with fever! 
	1) All future booking by that employee from meetings table, is cancelled,
	approved or not. (DONE)
	2) The employee also removed from all future attends table, approved 
	or not. (DONE)
	3) All employees in the same approved attends table from the past 3 (from day 
	D-3 to day D) days are contacted. (DONE)
	4) These employees are removed from future attends table in the next 7 days 
	(from day D to day D+7). (DONE) */
CREATE OR REPLACE FUNCTION contact_tracing
	(IN employee_id INT, IN date_of_tracing DATE)  
RETURNS TABLE(employee_contacted INT, date_of_contact DATE) AS
$$
DECLARE
	temperature_of_employee NUMERIC := NULL;
	temp_date DATE := date_of_tracing;
BEGIN
	ALTER TABLE attends DISABLE TRIGGER prevent_participant_modification;
	SELECT temperature INTO temperature_of_employee
	FROM health_declarations
	WHERE d_date = date_of_tracing 
		AND eid = employee_id;
	
	IF (temperature_of_employee IS NULL) THEN
		RAISE NOTICE 'You have not declared temperature yet!!!!!';
		RETURN;
	END IF;
	
	IF (temperature_of_employee > 37.5) THEN
		RAISE NOTICE 'You have fever! Performing contact tracing now and performing';
		
		/* Which of the below DELETION should take place first? */
		/* Remove that employee from all future attends */
		DELETE FROM attends
		WHERE eid = employee_id
			AND mdate >= date_of_tracing; 
			
		/* Remove meetings with booker having fever from all future meetings */
		DELETE FROM meetings
		WHERE booker_eid = employee_id
			AND mdate >= date_of_tracing; 
	ELSE 
		RAISE NOTICE 'YAY, you do not have fever!';
		RETURN; -- Maybe you should put the statement beyond this line into the if clause then you no need this. 
	END IF;
	
	/* Using a while loop to traverse through dates (up to D + 7) of attends table. */
	WHILE (temp_date < date_of_tracing + 8) LOOP -- Should this be + 7 instead?
		DELETE FROM attends
		WHERE mdate = temp_date -- Maybe you don't even need to care about when temp_date = date_of_tracing.
		/* Check using IN with the subquery being all the eid of people coming into contact with the fever person. */
			AND eid IN (SELECT a2.eid
						FROM attends a1 INNER JOIN attends a2 
							ON a1.mdate = a2.mdate 
								AND a1.floor_no = a2.floor_no 
								AND a1.room_no = a2.room_no
						WHERE a1.eid = employee_id AND 
							a2.eid <> a1.eid AND
							(a1.mdate = date_of_tracing
							OR a1.mdate = (date_of_tracing - 1)
							OR a1.mdate = (date_of_tracing - 2) 
							OR a1.mdate = (date_of_tracing - 3))
							AND (SELECT approver_eid 
								FROM meetings m
								WHERE m.mdate = a1.mdate 
									AND m.starttime = a1.starttime
									AND m.floor_no = a1.floor_no
									AND m.room_no = a1.room_no) IS NOT NULL);
		
		temp_date := (temp_date + 1); 
	END LOOP; 
	
	/* Returns the point no. 3 (close contact for back to D - 3)*/
	/* On D date, if the person with fever has same meeting as another person. It is not considered
		close contact in such a case. */
	/* For now the contact_tracing returns the person with fever himself, just add a not equal employee_id
		to remove him. */
	RETURN QUERY SELECT a2.eid, a2.mdate
	FROM attends a1 INNER JOIN attends a2 
		ON a1.mdate = a2.mdate 
			AND a1.floor_no = a2.floor_no 
			AND a1.room_no = a2.room_no
	WHERE a1.eid = employee_id AND 
		a2.eid <> a1.eid AND
		(a1.mdate = date_of_tracing
		OR a1.mdate = (date_of_tracing - 1)
		OR a1.mdate = (date_of_tracing - 2) 
		OR a1.mdate = (date_of_tracing - 3))
		AND (SELECT approver_eid 
			FROM meetings m
			WHERE m.mdate = a1.mdate 
				AND m.starttime = a1.starttime
				AND m.floor_no = a1.floor_no
				AND m.room_no = a1.room_no) IS NOT NULL;
	ALTER TABLE attends ENABLE TRIGGER prevent_participant_modification;
	
END
$$ LANGUAGE plpgsql;
--------------------------------------------------------------------
/*ADMIN*/
/*1.*/
CREATE OR REPLACE FUNCTION non_compliance
	(IN startdate date, IN enddate date)
RETURNS TABLE(eid INT, days BIGINT) AS $$
DECLARE
	currentdate date := startdate;
	num_of_days INT := enddate::date - startdate::date + 1;
BEGIN
	IF num_of_days < 1 THEN RAISE EXCEPTION 'Check date range';
	ELSE
	RETURN QUERY SELECT e1.id as employeeid, (num_of_days - count(d_date)) as days
	FROM employees e1 LEFT OUTER JOIN 
		(SELECT * from
		 health_declarations 
		 WHERE (d_date BETWEEN startdate AND enddate)
		 ) h1
	ON e1.id = h1.eid
	GROUP BY e1.id
	HAVING (num_of_days - count(d_date)) > 0
	ORDER BY days DESC;
	END IF;
END
$$ LANGUAGE plpgsql;

/*2.*/
CREATE OR REPLACE FUNCTION view_booking_report
	(IN startdate date, IN eid INT)
RETURNS TABLE(floor_number INT, room_number INT, 
			  meetingdate DATE, starthour INT, is_approved BOOL) AS $$

BEGIN

RETURN QUERY
SELECT floor_no, room_no, mdate, starttime, CASE
											WHEN approver_eid IS NULL THEN FALSE
											ELSE TRUE END AS is_approved
FROM meetings
WHERE booker_eid = eid
AND mdate >= startdate
ORDER BY mdate ASC, starttime ASC;

END
$$ LANGUAGE plpgsql;

/*3.*/
CREATE OR REPLACE FUNCTION view_future_meeting
	(IN start_date DATE, IN e_eid INT) 
RETURNS TABLE(mdate DATE, starttime INT, floor_no INT, room_no INT) AS
$$
DECLARE
	curs CURSOR FOR (SELECT a.mdate, a.starttime, a.floor_no, a.room_no 
			FROM attends a 
			WHERE a.eid = e_eid AND a.mdate >= start_date
			ORDER BY a.mdate ASC, a.starttime ASC);
	r1 record;
	approver_eid INT;
BEGIN
	OPEN curs;
	LOOP
		FETCH curs INTO r1;
		EXIT WHEN NOT FOUND;
		
		SELECT m.approver_eid INTO approver_eid
		FROM meetings m
		WHERE m.mdate = r1.mdate AND m.starttime = r1.starttime
			AND m.floor_no = r1.floor_no AND m.room_no = r1.room_no;
		
		IF (approver_eid IS NOT NULL) THEN 
			mdate := r1.mdate;
			starttime := r1.starttime;
			floor_no := r1.floor_no;
			room_no := r1.floor_no;
			RETURN NEXT;
		END IF;
	END LOOP;
	CLOSE curs;
END
$$ LANGUAGE plpgsql;

/*4.*/
CREATE OR REPLACE FUNCTION view_manager_report
	(IN start_date DATE, IN input_eid INT) 
RETURNS TABLE(mdate DATE, starttime INT, floor_no INT, room_no INT, booker_eid INT) AS
$$
DECLARE
	curs CURSOR FOR (SELECT * 
			FROM meetings m 
			WHERE m.mdate >= start_date AND m.approver_eid IS NULL
			ORDER BY m.mdate ASC, m.starttime ASC);
	r1 record;
	manager_did INT;
	meeting_did INT;
	manager_count INT := 0;
BEGIN
	/*Return if employee is not a manager*/
	SELECT COUNT(*) INTO manager_count
	FROM managers m
	WHERE m.eid = input_eid;
	
	IF (manager_count = 0) THEN
		RAISE NOTICE 'Not a manager';
		RETURN;
	END IF;

	/*Find manager department*/
	SELECT e.did INTO manager_did
	FROM employees e
	WHERE e.id = input_eid;
	
	OPEN curs;
	LOOP
		FETCH curs INTO r1;
		EXIT WHEN NOT FOUND;
		
		SELECT did INTO meeting_did
		FROM meeting_rooms m
		WHERE m.floor_no = r1.floor_no AND m.room_no = r1.room_no;
		
		IF (manager_did = meeting_did) THEN
			mdate := r1.mdate;
			starttime := r1.starttime;
			floor_no := r1.floor_no;
			room_no := r1.room_no;
			booker_eid := r1.booker_eid;
			RETURN NEXT;
		END IF;
	END LOOP;
	CLOSE curs;
END
$$ LANGUAGE plpgsql;
