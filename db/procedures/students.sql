\c shopman_pos;

-- Fetches all user students
DROP FUNCTION IF EXISTS getallstudents; -- IN in_option BOOLEAN: check why!
CREATE OR REPLACE FUNCTION getallstudents (IN in_connid VARCHAR(128), IN in_classid VARCHAR(10), IN locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_error VARCHAR(255);
    v_students JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('students','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWSTUDS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_usertype := (SELECT usertype FROM users WHERE userid=v_userid);

    IF v_usertype = 'student' THEN
        v_error := (SELECT fetchError(locale,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    ELSE
        IF in_classid IS NULL THEN 
        	v_students := (SELECT json_agg(t) FROM (SELECT u.userid, u.surname, u.othernames, u.dob, u.gender, u.locale, u.onidle, s.matricule, s.doe, s.pob, s.sstatus, st.descript, c.cname, c.classid, c.abbreviation AS cabbrev
					  FROM users u INNER JOIN students s ON u.userId = s.userId
					  INNER JOIN classrooms c ON s.classid = c.classid 
					  INNER JOIN studentstatuses st ON s.sstatus = st.sstatus
					  WHERE u.orgid=v_orgid AND u.usertype='student' AND is_system_user(u.username)=0
					  						AND u.deleted=FALSE ORDER BY s.matricule ASC) AS t);

		ELSE 
			v_students := (SELECT json_agg(t) FROM (SELECT u.userid, u.surname, u.othernames, u.dob, u.gender, u.locale, u.onidle, s.matricule, s.doe, s.pob, s.status, st.descript, c.name, c.classid, c.abbreviation AS cabbrev
					  FROM users u INNER JOIN students s ON u.userId = s.userId
					  INNER JOIN classrooms c ON s.classid = c.classid 
					  INNER JOIN studentstatuses st ON s.status = st.status
					  WHERE u.orgid=v_orgid AND u.usertype="student" AND is_system_user(u.username)=FALSE 
					  		AND u.deleted=FALSE AND c.classid = in_classid::INTEGER AND s.status NOT IN ('dismissed', 'graduate')
                            ORDER BY s.matricule ASC) AS t);
        END IF;
    END IF;

    IF v_students IS NULL THEN
        v_students := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_students,'}}');

    CALL log_activity('students','view',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Adds a new student
DROP FUNCTION IF EXISTS addstudent;
CREATE OR REPLACE FUNCTION addstudent (IN in_surname VARCHAR(64), IN in_othernames VARCHAR(128), 
                                    IN in_dob DATE, IN in_pob VARCHAR(20), 
                                    IN in_gender BOOLEAN, IN in_classid INTEGER, IN in_locale CHAR(5), 
                                    IN in_connid VARCHAR(128), IN in_localee CHAR(2)) 
									RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_users JSON;
    v_role INTEGER;
    v_uid INTEGER;
    v_letter CHAR;
    v_ucount INTEGER;
    V_scount VARCHAR(4);
    v_matricule VARCHAR(10);
    v_year VARCHAR(4);
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','add',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF EXISTS (SELECT * FROM examinations WHERE term IN (SELECT termid FROM academicterm WHERE yearid = active_year(v_orgid))) THEN
    	v_error := (SELECT fetchError(in_localee,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    ELSE
    	IF NOT EXISTS (SELECT * FROM classrooms WHERE classid = in_classid AND orgid = v_orgid and deleted = FALSE) THEN
    		v_error := (SELECT fetchError(in_localee,'studCtAdmiBadClassSpeci')) ;
			RAISE EXCEPTION '%', v_error USING HINT = v_error;
		ELSE 
			v_letter := (SELECT letter FROM classrooms WHERE classid = in_classid);
			v_ucount := (SELECT COUNT(*) FROM students WHERE classid = in_classid);
			v_year := (SELECT DATE_PART('year', CURRENT_DATE));
			v_scount := (SELECT TO_CHAR(v_ucount+1,'fm0000'));
			v_matricule := (CONCAT(v_year,v_letter,v_scount));

			INSERT INTO users(orgid, username,surname,othernames, usertype, dob, gender, onidle, locale)
		    VALUES(v_orgid, v_matricule, in_surname,in_othernames, 'student', in_dob, in_gender, 'logOut',in_locale) RETURNING userid INTO v_uid;

		    INSERT INTO students(userid, matricule, classid, pob) VALUES (v_uid, v_matricule, in_classid, in_pob);

            CALL log_activity('students','add',in_connid,CONCAT('Added. User Id:',v_uid,',matricule:',v_matricule),TRUE);

            au := (SELECT getallstudents(in_connid, NULL, in_localee));

		    RETURN au;
    	END IF;
    END IF;
END; $$;

-- Adds a new student
DROP FUNCTION IF EXISTS editstudent;
CREATE OR REPLACE FUNCTION editstudent (IN in_userid INTEGER, IN in_surname VARCHAR(64), IN in_othernames VARCHAR(128), 
                                    IN in_dob DATE, IN in_pob VARCHAR(20), 
                                    IN in_gender BOOLEAN, IN in_classid INTEGER, IN in_locale CHAR(5), 
                                    IN in_connid VARCHAR(128), IN in_localee CHAR(2)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_users JSON;
    v_role INTEGER;
    v_uid INTEGER;
    v_letter CHAR;
    v_ucount INTEGER;
    V_scount VARCHAR(4);
    v_matricule VARCHAR(10);
    v_year VARCHAR(4);
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','edit',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF EXISTS (SELECT * FROM examinations WHERE term IN (SELECT termid FROM academicterm WHERE yearid = active_year(v_orgid))) THEN
        v_error := (SELECT fetchError(in_localee,'loginGoAway')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    ELSE
        IF NOT EXISTS (SELECT * FROM classrooms WHERE classid = in_classid AND orgid = v_orgid and deleted = FALSE) THEN
            v_error := (SELECT fetchError(in_localee,'studCtAdmiBadClassSpeci')) ;
            RAISE EXCEPTION '%', v_error USING HINT = v_error;
        ELSE 
            UPDATE users SET surname = in_surname, othernames = in_othernames, 
                    gender = in_gender, dob = in_dob WHERE userid = in_userid;
            UPDATE students SET pob = in_pob, classid = in_classid WHERE userid = in_userid;

            CALL log_activity('student','edit',in_connid,CONCAT('Modified. User Id:',v_uid,',surname:',in_surname,',othernames:',in_othernames,',dob:',in_dob,',pob:',in_pob,',gender:',in_gender,',classid:',in_classid),TRUE);

            au := (SELECT getallstudents(in_connid, NULL, in_localee));

            RETURN au;
        END IF;
    END IF;
END; $$;

-- Adds a new student
DROP FUNCTION IF EXISTS fetchstudentparents;
CREATE OR REPLACE FUNCTION fetchstudentparents (IN in_userid INTEGER, IN in_connid VARCHAR(128), IN in_locale CHAR(2)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_parents JSON;
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','parents',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM students WHERE userid = in_userid) THEN
        v_error := (SELECT fetchError(in_localee,'studNoSuchStud')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_parents := (SELECT json_agg(t) FROM (SELECT * FROM users WHERE userid IN (SELECT UNNEST(parents) FROM students WHERE userid = in_userid)) AS t);

    IF v_parents IS NULL THEN
        v_parents := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_parents,'}}');

    CALL log_activity('students','parents',in_connid,CONCAT('Fetched. For stud:',in_userid),TRUE);

    RETURN au;

END; $$;

-- Removes a parent from a student
DROP FUNCTION IF EXISTS removestudentparent;
CREATE OR REPLACE FUNCTION removestudentparent (IN in_studentid INTEGER, IN in_parentid INTEGER, IN in_connid VARCHAR(128), IN in_locale CHAR(2)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_parents JSON;
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','parents',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM students WHERE userid = in_studentid) THEN
        v_error := (SELECT fetchError(in_localee,'studNoSuchStud')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE students SET parents = ARRAY_REMOVE((SELECT parents FROM students WHERE userid = in_studentid), in_parentid) WHERE userid = in_studentid;
    
    v_parents := (SELECT json_agg(t) FROM (SELECT * FROM users WHERE userid IN (SELECT UNNEST(parents) FROM students WHERE userid = in_studentid)) AS t);

    IF v_parents IS NULL THEN
        v_parents := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_parents,'}}');

    CALL log_activity('students','parents',in_connid,CONCAT('Removed. For stud:',in_studentid,':parentid:',in_parentid),TRUE);

    RETURN au;
END; $$;

-- Adds a parent to a student
DROP FUNCTION IF EXISTS addstudentparent;
CREATE OR REPLACE FUNCTION addstudentparent (IN in_studentid INTEGER, IN in_parentid INTEGER, IN in_connid VARCHAR(128), IN in_locale CHAR(2)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_parents JSON;
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','parents',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM students WHERE userid = in_studentid) THEN
        v_error := (SELECT fetchError(in_localee,'studNoSuchStud')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE students SET parents = ARRAY_APPEND((SELECT parents FROM students WHERE userid = in_studentid), in_parentid) WHERE userid = in_studentid;
    
    v_parents := (SELECT json_agg(t) FROM (SELECT * FROM users WHERE userid IN (SELECT UNNEST(parents) FROM students WHERE userid = in_studentid)) AS t);

    IF v_parents IS NULL THEN
        v_parents := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_parents,'}}');

    CALL log_activity('students','parents',in_connid,CONCAT('Added. For stud:',in_studentid,':parentid:',in_parentid),TRUE);

    RETURN au;
END; $$;

-- Adds a picture to a student
DROP FUNCTION IF EXISTS updatestudentpicture;
CREATE OR REPLACE FUNCTION updatestudentpicture (IN in_studentid INTEGER, IN in_photo TEXT, IN in_connid VARCHAR(128), IN in_locale CHAR(2)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_students JSON;
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','photo',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM students WHERE userid = in_studentid) THEN
        v_error := (SELECT fetchError(in_localee,'studNoSuchStud')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE students SET picture = in_photo WHERE userid = in_studentid;

    au := CONCAT('{"error":false,"result":{"status":200,"value":"ok"}}');

    CALL log_activity('students','photo',in_connid,CONCAT('Added. Pic to stud:',in_studentid),TRUE);

    RETURN au;
END; $$;

-- Gets a student picture
DROP FUNCTION IF EXISTS getstudentpicture;
CREATE OR REPLACE FUNCTION getstudentpicture (IN in_studentid INTEGER, IN in_connid VARCHAR(128), IN in_locale CHAR(2)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_picture JSON;
    au VARCHAR(9216);
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','photo',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM students WHERE userid = in_studentid) THEN
        v_error := (SELECT fetchError(in_localee,'studNoSuchStud')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_picture := (SELECT json_agg(t) FROM (SELECT picture FROM students where userid=in_studentid) AS t);

    IF v_picture IS NULL THEN
        v_picture := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_picture,'}}');

    CALL log_activity('students','photo',in_connid,CONCAT('Fetched. Pic for stud:',in_studentid),TRUE);

    RETURN au;
END; $$;

-- Adds student batch
DROP FUNCTION IF EXISTS uploadbatchstudents;
CREATE OR REPLACE FUNCTION uploadbatchstudents (IN in_batch VARCHAR(9216), IN in_connid VARCHAR(128), IN in_locale CHAR(5)) 
                                    RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    au VARCHAR(9216);
    res VARCHAR(9216);
    i JSON;
BEGIN
    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    CALL log_activity('students','batch',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    in_batch := (SELECT REPLACE(in_batch, '\',''));
    FOR i IN SELECT * FROM JSONB_ARRAY_ELEMENTS(in_batch::JSONB)
    LOOP
        res := (SELECT addstudent(CAST(i->>'surname' AS VARCHAR),CAST(i->>'othernames' AS VARCHAR), CAST(i->>'dob' AS DATE), CAST(i->>'pob' AS VARCHAR),CAST( i->>'gender' AS BOOLEAN), CAST(i->>'classroomid' AS INTEGER), in_locale, in_connid, in_locale));
    END LOOP;

    CALL log_activity('students','batch',in_connid,CONCAT('Added batch:',in_batch),TRUE);
    au := (SELECT getallstudents(in_connid, NULL, in_locale));
    RETURN au;
END; $$;