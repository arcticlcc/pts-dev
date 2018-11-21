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
