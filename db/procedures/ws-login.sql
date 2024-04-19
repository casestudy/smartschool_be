\c shopman_pos; 

-- Verifies a user's privilege
DROP PROCEDURE IF EXISTS cachepermissionsforuser;
CREATE OR REPLACE PROCEDURE cachepermissionsforuser (IN in_userid INTEGER) LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM userprivs WHERE userid = in_userid;
    INSERT INTO userprivs(userid, priv)
            SELECT in_userid, p.mode
            FROM permissions p
            WHERE p.roleid in (SELECT roleid FROM userroles WHERE userid=in_userid)
            UNION
            SELECT in_userid, p.mode
            FROM permissions p
            WHERE p.roleid in (SELECT roleid 
                                    FROM rolepermissions 
                                    WHERE ownerroleid IN (SELECT roleid FROM userroles WHERE userid=in_userid));

    EXCEPTION WHEN OTHERS THEN
    BEGIN
        ROLLBACK;
        RAISE EXCEPTION '% %', SQLERRM, SQLSTATE;
    END;

    COMMIT;
END; $$;

DROP FUNCTION IF EXISTS getpermissionsforuser;
CREATE OR REPLACE FUNCTION getpermissionsforuser (IN in_userid INTEGER) RETURNS JSON LANGUAGE plpgsql
AS $$
DECLARE 
    perms JSON;
BEGIN
    perms := (SELECT json_agg(json_build_object('mode',up.priv)) FROM userprivs up WHERE up.userid=in_userid);
    RETURN perms;
END; $$;

-- Feteches last login
DROP FUNCTION IF EXISTS lastlogin;
CREATE OR REPLACE FUNCTION lastlogin (in_userid INTEGER, in_appid VARCHAR(128)) RETURNS TABLE(
    userid INTEGER, 
    orgid INTEGER, 
    username VARCHAR(64),
    surname VARCHAR(128), 
    othernames VARCHAR(128), 
    emailaddress VARCHAR(255), 
    phonenumber VARCHAR(255), 
    positio VARCHAR(255), 
    dob DATE,
    gender BOOLEAN, 
    locale CHAR(5), 
    onidle VARCHAR(10), 
    usertype VARCHAR(20), 
    lastlogin TIMESTAMP, 
    remotehost VARCHAR(255), 
    workstation VARCHAR(255), 
    app_id VARCHAR(128), 
    idletmout INTEGER, 
    chpasswd INTEGER, 
    tz INTEGER) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT u.userid, u.orgid, u.username, u.surname, u.othernames, u.emailaddress, u.phonenumber, u.position, u.dob, u.gender, u.locale, u.onidle, u.usertype,
			   l.logintime, l.remotehost, l.CLIENT_WRKST as workstation, in_appid as appid,
			   i.onidletimeout as idletmout, 
			   (CASE WHEN sp.userid IS NULL THEN 0 ELSE 1 END) AS chpasswd, 
			   0 as TZ
		  FROM users u
    LEFT JOIN userlogins l ON u.userid=l.userid 
    LEFT JOIN stalepasswds sp ON sp.userid=u.userid
    LEFT JOIN onidletypes i ON i.onidle=u.onidle
    WHERE u.userid=in_userid AND l.connectionid<>in_appid AND l.logintime=(SELECT MAX(ul.logintime) FROM userlogins ul WHERE ul.userid=in_userid AND ul.connectionid<>in_appid);
END; $$;

-- Logins in a user
DROP FUNCTION IF EXISTS loginuser;
CREATE OR REPLACE FUNCTION loginuser (IN username VARCHAR(64), IN in_orgid INTEGER, 
    IN pwd VARCHAR(128), IN machineid VARCHAR(255), IN machineidtype VARCHAR(5), 
    IN remotehost VARCHAR(255), IN magik CHAR(10), IN locale VARCHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_error VARCHAR(255);
    v_usertype VARCHAR(255);
    v_connid VARCHAR(128);
    v_appid VARCHAR(128);
    perms JSON;
    dashboard JSON;
    ll JSON;
    lu VARCHAR(9216);
BEGIN
    v_appid := mon_get_application_id();

    CALL log_activity('user','login', CONCAT('_H:',v_connid), CONCAT('usrname: ', NOTNULL(username) , '/' , NOTNULL(in_orgid::VARCHAR(64)), '@', NOTNULL(machineid) , '; rhost: ' , NOTNULL(remotehost) ,  '; on: ', CLIENT_WRKSTNNAME())::VARCHAR(2024),FALSE);
    
    IF magik IS NULL OR magik <> system_magik() THEN
		v_error := (SELECT fetchError(locale,'loginBadMagik')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    -- IF is_db_admin() <> 0 THEN
        -- v_error := (SELECT fetchError(locale,'loginCantRoot')) ;
		-- RAISE EXCEPTION '%', v_error;
	-- END IF;
    
    v_userid := username2id(username,in_orgid);
    IF v_userid IS NULL THEN
        v_error := (SELECT fetchError(locale,'loginBadCredentials')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF is_system_user(username) = 1 THEN
        v_error := (SELECT fetchError(locale,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF EXISTS(SELECT * FROM stalepasswds WHERE userid = v_userid) THEN
        v_error := (SELECT fetchError(locale,'loginChangePass')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF EXISTS (SELECT * FROM assistances WHERE teacher=v_userid AND status=TRUE AND yearid=active_year(in_orgid)) THEN
		v_error := (SELECT fetchError(locale,'loginUnderAssist')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
	END IF;

    IF remotehost = 'mobile' THEN
		v_usertype := (SELECT usertype  FROM users WHERE userid=v_userid);
		IF v_userType <> 'teacher' THEN
            v_error := (SELECT fetchError(locale,'loginNoConOnMobi')) ;
			RAISE EXCEPTION '%', v_error USING HINT = v_error;
		END IF; 
	END IF;

    IF username <> 'super' THEN
		IF NOT EXISTS(SELECT * FROM organisations WHERE orgid=in_orgid AND expirydate > CURRENT_TIMESTAMP) THEN
            v_error := (SELECT fetchError(locale,'loginOrgExpired')) ;
			RAISE EXCEPTION '%', v_error USING HINT = v_error;
		END IF;
	END IF;

    BEGIN
        IF authenticateUser(v_userId,pwd)<>0 THEN 
            v_appid := CONCAT(servertime(),mon_get_application_id(),'@',remotehost) ;

            INSERT INTO userlogins(userid,remotehost,machineid,machineidtype,logintime, CLIENT_WRKST, connectionid)
            VALUES (v_userid,remotehost,machineid,machineidtype,CURRENT_TIMESTAMP,(CLIENT_WRKSTNNAME()), v_appid);

            CALL log_activity('user','login', v_appId, CONCAT('logged in: ',userid2name(v_userid) ,'.'), TRUE);

            CALL cachepermissionsforuser(v_userid);
            perms := (SELECT getpermissionsforuser(v_userid)); 
            dashboard := (SELECT getdashboarddetails(v_userid,locale));
            ll := (SELECT json_agg(t) FROM lastlogin(v_userid,v_appid) t);
            lu := CONCAT('{"error":false,"result":{"status":200,"value":[',ll,',',perms,',',dashboard,']}}');
            RETURN lu;
        ELSE
            v_error := (SELECT fetchError(locale,'loginAuthenFail')) ;
            RAISE EXCEPTION '%', v_error USING HINT = v_error;
            ROLLBACK;
        END IF;
    END;
END; $$;

-- Logouts a user
DROP PROCEDURE IF EXISTS logoutuser;
CREATE OR REPLACE PROCEDURE logoutuser (IN in_connid VARCHAR(128), IN in_locale CHAR(5)) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('users','logout',in_connid,CONCAT('_H:',in_connid),FALSE);

    IF NOT EXISTS (SELECT * FROM userlogins WHERE connectionid = in_connid AND logouttime IS NULL) THEN
        v_error := (SELECT fetchError(in_locale,'loginNoOpenConn')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE userlogins SET logouttime = CURRENT_TIMESTAMP WHERE connectionid = in_connid;

    v_userid := connid2userid(in_connid);

    CALL log_activity('users','logout',in_connid,CONCAT('Logged out UID:',v_userid),TRUE);

END; $$;

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

-- Changes a user's password
DROP PROCEDURE IF EXISTS chusrpwd;
CREATE OR REPLACE PROCEDURE chusrpwd (IN in_username VARCHAR(64), IN in_orgid INTEGER, IN in_emailaddr VARCHAR(128), IN in_code VARCHAR(128)) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_error VARCHAR(255);
BEGIN

    IF NOT EXISTS (SELECT * FROM stalepasswds WHERE userid = (SELECT userid FROM users WHERE username = in_username AND orgid = in_orgid)) THEN
        v_error := (SELECT fetchError('en','chgPassNotStalled')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF NOT EXISTS (SELECT * FROM users WHERE username = in_username AND emailaddress = in_emailaddr) THEN
        v_error := (SELECT fetchError('en','loginAuthenFail')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE users SET pwd = CRYPT(in_code,gen_salt('bf')) WHERE username = in_username AND orgid = in_orgid;
    DELETE FROM stalepasswds WHERE userid = (SELECT userid FROM users WHERE username = in_username AND orgid = in_orgid);

    CALL log_activity('users','chpasswd','',CONCAT('Changed password for user:',in_username,'/',in_orgid),TRUE);

END; $$;

-- Obsolete for when we use codes
DROP PROCEDURE IF EXISTS setusrpwdcode;
CREATE OR REPLACE PROCEDURE setusrpwdcode (IN in_username VARCHAR(64), IN in_orgid INTEGER, IN in_code VARCHAR(6)) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('users','setcode','',CONCAT('_H:'),FALSE);

    IF NOT EXISTS (SELECT * FROM stalepasswds WHERE userid = (SELECT userid FROM users WHERE username = in_username AND orgid = in_orgid)) THEN
        v_error := (SELECT fetchError('en','chgPassNotStalled')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    UPDATE stalepasswds SET code = in_code WHERE userid = (SELECT userid FROM users WHERE username = in_username AND orgid = in_orgid);

    CALL log_activity('users','setcode','',CONCAT('Set auth code for:',in_username,'/',in_orgid,'. code:',in_code),TRUE);

END; $$;