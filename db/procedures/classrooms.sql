\c shopman_pos;

-- Fetches all user classrooms
DROP FUNCTION IF EXISTS getallclassrooms; -- IN in_option BOOLEAN: check why!
CREATE OR REPLACE FUNCTION getallclassrooms (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_classrooms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCLASS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_usertype := (SELECT usertype FROM users WHERE userid=v_userid);

    IF v_usertype IN ('teacher', 'hybrid1', 'hybrid2', 'hybrid4') THEN -- It's a class master fetching the data
        v_classrooms := (SELECT json_agg(t) FROM (SELECT c.classid, c.cname, c.abbreviation, c.descript, c.letter, 
            CONCAT(t.surname,' ',t.othernames) AS classmaster, 
            CONCAT(s.surname,' ',s.othernames) AS classhead  
            FROM classrooms c LEFT JOIN users t ON c.classmaster = t.userid 
            LEFT JOIN users s ON c.classhead = s.userid 
            WHERE c.deleted = FALSE AND c.orgId=v_orgId AND c.classmaster = v_userid) AS t);
    ELSE
        v_classrooms := (SELECT json_agg(t) FROM (SELECT c.classid, c.cname, c.abbreviation, c.descript, c.letter, 
            CONCAT(t.surname,' ',t.othernames) AS classmaster, 
            CONCAT(s.surname,' ',s.othernames) AS classhead 
            FROM classrooms c LEFT JOIN users t ON c.classmaster = t.userid 
            LEFT JOIN users s ON c.classhead = s.userid 
            WHERE c.deleted = FALSE AND c.orgId=v_orgId) AS t);
    END IF;

    IF v_classrooms IS NULL THEN
        v_classrooms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_classrooms,'}}');

    CALL log_activity('classrooms','view',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Create new classroom
DROP FUNCTION IF EXISTS createclassroom;
CREATE OR REPLACE FUNCTION createclassroom (IN in_connid VARCHAR(128), IN in_name VARCHAR(255), IN in_abbreviation VARCHAR(10), IN in_description VARCHAR(255), IN in_letter CHAR(1)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_classrooms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','add',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCLASS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    INSERT INTO classrooms(cname, abbreviation, descript, letter, orgid) VALUES (in_name, in_abbreviation, in_description, in_letter, v_orgid);

    v_classrooms := (SELECT json_agg(t) FROM (SELECT c.classid, c.cname, c.abbreviation, c.descript,
        CONCAT(t.surname,' ',t.othernames) AS classmaster, 
        CONCAT(s.surname,' ',s.othernames) AS classhead 
        FROM classrooms c LEFT JOIN users t ON c.classmaster = t.userid 
        LEFT JOIN users s ON c.classhead = s.userid 
        WHERE c.deleted = FALSE AND c.orgId=v_orgId) AS t);

    IF v_classrooms IS NULL THEN
        v_classrooms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_classrooms,'}}');

    CALL log_activity('classrooms','create',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Update classroom
DROP FUNCTION IF EXISTS updateclassroom;
CREATE OR REPLACE FUNCTION updateclassroom (IN in_connid VARCHAR(128), IN in_classid INTEGER, IN in_name VARCHAR(255), IN in_abbreviation VARCHAR(10), IN in_description VARCHAR(255), IN in_letter CHAR(1)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_classrooms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','modify',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCLASS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    UPDATE classrooms SET 
        cname = in_name, abbreviation = in_abbreviation, descript = in_description, letter = in_letter
             WHERE classid = in_classid AND deleted = false;

    v_classrooms := (SELECT json_agg(t) FROM (SELECT c.classid, c.cname, c.abbreviation, c.descript, 
        CONCAT(t.surname,' ',t.othernames) AS classmaster, 
        CONCAT(s.surname,' ',s.othernames) AS classhead 
        FROM classrooms c LEFT JOIN users t ON c.classmaster = t.userid 
        LEFT JOIN users s ON c.classhead = s.userid 
        WHERE c.deleted = FALSE AND c.orgId=v_orgId) AS t);

    IF v_classrooms IS NULL THEN
        v_classrooms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_classrooms,'}}');

    CALL log_activity('classrooms','modify',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Fetches all classroom teachers
DROP FUNCTION IF EXISTS getclassroomteachers;
CREATE OR REPLACE FUNCTION getclassroomteachers (IN in_connid VARCHAR(128), IN in_classid INTEGER, IN locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_classrooms JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','teachers',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCLASS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM classrooms WHERE classid = in_classid) THEN
        v_error := (SELECT fetchError(locale,'classTeachersAdd')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_classrooms := (SELECT json_agg(t) FROM (SELECT s.subjectid, s.code, s.sname, s.descript, 
                    u.userid, u.surname, u.othernames FROM subjects s 
                    LEFT JOIN classsubjects cs ON cs.subjectid=s.subjectid 
                    LEFT JOIN users u ON cs.userid = u.userid
                    WHERE  cs.classid=in_classid AND cs.yearid = active_year(v_orgid) 
                    AND u.usertype IN ('teacher', 'hybrid1', 'hybrid2', 'hybrid4')) AS t);

    IF v_classrooms IS NULL THEN
        v_classrooms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_classrooms,'}}');

    CALL log_activity('classrooms','teachers',in_connid,CONCAT('Viewed. For class:',in_classid),TRUE);

    RETURN au;
END; $$;

-- Add teacher subject
DROP FUNCTION IF EXISTS addteacherclassroom;
CREATE OR REPLACE FUNCTION addteacherclassroom (
        IN in_connid VARCHAR(128), 
        IN in_classid INTEGER, 
        IN in_userid INTEGER, 
        IN in_subjectid INTEGER, 
        IN locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_classrooms JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','teachers',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCLASS');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM users WHERE userid=in_userid and usertype IN ('teacher','hybrid1','hybrid2','hybrid4')) THEN
        v_error := (SELECT fetchError(locale,'classUsrNotTeacher')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF EXISTS (SELECT * FROM examinations e JOIN academicterm t ON e.term = t.termid WHERE t.yearid=active_year(v_orgid) AND e.startdate<=CURRRENT_DATE) THEN
        v_error := (SELECT fetchError(locale,'classAddTeacher')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF active_year(v_orgid) = FALSE THEN
        v_error := (SELECT fetchError(locale,'calTermNoActYear')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF EXISTS (SELECT * FROM subjects WHERE subjectid=in_subjectId AND deleted=TRUE) THEN
        RAISE EXCEPTION '%', 'Subject doesn''t exits' USING HINT = 'Subject doesn''t exits';
    END IF;

    IF EXISTS(SELECT * FROM classsubjects WHERE classid=in_classid AND subjectid=in_subjectid AND yearid=active_year(v_orgid)) THEN
        v_error := (SELECT fetchError(locale,'classDoingSubject')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF NOT EXISTS(SELECT * FROM students WHERE classid=in_classid AND status NOT IN ('dismissed','graduate')) THEN -- There is atleast one student in that class
        v_error := (SELECT fetchError(locale,'classStudsNotInClass')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    INSERT INTO classsubjects(userid, classid, subjectid,yearid) VALUES (in_userid,in_classid,in_subjectid,active_year(v_orgid));

    v_classrooms := (SELECT json_agg(t) FROM (SELECT s.subjectid, s.code, s.sname, s.descript, 
                    u.userid, u.surname, u.othernames FROM subjects s 
                    LEFT JOIN classsubjects cs ON cs.subjectid=s.subjectid 
                    LEFT JOIN users u ON cs.userid = u.userid
                    WHERE  cs.classid=in_classid AND cs.yearid = active_year(v_orgid) 
                    AND u.usertype IN ('teacher', 'hybrid1', 'hybrid2', 'hybrid4')) AS t);

    IF v_classrooms IS NULL THEN
        v_classrooms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_classrooms,'}}');

    CALL log_activity('classrooms','teachers',in_connid,CONCAT('Added. For teacher:',in_userid,', for class:',in_classid,'subject:',in_subjectid),TRUE);

    RETURN au;
END; $$;

-- Add teacher subjects
DROP FUNCTION IF EXISTS addteacherclassrooms;
CREATE OR REPLACE FUNCTION addteacherclassrooms (
        IN in_connid VARCHAR(128), 
        IN in_classids TEXT, 
        IN in_userid INTEGER, 
        IN in_subjectid INTEGER, 
        IN locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_classrooms JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
    v VARCHAR(32);
    out_failed VARCHAR(255);
BEGIN
    CALL log_activity('classrooms','teachers',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCLASS');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM users WHERE userid=in_userid and usertype IN ('teacher','hybrid1','hybrid2','hybrid4')) THEN
        v_error := (SELECT fetchError(locale,'classUsrNotTeacher')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF EXISTS (SELECT * FROM examinations e JOIN academicterm t ON e.term = t.termid WHERE t.yearid=active_year(v_orgid) AND e.startdate <= CURRENT_DATE) THEN
        v_error := (SELECT fetchError(locale,'classAddTeacher')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF active_year(v_orgid) = 0 THEN
        v_error := (SELECT fetchError(locale,'calTermNoActYear')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF EXISTS (SELECT * FROM subjects WHERE subjectid=in_subjectid AND deleted=TRUE) THEN
        RAISE EXCEPTION '%', 'Subject doesn''t exits' USING HINT = 'Subject doesn''t exits';
    END IF;

    CALL split(in_classids);

    BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            IF EXISTS(SELECT * FROM classsubjects WHERE classid=v::INTEGER AND subjectid=in_subjectid AND yearid=active_year(v_orgid)) THEN
                v_error := (SELECT fetchError(locale,'classDoingSubject')) ;
                RAISE EXCEPTION '%', v_error USING HINT = v_error;
            END IF;

            IF NOT EXISTS(SELECT * FROM students WHERE classid=v::INTEGER AND sstatus NOT IN ('dismissed','graduate')) THEN -- There is atleast one student in that class
                v_error := (SELECT fetchError(locale,'classStudsNotInClass')) ;
                RAISE EXCEPTION '%', v_error USING HINT = v_error;
            END IF;

            INSERT INTO classsubjects(userid, classid, subjectid,yearid) VALUES (in_userid,v::INTEGER,in_subjectid,active_year(v_orgid));
        END LOOP;
    END;

    v_classrooms := (SELECT getallclassrooms(in_connid));

    CALL log_activity('classrooms','teachers',in_connid,CONCAT('Added. For teacher:',in_userid,', for classids:',in_classids,'subject:',in_subjectid),TRUE);

    RETURN v_classrooms;
END; $$;

-- Fetches all classroom teachers
DROP FUNCTION IF EXISTS getclassroomstudents;
CREATE OR REPLACE FUNCTION getclassroomstudents (IN in_connid VARCHAR(128), IN in_classid INTEGER, IN locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_classrooms JSON;
    v_details JSON;
    v_year JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','students',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCLASS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF NOT EXISTS (SELECT * FROM classrooms WHERE classid = in_classid) THEN
        v_error := (SELECT fetchError(locale,'classTeachersAdd')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_classrooms := (SELECT json_agg(t) FROM (SELECT u.surname, u.othernames, u.dob, 
                        s.userid, s.matricule, s.doe, st.descript FROM users u
                        LEFT JOIN students s ON u.userid = s.userid
                        LEFT JOIN studentstatuses st ON s.sstatus = st.sstatus 
                        WHERE s.classid=in_classid AND u.usertype='student' 
                            AND u.deleted = FALSE AND s.sstatus NOT IN ('dismissed', 'graduated') 
                            AND s.userid NOT IN 
                            (SELECT userid FROM legacy WHERE yearid=active_year(v_orgid) 
                            AND classid <> in_classid) ORDER BY s.matricule ASC) AS t);

    IF v_classrooms IS NULL THEN
        v_classrooms := '[]';
    END IF;

    v_details := (SELECT json_agg(t) FROM (SELECT CONCAT(cname, ' (', abbreviation,')') AS cname FROM  classrooms WHERE classid = in_classid) AS t);

    v_year := (SELECT json_agg(t) FROM (SELECT startdate, enddate FROM academicyear WHERE yearid=active_year(v_orgid)) AS t);

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_classrooms,',"details":',v_details,',"calendar":',v_year,'}}');

    CALL log_activity('classrooms','students',in_connid,CONCAT('Viewed. For class:',in_classid),TRUE);

    RETURN au;
END; $$;

-- Fetches all teachers in a class
DROP FUNCTION IF EXISTS beginsequenceentry;
CREATE OR REPLACE FUNCTION beginsequenceentry (IN in_connid VARCHAR(128), IN in_locale VARCHAR(5), IN in_classid INTEGER, IN in_subjectId INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_yearid INTEGER;
    v_termid INTEGER;
    v_examid INTEGER;
    v_examstartdate DATE;
    v_students JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','beginSequence',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'BEGINEXAM');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    v_yearid := active_year(v_orgid);
    v_termid := active_term(v_yearid);
    v_examid := active_exam(v_termid) ;

    IF v_examid = 0 THEN
		v_error := (SELECT fetchError(in_locale,'classAddSeqNoActExam')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_examstartdate := (SELECT startdate FROM examinations WHERE examid = v_examid) ;

    IF v_examstartdate > CURRENT_DATE THEN
		v_error := (SELECT fetchError(in_locale,'classAddSeqNotYetTime')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF NOT EXISTS (SELECT * FROM classsubjects WHERE userid = v_userid AND classid = in_classid AND subjectid = in_subjectid AND yearid = v_yearid) THEN
        IF NOT EXISTS (SELECT * FROM assistances WHERE assistor = v_userid) THEN
            v_error := (SELECT fetchError(in_locale,'classNotTeachingclass')) ;
		    RAISE EXCEPTION '%', v_error USING HINT = v_error;
        END IF;
    END IF;

    IF EXISTS (SELECT * FROM legacy WHERE yearid = v_yearid) THEN
        v_error := (SELECT fetchError(in_locale,'classAddSeqStudPromAlr')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_students := (SELECT json_agg(t) FROM (SELECT u.userid, u.surname, u.othernames, er.mark  FROM examresults er 
                    JOIN users u ON u.userid = er.userid JOIN students s ON u.userid = s.userid 
                    WHERE er.subjectid = in_subjectid AND s.classid = in_classid AND er.examid = v_examid ) AS t);

    IF v_students IS NULL THEN
        v_students := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_students,'}}');

    CALL log_activity('classrooms','beginSequence',in_connid,CONCAT('Prepared sequence entry for class=',in_classid,',subject=',in_subjectid,',user=',v_userid),TRUE);

    RETURN au;
END; $$;

-- Fetches all teachers in a class
DROP FUNCTION IF EXISTS submitsequencemarks;
CREATE OR REPLACE FUNCTION submitsequencemarks (IN in_connid VARCHAR(128), IN in_locale VARCHAR(5), IN in_classid INTEGER, IN in_subjectId INTEGER, IN in_data VARCHAR(9216)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_yearid INTEGER;
    v_termid INTEGER;
    v_examid INTEGER;
    v_examstartdate DATE;
    v_students JSON;
    i JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','submitSequence',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDEXAMMARKS');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    v_yearid := active_year(v_orgid);
    v_termid := active_term(v_yearid);
    v_examid := active_exam(v_termid) ;

    IF v_examid = 0 THEN
		v_error := (SELECT fetchError(in_locale,'classAddSeqNoActExam')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_examstartdate := (SELECT startdate FROM examinations WHERE examid = v_examid) ;

    IF v_examstartdate > CURRENT_DATE THEN
		v_error := (SELECT fetchError(in_locale,'classAddSeqNotYetTime')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF NOT EXISTS (SELECT * FROM classsubjects WHERE userid = v_userid AND classid = in_classid AND subjectid = in_subjectid AND yearid = v_yearid) THEN
        IF NOT EXISTS (SELECT * FROM assistances WHERE assistor = v_userid) THEN
            v_error := (SELECT fetchError(in_locale,'classNotTeachingclass')) ;
		    RAISE EXCEPTION '%', v_error USING HINT = v_error;
        END IF;
    END IF;

    IF EXISTS (SELECT * FROM legacy WHERE yearid = v_yearid) THEN
        v_error := (SELECT fetchError(in_locale,'classAddSeqStudPromAlr')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    in_data := (SELECT REPLACE(in_data, '\',''));
    FOR i IN SELECT * FROM JSONB_ARRAY_ELEMENTS(in_data::JSONB)
    LOOP
        UPDATE examresults SET mark = CAST(i->>'mark' AS DECIMAL(4,2)) WHERE userid = CAST(i->>'userid' AS INTEGER)  AND subjectid = in_subjectid AND examid = v_examid;
    END LOOP;

    v_students := (SELECT json_agg(t) FROM (SELECT u.userid, u.surname, u.othernames, er.mark  FROM examresults er 
                    JOIN users u ON u.userid = er.userid JOIN students s ON u.userid = s.userid 
                    WHERE er.subjectid = in_subjectid AND s.classid = in_classid AND er.examid = v_examid ) AS t);

    IF v_students IS NULL THEN
        v_students := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_students,'}}');

    CALL log_activity('classrooms','submitSequence',in_connid,CONCAT('Added sequence marks for class=',in_classid,',subject=',in_subjectid),TRUE);

    RETURN au;
END; $$;