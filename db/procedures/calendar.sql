\c shopman_pos;

-- Fetches all subjects
DROP FUNCTION IF EXISTS getacademicyears;
CREATE OR REPLACE FUNCTION getacademicyears (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_years JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('years','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_years := (SELECT json_agg(t) FROM (SELECT yearid, startdate, enddate, descript FROM academicyear WHERE orgid = v_orgid ORDER BY enddate DESC) AS t);

    IF v_years IS NULL THEN
        v_years := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_years,'}}');

    CALL log_activity('years','view',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Create new academic year
DROP FUNCTION IF EXISTS createacademicyear;
CREATE OR REPLACE FUNCTION createacademicyear (IN in_connid VARCHAR(128), IN in_startdate DATE, IN in_enddate DATE, IN in_description VARCHAR(255), IN in_locale CHAR(2)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE 
    v_userid INTEGER;
    v_orgid INTEGER;
    v_years JSON;
    v_error VARCHAR(255);
    v_expire DATE;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('years','create',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF in_startdate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calYrStartPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calYrEndPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_startdate >= in_enddate THEN
		v_error := (SELECT fetchError(in_locale,'calYrEndB4Start')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF NOT EXISTS(SELECT * FROM organisations WHERE orgid=v_orgId AND expirydate > CURRENT_TIMESTAMP) THEN
        v_error := (SELECT fetchError(in_locale,'loginOrgExpired')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_expire := (SELECT expirydate FROM organisations WHERE orgid=v_orgid) ;

    IF in_enddate > v_expire THEN
        v_error := (SELECT fetchError(in_locale,'calYrEndAfterOrg')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF active_year(v_orgId) = 0 THEN
        INSERT INTO academicyear(startdate, enddate, descript, orgid) VALUES (in_startdate, in_enddate, in_description, v_orgid);
    ELSE
        v_error := (SELECT fetchError(in_locale,'calYrStartPrevAct')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_years := (SELECT json_agg(t) FROM (SELECT yearid, startdate, enddate, descript FROM academicyear WHERE orgid = v_orgid ORDER BY enddate DESC) AS t);

    IF v_years IS NULL THEN
        v_years := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_years,'}}');

    CALL log_activity('years','add',in_connid,CONCAT('Created year for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Modify academic year
DROP FUNCTION IF EXISTS modifyacademicyear;
CREATE OR REPLACE FUNCTION modifyacademicyear (IN in_connid VARCHAR(128), IN in_yearid INTEGER, IN in_startdate DATE, IN in_enddate DATE, IN in_description VARCHAR(255), IN in_locale CHAR(2)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE 
    v_userid INTEGER;
    v_orgid INTEGER;
    v_years JSON;
    v_error VARCHAR(255);
    v_expire DATE;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('years','modify',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF in_enddate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calYrEndPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_startdate >= in_enddate THEN
		v_error := (SELECT fetchError(in_locale,'calYrEndB4Start')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF NOT EXISTS(SELECT * FROM organisations WHERE orgid=v_orgId AND expirydate > CURRENT_TIMESTAMP) THEN
        v_error := (SELECT fetchError(in_locale,'loginOrgExpired')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF EXISTS (SELECT * FROM academicyear WHERE yearid = in_yearid AND enddate < CURRENT_DATE - INTERVAL '2 WEEK') THEN
        v_error := (SELECT fetchError(in_locale,'calYrModLnGone')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF (in_endDate < CURRENT_DATE AND active_year(v_orgid) <> 0) THEN
        v_error := (SELECT fetchError(in_locale,'calYrModNewStart')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF active_year(v_orgid) <> in_yearId AND active_year(v_orgid) <> 0 THEN
        v_error := (SELECT fetchError(in_locale,'calYrModLnGone')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_expire := (SELECT expirydate FROM organisations WHERE orgid=v_orgid) ;

    IF in_enddate > v_expire THEN
        v_error := (SELECT fetchError(in_locale,'calYrEndAfterOrg')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    UPDATE academicyear SET startdate=in_startdate, enddate=in_enddate, descript=in_description WHERE yearid=in_yearid;

    v_years := (SELECT json_agg(t) FROM (SELECT yearid, startdate, enddate, descript FROM academicyear WHERE orgid = v_orgid ORDER BY enddate DESC) AS t);

    IF v_years IS NULL THEN
        v_years := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_years,'}}');

    CALL log_activity('years','update',in_connid,CONCAT('Modified year with id:',in_yearid),TRUE);

    RETURN au;
END; $$;