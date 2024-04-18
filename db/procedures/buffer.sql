\c shopman_pos;
DROP FUNCTION IF EXISTS getdashboarddetails;
CREATE OR REPLACE FUNCTION getdashboarddetails (IN in_userid INTEGER, IN in_locale VARCHAR(5)) RETURNS JSON LANGUAGE plpgsql
AS $$
DECLARE 
    v_usertype VARCHAR(20);
    v_subjectcount INTEGER;
    v_yearenddate DATE;
    v_yearstartdate DATE;
    v_termstartdate DATE;
    v_termenddate DATE;
    v_termdescription VARCHAR(64);
    v_count INTEGER;
    v_studentcount INTEGER;
    v_teachercount INTEGER;
    v_parentcount INTEGER;
    v_classroomcount INTEGER;
    v_error VARCHAR(255);
    details VARCHAR(9261) DEFAULT '[';

BEGIN
    v_usertype := (SELECT userType FROM users WHERE userid=in_userid);

    IF v_usertype = 'teacher' THEN
        v_subjectcount := (SELECT COUNT(*) FROM classsubjects WHERE userid=4 AND yearid=active_year(userid2orgid(in_userid))); 

        details := CONCAT(details,'{"subjects":',v_subjectcount,'}');

        IF EXISTS (SELECT startdate, enddate FROM academicyear WHERE startdate <= CURRENT_DATE AND enddate >= CURRENT_DATE AND orgid=userid2orgid(in_userid)) THEN
			SELECT startdate, enddate INTO v_yearstartdate, v_yearenddate FROM academicyear WHERE  startdate <= CURRENT_DATE AND enddate >= CURRENT_DATE AND orgid=userid2orgid(in_userid);
			details := CONCAT (details,',{"current_year_start":"',v_yearstartdate,'","current_year_end":"',v_yearenddate,'"}');

			SELECT t.startdate, t.enddate, tt.descript INTO v_termstartdate, v_termenddate, v_termdescription FROM academicterm t JOIN termtypes tt ON t.termtype = tt.term WHERE t.enddate >= CURRENT_DATE AND t.yearid=active_year(userid2orgid(in_userid));
			
            v_count := (SELECT COUNT(*) FROM academicterm t JOIN termtypes tt ON t.termtype = tt.term WHERE t.enddate >= CURRENT_DATE AND t.yearid=active_year(userid2orgid(in_userid)));

			IF v_count > 0 THEN
				details := CONCAT (details, ',{"current_term_start":"',v_termstartdate,'","current_term_end":"',v_termenddate,'","current_term_description":"',v_termdescription,'"}');
			END IF;
		END IF;

        details := CONCAT(details, ']') ;
        RETURN details;
    ELSEIF v_usertype IN ('administrator', 'system') THEN
        v_studentcount := (SELECT COUNT(*) FROM students s JOIN users u ON u.userid=s.userid WHERE u.usertype='student' AND u.orgId=userid2orgid(in_userid));
		v_teachercount := (SELECT COUNT(*) FROM users WHERE usertype = 'teacher' AND orgid=userid2orgid(in_userid));
		v_parentcount := (SELECT COUNT(*) FROM users WHERE usertype = 'parent' AND orgid=userid2orgid(in_userid));
		v_classroomcount := (SELECT COUNT(*) FROM classrooms WHERE orgid=userid2orgid(in_userid));
		v_subjectcount := (SELECT COUNT(*) FROM subjects WHERE orgid=userid2orgid(in_userid));

        details := CONCAT (details, '{"students":',v_studentCount,',"teachers":',v_teacherCount,',"parents":',v_parentCount,',"classrooms":',v_classroomCount,',"subjects":',v_subjectCount,'}');
       
        IF EXISTS (SELECT startdate, enddate FROM academicyear WHERE startdate <= CURRENT_DATE AND enddate >= CURRENT_DATE AND orgid=userid2orgid(in_userid)) THEN
			SELECT y.startdate, y.enddate INTO v_yearstartdate, v_yearenddate FROM academicyear y WHERE y.startdate <= CURRENT_DATE AND y.enddate >= CURRENT_DATE AND y.orgid=userid2orgid(in_userid);
			details := CONCAT (details,',{"current_year_start":"',v_yearstartdate,'","current_year_end":"',v_yearenddate,'"}');

			SELECT t.startdate, t.enddate, tt.descript INTO v_termstartdate, v_termenddate, v_termdescription FROM academicterm t JOIN termtypes tt ON t.termtype = tt.term WHERE t.enddate >= CURRENT_DATE AND t.yearid=active_year(userid2orgid(in_userid));
			
            v_count := (SELECT COUNT(*) FROM academicterm t JOIN termtypes tt ON t.termtype = tt.term WHERE t.enddate >= CURRENT_DATE AND t.yearid=active_year(userid2orgid(in_userid)));

			IF v_count > 0 THEN
				details := CONCAT (details, ',{"current_term_start":"',v_termstartdate,'","current_term_end":"',v_termenddate,'","current_term_description":"',v_termdescription,'"}');
			END IF;
		END IF;

        details := CONCAT(details, ']') ;
        RETURN details ;
    ELSE
        v_error := (SELECT fetchError(in_locale,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;
END; $$;