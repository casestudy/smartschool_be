\c shopman_pos;
DROP FUNCTION IF EXISTS setdefaultmarksforexamination;
DROP PROCEDURE IF EXISTS setdefaultmarksforexamination;
CREATE OR REPLACE PROCEDURE setdefaultmarksforexamination(IN in_connid VARCHAR(128), IN in_examid INTEGER, IN in_locale CHAR(2)) LANGUAGE plpgsql
AS $$
DECLARE
    v_classrooms JSON;
    v_userid INTEGER;
    v_orgid INTEGER;
    i INTEGER;
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('classrooms','setDefaultMarks',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_classrooms := (SELECT json_agg(userid) FROM users WHERE orgid = v_orgid);
    IF  JSON_ARRAY_LENGTH(v_classrooms) > 3 THEN
        FOR i IN SELECT * FROM JSON_ARRAY_ELEMENTS(v_classrooms)
        LOOP 
            RAISE NOTICE 'count: %', i;
        END LOOP;
    ELSE
        v_error := (SELECT fetchError(in_locale,'calExamNoClass')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;
END; $$;