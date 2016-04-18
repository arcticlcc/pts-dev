ALTER TABLE dev.product
   ALTER COLUMN projectid DROP NOT NULL;

   -- View: dev.productgrouplist

   -- DROP VIEW dev.productgrouplist;

   CREATE OR REPLACE VIEW dev.productgrouplist AS
    SELECT p.productid,
       p.projectid,
       common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
       p.uuid,
       p.title,
       p.isgroup,
       p.productgroupid
      FROM product p
        left JOIN project USING (projectid)
        left JOIN contactgroup ON project.orgid = contactgroup.contactid
        where isgroup;

   ALTER TABLE dev.productgrouplist
     OWNER TO bradley;
   GRANT ALL ON TABLE dev.productgrouplist TO bradley;
   GRANT SELECT ON TABLE dev.productgrouplist TO pts_read;
   GRANT ALL ON TABLE dev.productgrouplist TO pts_admin;
