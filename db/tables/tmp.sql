\c shopman_pos;
DROP TABLE IF EXISTS groupings;
CREATE TABLE groupings (
	subjectid INTEGER NOT NULL,
	groupid INTEGER NOT NULL,
	UNIQUE (subjectid), -- We cannot have a subject in the group table twice. i.e 2 groups
	FOREIGN KEY (subjectid) REFERENCES subjects (subjectid) ON DELETE NO ACTION,
	FOREIGN KEY (groupid) REFERENCES groups (groupid) ON DELETE CASCADE
);