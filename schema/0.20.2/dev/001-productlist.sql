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
