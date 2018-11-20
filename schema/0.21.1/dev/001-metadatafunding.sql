-- View: dev.metadatafunding

-- DROP VIEW dev.metadatafunding;

CREATE OR REPLACE VIEW dev.metadatafunding AS
 SELECT f.fundingid,
    f.fundingtypeid,
    f.title,
    f.amount,
    rc.uuid AS recipientid,
    fs.uuid AS sourceid,
    ft.type,
    m.modificationcode,
    m.startdate,
    m.enddate,
    m.projectid,
    fs.contacttypeid AS sourcetypeid,
    fc.contacttype AS sourcetype,
    fc.uuid AS adminid
   FROM funding f
     JOIN modification m USING (modificationid)
     JOIN fundingtype ft USING (fundingtypeid)
     LEFT JOIN projectcontact fun ON f.projectcontactid = fun.projectcontactid
     JOIN metadatacontact fc ON fun.contactid = fc."contactId"
     LEFT JOIN contact fs ON fc.allids[1] = fs.contactid
     LEFT JOIN projectcontact rec ON rec.projectcontactid = f.fundingrecipientid
     JOIN contact rc ON rec.contactid = rc.contactid;
