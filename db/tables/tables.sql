-- Database: shopman_pos
-- Author: Femencha Azombo Fabrice
-- Purpose: Simple DB for Job Application phase
DROP DATABASE IF EXISTS shopman_pos;
CREATE DATABASE shopman_pos WITH ENCODING = 'UTF-8';

\c shopman_pos;
SET client_encoding = WIN1252;
CREATE EXTENSION pgcrypto;

/*This table will contain the various idle options we have*/
DROP TABLE IF EXISTS onIdleTypes;

CREATE TABLE onidletypes (
	onidle VARCHAR(10) NOT NULL,
	onidletimeOut INTEGER NOT NULL,
	PRIMARY KEY (onidle)
);

/*Default data for idle types*/
INSERT INTO onidletypes VALUES ('lockScreen' , '300'),('logOut' , '300');

/*This table will contain the various locales we have in our system*/
DROP TABLE IF EXISTS locales;
CREATE TABLE locales (
	code CHAR(5) NOT NULL,
	descript VARCHAR(255) NOT NULL,
	PRIMARY KEY (code)
);

/*Default data for locales*/
INSERT INTO locales VALUES ('en_US' , 'United states english'),('fr_FR' , 'France french');

/*This table will containe the various machine id types that exist*/
DROP TABLE IF EXISTS machineidtypes;

CREATE TABLE machineidtypes (
	code VARCHAR(5) NOT NULL,
	descript VARCHAR(255) NULL DEFAULT NULL,
	PRIMARY KEY (code)
) ;

/*Default data for machineIdTypes*/
INSERT INTO machineidtypes VALUES ('cpu','CPU serial number'),('hdd','Hard disk serial number'),('host','hostname'),('mac','mac address');

/*This table will contain information about an organisation*/
DROP TABLE IF EXISTS organisations;

CREATE TABLE organisations (
	orgid SERIAL PRIMARY KEY,
	code SMALLINT NOT NULL,
	alias VARCHAR(15) NOT NULL,
	orgname VARCHAR(255) NOT NULL,
	logo BYTEA NULL DEFAULT NULL,
	expirydate TIMESTAMP NOT NULL,
	createdby INTEGER NULL DEFAULT NULL,
	createdat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
	-- FOREIGN KEY (createdBy) REFERENCES users (userId) ON DELETE NO ACTION
);

ALTER SEQUENCE organisations_orgid_seq RESTART WITH 8;

/*Default organization*/
INSERT INTO organisations (orgid,code, alias, orgname, expirydate) VALUES (1,10100,'G.B.H.S Deido','Government Bilingual High School Deido Douala','2023-01-01 00:00:00');

/*This table will contain information about the various types of users we have in our system*/
DROP TABLE IF EXISTS usertypes;

CREATE TABLE usertypes (
	utype VARCHAR(20) PRIMARY KEY,
	descript VARCHAR(255) NULL DEFAULT NULL
) ;

/*Default data for usertypes*/
INSERT INTO usertypes (utype, descript) VALUES ('administrator','A school administrator'),('teacher','A school teacher'),
                            ('hybrid1','A user who is an administrator and also a teacher'),('hybrid2','A user who is a teacher and also a parent'),
                            ('hybrid3','A user who is an administrator and also a parent'),('hybrid4','A user who is an administrator, a teacher and also a parent'),
                            ('parent','A student''s parent'),('system','A system user'),('student','A student');

/* This table will contain information about a user at the POS*/
DROP TABLE IF EXISTS users;

-- Will contain data for the school administrators, teachers and parents
CREATE TABLE users (
	userid SERIAL PRIMARY KEY,
	orgid INTEGER NOT NULL,
	username VARCHAR(64) NOT NULL,
	pwd VARCHAR(255) NULL DEFAULT NULL,
	surname VARCHAR(128) NOT NULL,
	othernames VARCHAR(128) NULL DEFAULT NULL,
	emailaddress VARCHAR(255) NULL DEFAULT NULL,
	phonenumber VARCHAR(255) NULL DEFAULT NULL,
	position VARCHAR(255) NULL DEFAULT NULL,
	usertype VARCHAR(20) NOT NULL,
	dob DATE NULL DEFAULT NULL,
	gender BOOLEAN NULL DEFAULT NULL,
	onidle VARCHAR(10) NULL DEFAULT NULL,
	locale CHAR(5) NULL DEFAULT NULL,
	deleted BOOLEAN NOT NULL DEFAULT FALSE,
	UNIQUE (orgid, username),
	UNIQUE (orgid, emailaddress), 
	UNIQUE (orgid, phonenumber),
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION,
	FOREIGN KEY (onidle) REFERENCES onidletypes (onidle) ON DELETE NO ACTION,
	FOREIGN KEY (locale) REFERENCES locales (code) ON DELETE NO ACTION,
	FOREIGN KEY (usertype) REFERENCES usertypes (utype) ON DELETE NO ACTION
);

ALTER SEQUENCE users_userid_seq RESTART WITH 8;

/*Default data for users*/
INSERT INTO users (userid,orgid,username,pwd,surname,othernames,emailaddress,phonenumber,position,usertype,dob,gender,onidle,locale,deleted) 
    VALUES (1,1,'wheel',CRYPT('wheel',gen_salt('bf')),'Big Wheel',NULL,NULL,NULL,NULL,'system',NULL,NULL,NULL,NULL,FALSE),
    (2,1,'system',CRYPT('system',gen_salt('bf')),'system','Internal rule keeper',NULL,NULL,NULL,'system',NULL,NULL,NULL,NULL,FALSE),
    (3,1,'super',CRYPT('super',gen_salt('bf')),'Super','Authorizor',NULL, NULL,NULL,'system',NULL,NULL,NULL,NULL,FALSE),
    (4,1,'dev01',CRYPT('dev01',gen_salt('bf')),'Developer','Eins','dev@mail.com',NULL,NULL,'administrator',NULL,NULL,NULL,NULL,FALSE),
    (5,1,'dev02',CRYPT('dev02',gen_salt('bf')),'Developer','Zwei','nobody@mail.com',NULL,NULL,'administrator',NULL,NULL,NULL,NULL,FALSE);

/*This table will contain information about a user's login information*/
DROP TABLE IF EXISTS userlogins;

CREATE TABLE userlogins (
	connectionid VARCHAR(128) PRIMARY KEY,
	userid INTEGER NOT NULL,
	remotehost VARCHAR(255) NOT NULL,
	machineid VARCHAR(255) NOT NULL,
	machineidtype VARCHAR(5) NOT NULL,
	logintime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	logouttime TIMESTAMP NULL DEFAULT NULL,
	CLIENT_WRKST VARCHAR(255) NOT NULL,
	FOREIGN KEY (machineidtype) REFERENCES machineidtypes (code) ON DELETE NO ACTION,
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION
);

/*This table will contain stale passwords*/
DROP TABLE IF EXISTS stalepasswds;

CREATE TABLE stalepasswds (
	userid INTEGER NOT NULL,
	createdat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	code VARCHAR(6) NULL DEFAULT NULL,
	PRIMARY KEY (userid),
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION
);

/*This table will contain information about a role*/
DROP TABLE IF EXISTS roles ;

CREATE TABLE roles (
	roleid SERIAL PRIMARY KEY,
	orgid INTEGER NOT NULL,
	rname VARCHAR(64) NOT NULL,
	descript VARCHAR(255) NOT NULL,
	UNIQUE (rname, orgid),
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE CASCADE
);

ALTER SEQUENCE roles_roleid_seq RESTART WITH 8;

/*Default data for roles*/
INSERT INTO roles (roleid,orgid,rname,descript) VALUES (1,1,'wheel','Administrative tasks'),
        (2,1,'system','system rule keeper'),(3,1,'supervisor','Authorize exceptions'),
        (4,1,'administrator','The system administrator. He/She manages the system on behalf of the institution'),
        (5,1,'reports','Generate reports of all types'),(6,1,'teacher','A school teacher.'),
        (7,1,'classmaster','Teacher who can perform very special operations.'),(8,1,'student','Set of activities a student can perform'),
        (9,1,'parent','Set of activities a parent can perform');

/*This table will contain information about a permission types*/
DROP TABLE IF EXISTS permissiontypes;

CREATE TABLE permissiontypes (
	mode VARCHAR(32) PRIMARY KEY,
	descript VARCHAR(255) NOT NULL
);

/*Default data for permitionTypes*/
INSERT INTO permissiontypes VALUES 
    ('MONITOR','Monitor events'), ('SYS','System rule keeper'), 
    ('AUTHORIZER','Can perform exceptional operations'), ('ROLE','Manage priviledge related data'), 
    ('VIEWADMIN','Can view school administrators'), ('ADDADMIN','Can add and modify a school administrator'), 
    ('DELADMIN','Can delete a school administrator'), ('VIEWTEACH','Can view teachers'), 
    ('ADDTEACH','Can add and modify a teacher'), ('DELTEACH','Can delete a teacher'),
    ('VIEWPARENT','Can view parents'),('ADDPARENT','Can add a parent'),('DELPARENT','Can delete a parent'), 
    ('VIEWSTUDS','Can view students'), ('ADDSTUDS','Can admit a new student'), 
    ('MODISTUDS','Can modify a student''s basic records'), ('DELSTUDS','Can delete a student'), 
    ('CHGSTUDSTAT','Can change a student''s status'),('CHGSTUDCLASS','Can change a student''s class'), 
    ('VIEWCLASS','Can view classrooms'), ('ADDCLASS','Can create and modify a classroom'), 
    ('DELCLASS','Can delete a classroom'), ('VIEWSUBJ','Can view subjects'), 
    ('ADDSUBJ','Can add and modify a subject'), ('DELSUBJ','Can delete a subject'), 
    ('VIEWFEES','Can view fees'), ('ADDFEES','Can add and modify fees'), 
    ('VIEWREQUEST','Can view requests for date extension'),
    ('ADDREQUEST','Can create requests for date extension for sequence marks entry'), 
    ('ABSENSE','Can manage student absenses'), ('CLASSMASTER','A class master'), 
    ('VIEWCALEN','Can view evnts and timelines'),('ADDCALEN','Can create and modify an event'),
    ('VIEWEXAM','Can view examinations'),('ADDEXAM','Can create an examination'),
    ('BEGINEXAM','Begin examination entry'),('ADDEXAMMARKS','Submit examination marks'),    
    ('IDCARD','Can generate id cards');  	

/*This table will contain information about a permission types that are system reserved*/
DROP TABLE IF EXISTS permissiontypesx;

CREATE TABLE permissiontypesx (
	ptype VARCHAR(32) PRIMARY KEY,
	FOREIGN KEY (ptype) REFERENCES permissionTypes (mode) ON DELETE NO ACTION
);

/*Default data for permitionTypes*/
INSERT INTO permissiontypesx VALUES ('MONITOR'),('SYS');

/*The is table will contain information about a permission. A role can have permissions*/
DROP TABLE IF EXISTS permissions;

CREATE TABLE permissions (
	mode VARCHAR(32) NOT NULL,
	roleid INTEGER NOT NULL,
	PRIMARY KEY (roleid,mode),
	FOREIGN KEY (mode) REFERENCES permissiontypes (mode) ON DELETE NO ACTION,
	FOREIGN KEY (roleid) REFERENCES roles (roleid) ON DELETE CASCADE
) ;

/*Default data for permissions*/
INSERT INTO permissions VALUES ('AUTHORIZER',3),('ADDADMIN',4),('ADDCALEN',4),
    ('ADDCLASS',4),('ADDEXAM',4),('ADDPARENT',4),('ADDSUBJ',4),('ADDTEACH',4),
    ('AUTHORIZER',4),('DELADMIN',4),('DELCLASS',4),('DELSUBJ',4),
    ('DELTEACH',4),('IDCARD',4),('MODISTUDS',4),('ROLE',4),('VIEWADMIN',4),
    ('VIEWCALEN',4),('VIEWCLASS',4),('VIEWEXAM',4),('VIEWFEES',4),
    ('VIEWPARENT',4),('VIEWREQUEST',4),('VIEWSTUDS',4),('VIEWSUBJ',4),
    ('VIEWTEACH',4),('ADDEXAMMARKS',6),('ADDREQUEST',6),('BEGINEXAM',6),
    ('VIEWCLASS',6),('VIEWEXAM',6),('VIEWTEACH',6),('CHGSTUDCLASS',7),
    ('CHGSTUDSTAT',7),('CLASSMASTER',7),('VIEWSTUDS',7),('ADDFEES',8),
    ('ADDSTUDS',8),('CHGSTUDCLASS',8),('DELSTUDS',8),('MODISTUDS',8),
    ('VIEWCLASS',8),('VIEWFEES',8),('VIEWPARENT',8),('VIEWSTUDS',8),
    ('VIEWPARENT',9),('VIEWSTUDS',9),('VIEWFEES',9);

/*This table will contain information about a role's permission. A role can have a role*/
DROP TABLE IF EXISTS rolepermissions;

CREATE TABLE rolepermissions (
	ownerroleid INTEGER NOT NULL, -- The Role we are adding to
	roleid INTEGER NOT NULL, -- The subrole to be added to the owner role
	PRIMARY KEY (ownerroleid, roleid),
	FOREIGN KEY (ownerroleid) REFERENCES roles (roleid) ON DELETE CASCADE,
	FOREIGN KEY (roleid) REFERENCES roles (roleid) ON DELETE CASCADE
);

/*This table will contain information about a user's roles and permissions. A user can have roles*/
DROP TABLE IF EXISTS userroles;

CREATE TABLE userroles (
	userid INTEGER NOT NULL,
	roleid INTEGER NOT NULL,
	PRIMARY KEY (userid, roleid),
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (roleid) REFERENCES roles (roleid) ON DELETE CASCADE
);

/*Default data for user roles*/
INSERT INTO userroles VALUES (1,1),(4,4),(3,3);

/*This table will contain information about a user's priviledge. A user can have priviledges or permissions*/
DROP TABLE IF EXISTS userprivs;

CREATE TABLE userprivs (
	userid INTEGER NOT NULL,
	priv VARCHAR(32) NOT NULL,
	PRIMARY KEY (userid, priv),
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (priv) REFERENCES permissionTypes (mode) ON DELETE NO ACTION
);

/*Default data for user priviledges*/
INSERT INTO userprivs VALUES (4,'ROLE'),(5,'ROLE');

/*This table will contain information about user logs*/
DROP TABLE IF EXISTS auditlogs;

CREATE TABLE auditlogs (
	topic VARCHAR(32) NOT NULL,
	aktion VARCHAR(32) NOT NULL,
	connectionid VARCHAR(128) NOT NULL,
	orgid INTEGER NULL DEFAULT NULL,
	details VARCHAR(1024) NOT NULL,
	final BOOLEAN NOT NULL DEFAULT FALSE,
	thetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

/*This table will contain some basic variables in our system*/
DROP TABLE IF EXISTS variables;

CREATE TABLE variables (
	vname VARCHAR(64) PRIMARY KEY,
	vvalue VARCHAR(512) NULL DEFAULT NULL
);

/*Default variables*/
INSERT INTO variables VALUES ('appprompt','??'),('logdir','logdir'),
    ('logfile','audit.log'),('logfilehandle',NULL),('NULLstr','!null!'),
    ('varIsDba','N'),('varRunAI_occupation_cat','Y');

-- This table will contain information about a class
DROP TABLE IF EXISTS classrooms;

CREATE TABLE classrooms (
	classid SERIAL PRIMARY KEY,
	cname VARCHAR(255) NOT NULL,
	abbreviation VARCHAR(10) NULL DEFAULT NULL,
	descript VARCHAR(255) NULL DEFAULT NULL,
	deleted BOOLEAN NOT NULL DEFAULT FALSE,
	classhead INTEGER NULL DEFAULT NULL,
	classmaster INTEGER NULL DEFAULT NULL,
	letter CHAR(1) NOT NULL, -- Used for generating matricules
	orgid INTEGER NOT NULL,
	UNIQUE (orgid,cname),
	UNIQUE (orgid, letter),
	FOREIGN KEY (classhead) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (classmaster) REFERENCES users(userid) ON DELETE NO ACTION
);

ALTER SEQUENCE classrooms_classid_seq RESTART WITH 8;

--This table will contain information about a student's various statuses
DROP TABLE IF EXISTS studentstatuses;

CREATE TABLE studentstatuses (
	sstatus VARCHAR(20) PRIMARY KEY,
	descript VARCHAR(255) NULL DEFAULT NULL
);

-- Default data for studentstatuses
INSERT INTO studentstatuses VALUES ('good','Good Standing'),('warning','Warning'),
    ('swarning','Serious Warning'),('suspended','Suspended'),
    ('dismissed','Dismissed'),('graduate','Graduated') ;

-- Contain info about students
DROP TABLE IF EXISTS students;

CREATE TABLE students (
	userid INTEGER NOT NULL,
	matricule CHAR(10) PRIMARY KEY,
	doe DATE NOT NULL DEFAULT CURRENT_DATE,
	pob VARCHAR(20) NOT NULL,
	classid INTEGER NOT NULL,
	parents INTEGER ARRAY[2] DEFAULT '{}',
	picture VARCHAR(20) NULL DEFAULT NULL,
	sstatus VARCHAR(20) NOT NULL DEFAULT 'good',
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (classid) REFERENCES classrooms (classid) ON DELETE NO ACTION,
	FOREIGN KEY (sstatus) REFERENCES studentstatuses (sstatus) ON DELETE NO ACTION
);

-- Contain data about an academicyear
DROP TABLE IF EXISTS academicyear;

CREATE TABLE academicyear (
	yearid SERIAL PRIMARY KEY,
	startdate DATE NOT NULL,
	enddate DATE NOT NULL,
	descript VARCHAR(255) NULL DEFAULT NULL,
	orgid INTEGER NOT NULL,
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION
);

ALTER SEQUENCE academicyear_yearid_seq RESTART WITH 8;

-- Data about student repeat status
DROP TABLE IF EXISTS repeats;

CREATE TABLE repeats (
	userid INTEGER NOT NULL,
	yearid INTEGER NOT NULL,
	classroomid INTEGER NOT NULL,
    UNIQUE (userid, yearid),
	FOREIGN KEY (userid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION,
	FOREIGN KEY (classroomid) REFERENCES classrooms(classid) ON DELETE NO ACTION
);

-- This table will contain information about a subject
DROP TABLE IF EXISTS subjects;

CREATE TABLE subjects (
	subjectid  SERIAL PRIMARY KEY,
	code INTEGER NOT NULL,
	sname VARCHAR(255) NOT NULL,
	descript VARCHAR(255) NULL DEFAULT NULL,
	coefficient INTEGER NOT NULL,
	deleted BOOLEAN NOT NULL DEFAULT FALSE,
	orgid INTEGER NOT NULL,
	UNIQUE (orgid,code),
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION
);

-- This table will contain information groups
-- A group will contain classes of the same level, such as Form one A, Form one B...all under Form One
DROP TABLE IF EXISTS groups;

CREATE TABLE groups (
	groupid SERIAL PRIMARY KEY,
	orgid INTEGER NOT NULL,
	gname VARCHAR(64) NOT NULL,
	descript VARCHAR(255) NOT NULL,
	academicyearid INTEGER NOT NULL,
	UNIQUE (orgid,gname,academicyearid),
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION,
	FOREIGN KEY (academicyearid) REFERENCES academicyear (yearid) ON DELETE NO ACTION
);

ALTER SEQUENCE groups_groupid_seq RESTART WITH 8;

-- This table will contain information about class groupings
DROP TABLE IF EXISTS groupings;

CREATE TABLE groupings (
	subjectid INTEGER NOT NULL,
	groupid INTEGER NOT NULL,
	UNIQUE (subjectid), -- We cannot have a subject in the group table twice. i.e 2 groups
	FOREIGN KEY (subjectid) REFERENCES subjects (subjectid) ON DELETE NO ACTION,
	FOREIGN KEY (groupid) REFERENCES groups (groupid) ON DELETE CASCADE
);

-- This table will contain information about class students
DROP TABLE IF EXISTS classstudents;

CREATE TABLE classstudents (
	userid INTEGER NOT NULL,
	classid INTEGER NOT NULL,
	yearid INTEGER NOT NULL,
	PRIMARY KEY (userid, classid, yearid),
	FOREIGN KEY (userid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (classid) REFERENCES classrooms(classid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION
);

DROP TABLE IF EXISTS classsubjects;

CREATE TABLE classsubjects (
	userid INTEGER NOT NULL,
	classid INTEGER NOT NULL,
	subjectid INTEGER NOT NULL,
	yearid INTEGER NOT NULL,
	PRIMARY KEY (userid, classid, subjectid, yearId),
	FOREIGN KEY (userid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (classid) REFERENCES classrooms(classid) ON DELETE NO ACTION,
	FOREIGN KEY (subjectid) REFERENCES subjects (subjectid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicYear(yearid) ON DELETE NO ACTION
);

-- Fee types
DROP TABLE IF EXISTS feetypes ;

CREATE TABLE feetypes (
	ftype VARCHAR(20) PRIMARY KEY,
	descript VARCHAR(255) NULL DEFAULT NULL,
	orgid INTEGER NOT NULL,
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION
);

-- Default data for fee types
INSERT INTO feetypes VALUES ('regist','Registration',1),('firstint','First installment',1),
	('secint','Second installment',1),('thirdint','Third installment',1),
	('pta','Parents Teachers Association (PTA)',1);

DROP TABLE IF EXISTS paymethods;

CREATE TABLE paymethods (
	method VARCHAR(10) PRIMARY KEY,
	descript VARCHAR(255) NULL DEFAULT NULL
);

-- Default data for payment methods
INSERT INTO payMethods VALUES ('cash','Cash'),('cheque','Cheque'),
	('visa','Visa Card'),('mobile','Mobile Money');

DROP TABLE IF EXISTS fees;

CREATE TABLE fees (
	feeid SERIAL PRIMARY KEY,
	userid INTEGER NOT NULL,
	ftype VARCHAR(20) NOT NULL,
	yearid INTEGER NOT NULL,
	amount NUMERIC NOT NULL,
	paidon DATE NOT NULL DEFAULT CURRENT_DATE,
	paidby VARCHAR(10) NOT NULL DEFAULT 'cash',
	reference VARCHAR(20) NOT NULL,
	FOREIGN KEY (userid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION,
	FOREIGN KEY (ftype) REFERENCES feetypes(ftype) ON DELETE NO ACTION,
	FOREIGN KEY (paidby) REFERENCES paymethods(method) ON DELETE NO ACTION
);

ALTER SEQUENCE fees_feeid_seq RESTART WITH 8;

-- Begining of examination module
DROP TABLE IF EXISTS termTypes;

CREATE TABLE termtypes (
	term VARCHAR(10) PRIMARY KEY,
	descript VARCHAR(255) NOT NULL
);

INSERT INTO termtypes VALUES ('first','First Term'),('second','Second Term'),('third','Third Term');

DROP TABLE IF EXISTS academicterm ;

CREATE TABLE academicterm (
	termid SERIAL PRIMARY KEY,
	termtype VARCHAR(10) NOT NULL,
	startdate DATE NOT NULL,
	enddate DATE NOT NULL,
	yearid INTEGER NOT NULL,
	FOREIGN KEY (termtype) REFERENCES termtypes(term) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION
);

ALTER SEQUENCE academicterm_termid_seq RESTART WITH 8;

DROP TABLE IF EXISTS examtypes ;

CREATE TABLE examtypes (
	name VARCHAR(5) PRIMARY KEY,
	descript VARCHAR(255) NULL DEFAULT NULL
);

INSERT INTO examtypes VALUES ('seq1','First sequence'),('seq2','Second sequence'),
	('seq3','Third sequence'),('seq4','Fourth sequence'),
	('seq5','Fifth sequence'),('seq6','Sixth sequence');

DROP TABLE IF EXISTS examinations;

CREATE TABLE examinations (
	examid SERIAL PRIMARY KEY,
	startdate DATE NOT NULL,
	enddate DATE NOT NULL,
	closed BOOLEAN NOT NULL DEFAULT FALSE,
	examtype VARCHAR(5) NOT NULL,
	term INTEGER NOT NULL,
	orgid INTEGER NOT NULL,
	FOREIGN KEY (examtype) REFERENCES examtypes(name) ON DELETE NO ACTION,
	FOREIGN KEY (term) REFERENCES academicterm(termid) ON DELETE NO ACTION,
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION
);

ALTER SEQUENCE examinations_examid_seq RESTART WITH 8;

DROP TABLE IF EXISTS examresults ;

CREATE TABLE examresults (
	userid INTEGER NOT NULL,
	examid INTEGER NOT NULL,
	subjectid INTEGER NOT NULL,
	mark DECIMAL(4,2) NULL DEFAULT NULL,
	PRIMARY KEY(userid,examid,subjectid,mark),
	FOREIGN KEY (userid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (subjectid) REFERENCES subjects(subjectid) ON DELETE NO ACTION,
	FOREIGN KEY (examid) REFERENCES examinations(examid) ON DELETE NO ACTION
);

-- This table will be used to track the previous classrooms of students as the year progresses
DROP TABLE IF EXISTS legacy;

CREATE TABLE legacy (
	userid INTEGER NOT NULL,
	classid INTEGER NOT NULL,  -- The student's previous class
	yearid INTEGER NOT NULL,   -- The year the student was in that class
	PRIMARY KEY(userid,yearid), -- A student cannot be in legacy for the same year twice
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (classid) REFERENCES classrooms (classid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION
);

-- This table will use used to keep track of student absenses
DROP TABLE IF EXISTS absenses;

CREATE TABLE absenses (
	userid INTEGER NOT NULL,
	termid INTEGER NOT NULL,
	subjectid INTEGER NOT NULL,
	thetime TIMESTAMP NOT NULL,
	justified BOOLEAN NOT NULL DEFAULT FALSE,
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (termid) REFERENCES academicterm (termid) ON DELETE NO ACTION,
	FOREIGN KEY (subjectid) REFERENCES subjects (subjectid) ON DELETE NO ACTION
);

-- This table will be used to keep track requests made to enter previous sequence marks
DROP TABLE IF EXISTS requests;

CREATE TABLE requests (
	requestid SERIAL PRIMARY KEY,
	userid INTEGER NOT NULL, -- The user (teacher) who made the request
	yearid INTEGER NOT NULL,   -- The year the request was made
	examid INTEGER NOT NULL, -- The exam the request was made for
	subjectid INTEGER NOT NULL, -- The exam the request was made for
	classid INTEGER NOT NULL, -- The exam the request was made for
	newdate DATE NULL DEFAULT NULL, -- The new date and time for the extension. After that date, the request is deleted
	thetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- The time the request was made
	reason VARCHAR(255) NULL, -- The reason why the user did not enter marks during the normal
	granted BOOLEAN NOT NULL DEFAULT FALSE, -- Has the request beeen granted? default is false
	FOREIGN KEY (userid) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION,
	FOREIGN KEY (examid) REFERENCES examinations(examid) ON DELETE NO ACTION
);

ALTER SEQUENCE requests_requestid_seq RESTART WITH 8;

-- This table will be used to track codes that will be used to activate the system yearly
DROP TABLE IF EXISTS activators;

CREATE TABLE activators (
	code VARCHAR(64) PRIMARY KEY, -- The activation code
	used BOOLEAN NOT NULL DEFAULT FALSE, -- The code has not been used before
	dateused TIMESTAMP NULL DEFAULT NULL, -- When the code was used
	orgid INTEGER NULL DEFAULT NULL, -- The organisation who used the code
	FOREIGN KEY (orgid) REFERENCES organisations (orgid) ON DELETE NO ACTION
);

-- This table will be used to track teachers who assist other teachers to enter sequence marks
DROP TABLE IF EXISTS assistances;

CREATE TABLE assistances (
	assistid SERIAL PRIMARY KEY,
	assistor INTEGER NOT NULL, -- The teacher who is doing the assisting
	teacher INTEGER NOT NULL, -- The teacher being assisted
	yearid INTEGER NOT NULL, -- The academic year the assistor is doing the assistance. 
	status BOOLEAN NOT NULL DEFAULT TRUE, -- The assistance can be cancelled, or reassigned
	UNIQUE (assistor,teacher,yearid), -- Only one assistor can assist the a teacher in a year
	FOREIGN KEY (assistor) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (teacher) REFERENCES users (userid) ON DELETE NO ACTION
);

ALTER SEQUENCE assistances_assistid_seq RESTART WITH 8;

-- This table will be used to handle the error messages at the code level. The engine level errors will be handled later
DROP TABLE IF EXISTS errormessages;

CREATE TABLE errormessages (
	errkey VARCHAR(50) PRIMARY KEY,
	erren VARCHAR(255) NOT NULL, -- The english version of the error message
	errfr VARCHAR(255) NOT NULL -- The french version of the error message
);

INSERT INTO errormessages (errkey, erren, errfr) VALUES 
('loginBadMagik','Bad magik','Bad magik'),
('loginCantRoot', 'Cannot root now', 'Ne peut pas rootter maintenant'),
('loginBadCredentials','Bad credentials', 'Mauvais nom d''utilisateur et mot de passe'),
('loginGoAway','Please go away','Partez s''il vous plait'),
('loginChangePass','Must change password','Doit changer de mot de passe'),
('loginUnderAssist','You are currenly under assistance. Please contact the system administrator.','Vous êtes actuellement sous assistance. Veuillez contacter l''administrateur du système.'),
('loginOrgExpired','Your organisation have expire. Please contact Smart Systems support services.','Votre organisation a expiré. Veuillez contacter les services de support de Smart Systems.'),
('loginAlreadyIn','User is already logged in','L''utilisateur est déjà connecté'),
('loginAuthenFail','User authentication fail','L''authentification de l''utilisateur échoue'),
('loginNoOpenConn','No such open connection','Pas de connexion ouverte'),
('loginNoConOnMobi','You are not authorized to connect from the mobile platform.','Vous n’êtes pas autorisé à vous connecter à partir de la plate-forme mobile.'),

('usrCrtUnmExist','Username must be unique.','Le nom d''utilisateur doit être unique.'),
('chgPasBadEmail','Wrong email address','Mauvaise adresse email'),
('chgPassBadPhone','Wrong phone number','Mauvais numéro de telephone'),
('chgPassNoMatch','passwords do not match','Les mots de passe ne correspondent pas'),
('chgPassNotStalled','You are not staled. Contact system administrator.','Vous n''êtes pas rassis. Contactez l''administrateur du système.'),

('calYrStartPast','Academic year cannot start in the past','Academic year cannot start in the past'),
('calYrEndPast','Academic year cannot end in the past','L''année académique ne peut pas finir dans le passé'),
('calYrEndB4Start','Academic year cannot end before it has started','L''année académique ne peut pas se terminer avant d''avoir commencé'),
('calYrEndAfterOrg','Academic year cannot end after your organization''s expiry date.','L''année académique ne peut pas se terminer après la date d''expiration de votre organisation.'),
('calYrStartPrevAct','Academic year cannot be created now. The previous year is still active','L''année académique ne peut pas être créée maintenant. L''année précédente est toujours active.'),
('calYrModNewStart','Academic year cannot be Modified. It has ended and a new year has already started.','L''année académique ne peut pas être modifiée. C''est terminé et une nouvelle année a déjà commencé'),
('calYrModLnGone','Academic year cannot be modified. It is long gone.','L''année académique ne peut pas être modifiée. Il est parti depuis longtemps.'),

('calTermStartPast','Academic term cannot start in the past','Trimestre académique ne peut pas commencer dans le passé'),
('calTermEndPast','Academic term cannot end in the past','Trimestre académique ne peut pas se terminer dans le passé'),
('calTermEndB4Start','Academic term cannot end before it has started','Le trimestre académique ne peut pas se terminer avant d''avoir commencé'),
('calTermNoActYear','No active academic year set','Aucune année scolaire active'),
('calTermStartB4YearStart','Academic term cannot start before the academic year has started','Le trimestre académique ne peut pas commencer avant l''année scolaire n''a commencé'),
('calTermStartA4YearEnd','Academic term cannot start after the academic year has ended','Le trimestre académique ne peut pas commencer après la fin de l''année académique'),
('calTermEndA4YearEnd','Academic term cannot end after the academic year has ended','Le trimestre académique ne peut pas se terminer après la fin de l''année académique'),
('calTermEndB4YearStart','Academic term cannot end before the academic year has started','Le trimestre académique ne peut se terminer avant le début de l''année académique'),
('calTermStartPrevAct','Academic term cannot be created now. Previous term is still active','Le trimestre académique ne peut pas être créé maintenant. Le trimestres précédent est toujours actif'),
('calTermAlreadyCrea','This term has already been created.','Ce trimestre a déjà été créé.'),
('calTermLimit3','Academic year cannot have more than three(3) terms','L''année académique ne peut avoir plus de trois (3) trimestres'),
('calTermModNewStart','Academic term cannot be Modified. It has ended and a new term has already started','Trimestre académique ne peut pas être modifié. Il est terminé et un nouveau trimestre a déjà commencé'),
('calTermModLnGone','Academic term cannot be modified. It is long gone','Trimestre académique ne peut pas être modifié. Il est parti depuis longtemps'),
('calTermMSExNtTwo','Academic term must have two sequences','Trimestre académique doit avoir deux séquences'),

('classTeachersAdd','No such classroom exists.','Cette classe n''existe pas.'),
('calExamNoClass','There are no classrooms in your school.','Il n''y a pas de salles de classe dans votre école.'),
('calExamNoClassTeachers','No class in your school has been assigned teachers.','Aucune salle de classe de votre école n''a d''enseignants assignés.'),
('calExamNoStudent','There are no students in your school.','Il n''y a pas d''élèves dans ton école.'),
('calExamStartPast','Examination cannot start in the past.','L''examen ne peut pas commencer dans le passé.'),
('calExamEndPast','Examination cannot end in the past.','L''examen ne peut pas finir dans le passé.'),
('calExamEndB4Start','Examination cannot end before it has started.','L''examen ne peut pas se terminer avant d''avoir commencé.'),
('calExamNoActTerm','No active academic term set.','Aucune trimestre académique active.'),
('calExamStartPrevAct','Examination cannot be created now. Previous examination is still active.','L''examen ne peut pas être créé maintenant. L''examen précédent est toujours actif.'),
('calExamAlreadyCrea','This examination has already been created.','Cet examen a déjà été créé.'),
('calExamStartB4TermStart','Examination cannot start before the term has started.','L''examen ne peut pas commencer avant le début du trimestre.'),
('calExamEndA4TermStart','Examination cannot end after the academic term has ended.','L''examen ne peut pas se terminer après la fin du trimestre.'),
('calExamEndB4TermStart','Examination cannot end before the term has started.','L''examen ne peut pas se terminer avant le début du trimestre.'),
('calExamStartA4TermEnd','Examination cannot start after the academic term has ended.','L''examen ne peut pas commencer après la fin du trimestre.'),
('calExamLimit2','Academic term cannot have more than two(2) sequences.','Trimestre académique ne peut avoir plus de deux (2) séquences.'),
('calExamModNewStart','Examination cannot be Modified. It has ended and a new examination has already started.','L''examen ne peut être modifié. Il est terminé et un nouvel examen a déjà commencé.'),
('calExamModLnGone','Examination cannot be modified now. It is long gone.','L''examen ne peut pas être modifié maintenant. Il est parti depuis longtemps.'),
('calExamNtTeachCls','You are not teaching this subject in this classroom.','Vous n''enseignez pas ce matiere dans cette classe.'),

('classAddYearStarted','Cannot create classroom now. Academic year has already started.','Impossible de créer une salle de classe maintenant. L''année académique a déjà commencé.'),
('classAddTeacher','Cannot assign teachers now. Some examinations have already been written.','Impossible d''affecter des enseignants maintenant. Certains examens ont déjà été écrits.'),
('classUsrNotTeacher','User is not a teacher.','L''utilisateur n''est pas un enseignant.'),
('classStudsNotInClass','There are no students in this class.','Il n''y a pas d''élèves dans cette classe.'),
('classDoingSubject','Class already doing this subject.','La classe fait déjà ce matiere.'),
('classAddSeqNoActExam','No active examination or current examination has ended.','Aucun examen en cours ou en cours est déjà terminé.'),
('classAddSeqNotYetTime','Not yet time to enter sequence marks. Check later.','Pas encore le temps d''entrer des notes de séquence. Vérifier plus tard.'),
('classNotTeachingclass','You are not teaching this subject in this classroom or you are not assisting someone.','Vous n''enseignez pas ce matiere dans cette classe ou vous n''assistez personne.'),
('classAddSeqStudPromAlr','Cannot enter sequence marks. Students have already been promoted.','Impossible d''entrer des notes de séquence. Les étudiants ont déjà été promus.'),
('classSubNotApproved','The selected subject have not approved for a revisit.','Le sujet sélectionné n''a pas té approuvé pour une revue.'),
('classTcherNtTching','Teacher is not teaching this subject in this classroom or is not assisting someone.','L''enseignant n''enseigne pas ce matiere dans cette classe ou n''assiste pas quelqu''un.'),
('classAddSeqNotJson','Value was not a well formated JSON string.','La valeur n''était pas une chaîne JSON bien formatée.'),
('classPrtReportNoActYr','Cannot print report now. No active year.','Impossible d''imprimer le bulletins maintenant. Aucune année active.'),
('classPrtReportYrNotStart','Cannot print report now. The academic year has not yet started.','Impossible d''imprimer le bulletins maintenant. L''année académique n''a pas encore commencé.'),
('classPrtLegacyRepYrAct','Academic year is active.','L''année académique est active.'),
('classPrtLegacyRepNoTerm','There are no terms in this academic year.','Il n''y a pas de trimestres dans cette année académique.'),
('classAddAbsenceNoYear','Cannot mark absences now. No active academic term set.','Impossible de marquer les absences maintenant. Aucune trimestre académique active.'),
('classIdPrtNoActYear','Cannot print ID Card now. No active year.','Impossible d''imprimer la carte scolaire maintenant. Aucune année active.'),
('classIdPrtYrNotStarted','Cannot print ID Card now. The academic year has not yet started.','Impossible d''imprimer la carte scolaire maintenant. L''année académique n''a pas encore commencé.'),

('reqExamStillActive','The selected examination is still active.','L''examen sélectionné est toujours actif.'),
('reqExamSimilarReq','You have already made a similar request. Please be patient for it to be granted.','Vous avez déjà fait une demande similaire. S''il vous plaît soyez patient pour qu''il soit accordé.'),
('reqTeachAssisHimSelf','Teacher cannot assist his/her self.','L''enseignant ne peut pas s''auto-aider.'),
('reqTeachHasAssistant','Teacher already have an assistor.','L''enseignant a déjà un assistant.'),

('roleUpdateSystem','Cannot update system values.','Impossible de mettre à jour les valeurs du système.'),
('roleRemoveSystem','Cannot remove system values.','Impossible de supprimer les valeurs du système.'),
('rolePermDenied','Permission denied.','Permission refusée.'),

('settingOrgNotExp','Your organization has not expired yet.','Votre organisation n''a pas encore expiré.'),
('settingInvalidCode','Invalid activation code.','Code d''activation invalide.'),

('studCtAdmiYrStedExWrit','Cannot admit a student now. Academic year has already started and some examinations have already been written.','Ne peut pas admettre un élève maintenant. L''année académique a déjà commencé et certains examens ont déjà été écrits.'),
('studCtAdmiBadClassSpeci','Cannot admit a student. Bad classroom specified.','Impossible d''admettre un étudiant. Mauvaise classe spécifiée.'),
('studModCtExamWritten','Cannot change student class now. Some examinations have already been written.','Impossible de changer de classe maintenant. Certains examens ont déjà été écrits.'),
('studAddParentNoSuchPar','No such parent.','Le parent n''existe pas.'),
('studAddParAlreadyHave','Student already has this parent.','L''élève a déjà ce parent.'),
('studAddParentLimit2','Student cannot have more than two parents.','L''élève ne peut avoir plus de deux parents.'),
('studRemParentNoSuchPar','Student don''t have this parent.','L''élève n''a pas ce parent.'),
('studChgStatusNotClassMas','You are not the classmaster.','Vous n''êtes pas le professeur principal.'),
('studChgClassCantYrEnded','Cannot change class now. Academic year has ended.','Impossible de changer de classe maintenant. L''année académique est terminée.'),
('studChgCtPromToSamClass','Student cannot be promoted to the same classroom.','L''élève ne peut pas être promu dans la même classe.'),
('studChgClassHasAllExWrit','Student cannot be promoted now. Have all the examinations been written?','L''élève ne peut pas être promu maintenant. Tous les examens ont-ils été écrits?'),
('studChgClassAlreadyChanged','Student class has already been changed for this academic year.','La classe de l''élève a déjà été modifiée pour cette année académique.'),
('studRepeatHaveAllExWrit','Student cannot repeat now. Have all the examinations been written?','L''élève ne peut pas redoubler maintenant. Tous les examens ont-ils été écrits?'),

('usrAddCtUseRsvVal4UsrNam','Cannot use a reserved value for username.','Impossible d''utiliser une valeur réservée pour le nom d''utilisateur.'),
('usrModNoSuchUsr','No such user.','L''utilisateur n''existe pas.'),

('usrAddRoleGetRoot','Get root.','Rooter vous.'),
('usrRemRoleNoSuchUsrRole','No such user/role assignment for','Aucune assignation utilisateur / rôle de ce type pour'),
('usrRemUsrCantRemSysUsers','Cannot delete system users.','Impossible de supprimer les utilisateurs du système.'),
('calExamNtEnd','Cannot print master sheet for this sequence. Examination has not ended yet.','Impossible d''imprimer le Procès-verbal pour cette séquence. L''examen n''est pas encore terminé.'),
('calYrNtSixSeq','Cannot print yearly summary now. All sequences have not been written.','Impossible d''imprimer le recapitulative. Toutes les séquences n''ont pas été écrites.'),
('subjAlrdyHasAGroup','This subject is already assigned to a group. Cannot exist in two groups.','Ce matière est déjà attribué à un groupe. Ne peut pas exister dans deux groupes.'),
('userRstOwnPas','You cannot reset your own password.','Vous ne pouvez pas réinitialiser votre propre mot de passe.'),
('rmvSubjectExamHasIt', 'You cannot delete this subject. Already used in an examination.', 'Vous ne pouvez pas supprimer matière. Déjà utilisé lors d''un sequence'),
('studNoSuchStud','No such student.','L''élève n''existe pas.');

-- This table will be used to stored uploaded data by teacher
DROP TABLE IF EXISTS teacherdocuploads;

CREATE TABLE teacherdocuploads (
	docId SERIAL PRIMARY KEY,
	doc BYTEA NOT NULL,
	descript VARCHAR(255) NOT NULL,
	subjectid INTEGER NOT NULL,
	classid INTEGER NOT NULL,
	uploadedon TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
	uploadedby INTEGER NOT NULL,
	yearid INTEGER NOT NULL,
	FOREIGN KEY (uploadedby) REFERENCES users (userid) ON DELETE NO ACTION,
	FOREIGN KEY (subjectid) REFERENCES subjects (subjectid) ON DELETE NO ACTION,
	FOREIGN KEY (classid) REFERENCES classrooms (classid) ON DELETE NO ACTION
);

ALTER SEQUENCE teacherdocuploads_docid_seq RESTART WITH 8;

DROP TABLE IF EXISTS parentuploads;

CREATE TABLE parentuploads (
	feeid SERIAL PRIMARY KEY,
	studentid INTEGER NOT NULL,
	type VARCHAR(20) NOT NULL,
	yearid INTEGER NOT NULL,
	amount VARCHAR(10)  NOT NULL,
	paidon DATE NOT NULL,
	paidby VARCHAR(10) NOT NULL DEFAULT 'cash',
	reference VARCHAR(20) NOT NULL,
	parentid INTEGER NOT NULL,
	proof BYTEA NOT NULL,
	status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
	comment VARCHAR(1024) NULL DEFAULT NULL,
	FOREIGN KEY (studentid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (parentid) REFERENCES users(userid) ON DELETE NO ACTION,
	FOREIGN KEY (yearid) REFERENCES academicyear(yearid) ON DELETE NO ACTION,
	FOREIGN KEY (type) REFERENCES feetypes(type) ON DELETE NO ACTION,
	FOREIGN KEY (paidby) REFERENCES paymethods(method) ON DELETE NO ACTION
);

ALTER SEQUENCE parentuploads_feeid_seq RESTART WITH 8;