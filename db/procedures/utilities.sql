\c shopman_pos; 

DROP FUNCTION IF EXISTS system_magik;
CREATE OR REPLACE FUNCTION system_magik() RETURNS CHAR(10) LANGUAGE plpgsql
AS $$
BEGIN
	RETURN '1478637565';
END; $$;

DROP FUNCTION IF EXISTS is_db_admin;
CREATE OR REPLACE FUNCTION is_db_admin() RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
DECLARE
    v_current_user VARCHAR(20);
BEGIN
    v_current_user := (SELECT current_user);
    RETURN CASE v_current_user WHEN 'postgres' THEN TRUE ELSE FALSE END;
END; $$;

--Gets the username based on the userid
DROP FUNCTION IF EXISTS userid2name;
CREATE OR REPLACE FUNCTION userid2name(in_userid INTEGER) RETURNS VARCHAR(64) LANGUAGE plpgsql
AS $$
DECLARE
    v_username VARCHAR(64);
BEGIN
    v_username := (SELECT username FROM users WHERE userid=in_userid);
    IF v_username IS NULL THEN
        RAISE EXCEPTION 'No such user.' USING HINT = CONCAT('Verify the userid : ',in_userid,' exists.');
    END IF;
    RETURN v_username;
END; $$;

--Checks if a user is the system manager
DROP FUNCTION IF EXISTS is_sys;
CREATE OR REPLACE FUNCTION is_sys(in_userid INTEGER) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
DECLARE
    v_username VARCHAR(64);
BEGIN
	v_username := userid2name(in_userid);
    RETURN CASE v_username WHEN 'system' THEN TRUE ELSE FALSE END;
END; $$;

-- Checks that a value is not null
DROP FUNCTION IF EXISTS NOTNULL;
CREATE OR REPLACE FUNCTION NOTNULL(in_str VARCHAR(512)) RETURNS VARCHAR(512) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN IFNULL(in_str, NULLstr());
END; $$;

-- Determines if a variable we defined exists
DROP FUNCTION IF EXISTS NULLstr;
CREATE OR REPLACE FUNCTION NULLstr() RETURNS VARCHAR(10) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT vvalue FROM VARIABLES WHERE vname='NULLstr' LIMIT 1);
END; $$;

-- Gets the orgid based on the userid
DROP FUNCTION IF EXISTS userid2orgid;
CREATE OR REPLACE FUNCTION userid2orgid(in_userid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE
   v_orgid INTEGER DEFAULT NULL;
BEGIN
    v_orgid := (SELECT orgid FROM users WHERE userid=in_userid) ;
    IF v_orgid IS NULL THEN
        -- RAISE EXCEPTION 'No such user.' USING HINT = CONCAT('Verify the userid : ',in_userid,' exists.');
        RAISE EXCEPTION 'No such user.' USING HINT = 'No such user.';
    END IF;
    RETURN v_orgid ;
END; $$;

-- Gets the user's orgId based on the user's id
DROP FUNCTION IF EXISTS userid2orgid2;
CREATE OR REPLACE FUNCTION userid2orgid2(in_userid INTEGER, strict INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE
    v_orgid INTEGER DEFAULT NULL;
BEGIN
    v_orgid := (SELECT orgid FROM users WHERE userid=in_userid) ;
    IF v_orgid IS NULL AND strict <> 0 THEN
        -- RAISE EXCEPTION 'No such user.' USING HINT = CONCAT('Verify the userid : ',in_userid,' exists.');
        RAISE EXCEPTION 'No such user.' USING HINT = 'No such user.';
    END IF;
    RETURN v_orgid ;
END; $$;

-- IFNULL
DROP FUNCTION IF EXISTS IFNULL;
CREATE OR REPLACE FUNCTION IFNULL(expression VARCHAR(255), alt_value VARCHAR(255)) RETURNS VARCHAR(255) LANGUAGE plpgsql
AS $$
BEGIN
    IF expression IS NULL THEN
        RETURN alt_value;
    ELSE
        RETURN expression ;
    END IF ;
END; $$;

-- Logs an activity. Initial log
DROP PROCEDURE IF EXISTS log_activity;
CREATE OR REPLACE PROCEDURE log_activity(
        IN topic VARCHAR(32), 
		IN aktion VARCHAR(32), 
		IN connid VARCHAR(128), 
		IN details VARCHAR(1024),
		IN final BOOLEAN) LANGUAGE plpgsql
AS $$
DECLARE
    v_orgid INTEGER DEFAULT NULL;
    v_userid INTEGER DEFAULT NULL;
BEGIN
    v_userid := connid2userida(connId, 0);
    IF v_userid IS NOT NULL THEN 
        v_orgid := userid2orgid2(v_userId, 0); 
    END IF;

    INSERT INTO auditlogs(orgid, topic, aktion, connectionid, details, final, thetime) 
            VALUES(v_orgid, topic, aktion, connid, IFNULL(details,NULLstr()), final, CURRENT_TIMESTAMP);
END; $$;

-- Gets the userId from the connection Id
DROP FUNCTION IF EXISTS connid2userid;
CREATE OR REPLACE FUNCTION connid2userid(connid VARCHAR(128)) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER DEFAULT NULL;
BEGIN
    v_userid := (SELECT userid FROM userlogins WHERE connectionid = connid) ;
    IF v_userid IS NULL THEN
        -- RAISE EXCEPTION 'No such connection.' USING HINT = CONCAT('Verify if the connection: ',connid,' exists.');
        RAISE EXCEPTION 'No such connection.' USING HINT = 'No such connection.';
    END IF;
    RETURN v_userid;
END; $$;

-- Gets the userId from the connection Id. previously connid2userida
DROP FUNCTION IF EXISTS connid2userida;
CREATE OR REPLACE FUNCTION connid2userida(connid VARCHAR(128), strict INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER DEFAULT NULL;
BEGIN
    v_userid := (SELECT userid FROM userlogins WHERE connectionid = connid AND logouttime IS NULL) ;
    IF v_userid IS NULL AND strict <> 0 THEN
        -- RAISE EXCEPTION 'No such connection.' USING HINT = CONCAT('Verify if the connection: ',connid,' exists.');
        RAISE EXCEPTION 'No such connection.' USING HINT = 'No such connection.';
    END IF;
    RETURN v_userid;
END; $$;

-- Gets the userid based on the username
DROP FUNCTION IF EXISTS username2id;
CREATE OR REPLACE FUNCTION username2id(in_username VARCHAR(64), in_orgid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER DEFAULT NULL;
BEGIN
    v_userid := (SELECT userid FROM users WHERE username = in_username AND orgid=in_orgid) ;
    IF v_userid IS NULL THEN
        -- RAISE EXCEPTION 'No such user.' USING HINT = CONCAT('Verify the username: ',in_username,' exists in org: ',in_orgid);
        RAISE EXCEPTION 'No such user.' USING HINT = 'No such user.';
    END IF;
    RETURN v_userid;
END; $$;

-- Gets the userid based on the username
DROP FUNCTION IF EXISTS username2id2;
CREATE OR REPLACE FUNCTION username2id2(in_username VARCHAR(64), in_orgid INTEGER, strict INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER DEFAULT NULL;
BEGIN
    v_userid := (SELECT userid FROM users WHERE username = in_username AND orgid=in_orgid) ;
    IF v_userid IS NULL AND strict <> 0 THEN
        -- RAISE EXCEPTION 'No such user.' USING HINT = CONCAT('Verify the username: ',in_username,' exists in org: ',in_orgid);
        RAISE EXCEPTION 'No such user.' USING HINT = 'No such user.';
    END IF;
    RETURN v_userid;
END; $$;

-- Gets the username based on the userid
DROP FUNCTION IF EXISTS userid2name;
CREATE OR REPLACE FUNCTION userid2name(in_userid INTEGER) RETURNS VARCHAR(64) LANGUAGE plpgsql
AS $$
DECLARE
    v_username VARCHAR(64) DEFAULT NULL;
BEGIN   
    v_username := (SELECT username FROM users WHERE userid = in_userid) ;
    IF v_username IS NULL THEN
        -- RAISE EXCEPTION 'No such user.' USING HINT = CONCAT('Verify the userid: ',in_userid,' exists.');
        RAISE EXCEPTION 'No such user.' USING HINT = 'No such user.';
    END IF;
    RETURN v_username;
END; $$;

-- Gets the user orgid based on the userrole
DROP FUNCTION IF EXISTS roleid2orgid;
CREATE OR REPLACE FUNCTION roleid2orgid(in_roleid INTEGER) RETURNS VARCHAR(64) LANGUAGE plpgsql
AS $$
DECLARE
    v_orgid INTEGER DEFAULT NULL;
BEGIN   
    v_orgid := (SELECT orgid FROM roles WHERE roleid = in_roleid) ;
    IF v_orgid IS NULL THEN
        -- RAISE EXCEPTION 'No such role.' USING HINT = CONCAT('Verify the roleid: ',v_roleid,' exists.');
        RAISE EXCEPTION 'No such role.' USING HINT = 'No such role.';
    END IF;
    RETURN v_orgid;
END; $$;

-- Gets the user rolename based on the role id
DROP FUNCTION IF EXISTS roleid2name;
CREATE OR REPLACE FUNCTION roleid2name(in_roleid INTEGER) RETURNS VARCHAR(64) LANGUAGE plpgsql
AS $$
DECLARE
    v_rolename VARCHAR(64) DEFAULT NULL;
BEGIN   
    v_rolename := (SELECT rname FROM roles WHERE roleid = in_roleid) ;
    IF v_rolename IS NULL THEN
        -- RAISE EXCEPTION 'No such role.' USING HINT = CONCAT('Verify the roleid: ',v_roleid,' exists.');
        RAISE EXCEPTION 'No such role.' USING HINT = 'No such role.';
    END IF;
    RETURN v_rolename;
END; $$;

-- Gets the current host
DROP FUNCTION IF EXISTS CLIENT_WRKSTNNAME;
CREATE OR REPLACE FUNCTION CLIENT_WRKSTNNAME() RETURNS VARCHAR(255) LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (SELECT inet_client_addr());
END; $$;

DROP FUNCTION IF EXISTS mon_get_application_id;
CREATE OR REPLACE FUNCTION mon_get_application_id() RETURNS VARCHAR(255) LANGUAGE plpgsql
AS $$
DECLARE
    v_appid VARCHAR(255);
BEGIN
    v_appid := CONCAT(CLIENT_WRKSTNNAME(),RANDOM());
    RETURN v_appid;
END; $$;

-- Validates an IP
DROP PROCEDURE IF EXISTS validate_ip_addr;
CREATE OR REPLACE PROCEDURE validate_ip_addr (p_connid VARCHAR(128), p_ipaddr VARCHAR(255)) LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT EXISTS (SELECT * FROM userlogins WHERE connectionid=p_connid AND remotehost=p_ipaddr) THEN
    -- RAISE EXCEPTION 'IP address changed.' USING HINT = 'Have you switch network?';
    RAISE EXCEPTION 'IP address changed. Have you switch network?' USING HINT = 'IP address changed. Have you switch network?';
  END IF;
END; $$;

-- Splits a string of text and save in a temp table
DROP PROCEDURE IF EXISTS split;
CREATE OR REPLACE PROCEDURE split (ttext TEXT) LANGUAGE plpgsql
AS $$
DECLARE 
    a INT Default 0 ;
    l INT DEFAULT 0 ;
    t VARCHAR(60);
    stri JSONB;
BEGIN
    DROP TABLE IF EXISTS the_split_tbl;
    CREATE TEMPORARY TABLE the_split_tbl(column_values VARCHAR (60));

    l := jsonb_array_length(ttext::JSONB);
    LOOP
        t := ttext::JSONB->a ;
        INSERT INTO the_split_tbl VALUES (TRANSLATE(t::TEXT,'"','')) ;
        a := a + 1 ;
        IF a = l THEN
            RETURN ;
        END IF;
    END LOOP;
    
END; $$;

-- Authenticates a user
DROP FUNCTION IF EXISTS authenticateuser;
CREATE OR REPLACE FUNCTION authenticateuser (in_user INTEGER, in_password VARCHAR(255)) RETURNS INTEGER LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT * FROM users WHERE userid=in_user AND pwd = CRYPT(in_password,pwd) AND deleted=FALSE) THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END; $$;

-- Splits a string of text and save in a temp table
DROP PROCEDURE IF EXISTS authenticateuser;
CREATE OR REPLACE PROCEDURE authenticateuser (IN in_connid VARCHAR(128), IN in_password VARCHAR(128), OUT out_match INTEGER) LANGUAGE plpgsql
AS $$
DECLARE 
    v_userId INTEGER;
BEGIN
    v_userId := connid2userida(inConnId, 1);
    out_match := authenticateuser(v_userId, in_password);
END; $$;

-- Gets role id from role name
DROP FUNCTION IF EXISTS rolename2id;
CREATE OR REPLACE FUNCTION rolename2id (in_rolename VARCHAR(64), in_orgid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_roleid int default NULL;
BEGIN
    v_roleid := (SELECT roleid FROM roles WHERE orgid=in_orgid AND rname=in_rolename) ;
    IF v_roleId IS NULL THEN
		-- RAISE EXCEPTION 'No such role.' USING HINT = CONCAT('Verify the role with ame: ',in_rolename,' exists.');
        RAISE EXCEPTION 'No such role.' USING HINT = 'No such role.';
	END IF;
	RETURN v_roleid;
END; $$;

-- Gets role id from role name
DROP FUNCTION IF EXISTS rolename2ida;
CREATE OR REPLACE FUNCTION rolename2ida (in_rolename VARCHAR(64), in_orgid INTEGER, signal_error INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_roleid int default NULL;
BEGIN
    v_roleid := (SELECT roleid FROM roles WHERE orgid=in_orgid AND rname=in_rolename) ;
    IF v_roleId IS NULL AND signal_error <> 0 THEN
		-- RAISE EXCEPTION 'No such role.' USING HINT = CONCAT('Verify the role with name: ',in_rolename,' exists.');
        RAISE EXCEPTION 'No such role.' USING HINT = 'No such role.';
	END IF;
	RETURN v_roleid;
END; $$;

DROP FUNCTION IF EXISTS servertime;
CREATE OR REPLACE FUNCTION servertime () RETURNS VARCHAR(64) LANGUAGE plpgsql
AS $$
DECLARE 
    v_unix VARCHAR(64);
BEGIN
    v_unix := (SELECT EXTRACT (EPOCH FROM NOW()));
   RETURN v_unix;
END; $$;

DROP FUNCTION IF EXISTS wheel;
CREATE OR REPLACE FUNCTION wheel(in_userid INTEGER, in_pwd VARCHAR(255), authenticate BOOLEAN) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
DECLARE 
    ret BOOLEAN DEFAULT FALSE;
BEGIN
    IF is_db_admin() THEN
		ret := TRUE;
	ELSE BEGIN
			IF EXISTS(SELECT * FROM userroles WHERE userid=in_userid AND roleid=rolename2id('wheel', userId2orgid(in_userid))) THEN
				ret := CASE authenticate
								WHEN FALSE THEN TRUE
								ELSE authenticateUser(in_userid, in_pwd) END;
			END IF;
		END;
	END IF;
	RETURN ret;
END; $$;

-- Verifies if a user is logged in
DROP FUNCTION IF EXISTS is_logged_in;

CREATE OR REPLACE FUNCTION is_logged_in(inconnid varchar(128)) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
BEGIN
	RETURN EXISTS(SELECT * FROM userlogins WHERE connectionid=inconnid AND logouttime IS NULL);
END; $$;

-- Used to check a user's login status
DROP PROCEDURE IF EXISTS checkloginstatus;
CREATE OR REPLACE PROCEDURE checkloginstatus (in_connid VARCHAR(128)) LANGUAGE plpgsql
AS $$
DECLARE 
    v_remhost VARCHAR(128) DEFAULT NULL;
BEGIN
   -- v_remhost := CLIENT_WRKSTNNAME();
   v_remhost := SPLIT_PART(in_connid, '@', 2);
   IF v_remhost <> in_connid THEN
        -- in_connId := LEFT(in_connId, LENGTH(in_connId)-LENGTH(v_remhost)-1);
        CALL validate_ip_addr(in_connId, v_remhost);
   END IF;

   IF NOT is_logged_in(in_connid) AND (NOT is_sys(connid2userId(in_connid)))  THEN 
        BEGIN 
		    -- RAISE EXCEPTION 'Not logged in.' USING HINT = CONCAT('Verify the connection with id: ',in_connid,' exists.');
            RAISE EXCEPTION 'Not logged in.' USING HINT = 'Not logged in.';
		END;
	END IF;
END; $$;

-- Used to check a user's login status
DROP PROCEDURE IF EXISTS checkloginstatusa;
CREATE OR REPLACE PROCEDURE checkloginstatusa (INOUT in_connid VARCHAR(128), is_system INTEGER) LANGUAGE plpgsql
AS $$
BEGIN
   IF NOT is_logged_in(in_connid) AND (is_system=0 OR NOT is_sys(connid2userId(in_connid)))  THEN 
        BEGIN 
		    -- RAISE EXCEPTION 'Not logged in.' USING HINT = CONCAT('Verify the connection with id: ',in_connid,' exists.');
            RAISE EXCEPTION 'Not logged in.' USING HINT = 'Not logged in.';
		END;
	END IF;
END; $$;

-- Used to check a user's login status
DROP FUNCTION IF EXISTS haspermission;
CREATE OR REPLACE FUNCTION haspermission (in_user INTEGER, in_priv VARCHAR(255)) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
BEGIN
  RETURN is_db_admin() OR EXISTS(SELECT * FROM userprivs WHERE userid=in_user AND priv=in_priv) ;
END; $$;

-- Used to check a user's login status
DROP PROCEDURE IF EXISTS checkpermission;
CREATE OR REPLACE PROCEDURE checkpermission (in_user INTEGER, in_perm VARCHAR(32)) LANGUAGE plpgsql
AS $$
BEGIN
  IF NOT haspermission(in_user,in_perm) AND (NOT is_sys(in_user)) THEN
    BEGIN
        RAISE EXCEPTION 'Permission denied to % for %.', in_user,SUBSTRING(in_perm,1,32)  USING HINT = CONCAT('Permission denied. ','Verify user with id: ',in_user,' has permission for: ',SUBSTRING(in_perm,1,32));
    END;
  END IF;
END; $$;

-- Verifies a user's privilege
DROP PROCEDURE IF EXISTS verifyprivilege;
CREATE OR REPLACE PROCEDURE verifyprivilege (INOUT in_connid VARCHAR(128), in_perm VARCHAR(32)) LANGUAGE plpgsql
AS $$
BEGIN
    CALL checkloginstatusa(in_connid,0);
    CALL checkpermission(connid2userId(in_connId),  in_perm);
END; $$;

-- Verifies if a user is a system user
DROP FUNCTION IF EXISTS is_system_user;
CREATE OR REPLACE FUNCTION is_system_user (in_username VARCHAR(64)) RETURNS INTEGER LANGUAGE plpgsql
AS $$
BEGIN
  RETURN CASE WHEN in_username in ('system', 'wheel', 'admin', 'root', 'postgres') THEN 1 ELSE 0 END;
END; $$;

-- Verifies if a user is deleted
DROP FUNCTION IF EXISTS is_deleted_user;
CREATE OR REPLACE FUNCTION is_deleted_user (in_userid INTEGER) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
DECLARE
    ret BOOLEAN DEFAULT FALSE;
BEGIN
    ret := (SELECT deleted FROM users WHERE userid=in_userid) ;
    RETURN ret ;
END; $$;

-- Verifies if a year is active
DROP FUNCTION IF EXISTS is_active_year;

CREATE OR REPLACE FUNCTION is_active_year(in_yearid INTEGER) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
BEGIN
	RETURN EXISTS(SELECT * FROM academicyear WHERE startdate <= CURRENT_DATE AND enddate >= CURRENT_DATE AND yearid = in_yearid);
END; $$;

-- Verifies if a year is active
DROP FUNCTION IF EXISTS active_year;

CREATE OR REPLACE FUNCTION active_year(in_orgid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_yearid INTEGER DEFAULT NULL;
BEGIN
	v_yearid := (SELECT yearid FROM academicyear WHERE enddate >= CURRENT_DATE AND orgid=in_orgid);
    RETURN CASE WHEN v_yearid IS NULL THEN 0 ELSE v_yearid END;
END; $$;

-- Verifies if a term is active
DROP FUNCTION IF EXISTS is_active_term;

CREATE OR REPLACE FUNCTION is_active_term(in_termid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
BEGIN
	RETURN EXISTS(SELECT * FROM academicterm WHERE startdate <= CURRENT_DATE AND enddate >= CURRENT_DATE AND termid = in_termid);
END; $$;

-- Verifies if a year is active
DROP FUNCTION IF EXISTS active_term;

CREATE OR REPLACE FUNCTION active_term(in_yearid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_termid INTEGER DEFAULT NULL;
BEGIN
	v_termid := (SELECT termid FROM academicterm WHERE enddate >= CURRENT_DATE AND yearid=in_yearid);
    RETURN CASE WHEN v_termid IS NULL THEN 0 ELSE v_termid END;
END; $$;

-- Verifies if a year is active
DROP FUNCTION IF EXISTS term2year;

CREATE OR REPLACE FUNCTION term2year(in_termid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_yearid INTEGER DEFAULT NULL;
BEGIN
	v_yearid := (SELECT yearid FROM academicterm WHERE termid=in_termid);
    RETURN CASE v_yearid WHEN NULL THEN 0 ELSE v_yearid END;
END; $$;

-- Verifies if a year is active
DROP FUNCTION IF EXISTS active_exam;

CREATE OR REPLACE FUNCTION active_exam(in_termid INTEGER) RETURNS INTEGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_examid INTEGER DEFAULT NULL;
BEGIN
    v_examid := (SELECT examid FROM examinations WHERE enddate >= CURRENT_DATE AND term=in_termid);
    RETURN CASE WHEN v_examid IS NULL THEN 0 ELSE v_examid END;
END; $$;

-- Verifies if an exam is active
DROP FUNCTION IF EXISTS is_active_exam;
CREATE OR REPLACE FUNCTION is_active_exam(in_examid INTEGER) RETURNS BOOLEAN LANGUAGE plpgsql
AS $$
BEGIN
	RETURN EXISTS(SELECT * FROM examinations WHERE enddate >= CURRENT_DATE AND examid = in_examid);
END; $$;

-- org insert trigger
DROP FUNCTION IF EXISTS ai_org CASCADE;
CREATE OR REPLACE FUNCTION ai_org() RETURNS TRIGGER LANGUAGE plpgsql
AS $$
DECLARE 
    v_orgid INTEGER DEFAULT NULL;
    user_1 INTEGER DEFAULT NULL;
    user_2 INTEGER DEFAULT NULL;
BEGIN
	v_orgid := NEW.orgid;
    INSERT INTO users (orgId,username,pwd,surname,othernames,emailaddress,phonenumber,position,usertype,dob,gender,onidle,locale,deleted) VALUES (v_orgId,'wheel',CRYPT('wheel',gen_salt('bf')),'Big Wheel',NULL,NULL,NULL,NULL,'system',NULL,NULL,NULL,NULL,0),(v_orgId,'system',CRYPT('system',gen_salt('bf')),'system','Internal rule keeper',NULL,NULL,NULL,'system',NULL,NULL,NULL,NULL,0),(v_orgId,'super',CRYPT('super',gen_salt('bf')),'Super','Authorizor',NULL, NULL,NULL,'system',NULL,NULL,NULL,NULL,0),(v_orgId,'dev01',CRYPT('dev01',gen_salt('bf')),'Developer','Eins','dev@mail.com',NULL,NULL,'administrator',NULL,NULL,NULL,NULL,0),(v_orgId,'dev02',CRYPT('dev02',gen_salt('bf')),'Developer','Zwei','nobody@mail.com',NULL,NULL,'administrator',NULL,NULL,NULL,NULL,0);
	INSERT INTO roles (orgId,name,description) VALUES (v_orgId,'wheel','Administrative tasks'),(v_orgId,'system','system rule keeper'),(v_orgId,'supervisor','Authorize exceptions'),(v_orgId,'administrator','The system administrator. He/She manages the system on behalf of the institution'),(v_orgId,'reports','Generate reports of all types'),(v_orgId,'teacher','A school teacher.'),(v_orgId,'classmaster','Teacher who can perform very special operations.');
	user_1 := (SELECT userid FROM users WHERE username = 'dev01' AND orgid=v_orgid);
	user_2 := (SELECT userid FROM users WHERE username = 'wheel' AND orgid=v_orgid);
	INSERT INTO userroles (userid,roleid) VALUES (user_2,1),(user_1,4);

    RETURN NEW;
END; $$;

-- Triggers for the organisation tables start
DROP TRIGGER IF EXISTS ai_organisations ON organisations ;
CREATE OR REPLACE TRIGGER ai_organisations AFTER INSERT ON organisations 
FOR EACH ROW
EXECUTE PROCEDURE ai_org();

-- Fetchs error message
DROP FUNCTION IF EXISTS fetcherror;

CREATE OR REPLACE FUNCTION fetcherror(in_locale VARCHAR(5), in_errkey VARCHAR(30)) RETURNS VARCHAR(255) LANGUAGE plpgsql
AS $$
DECLARE 
    v_error VARCHAR(255) DEFAULT NULL;
BEGIN
    IF in_locale = 'en' OR in_locale = 'en_US' THEN
        v_error := (SELECT erren FROM errormessages WHERE errkey=in_errkey);
    ELSEIF in_locale = 'fr' OR in_locale = 'en_FR' THEN
        v_error := (SELECT errfr FROM errormessages WHERE errkey=in_errkey);
    ELSE
        v_error := (SELECT erren FROM errormessages WHERE errkey=in_errkey);
    END IF;
    RETURN v_error;
END; $$;

-- Triggers for user table insert start
DROP FUNCTION IF EXISTS ai_user CASCADE;
CREATE OR REPLACE FUNCTION ai_user() RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO stalepasswds(userid) VALUES (NEW.userid);
    RETURN NEW ;
END; $$;

DROP TRIGGER IF EXISTS ai_users ON users ;
CREATE OR REPLACE TRIGGER ai_users AFTER INSERT ON users 
FOR EACH ROW
EXECUTE PROCEDURE ai_user();

DROP FUNCTION IF EXISTS bu_user CASCADE;
CREATE OR REPLACE FUNCTION bu_user() RETURNS TRIGGER LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.username <> OLD.username THEN
        RAISE EXCEPTION 'Cannot alter user name.' USING HINT = 'Cannot alter user name.';
    END IF;
    RETURN NEW ;
END; $$;

DROP TRIGGER IF EXISTS bu_users ON users ;
CREATE OR REPLACE TRIGGER bu_users BEFORE UPDATE ON users 
FOR EACH ROW
EXECUTE PROCEDURE bu_user();

--Fees trigger
DROP FUNCTION IF EXISTS bu_fee CASCADE;
CREATE OR REPLACE FUNCTION bu_fee() RETURNS TRIGGER LANGUAGE plpgsql
AS $$
DECLARE
    v_days INTEGER;
BEGIN
    v_days := (SELECT DATE_PART('day', OLD.paidon::TIMESTAMP - CURRENT_TIMESTAMP));
	IF v_days < 0 THEN
        RAISE EXCEPTION 'Cannot update or delete fee after 24 hours.' USING HINT = 'Cannot update or delete fee after 24 hours.';
    END IF;
    RETURN NEW ;
END; $$;

DROP TRIGGER IF EXISTS bu_fees ON fees ;
CREATE OR REPLACE TRIGGER bu_fees BEFORE UPDATE ON fees 
FOR EACH ROW
EXECUTE PROCEDURE bu_fee();

DROP TRIGGER IF EXISTS bd_fees ON fees ;
CREATE OR REPLACE TRIGGER bd_fees BEFORE DELETE ON fees 
FOR EACH ROW
EXECUTE PROCEDURE bu_fee();