\c shopman_pos;

-- Fetches all user roles
DROP FUNCTION IF EXISTS getallroles;
CREATE OR REPLACE FUNCTION getallroles (IN in_connid VARCHAR(128)) RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','get',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_roles := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid) AS t);

    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('roles','get',in_connid,CONCAT('Fetched. For org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Create new role
DROP FUNCTION IF EXISTS createrole;
CREATE OR REPLACE FUNCTION createrole (IN in_connid VARCHAR(128), 
                                        IN in_name VARCHAR(64), IN in_desc VARCHAR(255)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    o_roleid INTEGER;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','add',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    INSERT INTO roles (orgid, rname, descript) VALUES (v_orgid, in_name, in_desc) RETURNING roleid INTO o_roleid;

    v_roles := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid) AS t);

    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('roles','add',in_connid,CONCAT('Created. rid:',o_roleid),TRUE);

    RETURN au;
END; $$;

-- Modify role
DROP FUNCTION IF EXISTS updaterole;
CREATE OR REPLACE FUNCTION updaterole (IN in_connid VARCHAR(128), IN in_roleid INTEGER,
                                        IN in_name VARCHAR(64), IN in_desc VARCHAR(255)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_roles JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','update',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    UPDATE roles SET rname = in_name, descript = in_desc WHERE roleid = in_roleid AND orgid = v_orgid;

    v_roles := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid) AS t);

    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('roles','update',in_connid,CONCAT('Updated. rid:',in_roleid,' for org:', v_orgid),TRUE);

    RETURN au;
END; $$;

-- Remove role
DROP FUNCTION IF EXISTS removerole;
CREATE OR REPLACE FUNCTION removerole (IN in_connid VARCHAR(128), IN in_roleid INTEGER) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_locale CHAR(5);
    v_error VARCHAR(255);
    v_roles JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','remove',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);
    v_locale := (SELECT locale FROM users WHERE userid = v_userid);

    IF roleid2name(in_roleid) IN ('wheel','system', 'supervisor', 'administrator', 'reports','teacher','classmaster','student','parent') THEN
        v_error := (SELECT fetchError(v_locale,'roleRemoveSystem')) ;
        RAISE EXCEPTION '%', v_error USING HINT = v_error;
    END IF;

    DELETE FROM roles WHERE roleid = in_roleid AND orgid = v_orgid;

    v_roles := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid) AS t);

    IF v_roles IS NULL THEN
        v_roles := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_roles,'}}');

    CALL log_activity('roles','remove',in_connid,CONCAT('Deleted. rid:',in_roleid,' for org:', v_orgid),TRUE);

    RETURN au;
END; $$;

-- Get role perms
DROP FUNCTION IF EXISTS getrolepermissions;
CREATE OR REPLACE FUNCTION getrolepermissions (IN in_connid VARCHAR(128), IN in_roleid INTEGER) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','roleperms',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_perms := (SELECT json_agg(t) FROM (SELECT p.roleid, p.mode, r.rname, pt.descript FROM permissions p JOIN permissiontypes pt ON p.mode=pt.mode JOIN roles r ON p.roleid=r.roleid WHERE p.roleid=in_roleid ORDER BY pt.mode) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('roles','roleperms',in_connid,CONCAT('Viewed for role:',in_roleid,' for org:', v_orgid),TRUE);

    RETURN au;
END; $$;

-- Fetch all privileges
DROP FUNCTION IF EXISTS getpermissiontypes;
CREATE OR REPLACE FUNCTION getpermissiontypes (IN in_connid VARCHAR(128)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('privileges','get',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_perms := (SELECT json_agg(t) FROM (SELECT mode, descript FROM permissiontypes WHERE mode NOT IN (SELECT ptype FROM permissiontypesx) ORDER BY mode) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('privilege','get',in_connid,CONCAT('Viewed all perm types'),TRUE);

    RETURN au;
END; $$;

-- Add priv from role
DROP FUNCTION IF EXISTS addprivilegetorole;
CREATE OR REPLACE FUNCTION addprivilegetorole (IN in_connid VARCHAR(128), IN in_roleid INTEGER, IN in_mode VARCHAR(32)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','addprivtorole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF (in_mode = 'ROLE' AND wheel(v_userid, '', FALSE)=FALSE) OR (in_Mode = 'ROLE' AND is_db_Admin()=FALSE) THEN
		RAISE EXCEPTION 'Permission denied.' USING HINT = 'Permission denied. ROLE is super privilege.';
	END IF;

    CALL verifyprivilege(in_connId, 'ROLE');

    INSERT INTO permissions(mode,roleid) VALUES(in_mode,in_roleid);

    v_perms := (SELECT json_agg(t) FROM (SELECT p.roleid, p.mode, r.rname, pt.descript FROM permissions p JOIN permissiontypes pt ON p.mode=pt.mode JOIN roles r ON p.roleid=r.roleid WHERE p.roleid=in_roleid ORDER BY pt.mode) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('roles','addprivtorole',in_connid,CONCAT('Added mode:',in_mode,' to role:', in_roleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Add privs from role
DROP FUNCTION IF EXISTS addprivilegestorole;
CREATE OR REPLACE FUNCTION addprivilegestorole (IN in_connid VARCHAR(128), IN in_roleid INTEGER, IN in_modes TEXT) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
    v VARCHAR(32);
    out_failed VARCHAR(255);
BEGIN
    CALL log_activity('roles','addprivtorole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    CALL split(in_modes);

    BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            IF (v = 'ROLE' AND wheel(v_userid, '', FALSE)=FALSE) OR (v = 'ROLE' AND is_db_Admin()=FALSE) THEN
                out_failed := CONCAT(v,',',out_failed);
            ELSE
                INSERT INTO permissions(mode,roleid) VALUES(v,in_roleid);
            END IF;
        END LOOP;
    END;
    
    v_perms := (SELECT json_agg(t) FROM (SELECT p.roleid, p.mode, r.rname, pt.descript FROM permissions p JOIN permissiontypes pt ON p.mode=pt.mode JOIN roles r ON p.roleid=r.roleid WHERE p.roleid=in_roleid ORDER BY pt.mode) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,',"failed":["',out_failed,'"]}}');

    CALL log_activity('roles','addprivtorole',in_connid,CONCAT('Added privs:',in_modes,' to role:', in_roleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Remove priv from role
DROP FUNCTION IF EXISTS removeprivilegefromrole;
CREATE OR REPLACE FUNCTION removeprivilegefromrole (IN in_connid VARCHAR(128), IN in_roleid INTEGER, IN in_mode VARCHAR(32)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','rmprivfrmrole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    IF (in_mode = 'ROLE' AND wheel(v_userid, '', FALSE)=FALSE) OR (in_Mode = 'ROLE' AND is_db_Admin()=FALSE) THEN
		RAISE EXCEPTION 'Permission denied.' USING HINT = 'Permission denied. ROLE is super privilege.';
	END IF;

    CALL verifyprivilege(in_connId, 'ROLE');

    DELETE FROM permissions WHERE mode = in_mode AND roleid = in_roleid;

    v_perms := (SELECT json_agg(t) FROM (SELECT p.roleid, p.mode, r.rname, pt.descript FROM permissions p JOIN permissiontypes pt ON p.mode=pt.mode JOIN roles r ON p.roleid=r.roleid WHERE p.roleid=in_roleid ORDER BY pt.mode) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('roles','rmprivfrmrole',in_connid,CONCAT('Removed mode:',in_mode,' from role:', in_roleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Add privs from role
DROP FUNCTION IF EXISTS removeprivilegesfromrole;
CREATE OR REPLACE FUNCTION removeprivilegesfromrole (IN in_connid VARCHAR(128), IN in_roleid INTEGER, IN in_modes TEXT) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
    v VARCHAR(32);
    out_failed VARCHAR(255);
BEGIN
    CALL log_activity('roles','rmprivfrmrole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    CALL split(in_modes);

     BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            IF (v = 'ROLE' AND wheel(v_userid, '', FALSE)=FALSE) OR (v = 'ROLE' AND is_db_Admin()=FALSE) THEN
                out_failed := CONCAT(v,',',out_failed);
            ELSE
                DELETE FROM permissions WHERE mode = v AND roleid = in_roleid;
            END IF;
        END LOOP;
    END;
    
    v_perms := (SELECT json_agg(t) FROM (SELECT p.roleid, p.mode, r.rname, pt.descript FROM permissions p JOIN permissiontypes pt ON p.mode=pt.mode JOIN roles r ON p.roleid=r.roleid WHERE p.roleid=in_roleid ORDER BY pt.mode) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,',"failed":["',out_failed,'"]}}');

    CALL log_activity('roles','rmprivfrmrole',in_connid,CONCAT('Remove privs:',in_modes,' from role:', in_roleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Get role perms
DROP FUNCTION IF EXISTS getrolesubroles;
CREATE OR REPLACE FUNCTION getrolesubroles (IN in_connid VARCHAR(128), IN in_roleid INTEGER) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
BEGIN
    CALL log_activity('roles','subrole',in_connid,CONCAT('_H:',in_connid),FALSE);
    CALL verifyprivilege(in_connId, 'ROLE');

    v_userid := connid2userid(in_connid);
	v_orgid := userid2orgid(v_userid);

    v_perms := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid AND roleid IN (SELECT roleid FROM rolepermissions WHERE ownerroleid = in_roleid) ORDER BY rname) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('roles','subrole',in_connid,CONCAT('Viewed for role:',in_roleid,' for org:', v_orgid),TRUE);

    RETURN au;
END; $$;

-- Add role from role owener=dest target=src
DROP FUNCTION IF EXISTS addroletorole;
CREATE OR REPLACE FUNCTION addroletorole (IN in_connid VARCHAR(128), IN in_ownerroleid INTEGER, IN in_targetroleid INTEGER, IN in_locale CHAR (5)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
    v_wheel INTEGER;
BEGIN
    CALL log_activity('roles','addroletorole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
	v_orgid := roleid2orgid(in_ownerroleid);

    v_wheel = rolename2id('wheel', v_orgid);

    IF ((in_targetroleid = v_wheel OR in_ownerroleid = v_wheel) AND wheel(v_userid, '', FALSE) = FALSE) OR 
        ((in_targetroleid = v_wheel OR in_ownerroleid = v_wheel) AND is_db_admin() = FALSE) THEN
        RAISE EXCEPTION 'Permission denied. Cannot add this role.' USING HINT = 'Permission denied. Cannot add this role.';
    END IF;

    CALL verifyprivilege(in_connId, 'ROLE');

    INSERT INTO rolepermissions (ownerroleid, roleid) VALUES (in_ownerroleid, in_targetroleid);
    
    v_perms := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid AND roleid IN (SELECT roleid FROM rolepermissions WHERE ownerroleid = in_ownerroleid) ORDER BY rname) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('roles','addroletorole',in_connid,CONCAT('Added role:',in_targetroleid,' to role:', in_ownerroleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Add roles ro role
DROP FUNCTION IF EXISTS addrolestorole;
CREATE OR REPLACE FUNCTION addrolestorole (IN in_connid VARCHAR(128), IN in_ownerroleid INTEGER, IN in_targetroleids TEXT, IN in_locale CHAR (5)) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
    v VARCHAR(32);
    v_targetroleid INTEGER;
    out_failed VARCHAR(255);
    v_wheel INTEGER;
BEGIN
    CALL log_activity('roles','addroletorole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
    v_orgid := roleid2orgid(in_ownerroleid);

    v_wheel = rolename2id('wheel', v_orgid);

    CALL split(in_targetroleids);

    BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            IF ((v::INTEGER = v_wheel OR in_ownerroleid = v_wheel) AND wheel(v_userid, '', FALSE) = FALSE) OR 
                ((v::INTEGER = v_wheel OR in_ownerroleid = v_wheel) AND is_db_admin() = FALSE) THEN
                out_failed := CONCAT(v,',',out_failed);
            ELSE
                INSERT INTO rolepermissions (ownerroleid, roleid) VALUES (in_ownerroleid, v::INTEGER);
            END IF;
        END LOOP;
    END;
    
    v_perms := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid AND roleid IN (SELECT roleid FROM rolepermissions WHERE ownerroleid = in_ownerroleid) ORDER BY rname) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,',"failed":["',out_failed,'"]}}');

    CALL log_activity('roles','addroletorole',in_connid,CONCAT('Added roles:',in_targetroleids,' to role:', in_ownerroleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Remove role from role owener=dest target=src
DROP FUNCTION IF EXISTS removerolefromrole;
CREATE OR REPLACE FUNCTION removerolefromrole (IN in_connid VARCHAR(128), IN in_ownerroleid INTEGER, IN in_targetroleid INTEGER) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
    v_wheel INTEGER;
BEGIN
    CALL log_activity('roles','removerolefromrole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
	v_orgid := roleid2orgid(in_ownerroleid);

    CALL verifyprivilege(in_connId, 'ROLE');

    DELETE FROM rolepermissions WHERE ownerroleid = in_ownerroleid AND roleid = in_targetroleid ;
    
    v_perms := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid AND roleid IN (SELECT roleid FROM rolepermissions WHERE ownerroleid = in_ownerroleid) ORDER BY rname) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,'}}');

    CALL log_activity('roles','removerolefromrole',in_connid,CONCAT('Removed role:',in_targetroleid,' from role:', in_ownerroleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;

-- Add roles ro role
DROP FUNCTION IF EXISTS removerolesfromrole;
CREATE OR REPLACE FUNCTION removerolesfromrole (IN in_connid VARCHAR(128), IN in_ownerroleid INTEGER, IN in_targetroleids TEXT) 
                                        RETURNS VARCHAR(9216) LANGUAGE plpgsql
AS $$
DECLARE
    v_userid INTEGER;
    v_orgid INTEGER;
    v_error VARCHAR(255);
    v_perms JSON;
    au VARCHAR(9216);
    v VARCHAR(32);
    v_targetroleid INTEGER;
    out_failed VARCHAR(255);
    v_wheel INTEGER;
BEGIN
    CALL log_activity('roles','removerolesfromrole',in_connid,CONCAT('_H:',in_connid),FALSE);
    v_userid := connid2userid(in_connid);
    v_orgid := roleid2orgid(in_ownerroleid);

    CALL split(in_targetroleids);

     BEGIN
        FOR v IN SELECT column_values FROM the_split_tbl
        LOOP
            DELETE FROM rolepermissions WHERE ownerroleid = in_ownerroleid AND roleid = v::INTEGER ;
        END LOOP;
    END;
    
    v_perms := (SELECT json_agg(t) FROM (SELECT roleid, orgid, rname, descript FROM roles WHERE orgid = v_orgid AND roleid IN (SELECT roleid FROM rolepermissions WHERE ownerroleid = in_ownerroleid) ORDER BY rname) AS t);

    IF v_perms IS NULL THEN
        v_perms := '[]';
    END IF;

    au := CONCAT('{"error":false,"result":{"status":200,"value":',v_perms,',"failed":["',out_failed,'"]}}');

    CALL log_activity('roles','removerolesfromrole',in_connid,CONCAT('Removed roles:',in_targetroleids,' from role:', in_ownerroleid,'for org:',v_orgid),TRUE);

    RETURN au;
END; $$;