\c shopman_pos;
-- Generates student's report card
DROP FUNCTION IF EXISTS generatereportcard;
CREATE OR REPLACE FUNCTION generatereportcard (IN in_connid VARCHAR(128), IN in_classid INTEGER,  IN in_locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_yearid INTEGER;
    v_termid INTEGER;
    v_examid INTEGER;
    v_teacherid INTEGER;
    v_examstartdate DATE;
    v_students VARCHAR(9216);
    v_terms VARCHAR(9216);
    v_exams VARCHAR(9216);
    v_exammarks VARCHAR(9216);
    i JSON;
    j JSON;
    k JSON;
    m JSON;
    v_error VARCHAR(255);
    report_card VARCHAR(9216);
BEGIN
    CALL log_activity('classrooms','fetchReportCards',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCLASS');

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
		v_error := (SELECT fetchError(in_locale,'classPrtReportYrNotStart')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    report_card := '{"error":false,"result":{"status":200, "value": ['; -- We open geenral array

    v_students := (SELECT json_agg(t) FROM (SELECT s.userid FROM students s JOIN users u ON s.userid = u.userid WHERE s.classid = in_classid) AS t);

    

    report_card := CONCAT(report_card, ']}'); -- We close the array general array

    CALL log_activity('classrooms','fetchReportCards',in_connid,CONCAT('Fetched report card for class=',in_classid),TRUE);

    RETURN report_card;
END; $$;