--------------------------------------------------------------------
/* TEST CASE (booker_nofever) */
/* 1 */
INSERT INTO departments (did, name) VALUES (1, 'temp1');
INSERT INTO employees (id, email, name, contact_no, did) VALUES (1, 'A.GMAIL','Andy','999', 1);
INSERT INTO employees (id, email, name, contact_no, did) VALUES (2, 'B.GMAIL','Ben','989', 1);
INSERT INTO bookers (eid) VALUES (1);
INSERT INTO managers (eid) VALUES (1);
INSERT INTO bookers (eid) VALUES (2);
INSERT INTO managers (eid) VALUES (2);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (1, 1, 'meetrm1', 1);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (TO_DATE('23/10/2021', 'DD/MM/YYYY'), 1, 39.0);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (TO_DATE('23/10/2021', 'DD/MM/YYYY'), 2, 37.0);

/* (Fail) */
INSERT INTO meetings (starttime, mdate, floor_no, room_no, booker_eid, approver_eid) VALUES (10, TO_DATE('23/11/2021', 'DD/MM/YYYY'), 1, 1, 1, NULL);
/* (Pass) */
INSERT INTO meetings (starttime, mdate, floor_no, room_no, booker_eid, approver_eid) VALUES (10, TO_DATE('23/11/2021', 'DD/MM/YYYY'), 1, 1, 2, NULL);
--------------------------------------------------------------------
/* TEST CASE (employee_isa) */
/* 1 */
DELETE FROM seniors;
DELETE FROM juniors;
DELETE FROM seniors;
DELETE FROM employees;
INSERT INTO employees (id, email, name, contact_no, did) VALUES (1, 'A.GMAIL','Andy','999', 1);
INSERT INTO employees (id, email, name, contact_no, did) VALUES (2, 'B.GMAIL','Ben','989', 1);
INSERT INTO employees (id, email, name, contact_no, did) VALUES (3, 'C.GMAIL','Cindy','996', 1);
INSERT INTO managers (eid) VALUES (1);
INSERT INTO seniors (eid) VALUES (2);
INSERT INTO juniors (eid) VALUES (3);

/* Trying to UPDATE seniors to someone who is managers (Fail) */
UPDATE seniors 
SET eid = 1
WHERE eid = 2;
/* Trying to INSERT seniors who is already juniors (Fail) */
INSERT INTO seniors (eid) VALUES (3);
/* Update a eid (Pass) */
INSERT INTO employees (id, email, name, contact_no, did) VALUES (4, 'AA.GMAIL','Andy','999', 1);
UPDATE seniors 
SET eid = 4
WHERE eid = 2;

/* Trying to UPDATE managers to someone who is seniors (Fail) */
UPDATE managers 
SET eid = 2
WHERE eid = 1;
/* Trying to INSERT managers who is already juniors (Fail) */
INSERT INTO managers (eid) VALUES (3);
/* Update a eid (Pass) */
INSERT INTO employees (id, email, name, contact_no, did) VALUES (5, 'BB.GMAIL','Ben','989', 1);
UPDATE managers 
SET eid = 5
WHERE eid = 1;

/* Trying to UPDATE juniors to someone who is managers (Fail) */
UPDATE juniors 
SET eid = 5
WHERE eid = 3;
/* Trying to INSERT juniors who is already seniors (Fail) */
INSERT INTO juniors (eid) VALUES (2);
/* Update a eid (Pass) */
INSERT INTO employees (id, email, name, contact_no, did) VALUES (6, 'CC.GMAIL','Cindy','996', 1);
UPDATE juniors 
SET eid = 6
WHERE eid = 3;
--------------------------------------------------------------------
/* TEST CASE (change_capacity) */
/* 1 */
SET datestyle TO DMY;
CALL change_capacity (1, 1, 90, '26/10/2021');
CALL change_capacity (1, 1, 10, '26/10/2021');
--------------------------------------------------------------------
/* TEST CASE (add_employee) */
/* 1 */
(IN employee_name VARCHAR(50), IN contact_number VARCHAR(20), IN kind VARCHAR(10), IN department_id INTEGER) 
CALL add_employee ('joe', '96969', 'seniors', 1);
CALL add_employee ('joe', '96969', 'managers', 1);
CALL add_employee ('joe', '96969', 'juniors', 1);
--------------------------------------------------------------------
/* TEST CASE (remove_employee) */
/* 1 */
/* Test for if approver is fired, it keeps the meeting intact, just without approver. */
UPDATE meetings
SET approver_eid = 41
WHERE starttime =  12
	AND mdate = '28/10/2021'   
	AND floor_no = 4
	AND room_no = 5
	AND booker_eid = 30;
	
CALL remove_employee (11, '26/10/2021');
CALL remove_employee (12, '26/10/2021');
--------------------------------------------------------------------
/* TEST CASE (declare_health) */
/* 1 */
CALL declare_health (13, '29-10-2021', 36.0);
--------------------------------------------------------------------
/* TEST CASE (contact_tracing) */
/* 1 */
/* Needs to be tested */
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 3, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 13);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 1, (CURRENT_DATE + INTERVAL '0 DAY')::date, 12, 13);

INSERT INTO attends (floor_no, room_no, mdate, starttime, eid) VALUES (1, 1, (CURRENT_DATE - INTERVAL '0 DAY')::date, 12, 2);
INSERT INTO attends (floor_no, room_no, mdate, starttime, eid) VALUES (1, 1, (CURRENT_DATE - INTERVAL '0 DAY')::date, 12, 2);

INSERT INTO attends (floor_no, room_no, mdate, starttime, eid) values (1, 3, '30/10/2021', 12, 14);

SELECT *
FROM attends;

SELECT *
FROM meetings;

SELECT *
FROM attends
WHERE mdate = '30/10/2021'
	AND floor_no = 1
	AND room_no = 3;
	
SELECT *
FROM attends
WHERE mdate = '31/10/2021'
	AND floor_no = 1
	AND room_no = 5;

CALL declare_health (13, '31-10-2021', 38.0);
SELECT contact_tracing (13, '31-10-2021');

INSERT INTO attends (floor_no, room_no, mdate, starttime, eid) values (1, 5, '31/10/2021', 12, 14);

INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) values (1, 5, '02/11/2021', 12, 15);
INSERT INTO attends (floor_no, room_no, mdate, starttime, eid) values (1, 5, '02/11/2021', 12, 14);

SELECT *
FROM attends
WHERE mdate = '02/11/2021'
	AND floor_no = 1
	AND room_no = 5;

/* SQL Logging */
/* In this test, you should test the function in a way such that no.3 is tested first, 
	do this by commenting out the while loop where you delete the attendees that is 
	close contact up to D + 7. */
/*
-- This Part test for point no. 3
-- CALL declare_health (13, '31-10-2021', 38.0);
-- So all people 3 days before 31-10-2021 in same meeting as fever person must be returned!
-- So in this case, eid 13 and 14 contact date will be shown.
--------------------------------------------------------------------
postgres=# SELECT *
postgres-# FROM attends
postgres-# WHERE mdate = '30/10/2021'
postgres-# AND floor_no = 1
postgres-# AND room_no = 3;
 eid | starttime |   mdate    | floor_no | room_no
-----+-----------+------------+----------+---------
  13 |        12 | 2021-10-30 |        1 |       3
  14 |        12 | 2021-10-30 |        1 |       3
(2 rows)


postgres=# CALL declare_health (13, '31-10-2021', 38.0);
NOTICE:  You have declared your temperature successfully!
CALL
postgres=# SELECT contact_tracing (13, '29-10-2021');
NOTICE:  YAY, you do not have fever!
ERROR:  invalid transaction termination
CONTEXT:  PL/pgSQL function contact_tracing(integer,date) line 26 at ROLLBACK
postgres=# SELECT contact_tracing (13, '31-10-2021');
NOTICE:  You have fever! Performing contact tracing now and performing
 contact_tracing
-----------------
 (13,2021-10-28)
 (13,2021-10-30)
 (14,2021-10-30)
 (13,2021-10-29)
(4 rows)
--------------------------------------------------------------------
-- This Part test for point no. 4
-- CALL declare_health (13, '31-10-2021', 38.0);
-- So now even future attendees which are close contact must be removed.
-- In this example, I made a meeting on 2021-11-02 where both 14 and 15 is attending.
-- Since 14 come into close contact with 14 on 2021-10-30, we must make sure that
-- 14 is being removed from that meetin on 2021-11-02...
--------------------------------------------------------------------
postgres=# SELECT *
postgres-# FROM attends
postgres-# WHERE mdate = '31/10/2021'
postgres-# AND floor_no = 1
postgres-# AND room_no = 5;
 eid | starttime |   mdate    | floor_no | room_no
-----+-----------+------------+----------+---------
  14 |        12 | 2021-10-31 |        1 |       5
  15 |        12 | 2021-10-31 |        1 |       5
(2 rows)

postgres=# SELECT *
postgres-# FROM attends
postgres-# WHERE mdate = '02/11/2021'
postgres-# AND floor_no = 1
postgres-# AND room_no = 5;
 eid | starttime |   mdate    | floor_no | room_no
-----+-----------+------------+----------+---------
  14 |        12 | 2021-11-02 |        1 |       5
  15 |        12 | 2021-11-02 |        1 |       5
(2 rows)

postgres=# SELECT contact_tracing (13, '31-10-2021');
NOTICE:  You have fever! Performing contact tracing now and performing
 contact_tracing
-----------------
 (13,2021-10-28)
 (13,2021-10-30)
 (13,2021-10-29)
 (14,2021-10-30)
(4 rows)

postgres=# SELECT *
postgres-# FROM attends
postgres-# WHERE mdate = '31/10/2021'
postgres-# AND floor_no = 1
postgres-# AND room_no = 5;
 eid | starttime |   mdate    | floor_no | room_no
-----+-----------+------------+----------+---------
  15 |        12 | 2021-10-31 |        1 |       5
(1 row)

postgres=# SELECT *
postgres-# FROM attends
postgres-# WHERE mdate = '02/11/2021'
postgres-# AND floor_no = 1
postgres-# AND room_no = 5;
 eid | starttime |   mdate    | floor_no | room_no
-----+-----------+------------+----------+---------
  15 |        12 | 2021-11-02 |        1 |       5
(1 row)
*/
--------------------------------------------------------------------
CREATE OR REPLACE FUNCTION contact_tracing_caller()
RETURNS TRIGGER AS $$
DECLARE 
	employee_id INT;
	date_of_tracing DATE;
BEGIN
	employee_id := NEW.eid;
	date_of_tracing := NEW.d_date;
	
	IF (NEW.temperature > 37.5) THEN
		PERFORM * FROM contact_tracing (employee_id, date_of_tracing);
		RETURN NEW;
	ELSE
		RETURN NEW;
	END IF;	 
	
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS contact_tracing_trigger ON health_declarations;
CREATE TRIGGER contact_tracing_trigger
AFTER INSERT OR UPDATE ON health_declarations
FOR EACH ROW EXECUTE FUNCTION contact_tracing_caller();
--------------------------------------------------------------------