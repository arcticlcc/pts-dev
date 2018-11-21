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
---- File: 002-sbproductmissing.sql ----

SET search_path TO dev, cvl, public;

-- View: dev.sbproductmissing

-- DROP VIEW dev.sbproductmissing;

CREATE OR REPLACE VIEW dev.sbproductmissing AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.sciencebaseid,
    'https://www.sciencebase.gov/catalog/item/'::text || p.sciencebaseid::text AS sblink
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN isoprogresstype USING (isoprogresstypeid)
  WHERE p.exportmetadata AND NOT p.isgroup AND NOT (p.productid IN ( SELECT p_1.productid
           FROM product p_1
             LEFT JOIN onlineresource o USING (productid)
          WHERE p_1.exportmetadata AND NOT p_1.isgroup AND (o.onlinefunctionid = ANY (ARRAY[1, 2, 3, 11, 12])) AND o.uri::text ~~ 'https://www.sciencebase.gov%'::text
          GROUP BY p_1.productid));

ALTER TABLE dev.sbproductmissing
  OWNER TO bradley;
GRANT ALL ON TABLE dev.sbproductmissing TO bradley;
GRANT SELECT ON TABLE dev.sbproductmissing TO pts_read;
GRANT ALL ON TABLE dev.sbproductmissing TO pts_admin;

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
---- File: 002-sbproductmissing.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.sbproductmissing

-- DROP VIEW alcc.sbproductmissing;

CREATE OR REPLACE VIEW alcc.sbproductmissing AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.sciencebaseid,
    'https://www.sciencebase.gov/catalog/item/'::text || p.sciencebaseid::text AS sblink
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN isoprogresstype USING (isoprogresstypeid)
  WHERE p.exportmetadata AND NOT p.isgroup AND NOT (p.productid IN ( SELECT p_1.productid
           FROM product p_1
             LEFT JOIN onlineresource o USING (productid)
          WHERE p_1.exportmetadata AND NOT p_1.isgroup AND (o.onlinefunctionid = ANY (ARRAY[1, 2, 3, 11, 12])) AND o.uri::text ~~ 'https://www.sciencebase.gov%'::text
          GROUP BY p_1.productid));

ALTER TABLE alcc.sbproductmissing
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.sbproductmissing TO bradley;
GRANT SELECT ON TABLE alcc.sbproductmissing TO pts_read;
GRANT ALL ON TABLE alcc.sbproductmissing TO pts_admin;

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
---- File: 002-sbproductmissing.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.sbproductmissing

-- DROP VIEW walcc.sbproductmissing;

CREATE OR REPLACE VIEW walcc.sbproductmissing AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.sciencebaseid,
    'https://www.sciencebase.gov/catalog/item/'::text || p.sciencebaseid::text AS sblink
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN isoprogresstype USING (isoprogresstypeid)
  WHERE p.exportmetadata AND NOT p.isgroup AND NOT (p.productid IN ( SELECT p_1.productid
           FROM product p_1
             LEFT JOIN onlineresource o USING (productid)
          WHERE p_1.exportmetadata AND NOT p_1.isgroup AND (o.onlinefunctionid = ANY (ARRAY[1, 2, 3, 11, 12])) AND o.uri::text ~~ 'https://www.sciencebase.gov%'::text
          GROUP BY p_1.productid));

ALTER TABLE walcc.sbproductmissing
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.sbproductmissing TO bradley;
GRANT SELECT ON TABLE walcc.sbproductmissing TO pts_read;
GRANT ALL ON TABLE walcc.sbproductmissing TO pts_admin;

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
---- File: 002-sbproductmissing.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.sbproductmissing

-- DROP VIEW absi.sbproductmissing;

CREATE OR REPLACE VIEW absi.sbproductmissing AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.sciencebaseid,
    'https://www.sciencebase.gov/catalog/item/'::text || p.sciencebaseid::text AS sblink
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN isoprogresstype USING (isoprogresstypeid)
  WHERE p.exportmetadata AND NOT p.isgroup AND NOT (p.productid IN ( SELECT p_1.productid
           FROM product p_1
             LEFT JOIN onlineresource o USING (productid)
          WHERE p_1.exportmetadata AND NOT p_1.isgroup AND (o.onlinefunctionid = ANY (ARRAY[1, 2, 3, 11, 12])) AND o.uri::text ~~ 'https://www.sciencebase.gov%'::text
          GROUP BY p_1.productid));

ALTER TABLE absi.sbproductmissing
  OWNER TO bradley;
GRANT ALL ON TABLE absi.sbproductmissing TO bradley;
GRANT SELECT ON TABLE absi.sbproductmissing TO pts_read;
GRANT ALL ON TABLE absi.sbproductmissing TO pts_admin;

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
---- File: 002-sbproductmissing.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.sbproductmissing

-- DROP VIEW nwb.sbproductmissing;

CREATE OR REPLACE VIEW nwb.sbproductmissing AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.sciencebaseid,
    'https://www.sciencebase.gov/catalog/item/'::text || p.sciencebaseid::text AS sblink
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN isoprogresstype USING (isoprogresstypeid)
  WHERE p.exportmetadata AND NOT p.isgroup AND NOT (p.productid IN ( SELECT p_1.productid
           FROM product p_1
             LEFT JOIN onlineresource o USING (productid)
          WHERE p_1.exportmetadata AND NOT p_1.isgroup AND (o.onlinefunctionid = ANY (ARRAY[1, 2, 3, 11, 12])) AND o.uri::text ~~ 'https://www.sciencebase.gov%'::text
          GROUP BY p_1.productid));

ALTER TABLE nwb.sbproductmissing
  OWNER TO bradley;
GRANT ALL ON TABLE nwb.sbproductmissing TO bradley;
GRANT SELECT ON TABLE nwb.sbproductmissing TO pts_read;
GRANT ALL ON TABLE nwb.sbproductmissing TO pts_admin;

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
---- File: 002-sbproductmissing.sql ----

SET search_path TO sciapp, cvl, public;

-- View: sciapp.sbproductmissing

-- DROP VIEW sciapp.sbproductmissing;

CREATE OR REPLACE VIEW sciapp.sbproductmissing AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.sciencebaseid,
    'https://www.sciencebase.gov/catalog/item/'::text || p.sciencebaseid::text AS sblink
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN deliverabletype USING (deliverabletypeid)
     JOIN isoprogresstype USING (isoprogresstypeid)
  WHERE p.exportmetadata AND NOT p.isgroup AND NOT (p.productid IN ( SELECT p_1.productid
           FROM product p_1
             LEFT JOIN onlineresource o USING (productid)
          WHERE p_1.exportmetadata AND NOT p_1.isgroup AND (o.onlinefunctionid = ANY (ARRAY[1, 2, 3, 11, 12])) AND o.uri::text ~~ 'https://www.sciencebase.gov%'::text
          GROUP BY p_1.productid));

ALTER TABLE sciapp.sbproductmissing
  OWNER TO bradley;
GRANT ALL ON TABLE sciapp.sbproductmissing TO bradley;
GRANT SELECT ON TABLE sciapp.sbproductmissing TO pts_read;
GRANT ALL ON TABLE sciapp.sbproductmissing TO pts_admin;

