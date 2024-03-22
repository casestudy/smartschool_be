\c shopman_pos;

-- Fetches all subjects
DROP FUNCTION IF EXISTS getallsubjects;
CREATE OR REPLACE FUNCTION getallsubjects (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_subjects JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('subjects','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWSUBJ');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_subjects := (SELECT json_agg(t) FROM (SELECT subjectid, sname, code, descript, coefficient FROM subjects WHERE orgid = v_orgid AND deleted = FALSE ORDER BY code ASC) AS t);

    IF v_subjects IS NULL THEN
        v_subjects := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_subjects,'}}');

    CALL log_activity('subjects','view',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Create new classroom
DROP FUNCTION IF EXISTS createsubject;
CREATE OR REPLACE FUNCTION createsubject (IN in_connid VARCHAR(128), IN in_name VARCHAR(255), IN in_code INTEGER, IN in_coef INTEGER, IN in_description VARCHAR(255)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_subjects JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('subjects','create',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    INSERT INTO subjects(sname, code, coefficient, descript, orgid) VALUES (in_name, in_code, in_coef, in_description, v_orgid);

    v_subjects := (SELECT json_agg(t) FROM (SELECT subjectid, sname, code, descript, coefficient FROM subjects WHERE orgid = v_orgid AND deleted = FALSE ORDER BY code ASC) AS t);

    IF v_subjects IS NULL THEN
        v_subjects := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_subjects,'}}');

    CALL log_activity('subjects','create',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Update subject
DROP FUNCTION IF EXISTS updatesubject;
CREATE OR REPLACE FUNCTION updatesubject (IN in_connid VARCHAR(128), IN in_subjectid INTEGER, IN in_name VARCHAR(255), IN in_code INTEGER, IN in_coef INTEGER, IN in_description VARCHAR(255)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_subjects JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('subjects','modify',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    UPDATE subjects SET 
        sname = in_name, code = in_code, coefficient = in_coef, descript = in_description 
        WHERE subjectid = in_subjectid AND deleted = FALSE;
    
    v_subjects := (SELECT json_agg(t) FROM (SELECT subjectid, sname, code, descript, coefficient FROM subjects WHERE orgid = v_orgid AND deleted = FALSE ORDER BY code ASC) AS t);

    IF v_subjects IS NULL THEN
        v_subjects := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_subjects,'}}');

    CALL log_activity('subjects','modify',in_connid,CONCAT('Modified subject with id:',in_subjectid),TRUE);

    RETURN au;
END; $$;

-- Delete subject
DROP FUNCTION IF EXISTS deletesubject;
CREATE OR REPLACE FUNCTION deletesubject (IN in_connid VARCHAR(128), IN in_subjectid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_subjects JSON;
    v_exams JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('subjects','modify',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);
    
    v_exams := (SELECT json_agg(t) FROM (SELECT examid FROM examresults WHERE subjectid = in_subjectid) AS t);

    IF v_exams IS NULL THEN
        -- Subject can be deleted since no exam has use it
        UPDATE subjects SET
            deleted = TRUE WHERE subjectid = in_subjectid;
    ELSE 
        v_error := (SELECT fetchError(v_locale,'rmvSubjectExamHasIt')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_subjects := (SELECT json_agg(t) FROM (SELECT subjectid, sname, code, descript, coefficient FROM subjects WHERE orgid = v_orgid AND deleted = FALSE ORDER BY code ASC) AS t);

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_subjects,'}}');

    CALL log_activity('subjects','delete',in_connid,CONCAT('Deleted subject with id:',in_subjectid),TRUE);

    RETURN au;
END; $$;

-- Fetches all subject groups
DROP FUNCTION IF EXISTS getsubjectgroups;
CREATE OR REPLACE FUNCTION getsubjectgroups (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_groups JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWSUBJ');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_groups := (SELECT json_agg(t) FROM (SELECT groupid, gname, descript FROM groups WHERE orgid = v_orgid AND academicyearid = active_year(v_orgid) ORDER BY gname ASC) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','view',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Create new subject group
DROP FUNCTION IF EXISTS createsubjectgroup;
CREATE OR REPLACE FUNCTION createsubjectgroup (IN in_connid VARCHAR(128), IN in_name VARCHAR(255), IN in_description VARCHAR(255), IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_groups JSON;
    v_error VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','create',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF active_year(v_orgid) IS NULL THEN
        v_error := (SELECT fetchError(in_locale,'calTermNoActYear')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    INSERT INTO groups(gname, descript, orgid, academicyearid) VALUES (in_name, in_description, v_orgid, active_year(v_orgid));

    v_groups := (SELECT json_agg(t) FROM (SELECT groupid, gname, descript FROM groups WHERE orgid = v_orgid AND academicyearid = active_year(v_orgid) ORDER BY gname ASC) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','create',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Update subject group
DROP FUNCTION IF EXISTS updatesubjectgroup;
CREATE OR REPLACE FUNCTION updatesubjectgroup (IN in_connid VARCHAR(128), IN in_groupid INTEGER, IN in_name VARCHAR(255), IN in_description VARCHAR(255),IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_groups JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','update',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    UPDATE groups SET gname = in_name, descript = in_description WHERE groupid = in_groupid;

    v_groups := (SELECT json_agg(t) FROM (SELECT groupid, gname, descript FROM groups WHERE orgid = v_orgid AND academicyearid = active_year(v_orgid) ORDER BY gname ASC) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','update',in_connid,CONCAT('Modified. For groupid:',in_groupid),TRUE);

    RETURN au;
END; $$;

-- Delete subject group
DROP FUNCTION IF EXISTS deletesubjectgroup;
CREATE OR REPLACE FUNCTION deletesubjectgroup (IN in_connid VARCHAR(128), IN in_groupid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_groups JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','delete',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    DELETE FROM groups WHERE groupid = in_groupid AND orgid = v_orgid;

    v_groups := (SELECT json_agg(t) FROM (SELECT groupid, gname, descript FROM groups WHERE orgid = v_orgid AND academicyearid = active_year(v_orgid) ORDER BY gname ASC) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','delete',in_connid,CONCAT('Deleted. For groupid:',in_groupid),TRUE);

    RETURN au;
END; $$;

-- Get group subjects
DROP FUNCTION IF EXISTS getgroupsubjects;
CREATE OR REPLACE FUNCTION getgroupsubjects (IN in_connid VARCHAR(128), IN in_groupid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_groups JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','getsubjects',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    v_groups := (SELECT json_agg(t) FROM (SELECT s.subjectid, s.sname, s.code, s.coefficient, s.descript FROM subjects s JOIN groupings g ON s.subjectid = g.subjectid WHERE s.deleted = FALSE AND s.orgid = v_orgid AND g.groupid = in_groupid) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','getsubjects',in_connid,CONCAT('Fetched. For groupid:',in_groupid),TRUE);

    RETURN au;
END; $$;

-- Add subject to group
DROP FUNCTION IF EXISTS addgroupsubject;
CREATE OR REPLACE FUNCTION addgroupsubject (IN in_connid VARCHAR(128), IN in_groupid INTEGER, IN in_subjectid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_groups JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','addsubject',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    INSERT INTO groupings (subjectid, groupid) VALUES (in_subjectid, in_groupid) ;

    v_groups := (SELECT json_agg(t) FROM (SELECT s.subjectid, s.sname, s.code, s.coefficient, s.descript FROM subjects s JOIN groupings g ON s.subjectid = g.subjectid WHERE s.deleted = FALSE AND s.orgid = v_orgid AND g.groupid = in_groupid) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','addsubject',in_connid,CONCAT('Added. For groupid:',in_groupid,' subjectid:',in_subjectid),TRUE);

    RETURN au;
END; $$;

-- Add subject to group
DROP FUNCTION IF EXISTS removegroupsubject;
CREATE OR REPLACE FUNCTION removegroupsubject (IN in_connid VARCHAR(128), IN in_groupid INTEGER, IN in_subjectid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_groups JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('groups','removesubject',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDSUBJ');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    DELETE FROM groupings WHERE subjectid = in_subjectid AND groupid = in_groupid;

    v_groups := (SELECT json_agg(t) FROM (SELECT s.subjectid, s.sname, s.code, s.coefficient, s.descript FROM subjects s JOIN groupings g ON s.subjectid = g.subjectid WHERE s.deleted = FALSE AND s.orgid = v_orgid AND g.groupid = in_groupid) AS t);

    IF v_groups IS NULL THEN
        v_groups := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_groups,'}}');

    CALL log_activity('groups','removesubject',in_connid,CONCAT('Added. For groupid:',in_groupid,' subjectid:',in_subjectid),TRUE);

    RETURN au;
END; $$;

-- Teacher subjects
DROP FUNCTION IF EXISTS getteachersubjects;
CREATE OR REPLACE FUNCTION getteachersubjects (IN in_connid VARCHAR(128), IN in_userid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_subjects JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','teachers',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWTEACH');

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    v_subjects := (SELECT json_agg(t) FROM (SELECT s.subjectid, s.code, s.sname, s.descript AS sdescript, c.classid, c.cname, 
                        c.abbreviation, c.descript AS cdescript 
                        FROM subjects s LEFT JOIN classsubjects cs ON cs.subjectid=s.subjectid 
                        LEFT JOIN users u ON cs.userid=u.userid 
                        LEFT JOIN classrooms c ON cs.classid = c.classid 
                        WHERE cs.userid=in_userid AND u.usertype IN ('teacher','hybrid1','hybrid2', 'hybrid4') 
                        AND cs.yearid = active_year(v_orgid) 
                    UNION 
                    SELECT s.subjectid, s.code, s.sname, s.descript AS sdescript, c.classid, c.cname, 
                        c.abbreviation, c.descript AS cdescript 
                        FROM subjects s LEFT JOIN classsubjects cs ON cs.subjectid=s.subjectid 
                        LEFT JOIN users u ON cs.userid=u.userid 
                        LEFT JOIN classrooms c ON cs.classid = c.classid 
                        WHERE cs.userid=(SELECT teacher FROM assistances WHERE assistor=in_userid AND status=TRUE and yearid=active_year(v_orgid)) 
                        AND u.usertype IN ('teacher','hybrid1','hybrid2','hybrid4') 
                        AND cs.yearid = active_year(v_orgid)) AS t);

    IF v_subjects IS NULL THEN
        v_subjects := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_subjects,'}}');

    CALL log_activity('classrooms','teachers',in_connid,CONCAT('Viewed. For user:',in_userid),TRUE);

    RETURN au;
END; $$;