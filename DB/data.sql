/* Data for Test */

/* Departments */
INSERT INTO departments (did, name) VALUES (1, 'Services');
INSERT INTO departments (did, name) VALUES (2, 'Accounting');
INSERT INTO departments (did, name) VALUES (3, 'Product Management');
INSERT INTO departments (did, name) VALUES (4, 'Sales');
INSERT INTO departments (did, name) VALUES (5, 'Human Resources');
INSERT INTO departments (did, name) VALUES (6, 'Business Development');
INSERT INTO departments (did, name) VALUES (7, 'Engineering');
INSERT INTO departments (did, name) VALUES (8, 'Marketing');
INSERT INTO departments (did, name) VALUES (9, 'Training');
INSERT INTO departments (did, name) VALUES (10, 'Legal');

/* Employees */
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (1, 'fgratton0@tuttocitta.it', 'Felita', '127-992-9313', null, 1);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (2, 'otremoille1@i2i.jp', 'Orren', '846-949-8309', null, 2);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (3, 'ddeering2@sogou.com', 'Darb', '410-411-6987', null, 3);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (4, 'swhatling3@purevolume.com', 'Sarge', '806-599-5745', null, 4);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (5, 'dburcher4@wikipedia.org', 'Dom', '177-516-3254', null, 5);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (6, 'ddonnan5@fastcompany.com', 'Dinnie', '702-646-5966', null, 6);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (7, 'mdinneen6@wix.com', 'Marsha', '944-968-8833', null, 7);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (8, 'frosentholer7@topsy.com', 'Fawnia', '855-340-4743', null, 8);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (9, 'tsimoneau8@indiatimes.com', 'Terrill', '477-330-3216', null, 9);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (10, 'fhampshire9@epa.gov', 'Flint', '191-479-3924', null, 10);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (11, 'jjzaka@dedecms.com', 'Jobina', '694-684-3549', null, 1);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (12, 'okingsworthb@independent.co.uk', 'Othella', '893-818-6638', null, 2);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (13, 'jmcianc@foxnews.com', 'Jessi', '964-153-9349', null, 3);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (14, 'ibrunoned@wordpress.org', 'Ignacius', '100-266-3241', null, 4);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (15, 'kchazellee@spiegel.de', 'Korie', '359-912-0627', null, 5);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (16, 'dsolowayf@ning.com', 'Danyelle', '514-501-6312', null, 6);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (17, 'blohdeg@odnoklassniki.ru', 'Beatriz', '507-920-7071', null, 7);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (18, 'ispellerh@amazon.com', 'Inness', '414-758-3440', null, 8);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (19, 'epettengelli@gnu.org', 'Edna', '156-662-3473', null, 9);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (20, 'slicasj@tripadvisor.com', 'Sullivan', '563-428-0382', null, 10);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (21, 'ufolkerk@oakley.com', 'Uta', '670-961-2881', null, 1);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (22, 'mlincel@soup.io', 'Merrili', '997-379-7775', null, 2);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (23, 'lcroutearm@chron.com', 'Lindsey', '658-392-5036', null, 3);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (24, 'broscampn@globo.com', 'Bunni', '876-296-8070', null, 4);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (25, 'herto@deviantart.com', 'Hunter', '726-777-1616', null, 5);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (26, 'mlishmundp@prweb.com', 'Maynord', '605-460-5176', null, 6);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (27, 'lkennq@wikimedia.org', 'Linoel', '760-739-0009', null, 7);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (28, 'kwallingr@gravatar.com', 'Kyle', '434-581-4931', null, 8);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (29, 'qwasielewskis@topsy.com', 'Quent', '405-959-0201', null, 9);
INSERT INTO employees (id, email, name, contact_no, resignation_date, did) VALUES (30, 'gmacnamarat@cnet.com', 'Glori', '441-922-2908', null, 10);

/* Health declarations */
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 1, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 2, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 3, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 4, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 5, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 6, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 7, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 8, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 9, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 10, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 11, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 12, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 13, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 14, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 15, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 16, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 17, 35.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 18, 35.8);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 19, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 20, 35.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 21, 35.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 22, 35.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 23, 35.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 24, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 25, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 26, 35.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 27, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 28, 36.5);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 29, 36.7);
INSERT INTO health_declarations (d_date, eid, temperature) VALUES (CURRENT_DATE, 30, 36.7);

/* Juniors */
INSERT INTO juniors (eid) VALUES (1);
INSERT INTO juniors (eid) VALUES (2);
INSERT INTO juniors (eid) VALUES (3);
INSERT INTO juniors (eid) VALUES (4);
INSERT INTO juniors (eid) VALUES (5);
INSERT INTO juniors (eid) VALUES (6);
INSERT INTO juniors (eid) VALUES (7);
INSERT INTO juniors (eid) VALUES (8);
INSERT INTO juniors (eid) VALUES (9);
INSERT INTO juniors (eid) VALUES (10);

/* Bookers */
INSERT INTO bookers (eid) VALUES (11);
INSERT INTO bookers (eid) VALUES (12);
INSERT INTO bookers (eid) VALUES (13);
INSERT INTO bookers (eid) VALUES (14);
INSERT INTO bookers (eid) VALUES (15);
INSERT INTO bookers (eid) VALUES (16);
INSERT INTO bookers (eid) VALUES (17);
INSERT INTO bookers (eid) VALUES (18);
INSERT INTO bookers (eid) VALUES (19);
INSERT INTO bookers (eid) VALUES (20);
INSERT INTO bookers (eid) VALUES (21);
INSERT INTO bookers (eid) VALUES (22);
INSERT INTO bookers (eid) VALUES (23);
INSERT INTO bookers (eid) VALUES (24);
INSERT INTO bookers (eid) VALUES (25);
INSERT INTO bookers (eid) VALUES (26);
INSERT INTO bookers (eid) VALUES (27);
INSERT INTO bookers (eid) VALUES (28);
INSERT INTO bookers (eid) VALUES (29);
INSERT INTO bookers (eid) VALUES (30);

/* Seniors */
INSERT INTO seniors (eid) VALUES (11);
INSERT INTO seniors (eid) VALUES (12);
INSERT INTO seniors (eid) VALUES (13);
INSERT INTO seniors (eid) VALUES (14);
INSERT INTO seniors (eid) VALUES (15);
INSERT INTO seniors (eid) VALUES (16);
INSERT INTO seniors (eid) VALUES (17);
INSERT INTO seniors (eid) VALUES (18);
INSERT INTO seniors (eid) VALUES (19);
INSERT INTO seniors (eid) VALUES (20);

/* Managers */
INSERT INTO managers (eid) VALUES (21);
INSERT INTO managers (eid) VALUES (22);
INSERT INTO managers (eid) VALUES (23);
INSERT INTO managers (eid) VALUES (24);
INSERT INTO managers (eid) VALUES (25);
INSERT INTO managers (eid) VALUES (26);
INSERT INTO managers (eid) VALUES (27);
INSERT INTO managers (eid) VALUES (28);
INSERT INTO managers (eid) VALUES (29);
INSERT INTO managers (eid) VALUES (30);

BEGIN;
/* Meeting rooms */
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (1, 1, 'consequat', 1);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (1, 2, 'cum', 2);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (1, 3, 'elit', 3);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (1, 4, 'nullam', 4);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (1, 5, 'lorem', 5);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (2, 1, 'volutpat', 6);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (2, 2, 'amet', 7);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (2, 3, 'sem', 8);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (2, 4, 'nulla', 9);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (2, 5, 'pellentesque', 10);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (3, 1, 'purus', 1);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (3, 2, 'luctus', 2);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (3, 3, 'vivamus', 3);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (3, 4, 'etiam', 4);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (3, 5, 'a', 5);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (4, 1, 'dictumst', 6);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (4, 2, 'in', 7);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (4, 3, 'lacus', 8);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (4, 4, 'in', 9);
INSERT INTO meeting_rooms (floor_no, room_no, name, did) VALUES (4, 5, 'velit', 10);

/* Updates */
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (1, 1, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 21);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (1, 2, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 22);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (1, 3, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 23);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (1, 4, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 24);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (1, 5, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 25);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (2, 1, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 26);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (2, 2, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 27);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (2, 3, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 28);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (2, 4, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 29);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (2, 5, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 30);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (3, 1, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 21);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (3, 2, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 22);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (3, 3, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 23);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (3, 4, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 24);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (3, 5, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 25);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (4, 1, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 26);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (4, 2, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 27);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (4, 3, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 28);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (4, 4, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 29);
INSERT INTO updates (floor_no, room_no, udate, capacity, mid) VALUES (4, 5, (CURRENT_DATE - INTERVAL '1 DAY')::date, 10, 30);

COMMIT;

/* meetings */
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 1, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 11);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 2, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 12);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 3, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 13);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 4, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 14);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (1, 5, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 15);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (2, 1, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 16);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (2, 2, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 17);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (2, 3, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 18);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (2, 4, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 19);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (2, 5, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 20);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (3, 1, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 21);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (3, 2, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 22);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (3, 3, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 23);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (3, 4, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 24);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (3, 5, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 25);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (4, 1, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 26);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (4, 2, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 27);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (4, 3, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 28);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (4, 4, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 29);
INSERT INTO meetings (floor_no, room_no, mdate, starttime, booker_eid) VALUES (4, 5, (CURRENT_DATE + INTERVAL '1 DAY')::date, 12, 30);
