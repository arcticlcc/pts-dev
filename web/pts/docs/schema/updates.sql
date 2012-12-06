-- Table: deliverablenotice

-- DROP TABLE deliverablenotice;

CREATE TABLE deliverablenotice
(
  deliverablenoticeid serial NOT NULL, -- DELIVERABLENOTICE PK
  modificationid integer NOT NULL, -- PK for MODIFICATION
  deliverableid integer NOT NULL, -- PK for DELIVERABLE
  noticeid integer NOT NULL, -- PK for NOTICE
  projectcontactid integer NOT NULL, -- PK for PROJECTCONTACT
  contactid integer NOT NULL, -- PK for PERSON
  datesent date NOT NULL, -- Date that the notice was sent.
  comment character varying[],
  CONSTRAINT deliverablenotice_pk PRIMARY KEY (deliverablenoticeid ),
  CONSTRAINT deliverablemod_deliverablenotice_fk FOREIGN KEY (modificationid, deliverableid)
      REFERENCES deliverablemod (modificationid, deliverableid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT notice_deliverablenotice_fk FOREIGN KEY (noticeid)
      REFERENCES notice (noticeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT person_deliverablenotice_fk FOREIGN KEY (contactid)
      REFERENCES person (contactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT projectcontact_deliverablenotice_fk FOREIGN KEY (projectcontactid)
      REFERENCES projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE deliverablenotice
  OWNER TO bradley;
GRANT ALL ON TABLE deliverablenotice TO bradley;
GRANT SELECT ON TABLE deliverablenotice TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE deliverablenotice TO pts_write;
COMMENT ON TABLE deliverablenotice
  IS 'Tracks notices sent to deliverable contacts';
COMMENT ON COLUMN deliverablenotice.deliverablenoticeid IS 'DELIVERABLENOTICE PK';
COMMENT ON COLUMN deliverablenotice.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN deliverablenotice.deliverableid IS 'PK for DELIVERABLE';
COMMENT ON COLUMN deliverablenotice.noticeid IS 'PK for NOTICE';
COMMENT ON COLUMN deliverablenotice.projectcontactid IS 'PK for PROJECTCONTACT';
COMMENT ON COLUMN deliverablenotice.contactid IS 'PK for PERSON';
COMMENT ON COLUMN deliverablenotice.datesent IS 'Date that the notice was sent.';

-- Table: cvl.notice

-- DROP TABLE cvl.notice;

CREATE TABLE cvl.notice
(
  noticeid integer NOT NULL, -- PK for NOTICE
  title character varying NOT NULL, -- Full title of notice
  code character varying NOT NULL, -- Short title of notice
  description character varying NOT NULL,
  CONSTRAINT notice_pk PRIMARY KEY (noticeid )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.notice
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.notice TO bradley;
GRANT SELECT ON TABLE cvl.notice TO pts_read;
COMMENT ON TABLE cvl.notice
  IS 'CVL for types of notices';
COMMENT ON COLUMN cvl.notice.noticeid IS 'PK for NOTICE';
COMMENT ON COLUMN cvl.notice.title IS 'Full title of notice';
COMMENT ON COLUMN cvl.notice.code IS 'Short title of notice';

GRANT SELECT, UPDATE ON TABLE deliverablenotice_deliverablenoticeid_seq TO GROUP pts_write;
