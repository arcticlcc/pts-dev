--version 0.9.1

CREATE OR REPLACE VIEW report.shortprojectsummary AS
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear,
 project.number, project.startdate, project.enddate, project.uuid, COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators, project.shorttitle, project.abstract, project.description
,status   FROM project
   LEFT JOIN projectcontact pc ON project.projectid = pc.projectid AND pc.roletypeid = 7
   LEFT JOIN ( SELECT person.contactid, ((person.firstname::text || ' '::text) || person.lastname::text) || COALESCE(', '::text || cg.name::text, ''::text) AS fullname
      FROM person
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
              FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid) pi USING (contactid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   JOIN status ON project_status(project.projectid) = status.statusid;
