-- View: dev.metadatafunding

-- DROP VIEW dev.metadatafunding;

CREATE OR REPLACE VIEW dev.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fc.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN contact fc ON fun.contactid = fc.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;

ALTER TABLE dev.metadatafunding
  OWNER TO bradley;
GRANT ALL ON TABLE dev.metadatafunding TO bradley;
GRANT SELECT ON TABLE dev.metadatafunding TO pts_read;
GRANT ALL ON TABLE dev.metadatafunding TO pts_admin;
