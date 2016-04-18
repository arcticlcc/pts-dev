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
    p.maintenancefrequencyid
   FROM dev.product p
     left JOIN dev.project USING (projectid)
     left JOIN dev.contactgroup ON project.orgid = contactgroup.contactid
     JOIN cvl.deliverabletype USING (deliverabletypeid)
     JOIN cvl.isoprogresstype USING (isoprogresstypeid)
     LEFT JOIN dev.product pg ON p.productgroupid = pg.productid;
