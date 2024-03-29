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

-- Fetches all academic terms
DROP FUNCTION IF EXISTS getacademicterms;
CREATE OR REPLACE FUNCTION getacademicterms(IN in_connid VARCHAR(128), IN in_yearid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_terms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('terms','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_terms := (SELECT json_agg(t) FROM (SELECT at.termid, at.startdate, at.enddate, at.yearid, at.termtype, tt.descript FROM academicterm at JOIN termtypes tt ON at.termtype = tt.term WHERE at.yearid = in_yearid ORDER BY at.enddate DESC) AS t);

    IF v_terms IS NULL THEN
        v_terms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_terms,'}}');

    CALL log_activity('terms','view',in_connid,CONCAT('Fetched. For year:',in_yearid),TRUE);

    RETURN au;
END; $$;

-- Fetches all subjects
DROP FUNCTION IF EXISTS gettermtypes;
CREATE OR REPLACE FUNCTION gettermtypes (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_ttypes JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('years','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_ttypes := (SELECT json_agg(t) FROM (SELECT term, descript FROM termtypes ORDER BY term ASC) AS t);

    IF v_ttypes IS NULL THEN
        v_ttypes := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_ttypes,'}}');

    CALL log_activity('ttypes','view',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Create new academic year
DROP FUNCTION IF EXISTS createacademicterm;
CREATE OR REPLACE FUNCTION createacademicterm (IN in_connid VARCHAR(128), IN in_startdate DATE, IN in_enddate DATE, IN in_ttype VARCHAR(255), IN in_yearid INTEGER, IN in_locale CHAR(2)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE 
    v_userid INTEGER;
    v_orgid INTEGER;
    v_terms JSON;
    v_error VARCHAR(255);
    v_expire DATE;
    v_yearstartdate DATE;
    v_yearenddate DATE;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('terms','create',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF in_startdate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calTermStartPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calTermEndPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_startdate >= in_enddate THEN
		v_error := (SELECT fetchError(in_locale,'calTermEndB4Start')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF is_active_year(in_yearid) IS FALSE THEN
        v_error := (SELECT fetchError(in_locale,'calTermNoActYear')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_yearstartdate := (SELECT startdate FROM academicYear WHERE yearid = in_yearid) ;
    v_yearenddate := (SELECT enddate FROM academicYear WHERE yearid = in_yearid) ;

    IF in_startdate <= v_yearstartdate THEN
		v_error := (SELECT fetchError(in_locale,'calTermStartB4YearStart')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_startdate >= v_yearenddate THEN
		v_error := (SELECT fetchError(in_locale,'calTermStartA4YearEnd')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate >= v_yearenddate THEN
		v_error := (SELECT fetchError(in_locale,'calTermEndA4YearEnd')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate < v_yearstartdate THEN
		v_error := (SELECT fetchError(in_locale,'calTermEndB4YearStart')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF EXISTS(SELECT * FROM academicterm WHERE termtype = in_ttype AND yearid = active_year(v_orgid)) THEN
        v_error := (SELECT fetchError(in_locale,'calTermAlreadyCrea')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF active_term(active_year(v_orgid)) = 0 THEN
        INSERT INTO academicterm(startdate, enddate, termtype, yearid) VALUES (in_startdate, in_enddate, in_ttype, in_yearid);
    ELSE
        v_error := (SELECT fetchError(in_locale,'calTermStartPrevAct')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_terms := (SELECT json_agg(t) FROM (SELECT at.termid, at.startdate, at.enddate, at.yearid, tt.descript FROM academicterm at JOIN termtypes tt ON at.termtype = tt.term WHERE at.yearid = in_yearid ORDER BY at.enddate DESC) AS t);

    IF v_terms IS NULL THEN
        v_terms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_terms,'}}');

    CALL log_activity('terms','add',in_connid,CONCAT('Created term for year:',in_yearid),TRUE);

    RETURN au;
END; $$;

-- Create new academic year
DROP FUNCTION IF EXISTS modifyacademicterm;
CREATE OR REPLACE FUNCTION modifyacademicterm (IN in_connid VARCHAR(128), IN in_termid INTEGER, IN in_startdate DATE, IN in_enddate DATE, IN in_locale CHAR(2)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE 
    v_userid INTEGER;
    v_orgid INTEGER;
    v_yearid INTEGER;
    v_terms JSON;
    v_error VARCHAR(255);
    v_expire DATE;
    v_yearstartdate DATE;
    v_yearenddate DATE;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('terms','modify',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDCALEN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF in_startdate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calTermStartPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate <  CURRENT_DATE THEN
        v_error := (SELECT fetchError(in_locale,'calTermEndPast')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_startdate >= in_enddate THEN
		v_error := (SELECT fetchError(in_locale,'calTermEndB4Start')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_yearid := (SELECT yearid FROM academicterm WHERE termid = in_termid);

    v_yearstartdate := (SELECT startdate FROM academicyear WHERE yearid = v_yearid) ;
    v_yearenddate := (SELECT enddate FROM academicyear WHERE yearid = v_yearid) ;

    IF in_startdate <= v_yearstartdate THEN
		v_error := (SELECT fetchError(in_locale,'calTermStartB4YearStart')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_startdate >= v_yearenddate THEN
		v_error := (SELECT fetchError(in_locale,'calTermStartA4YearEnd')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate >= v_yearenddate THEN
		v_error := (SELECT fetchError(in_locale,'calTermEndA4YearEnd')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF in_enddate < v_yearstartdate THEN
		v_error := (SELECT fetchError(in_locale,'calTermEndB4YearStart')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF active_term(active_year(v_orgid)) = in_termid THEN
        UPDATE academicterm SET startdate = in_startdate, enddate = in_enddate WHERE termid = in_termid ;
    ELSE
        v_error := (SELECT fetchError(in_locale,'calTermModLnGone')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    v_terms := (SELECT json_agg(t) FROM (SELECT at.termid, at.startdate, at.enddate, at.yearid, tt.descript FROM academicterm at JOIN termtypes tt ON at.termtype = tt.term WHERE at.yearid = v_yearid ORDER BY at.enddate DESC) AS t);

    IF v_terms IS NULL THEN
        v_terms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_terms,'}}');

    CALL log_activity('terms','edit',in_connid,CONCAT('Modify for term:',in_termid),TRUE);

    RETURN au;
END; $$;