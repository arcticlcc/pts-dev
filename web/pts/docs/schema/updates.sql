--version 0.9.1

-- View: report.longprojectsummary

-- DROP VIEW report.longprojectsummary;

CREATE OR REPLACE VIEW report.longprojectsummary AS
 SELECT DISTINCT project.projectid, project.orgid, project.projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators, project.shorttitle, project.abstract, project.description, project.status, project.allocated, project.invoiced, project.difference, project.leveraged, project.total
   FROM ( SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, project.shorttitle, project.abstract, project.description, status.status, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated, COALESCE(invoice.amount, 0.00) AS invoiced, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00) AS difference, COALESCE(leveraged.leveraged, 0.00) AS leveraged, COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS total, pc.contactid
           FROM project
      LEFT JOIN modification USING (projectid)
   LEFT JOIN funding ON funding.modificationid = modification.modificationid AND funding.fundingtypeid = 1
   LEFT JOIN ( SELECT modification.projectid, sum(invoice.amount) AS amount
         FROM invoice
    JOIN funding USING (fundingid)
   JOIN modification USING (modificationid)
  WHERE funding.fundingtypeid = 1
  GROUP BY modification.projectid) invoice USING (projectid)
   LEFT JOIN ( SELECT DISTINCT modification.projectid, sum(funding.amount) OVER (PARTITION BY modification.projectid) AS leveraged
    FROM funding
   JOIN modification USING (modificationid)
  WHERE NOT funding.fundingtypeid = 1) leveraged USING (projectid)
   JOIN status ON project_status(project.projectid) = status.statusid
   LEFT JOIN projectcontact pc ON project.projectid = pc.projectid AND pc.roletypeid = 7
   JOIN contactgroup ON project.orgid = contactgroup.contactid) project
   LEFT JOIN ( WITH RECURSIVE grouptree AS (
                         SELECT contactgroup.contactid, contactgroup.organization, contactgroup.name, contactgroup.acronym, contactcontactgroup.groupid, contactgroup.name::text AS fullname, NULL::text AS parentname, ARRAY[contactgroup.contactid] AS contactids
                           FROM contactgroup
                      LEFT JOIN contactcontactgroup USING (contactid)
                     WHERE contactcontactgroup.groupid IS NULL
                UNION ALL
                         SELECT ccg.contactid, cg.organization, cg.name, cg.acronym, gt.contactid, (gt.acronym::text || ' -> '::text) || cg.name::text AS full_name, gt.name, array_append(gt.contactids, cg.contactid) AS array_append
                           FROM contactgroup cg
                      JOIN contactcontactgroup ccg USING (contactid)
                 JOIN grouptree gt ON ccg.groupid = gt.contactid
                )
         SELECT person.contactid, ((person.firstname::text || ' '::text) || person.lastname::text) || COALESCE(', '::text || cg.fullname, ''::text) AS fullname
           FROM person
      LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN grouptree cg ON cg.contactid = ccg.groupid) pi USING (contactid)
  ORDER BY project.fiscalyear, project.number;

ALTER TABLE report.longprojectsummary
  OWNER TO bradley;
GRANT ALL ON TABLE report.longprojectsummary TO bradley;
GRANT SELECT ON TABLE report.longprojectsummary TO pts_read;
