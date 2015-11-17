-- Table: dev.modificationcontact

-- DROP TABLE dev.modificationcontact;

CREATE TABLE dev.modificationcontact
(
  modificationid integer NOT NULL, -- PK for MODIFICATION
  projectcontactid integer NOT NULL, -- PK for PROJECTCONTACT
  priority integer NOT NULL, -- Priority of the contact
  CONSTRAINT modificationcontact_pk PRIMARY KEY (modificationid, projectcontactid),
  CONSTRAINT modification_modificationcontact_fk FOREIGN KEY (modificationid)
      REFERENCES dev.modification (modificationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT projectcontact_modificationcontact_fk FOREIGN KEY (projectcontactid)
      REFERENCES dev.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE dev.modificationcontact
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.modificationcontact TO pts_admin;
GRANT SELECT ON TABLE dev.modificationcontact TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.modificationcontact TO pts_write;
COMMENT ON TABLE dev.modificationcontact
  IS 'Associates project contacts with a modification';
COMMENT ON COLUMN dev.modificationcontact.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN dev.modificationcontact.projectcontactid IS 'PK for PROJECTCONTACT';
COMMENT ON COLUMN dev.modificationcontact.priority IS 'Priority of the contact';
