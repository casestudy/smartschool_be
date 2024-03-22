\c shopman_pos;
-- Fetches all users in our database
DROP FUNCTION IF EXISTS getusers;
CREATE OR REPLACE FUNCTION getusers (IN in_type VARCHAR(20), IN in_connid VARCHAR(128), IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_usertype VARCHAR(20);
    v_error VARCHAR(255);
    v_users JSON;
    au VARCHAR(9216);
BEGIN
    IF in_type = 'administrator' THEN
        CALL log_activity('users','view',in_connid,CONCAT('_H:',in_connid),FALSE);
        CALL verifyprivilege(in_connId, 'VIEWADMIN');

        v_userid := connid2userid(in_connid);
	    v_orgid := userid2orgid(v_userid);

        v_users := (SELECT json_agg(t) FROM (SELECT u.userId, u.username, u.surname, u.othernames, u.emailaddress, u.phonenumber, u.position ,u.dob, u.gender, u.locale, u.onIdle
	  		FROM users u
	  		WHERE u.orgid=v_orgid AND u.usertype IN ('administrator','hybrid1','hybrid3','hybrid4') AND is_system_user(u.username)=0 AND u.deleted=FALSE AND u.userid<>v_userid) AS t);
        
        IF v_users IS NULL THEN
            v_users := '[]';
        END IF;

        au := CONCAT('{"error":false,"result":{"status":200,"value":',v_users,'}}');

        CALL log_activity('users','view',in_connid,CONCAT('Fetched. Type:',in_type,' for org:',v_orgid),TRUE);

        RETURN au;
    ELSIF in_type = 'teacher' THEN
        CALL log_activity('users','view',in_connid,CONCAT('_H:',in_connid),FALSE);
        CALL verifyprivilege(in_connId, 'VIEWTEACH');

        v_userid := connid2userid(in_connid);
	    v_orgid := userid2orgid(v_userid);

        v_users := (SELECT json_agg(t) FROM (SELECT u.userId, u.orgId, u.username, u.surname, u.othernames, u.emailaddress, u.phonenumber, u.position ,u.dob, u.gender, u.locale, u.onIdle
	  		FROM users u
	  		WHERE u.orgid=v_orgid AND u.usertype IN ('teacher','hybrid1','hybrid2','hybrid4') AND is_system_user(u.username)=0 AND u.deleted=FALSE AND u.userid<>v_userid) AS t);

        IF v_users IS NULL THEN
            v_users := '[]';
        END IF;
        
        au := CONCAT('{"error":false,"result":{"status":200,"value":',v_users,'}}');

        CALL log_activity('users','view',in_connid,CONCAT('Fetched. Type:',in_type,' for org:',v_orgid),TRUE);

        RETURN au;
    ELSEIF in_type = 'parent'  THEN
        CALL log_activity('users','view',in_connid,CONCAT('_H:',in_connid),FALSE);
        CALL verifyprivilege(in_connId, 'VIEWPARENT');

        v_userid := connid2userid(in_connid);
	    v_orgid := userid2orgid(v_userid);

        v_users := (SELECT json_agg(t) FROM (SELECT u.userId, u.orgId, u.username, u.surname, u.othernames, u.emailaddress, u.phonenumber, u.position ,u.dob, u.gender, u.locale, u.onIdle
	  		FROM users u
	  		WHERE u.orgid=v_orgid AND u.usertype IN ('parent','hybrid2','hybrid3','hybrid4') AND is_system_user(u.username)=0 AND u.deleted=FALSE AND u.userid<>v_userid) AS t);

        IF v_users IS NULL THEN
            v_users := '[]';
        END IF;
        
        au := CONCAT('{"error":false,"result":{"status":200,"value":',v_users,'}}');

        CALL log_activity('users','view',in_connid,CONCAT('Fetched. Type:',in_type,' for org:',v_orgid),TRUE);

        RETURN au;
    ELSE
        v_error := (SELECT fetchError(in_locale,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

END; $$;

-- Adds a new user and returns all the users in this time
DROP FUNCTION IF EXISTS adduser;
CREATE OR REPLACE FUNCTION adduser (IN in_username VARCHAR(64), IN in_surname VARCHAR(64), 
                                    IN in_othernames VARCHAR(128), IN in_emailaddr VARCHAR(255), 
                                    IN in_phonenum VARCHAR(255), IN in_position VARCHAR(255),
                                    IN in_type VARCHAR(20), IN in_dob DATE, IN in_gender BOOLEAN,
                                    IN in_onidle VARCHAR(10), IN in_locale CHAR(5), IN in_connid VARCHAR(128),
                                    IN in_localee CHAR(2)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_users JSON;
    v_role INTEGER;
    v_uid INTEGER;
    au VARCHAR(9216);
BEGIN
    IF in_type = 'administrator' THEN
        CALL verifyprivilege(in_connId, 'ADDADMIN');
    ELSEIF in_type = 'teacher' THEN
        CALL verifyprivilege(in_connId, 'ADDATEACH');
    ELSEIF in_type = 'student' THEN
        CALL verifyprivilege(in_connId, 'ADDSTUDS');
    ELSEIF in_type = 'parent' THEN
        CALL verifyprivilege(in_connId, 'ADDPARENT');
    ELSE
        v_error := (SELECT fetchError(in_localee,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    CALL log_activity('users','add',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    IF in_username IN ('system', 'wheel', 'super', 'admin', 'root') THEN
        v_error := (SELECT fetchError(in_localee,'usrAddCtUseRsvVal4UsrNam')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF EXISTS (SELECT * FROM users WHERE username=in_username AND orgid=v_orgid) THEN
        v_error := (SELECT fetchError(in_localee,'usrCrtUnmExist')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    INSERT INTO users (orgid, username, surname, othernames, emailaddress, phonenumber, position, dob, gender, usertype, locale, onIdle) 
        VALUES (v_orgid, in_username, in_surname, in_othernames, in_emailaddr, in_phonenum, in_position, in_dob, in_gender, in_type, in_locale, in_onidle) RETURNING userid INTO v_uid;

    IF in_type = 'teacher' THEN
        v_role := (SELECT roleid FROM roles WHERE rname = 'teacher') ;
        INSERT INTO userroles (userid, roleid) VALUES (v_userid, v_role);
    END IF;

    v_users := (SELECT json_agg(t) FROM (SELECT u.userId, u.orgId, u.username, u.surname, u.othernames, u.emailaddress, u.phonenumber, u.position, u.dob, u.gender, u.locale, u.onIdle
        FROM users u
        WHERE u.orgid=v_orgid AND u.usertype=in_type AND is_system_user(u.username)=0 AND u.deleted=FALSE AND u.userid<>v_userid) AS t);

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_users,'}}');
    CALL log_activity('users','add',in_connid,CONCAT('Added. User Id:',v_uid),TRUE);

    RETURN au;

END; $$;

-- Modifies a user and returns all the users in this time
DROP FUNCTION IF EXISTS edituser;
CREATE OR REPLACE FUNCTION edituser (IN in_userid INTEGER, IN in_surname VARCHAR(64), 
                                    IN in_othernames VARCHAR(128), IN in_emailaddr VARCHAR(255), 
                                    IN in_phonenum VARCHAR(255), IN in_position VARCHAR(255),
                                    IN in_type VARCHAR(20), IN in_dob DATE, IN in_gender BOOLEAN,
                                    IN in_onidle VARCHAR(10), IN in_locale CHAR(5), IN in_connid VARCHAR(128),
                                    IN in_localee CHAR(2)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_users JSON;
    v_role INTEGER;
    v_uid INTEGER;
    au VARCHAR(9216);
BEGIN
    IF in_type = 'administrator' THEN
        CALL verifyprivilege(in_connId, 'ADDADMIN');
    ELSEIF in_type = 'teacher' THEN
        CALL verifyprivilege(in_connId, 'ADDATEACH');
    ELSEIF in_type = 'student' THEN
        CALL verifyprivilege(in_connId, 'ADDSTUDS');
    ELSEIF in_type = 'parent' THEN
        CALL verifyprivilege(in_connId, 'ADDPARENT');
    ELSE
        v_error := (SELECT fetchError(in_localee,'loginGoAway')) ;
		RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    CALL log_activity('users','edit',in_connid,CONCAT('_H:',in_connid),FALSE);

    v_userid := connid2userid(in_connid);
    v_orgid := userid2orgid(v_userid);

    UPDATE users SET surname=in_surname, othernames=in_othernames, 
        phonenumber=in_phonenum, position=in_position, dob=in_dob, 
        gender=in_gender, usertype=in_type, locale=in_locale, onidle=in_onidle WHERE userid=in_userid;

    v_users := (SELECT json_agg(t) FROM (SELECT u.userId, u.orgId, u.username, u.surname, u.othernames, u.emailaddress, u.phonenumber, u.position, u.dob, u.gender, u.locale, u.onIdle
        FROM users u
        WHERE u.orgid=v_orgid AND u.usertype=in_type AND is_system_user(u.username)=0 AND u.deleted=FALSE AND u.userid<>v_userid) AS t);

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_users,'}}');
    CALL log_activity('users','edit',in_connid,CONCAT('Updated. User Id:',in_userid),TRUE);

    RETURN au;

END; $$;

-- Fetches all user roles
DROP FUNCTION IF EXISTS getuserroles;
CREATE OR REPLACE FUNCTION getuserroles (IN in_userid INTEGER, IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('users','roles',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_roles := (SELECT json_agg(t) FROM (SELECT ur.roleid, r.orgid, r.rname, r.descript FROM userroles ur JOIN roles r ON ur.roleid=r.roleid AND ur.userid=in_userid) AS t);

    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('users','role',in_connid,CONCAT('Fetched. For user:',in_userid),TRUE);

    RETURN au;
END; $$;

-- Fetches all user roles
DROP FUNCTION IF EXISTS addroletouser;
CREATE OR REPLACE FUNCTION addroletouser (IN in_connid VARCHAR(128), IN in_userid INTEGER, IN in_roleid INTEGER, IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    v_wheel INTEGER;
    au VARCHAR(9216);
    v_error VARCHAR(255);
BEGIN
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_wheel := rolename2id('wheel', v_orgid);

    IF in_roleid = v_wheel AND is_db_admin() = FALSE THEN
        v_error := (SELECT fetchError(in_locale,'usrAddRoleGetRoot')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF is_deleted_user(in_userid) = TRUE THEN
        v_error := (SELECT fetchError(in_locale,'usrModNoSuchUsr')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    CALL log_activity('users','roles',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    INSERT INTO userroles (userid, roleid) VALUES (in_userid, in_roleid);

    v_roles := (SELECT json_agg(t) FROM (SELECT ur.roleid, r.orgid, r.rname, r.descript FROM userroles ur JOIN roles r ON ur.roleid=r.roleid AND ur.userid=in_userid) AS t);
    
    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('users','role',in_connid,CONCAT('Added role:', in_roleid, ' to user:',in_userid),TRUE);

    RETURN au;
END; $$;

-- Fetches all user roles
DROP FUNCTION IF EXISTS addrolestouser;
CREATE OR REPLACE FUNCTION addrolestouser (IN in_connid VARCHAR(128), IN in_userid INTEGER, IN in_roleids TEXT) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    v_wheel INTEGER;
    v VARCHAR(32);
    out_failed VARCHAR(255);
    au VARCHAR(9216);
BEGIN
    CALL log_activity('users','roles',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_wheel := rolename2id('wheel', v_orgid);

    CALL split(in_roleids);

    BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            IF v::INTEGER = v_wheel AND is_db_admin() = FALSE AND is_deleted_user(in_userid) = FALSE THEN
                out_failed := CONCAT(v,',',out_failed);
            ELSE
                INSERT INTO userroles (userid, roleid) VALUES (in_userid, v::INTEGER);
            END IF;
        END LOOP;
    END;

    v_roles := (SELECT json_agg(t) FROM (SELECT ur.roleid, r.orgid, r.rname, r.descript FROM userroles ur JOIN roles r ON ur.roleid=r.roleid AND ur.userid=in_userid) AS t);
    
    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('users','role',in_connid,CONCAT('Added roles:', in_roleids, ' to user:',in_userid),TRUE);

    RETURN au;
END; $$;

-- Fetches all user roles
DROP FUNCTION IF EXISTS removeuserrole;
CREATE OR REPLACE FUNCTION removeuserrole (IN in_connid VARCHAR(128), IN in_userid INTEGER, IN in_roleid INTEGER, IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    v_wheel INTEGER;
    au VARCHAR(9216);
    v_error VARCHAR(255);
BEGIN
    v_userid := connid2userid(in_connid);

    IF is_deleted_user(in_userid) = TRUE THEN
        v_error := (SELECT fetchError(in_locale,'usrModNoSuchUsr')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    v_orgid := roleid2orgid(in_roleid);

    CALL log_activity('users','roles',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    DELETE FROM userroles WHERE userid=in_userid AND roleid=in_roleid;

    v_roles := (SELECT json_agg(t) FROM (SELECT ur.roleid, r.orgid, r.rname, r.descript FROM userroles ur JOIN roles r ON ur.roleid=r.roleid AND ur.userid=in_userid) AS t);
    
    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('users','role',in_connid,CONCAT('Removed role:', in_roleid, ' from user:',in_userid),TRUE);

    RETURN au;
END; $$;

-- Fetches all user roles
DROP FUNCTION IF EXISTS removeuserroles;
CREATE OR REPLACE FUNCTION removeuserroles (IN in_connid VARCHAR(128), IN in_userid INTEGER, IN in_roleids TEXT, IN in_locale CHAR(5)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    v_wheel INTEGER;
    v VARCHAR(32);
    out_failed VARCHAR(255);
    au VARCHAR(9216);
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('users','roles',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_wheel := rolename2id('wheel', v_orgid);

    IF is_deleted_user(in_userid) = TRUE THEN
        v_error := (SELECT fetchError(in_locale,'usrModNoSuchUsr')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    CALL split(in_roleids);

    BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            DELETE FROM userroles WHERE userid=in_userid AND roleid=v::INTEGER;
        END LOOP;
    END;

    v_roles := (SELECT json_agg(t) FROM (SELECT ur.roleid, r.orgid, r.rname, r.descript FROM userroles ur JOIN roles r ON ur.roleid=r.roleid AND ur.userid=in_userid) AS t);
    
    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('users','role',in_connid,CONCAT('Removed roles:', in_roleids, ' from user:',in_userid),TRUE);

    RETURN au;
END; $$;

-- Fetches all user roles
DROP PROCEDURE IF EXISTS resetuserpassword;
CREATE OR REPLACE PROCEDURE resetuserpassword (IN in_connid VARCHAR(128), IN in_userid INTEGER, IN in_locale CHAR(5)) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
BEGIN
    CALL log_activity('users','pass',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ADDADMIN');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF is_deleted_user(in_userid) = TRUE THEN
        v_error := (SELECT fetchError(in_locale,'usrModNoSuchUsr')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    IF in_userid = v_userid THEN
        v_error := (SELECT fetchError(in_locale,'userRstOwnPas')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    INSERT INTO stalepasswds(userid) VALUES (in_userid);

    CALL log_activity('users','role',in_connid,CONCAT('Stalled the password for user:',in_userid),TRUE);

END; $$;