Begin;

---- Schema: dev ----


---- File: 001-productlist.sql ----

SET search_path TO dev, cvl, public;

-- View: dev.productlist

-- DROP VIEW dev.productlist;

CREATE OR REPLACE VIEW dev.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid,
    p.sciencebaseid
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN product pg ON p.productgroupid = pg.productid;

---- Schema: alcc ----


---- File: 001-productlist.sql ----

SET search_path TO alcc, cvl, public;

-- View: alcc.productlist

-- DROP VIEW alcc.productlist;

CREATE OR REPLACE VIEW alcc.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid,
    p.sciencebaseid
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN product pg ON p.productgroupid = pg.productid;

---- Schema: walcc ----


---- File: 001-productlist.sql ----

SET search_path TO walcc, cvl, public;

-- View: walcc.productlist

-- DROP VIEW walcc.productlist;

CREATE OR REPLACE VIEW walcc.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid,
    p.sciencebaseid
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN product pg ON p.productgroupid = pg.productid;

---- Schema: absi ----


---- File: 001-productlist.sql ----

SET search_path TO absi, cvl, public;

-- View: absi.productlist

-- DROP VIEW absi.productlist;

CREATE OR REPLACE VIEW absi.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid,
    p.sciencebaseid
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN product pg ON p.productgroupid = pg.productid;

---- Schema: nwb ----


---- File: 001-productlist.sql ----

SET search_path TO nwb, cvl, public;

-- View: nwb.productlist

-- DROP VIEW nwb.productlist;

CREATE OR REPLACE VIEW nwb.productlist AS
 SELECT p.productid,
    p.projectid,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress,
    p.isgroup,
    p.productgroupid,
    p.uselimitation,
    pg.title AS productgroup,
    p.perioddescription,
    p.maintenancefrequencyid,
    p.sciencebaseid
   FROM product p
     LEFT JOIN project USING (projectid)
     LEFT JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN product pg ON p.productgroupid = pg.productid;

