-- View: dev.projectallcontacts

-- DROP VIEW dev.projectallcontacts;

CREATE OR REPLACE VIEW dev.projectallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.projectid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            projectcontact.projectid
           FROM dev.metadatacontact
             JOIN dev.projectcontact ON metadatacontact."contactId" = projectcontact.contactid) dt(contactid, projectid);

ALTER TABLE dev.projectallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE dev.projectallcontacts TO bradley;
GRANT SELECT ON TABLE dev.projectallcontacts TO pts_read;
GRANT ALL ON TABLE dev.projectallcontacts TO pts_admin;

-- View: dev.productallcontacts

-- DROP VIEW dev.productallcontacts;

CREATE OR REPLACE VIEW dev.productallcontacts AS
 SELECT DISTINCT dt.contactid,
    dt.productid
   FROM ( SELECT unnest(metadatacontact.allids) AS unnest,
            productcontact.productid
           FROM dev.metadatacontact
             JOIN dev.productcontact ON metadatacontact."contactId" = productcontact.contactid) dt(contactid, productid);

ALTER TABLE dev.productallcontacts
  OWNER TO bradley;
GRANT ALL ON TABLE dev.productallcontacts TO bradley;
GRANT SELECT ON TABLE dev.productallcontacts TO pts_read;
GRANT ALL ON TABLE dev.productallcontacts TO pts_admin;
