\c shopman_pos;

-- Fetches all subjects
DROP FUNCTION IF EXISTS getfeetypes;
CREATE OR REPLACE FUNCTION getfeetypes (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_ftypes JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('fees','types',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWFEES');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_ftypes := (SELECT json_agg(t) FROM (SELECT ftype, descript FROM feeTypes) AS t);

    IF v_ftypes IS NULL THEN
        v_ftypes := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_ftypes,'}}');

    CALL log_activity('fees','types',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Fetches all subjects
DROP FUNCTION IF EXISTS getpaymethods;
CREATE OR REPLACE FUNCTION getpaymethods (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_methods JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('fees','methods',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWFEES');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_methods := (SELECT json_agg(t) FROM (SELECT method, descript FROM paymethods) AS t);

    IF v_methods IS NULL THEN
        v_methods := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_methods,'}}');

    CALL log_activity('fees','methods',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Get all student's fees
DROP FUNCTION IF EXISTS getstudentfees;
CREATE OR REPLACE FUNCTION getstudentfees (IN in_connid VARCHAR(128), IN in_userid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_fees JSON;
    v_details JSON;
    v_year JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('fees','view',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'VIEWFEES');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_fees := (SELECT json_agg(t) FROM (SELECT f.feeid, f.amount, f.reference, f.paidon, ft.descript, pm.descript AS method FROM fees f 
                LEFT JOIN feetypes ft ON f.ftype = ft.ftype 
                LEFT JOIN paymethods pm ON f.paidby = pm.method 
                WHERE f.userid = in_userid AND f.yearid = active_year(v_orgid)) AS t);

    IF v_fees IS NULL THEN
        v_fees := '[]';
    ELSE
        v_details := (SELECT json_agg(t) FROM (SELECT u.userid, u.surname, u.othernames, u.dob, u.gender, s.matricule, s.doe, s.pob, s.sstatus, st.descript, c.cname, c.classid, c.abbreviation AS cabbrev
                      FROM users u INNER JOIN students s ON u.userId = s.userId
                      INNER JOIN classrooms c ON s.classid = c.classid 
                      INNER JOIN studentstatuses st ON s.sstatus = st.sstatus
                      WHERE u.orgid=v_orgid AND u.usertype='student' AND is_system_user(u.username)=0
                                            AND u.deleted=FALSE AND u.userid=in_userid) AS t);

        v_year := (SELECT json_agg(t) FROM (SELECT startdate, enddate FROM academicyear WHERE yearid=active_year(v_orgid)) AS t);
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_fees,', "details":',v_details,', "calendar": ',v_year,'}}');

    CALL log_activity('fees','view',in_connid,CONCAT('Fetched. For student:',in_userid),TRUE);

    RETURN au;
END; $$;

-- Add student's fee
DROP FUNCTION IF EXISTS addstudentfee;
CREATE OR REPLACE FUNCTION addstudentfee (IN in_connid VARCHAR(128), IN in_userid INTEGER, 
            IN in_type VARCHAR(20), IN in_method VARCHAR(10),
            IN in_amount NUMERIC, IN in_reference VARCHAR(20), IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_fees JSON;
    au VARCHAR(9216);
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('fees','add',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDFEES');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF active_year(v_orgid) = 0 THEN
        v_error := (SELECT fetchError(in_locale,'calTermNoActYear')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    INSERT INTO fees (userid, ftype, amount, paidby, paidon, reference, yearid) 
    VALUES (in_userid, in_type, in_amount, in_method, CURRENT_DATE, in_reference, active_year(v_orgid));
    
    v_fees := (SELECT getstudentfees(in_connid, in_userid));

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_fees,'}}');

    CALL log_activity('fees','add',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

DROP FUNCTION IF EXISTS updatestudentfee;
CREATE OR REPLACE FUNCTION updatestudentfee (IN in_connid VARCHAR(128), IN in_feeid INTEGER, IN in_userid INTEGER, 
            IN in_type VARCHAR(20), IN in_method VARCHAR(10),
            IN in_amount NUMERIC, IN in_reference VARCHAR(20), IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_fees JSON;
    au VARCHAR(9216);
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('fees','update',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDFEES');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF active_year(v_orgid) = 0 THEN
        v_error := (SELECT fetchError(in_locale,'calTermNoActYear')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE fees SET ftype = in_type, paidby = in_method, amount = in_amount, reference = in_reference, paidon = CURRENT_DATE WHERE feeid = in_feeid AND userid = in_userid;
   
    v_fees := (SELECT getstudentfees(in_connid, in_userid));

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_fees,'}}');

    CALL log_activity('fees','update',in_connid,CONCAT('Updated For org:',v_orgid,';feeid:',in_feeid),TRUE);

    RETURN au;
END; $$;

DROP FUNCTION IF EXISTS removestudentfee;
CREATE OR REPLACE FUNCTION removestudentfee (IN in_connid VARCHAR(128), IN in_feeid INTEGER, IN in_userid INTEGER) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_fees JSON;
    au VARCHAR(9216);
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('fees','remove',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDFEES');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF active_year(v_orgid) = 0 THEN
        v_error := (SELECT fetchError(in_locale,'calTermNoActYear')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    DELETE FROM fees WHERE feeid = in_feeid AND userid = in_userid;
   
    v_fees := (SELECT getstudentfees(in_connid, in_userid));

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_fees,'}}');

    CALL log_activity('fees','remove',in_connid,CONCAT('Femoved. For org:',v_orgid,';feeid:',in_feeid),TRUE);

    RETURN au;
END; $$;