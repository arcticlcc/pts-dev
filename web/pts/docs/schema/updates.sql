-- Table: deliverablenotice

-- DROP TABLE deliverablenotice;

CREATE TABLE deliverablenotice
(
  deliverablenoticeid serial NOT NULL, -- DELIVERABLENOTICE PK
  modificationid integer NOT NULL, -- PK for MODIFICATION
  deliverableid integer NOT NULL, -- PK for DELIVERABLE
  noticeid integer NOT NULL, -- PK for NOTICE
  recipientid integer NOT NULL, -- The person that the notice was sent to.
  contactid integer NOT NULL, -- PERSON that sent the notice.
  datesent date NOT NULL, -- Date that the notice was sent.
  comment character varying,
  CONSTRAINT deliverablenotice_pk PRIMARY KEY (deliverablenoticeid ),
  CONSTRAINT deliverablemod_deliverablenotice_fk FOREIGN KEY (modificationid, deliverableid)
      REFERENCES deliverablemod (modificationid, deliverableid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT notice_deliverablenotice_fk FOREIGN KEY (noticeid)
      REFERENCES cvl.notice (noticeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT person_deliverablenotice_fk FOREIGN KEY (contactid)
      REFERENCES person (contactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT recipient_deliverablenotice_fk FOREIGN KEY (recipientid)
      REFERENCES person (contactid) MATCH SIMPLE
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
COMMENT ON COLUMN deliverablenotice.recipientid IS 'The person that the notice was sent to.';
COMMENT ON COLUMN deliverablenotice.contactid IS 'PERSON that sent the notice.';
COMMENT ON COLUMN deliverablenotice.datesent IS 'Date that the notice was sent.';


-- Index: fki_person_deliverablenotice_user_fk

-- DROP INDEX fki_person_deliverablenotice_user_fk;

CREATE INDEX fki_person_deliverablenotice_user_fk
  ON deliverablenotice
  USING btree
  (recipientid );

GRANT SELECT, UPDATE ON TABLE deliverablenotice_deliverablenoticeid_seq TO GROUP pts_write;

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

-- View: report.noticesent

-- DROP VIEW report.noticesent;

CREATE OR REPLACE VIEW report.noticesent AS
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate, d.title, d.description, notice.code AS lastnotice, deliverablenotice.datesent, projectlist.projectcode, project.shorttitle AS project, (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact, personlist.priemail AS email, (folist.firstname::text || ' '::text) || folist.lastname::text AS fofficer, folist.priemail AS foemail,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue, COALESCE(status.status, 'Not Received'::character varying) AS status, modification.projectid, dm.modificationid, d.deliverableid
   FROM deliverable d
   JOIN ( SELECT deliverablemod.modificationid, deliverablemod.deliverableid, deliverablemod.duedate, deliverablemod.receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverablemod.personid
           FROM deliverablemod
          WHERE NOT deliverablemod.invalid OR NOT (EXISTS ( SELECT 1
                   FROM deliverablemod dp
                  WHERE dp.modificationid = dp.parentmodificationid AND dp.deliverableid = dp.parentdeliverableid))) dm USING (deliverableid)
   JOIN modification USING (modificationid)
   JOIN projectlist USING (projectid)
   JOIN project USING (projectid)
   LEFT JOIN ( SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid
   FROM projectcontact
  WHERE projectcontact.roletypeid = ANY (ARRAY[7])) projectcontact USING (projectid)
   LEFT JOIN personlist USING (contactid)
   LEFT JOIN ( SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid
   FROM projectcontact
  WHERE projectcontact.roletypeid = 5
  ORDER BY projectcontact.priority) focontact USING (projectid)
   LEFT JOIN personlist folist ON focontact.contactid = folist.contactid
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
   FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (modificationid, deliverableid)
   LEFT JOIN deliverablenotice USING (modificationid, deliverableid)
   LEFT JOIN notice USING (noticeid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT COALESCE(status.deliverablestatusid >= 10, false) AND
CASE
    WHEN status.deliverablestatusid >= 10 THEN 0
    WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
    ELSE 'now'::text::date - dm.duedate
END > (-30)
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;

ALTER TABLE report.noticesent
  OWNER TO bradley;
GRANT ALL ON TABLE report.noticesent TO bradley;
GRANT SELECT ON TABLE report.noticesent TO pts_read;
