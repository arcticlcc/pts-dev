Begin;

---- Schema: dev ----


---- File: 001-metadatafunding.sql ----

SET search_path TO dev, cvl, public;

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

---- Schema: alcc ----


---- File: 001-metadatafunding.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.metadatafunding

-- DROP VIEW alcc.metadatafunding;

CREATE OR REPLACE VIEW alcc.metadatafunding AS
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

---- Schema: walcc ----


---- File: 001-metadatafunding.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.metadatafunding

-- DROP VIEW walcc.metadatafunding;

CREATE OR REPLACE VIEW walcc.metadatafunding AS
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

---- Schema: absi ----


---- File: 001-metadatafunding.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.metadatafunding

-- DROP VIEW absi.metadatafunding;

CREATE OR REPLACE VIEW absi.metadatafunding AS
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

---- Schema: nwb ----


---- File: 001-metadatafunding.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.metadatafunding

-- DROP VIEW nwb.metadatafunding;

CREATE OR REPLACE VIEW nwb.metadatafunding AS
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

---- Schema: sciapp ----


---- File: 001-metadatafunding.sql ----

SET search_path TO sciapp, cvl, public;

-- View: sciapp.metadatafunding

-- DROP VIEW sciapp.metadatafunding;

CREATE OR REPLACE VIEW sciapp.metadatafunding AS
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

