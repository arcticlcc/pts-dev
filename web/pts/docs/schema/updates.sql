-- Schema: report

-- DROP SCHEMA report;

CREATE SCHEMA report
  AUTHORIZATION bradley;

GRANT ALL ON SCHEMA report TO bradley;
GRANT USAGE ON SCHEMA report TO pts_read;

ALTER DATABASE pts SET search_path=pts, cvl, report, public;

-- View: report.alccsteeringcommittee

-- DROP VIEW report.alccsteeringcommittee;

CREATE OR REPLACE VIEW report.alccsteeringcommittee AS
 SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, ccg.groupid AS prigroupid, cg.acronym AS priacronym, cg.name AS prigroupname, p.areacode AS priareacode, p.phnumber AS priphnumber, p.extension AS priextension, p.countryiso AS pricountryiso, e.uri AS priemail
   FROM person
   LEFT JOIN ( SELECT phone.phoneid, phone.contactid, phone.addressid, phone.phonetypeid, phone.countryiso, phone.areacode, phone.phnumber, phone.extension, phone.priority, row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
   LEFT JOIN ( SELECT eaddress.eaddressid, eaddress.contactid, eaddress.eaddresstypeid, eaddress.uri, eaddress.priority, eaddress.comment, row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
      FROM eaddress
     WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
   FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid
   JOIN contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND sc.positionid = 85
  ORDER BY person.lastname;

ALTER TABLE report.alccsteeringcommittee
  OWNER TO bradley;
GRANT ALL ON TABLE report.alccsteeringcommittee TO bradley;
GRANT SELECT ON TABLE report.alccsteeringcommittee TO pts_read;

-- View: report.alccstaff

-- DROP VIEW report.alccstaff;

CREATE OR REPLACE VIEW report.alccstaff AS
 SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, ccg.groupid AS prigroupid, cg.acronym AS priacronym, cg.name AS prigroupname, p.areacode AS priareacode, p.phnumber AS priphnumber, p.extension AS priextension, p.countryiso AS pricountryiso, e.uri AS priemail
   FROM person
   LEFT JOIN ( SELECT phone.phoneid, phone.contactid, phone.addressid, phone.phonetypeid, phone.countryiso, phone.areacode, phone.phnumber, phone.extension, phone.priority, row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
   LEFT JOIN ( SELECT eaddress.eaddressid, eaddress.contactid, eaddress.eaddresstypeid, eaddress.uri, eaddress.priority, eaddress.comment, row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
      FROM eaddress
     WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
   FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid
   JOIN contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42
   JOIN contact ON contact.contactid = person.contactid AND contact.contacttypeid = 5
  ORDER BY person.lastname;

ALTER TABLE report.alccstaff
  OWNER TO bradley;
GRANT ALL ON TABLE report.alccstaff TO bradley;
GRANT SELECT ON TABLE report.alccstaff TO pts_read;

--timestamp for project comments
ALTER TABLE projectcomment
   ALTER COLUMN stamp TYPE timestamp with time zone;
ALTER TABLE projectcomment
   ALTER COLUMN stamp SET DEFAULT now();

-- View: report.shortprojectsummary

-- DROP VIEW report.shortprojectsummary;

CREATE OR REPLACE VIEW report.shortprojectsummary AS
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators, project.shorttitle, project.abstract, project.description
   FROM project
   LEFT JOIN projectcontact pc ON project.projectid = pc.projectid AND pc.roletypeid = 7
   LEFT JOIN ( SELECT person.contactid, ((person.firstname::text || ' '::text) || person.lastname::text) || COALESCE(', '::text || cg.name::text, ''::text) AS fullname
      FROM person
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
              FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid) pi USING (contactid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid;

ALTER TABLE report.shortprojectsummary
  OWNER TO bradley;
GRANT ALL ON TABLE report.shortprojectsummary TO bradley;
GRANT SELECT ON TABLE report.shortprojectsummary TO pts_read;
