-- View: dev.modificationcontactlist

-- DROP VIEW dev.modificationcontactlist;

CREATE OR REPLACE VIEW dev.modificationcontactlist AS 
 SELECT modification.modificationid,
    string_agg(q.projectcontactid::text, ','::text) AS modificationcontact
   FROM dev.modification
     LEFT JOIN ( SELECT modificationcontact.modificationid,
            modificationcontact.projectcontactid,
            modificationcontact.priority
           FROM dev.modificationcontact
          ORDER BY modificationcontact.modificationid, modificationcontact.priority) q USING (modificationid)
  GROUP BY modification.modificationid;

ALTER TABLE dev.modificationcontactlist
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.modificationcontactlist TO pts_admin;
GRANT SELECT ON TABLE dev.modificationcontactlist TO pts_read;

