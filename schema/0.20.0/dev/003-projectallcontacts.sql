-- View: dev.projectallcontacts

-- DROP VIEW dev.projectallcontacts;

CREATE OR REPLACE VIEW dev.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM metadatacontact
             JOIN projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE dev.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE dev.projectallcontacts TO bradley;
GRANT SELECT ON TABLE dev.projectallcontacts TO pts_read;
GRANT ALL ON TABLE dev.projectallcontacts TO pts_admin;
