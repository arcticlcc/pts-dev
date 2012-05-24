-- Foreign Key: contactcostcode_costcode_fk

ALTER TABLE costcode DROP CONSTRAINT contactcostcode_costcode_fk;

-- View: projectlist

CREATE OR REPLACE VIEW projectlist AS 
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
  project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid,
   COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
   COALESCE(invoice.amount, 0.00) AS invoiced,
   COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00) AS difference
   FROM project
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   LEFT JOIN modification USING (projectid)
   LEFT JOIN funding ON funding.modificationid = modification.modificationid AND funding.fundingtypeid = 1
   LEFT JOIN ( SELECT modification.projectid, sum(invoice.amount) AS amount
   FROM invoice
   JOIN funding USING (fundingid)
   JOIN modification USING (modificationid)
  WHERE funding.fundingtypeid = 1
  GROUP BY modification.projectid) invoice USING (projectid);  
