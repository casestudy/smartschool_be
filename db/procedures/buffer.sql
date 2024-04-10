\c shopman_pos;
DROP PROCEDURE IF EXISTS setdefaultmarksforexamination;
CREATE OR REPLACE PROCEDURE setdefaultmarksforexamination(IN in_connid VARCHAR(128), IN in_examid INTEGER, IN in_locale CHAR(2)) LANGUAGE plpgsql
AS $$
DECLARE
    v_classrooms JSON;
    v_classsubjects JSON;
    v_userid INTEGER;
    v_orgid INTEGER;
    i JSON;
    v_yearid INTEGER;
    v_error VARCHAR(255);
BEGIN
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    v_yearid := active_year(v_orgid);

    v_classrooms := (SELECT json_agg(t) FROM (SELECT c.classid, cs.subjectid FROM classrooms c JOIN classsubjects cs ON c.classid = cs.classid WHERE c.orgid = v_orgid AND cs.yearid = v_yearid) AS t); -- Get all classrooms
    IF  JSON_ARRAY_LENGTH(v_classrooms) > 0 THEN
        FOR i IN SELECT * FROM JSON_ARRAY_ELEMENTS(v_classrooms)
        LOOP 
           RAISE NOTICE 'count: %', CONCAT('classid=', (i->>'classid')::int, ', subjectid=', (i->>'subjectid')::int);
        END LOOP;
    ELSE
        v_error := (SELECT fetchError(in_locale,'calExamNoClassTeachers')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;
END; $$;
