ALTER TABLE pts.modcomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.modcomment ADD COLUMN modcommentid SERIAL;

ALTER TABLE pts.modcomment DROP CONSTRAINT modcomment_pk;

ALTER TABLE pts.modcomment ADD PRIMARY KEY (modcommentid);

ALTER TABLE pts.filecomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.filecomment ADD COLUMN filecommentid SERIAL;

ALTER TABLE pts.filecomment DROP CONSTRAINT filecomment_pkey;

ALTER TABLE pts.filecomment ADD PRIMARY KEY (filecommentid);

ALTER TABLE pts.projectcomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.projectcomment ADD COLUMN projectcommentid SERIAL;

ALTER TABLE pts.projectcomment DROP CONSTRAINT projectcomment_pk;

ALTER TABLE pts.projectcomment ADD PRIMARY KEY (projectcommentid);

ALTER TABLE pts.deliverablecomment ADD COLUMN deliverablecommentid SERIAL;

ALTER TABLE pts.deliverablecomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.deliverablecomment DROP CONSTRAINT deliverablecomment_pk;

ALTER TABLE pts.deliverablecomment ADD PRIMARY KEY (deliverablecommentid);

ALTER TABLE pts.invoicecomment ADD COLUMN invoicecommentid SERIAL;

ALTER TABLE pts.invoicecomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.invoicecomment DROP CONSTRAINT invoicecomment_pk;

ALTER TABLE pts.invoicecomment ADD PRIMARY KEY (invoicecommentid);

COMMENT ON COLUMN deliverablecomment.datemodified IS 'Date that the comment was modified.';

GRANT SELECT, UPDATE ON TABLE deliverablecomment_deliverablecommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE filecomment_filecommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE invoicecomment_invoicecommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE modcomment_modcommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE projectcomment_projectcommentid_seq TO GROUP pts_write;



CREATE TABLE pts.fundingcomment (
                fundingcommentid SERIAL NOT NULL,
                contactid INTEGER NOT NULL,
                fundingid INTEGER NOT NULL,
                datemodified DATE NOT NULL,
                comment VARCHAR NOT NULL,
                CONSTRAINT fundingcomment_pk PRIMARY KEY (fundingcommentid)
);
COMMENT ON COLUMN pts.fundingcomment.contactid IS 'FK for PERSON';
COMMENT ON COLUMN pts.fundingcomment.fundingid IS 'FK for FUNDING';
COMMENT ON COLUMN pts.fundingcomment.datemodified IS 'Date that the comment was modified.';


ALTER TABLE pts.fundingcomment ADD CONSTRAINT funding_fundingcomment_fk
FOREIGN KEY (fundingid)
REFERENCES pts.funding (fundingid)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE pts.fundingcomment ADD CONSTRAINT person_fundingcomment_fk
FOREIGN KEY (contactid)
REFERENCES pts.person (contactid)
ON DELETE CASCADE
ON UPDATE NO ACTION
NOT DEFERRABLE;

GRANT SELECT, UPDATE ON TABLE fundingcomment_fundingcommentid_seq TO GROUP pts_write;
GRANT SELECT ON TABLE fundingcomment TO GROUP pts_read;
GRANT UPDATE, INSERT, DELETE ON TABLE fundingcomment TO GROUP pts_write;

--fix ref integrity for deliverables
CREATE OR REPLACE FUNCTION delete_deliverable() RETURNS trigger AS $$
    BEGIN
        -- Check if no other instances of deliverablemod exist
        IF NOT EXISTS(SELECT 1 FROM deliverablemod WHERE deliverableid = OLD.deliverableid) THEN
        DELETE FROM deliverable WHERE deliverableid = OLD.deliverableid;
        END IF;

        RETURN OLD;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_deliverablemod
    AFTER DELETE ON deliverablemod
    FOR EACH ROW
    EXECUTE PROCEDURE delete_deliverable();

--make acronym required
ALTER TABLE contactgroup
   ALTER COLUMN acronym SET NOT NULL;

--add shorttitle to projectlist
CREATE OR REPLACE VIEW projectlist AS
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
  project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated, COALESCE(invoice.amount, 0.00) AS invoiced, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00) AS difference
  ,project.shorttitle FROM project
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   LEFT JOIN modification USING (projectid)
   LEFT JOIN funding ON funding.modificationid = modification.modificationid AND funding.fundingtypeid = 1
   LEFT JOIN ( SELECT modification.projectid, sum(invoice.amount) AS amount
   FROM invoice
   JOIN funding USING (fundingid)
   JOIN modification USING (modificationid)
  WHERE funding.fundingtypeid = 1
  GROUP BY modification.projectid) invoice USING (projectid);

--remove contactgroups from groupmemberlist, this is a temp hack to prevent groups from
--displaying in the member management grid
CREATE OR REPLACE VIEW groupmemberlist AS
         SELECT ccg.groupid, ccg.contactid, ccg.positionid, ccg.contactcontactgroupid, pg_catalog.concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name, ccg.priority
           FROM contactcontactgroup ccg
      JOIN person USING (contactid);
/*UNION
         SELECT ccg.groupid, ccg.contactid, ccg.positionid, ccg.contactcontactgroupid, contactgroup.name, ccg.priority
           FROM contactcontactgroup ccg
      JOIN contactgroup USING (contactid)
  ORDER BY 5, 3;*/

-- View: contactgrouplist

-- DROP VIEW contactgrouplist;

CREATE OR REPLACE VIEW contactgrouplist AS
 WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid, contactgroup.organization, contactgroup.name, contactgroup.acronym, contactcontactgroup.groupid, contactgroup.name::text || ''::text AS fullname, NULL::text AS parentname
                   FROM contactgroup
              LEFT JOIN contactcontactgroup USING (contactid)
             WHERE contactcontactgroup.groupid IS NULL
        UNION ALL
                 SELECT ccg.contactid, cg.organization, cg.name, cg.acronym, gt.contactid, (gt.fullname || ' -> '::text) || cg.name::text AS full_name, gt.name
                   FROM contactgroup cg
              JOIN contactcontactgroup ccg USING (contactid)
         JOIN grouptree gt ON ccg.groupid = gt.contactid
        )
 SELECT grouptree.contactid, grouptree.groupid AS parentgroupid, grouptree.organization, grouptree.name, grouptree.acronym, grouptree.fullname, grouptree.parentname
   FROM grouptree;

ALTER TABLE contactgrouplist
  OWNER TO bradley;
GRANT ALL ON TABLE contactgrouplist TO bradley;
GRANT SELECT ON TABLE contactgrouplist TO pts_read;

CREATE VIEW personpositionlist AS
    SELECT "position".positionid, "position".title, "position".code FROM cvl."position" WHERE ("position".positionid > 0);

COMMENT ON COLUMN deliverablecomment.deliverableid IS 'FK for DELIVERABLE';

COMMENT ON COLUMN deliverablecomment.contactid IS 'FK for PERSON';
