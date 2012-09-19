--add support for deliverable status
CREATE TABLE pts.deliverablemodstatus (
                deliverablemodstatusid SERIAL,
                deliverablestatusid INTEGER NOT NULL,
                modificationid INTEGER NOT NULL,
                deliverableid INTEGER NOT NULL,
                effectivedate DATE NOT NULL,
                comment VARCHAR,
                CONSTRAINT deliverablemodstatus_pk PRIMARY KEY (deliverablemodstatusid)
);
COMMENT ON TABLE pts.deliverablemodstatus IS 'Links DELIVERABLEMOD to DELIVERABLESTATUS';
COMMENT ON COLUMN pts.deliverablemodstatus.deliverablemodstatusid IS 'PK for MODSTATUS, created for convenience when using client applications';
COMMENT ON COLUMN pts.deliverablemodstatus.deliverablestatusid IS 'PK for DELIVERABLESTATUS';
COMMENT ON COLUMN pts.deliverablemodstatus.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN pts.deliverablemodstatus.deliverableid IS 'PK for DELIVERABLE';
COMMENT ON COLUMN pts.deliverablemodstatus.effectivedate IS 'Date of status change';

CREATE TABLE cvl.deliverablestatus (
                deliverablestatusid INTEGER NOT NULL,
                code VARCHAR NOT NULL,
                status VARCHAR NOT NULL,
                description VARCHAR NOT NULL,
                comment VARCHAR,
                CONSTRAINT deliverablestatus_pk PRIMARY KEY (deliverablestatusid)
);
COMMENT ON TABLE cvl.deliverablestatus IS 'status of DELIVERABLE';
COMMENT ON COLUMN cvl.deliverablestatus.deliverablestatusid IS 'PK for DELIVERABLESTATUS';
COMMENT ON COLUMN cvl.deliverablestatus.code IS 'code for status';
COMMENT ON COLUMN cvl.deliverablestatus.status IS 'status of PROJECT';
COMMENT ON COLUMN cvl.deliverablestatus.description IS 'description of status';


ALTER TABLE pts.deliverablemodstatus ADD CONSTRAINT deliverablestatus_deliverablemodstatus_fk
FOREIGN KEY (deliverablestatusid)
REFERENCES cvl.deliverablestatus (deliverablestatusid)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pts.deliverablemodstatus ADD CONSTRAINT deliverablemod_deliverablemodstatus_fk
FOREIGN KEY (modificationid, deliverableid)
REFERENCES pts.deliverablemod (modificationid, deliverableid)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

--permissions
GRANT SELECT, UPDATE ON TABLE deliverablemodstatus_deliverablemodstatusid_seq TO pts_write;
GRANT SELECT ON TABLE deliverablemodstatus TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE deliverablemodstatus TO pts_write;
GRANT SELECT ON TABLE cvl.deliverablestatus TO pts_read;

--track user for deliverable status

ALTER TABLE pts.deliverablemodstatus ADD COLUMN contactid INTEGER NOT NULL;

ALTER TABLE pts.deliverablemodstatus ADD CONSTRAINT person_deliverablemodstatus_fk
FOREIGN KEY (contactid)
REFERENCES pts.person (contactid)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

--data for DELIVERABLESTATUS
INSERT INTO deliverablestatus VALUES (1, 'Received', 'Received', 'Deliverable or Task has been delivered.', NULL);
INSERT INTO deliverablestatus VALUES (3, 'Revising', 'Under Revision', 'Deliverable or Task is being revised.', NULL);
INSERT INTO deliverablestatus VALUES (4, 'Completed', 'Completed', 'Deliverable or Task has been accepted as complete.', NULL);
INSERT INTO deliverablestatus VALUES (5, 'Archived', 'Archived', 'All items generated by the Deliverable or Task have been archived.', NULL);
INSERT INTO deliverablestatus VALUES (6, 'Published', 'Published', 'All publishable items generated by the Deliverable or Task have been published.', NULL);
INSERT INTO deliverablestatus VALUES (2, 'Reviewing', 'Under Review', 'Deliverable or Task is under review - received but not accepted.', NULL);
