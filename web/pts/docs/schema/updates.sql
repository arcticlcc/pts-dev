-- Foreign Key: contactcostcode_costcode_fk

ALTER TABLE costcode DROP CONSTRAINT contactcostcode_costcode_fk;

-- View: projectlist
CREATE OR REPLACE VIEW projectlist AS
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(sum(funding.amount), 0::numeric) AS allocated, COALESCE(sum(invoice.amount), 0::numeric) AS invoiced, COALESCE(sum(funding.amount), 0::numeric) - COALESCE(sum(invoice.amount), 0::numeric) AS difference
   FROM project
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   LEFT JOIN modification USING (projectid)
   LEFT JOIN funding ON funding.modificationid = modification.modificationid and fundingtypeid = 1
   LEFT JOIN invoice USING (fundingid)
  GROUP BY project.projectid, contactgroup.acronym;
