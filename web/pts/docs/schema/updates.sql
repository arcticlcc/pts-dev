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

-- move domain tables to new schema

-- Schema: cvl

-- DROP SCHEMA cvl;

CREATE SCHEMA cvl
  AUTHORIZATION bradley;

GRANT ALL ON SCHEMA cvl TO bradley;
GRANT USAGE ON SCHEMA cvl TO pts_read;

ALTER DATABASE pts SET search_path=pts, cvl, public

ALTER TABLE addresstype SET SCHEMA cvl;
ALTER TABLE contacttype SET SCHEMA cvl;
ALTER TABLE country SET SCHEMA cvl;
ALTER TABLE deliverabletype SET SCHEMA cvl;
ALTER TABLE eaddresstype SET SCHEMA cvl;
ALTER TABLE filetype SET SCHEMA cvl;
ALTER TABLE format SET SCHEMA cvl;
ALTER TABLE fundingtype SET SCHEMA cvl;
ALTER TABLE govunit SET SCHEMA cvl;
ALTER TABLE modcontacttype SET SCHEMA cvl;
ALTER TABLE modtype SET SCHEMA cvl;
ALTER TABLE modtypestatus SET SCHEMA cvl;
ALTER TABLE phonetype SET SCHEMA cvl;
ALTER TABLE postalcode SET SCHEMA cvl;
ALTER TABLE position SET SCHEMA cvl;
ALTER TABLE roletype SET SCHEMA cvl;
ALTER TABLE status SET SCHEMA cvl;
