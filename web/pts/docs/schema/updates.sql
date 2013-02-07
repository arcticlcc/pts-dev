--version 0.9

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

--insert canceled
INSERT INTO deliverablestatus VALUES (70, 'Canceled', 'Canceled', 'Deliverable or Task has been canceled or superseded by a modification.', NULL);

/* Fixed manually assigned overdue bug. This occurred when a deliverable was assigned the overdue status and
 * the duedate was subsequently modified to a date after the overdue effectivedate.
 * The database will now consider the duedate before applying the overdue status.
 *
 * The database will now use all assigned status records when determining the overall status for a deliverable.
 * Previously, only the statuses assigned under the current agreement were used.
 *
 * Deprecated deliverable.invalid
 */

COMMENT ON COLUMN deliverablemod.invalid IS 'DEPRECATED, Indicates whether deliverable is valid';

CREATE OR REPLACE VIEW deliverableall AS
	SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description, (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified, status.status, status.effectivedate, status.deliverablestatusid FROM (((deliverablemod LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)) LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) WHERE (deliverablemodstatus.deliverablestatusid = 10) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)) JOIN deliverable USING (deliverableid));

CREATE OR REPLACE VIEW deliverablecalendar AS
	SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverable.title, deliverable.description, (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS manager, deliverabletype.type, form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode, modification.projectid, CASE WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - deliverablemod.duedate) < 0)))) THEN status.status ELSE 'Not Received'::character varying END AS status, status.effectivedate, COALESCE((status.deliverablestatusid >= 40), false) AS completed FROM ((((((((deliverablemod LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)) LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.deliverableid FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) WHERE (deliverablemodstatus.deliverablestatusid = 10) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)) JOIN modification USING (modificationid)) JOIN project USING (projectid)) JOIN contactgroup ON ((project.orgid = contactgroup.contactid))) JOIN deliverable USING (deliverableid)) JOIN cvl.deliverabletype USING (deliverabletypeid)) JOIN person ON ((deliverablemod.personid = person.contactid))) WHERE ((NOT deliverablemod.invalid) AND (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))));

CREATE OR REPLACE VIEW deliverabledue AS
	SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate, efd.effectivedate AS receiveddate, d.title, d.description, projectlist.projectcode, project.shorttitle AS project, (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact, personlist.priemail AS email, CASE WHEN (status.deliverablestatusid >= 10) THEN 0 WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1) ELSE (('now'::text)::date - dm.duedate) END AS dayspastdue, modification.projectid, dm.modificationid, d.deliverableid, CASE WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status ELSE 'Not Received'::character varying END AS status, status.effectivedate, COALESCE((status.deliverablestatusid >= 40), false) AS completed FROM ((((((((deliverable d JOIN deliverablemod dm USING (deliverableid)) JOIN modification USING (modificationid)) JOIN projectlist USING (projectid)) JOIN project USING (projectid)) LEFT JOIN (SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid FROM projectcontact WHERE (projectcontact.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid)) LEFT JOIN personlist USING (contactid)) LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)) LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.deliverableid FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)) WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT (EXISTS (SELECT 1 FROM deliverablemod dp WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))))) ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

CREATE OR REPLACE VIEW deliverablelist AS
	SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description, modification.projectid FROM (((deliverablemod LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.deliverableid FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) WHERE (deliverablemodstatus.deliverablestatusid = 10) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)) JOIN deliverable USING (deliverableid)) JOIN modification USING (modificationid)) WHERE ((NOT deliverablemod.invalid) OR (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))));

COMMENT ON VIEW deliverablelist IS 'List of all valid, non-modified deliverables';

CREATE OR REPLACE VIEW task AS
	SELECT deliverablemod.duedate, deliverable.title, efd.effectivedate AS receiveddate, (((person.firstname)::text || ' '::text) || (person.lastname)::text) AS assignee, deliverable.description, deliverablemod.deliverableid, person.contactid, modification.projectid, deliverablemod.modificationid, CASE WHEN (status.deliverablestatusid >= 10) THEN 0 WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - deliverablemod.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1) ELSE (('now'::text)::date - deliverablemod.duedate) END AS dayspastdue, CASE WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - deliverablemod.duedate) < 0)))) THEN status.status ELSE 'Not Received'::character varying END AS status, status.effectivedate, COALESCE((status.deliverablestatusid >= 40), false) AS completed, projectlist.projectcode FROM ((((((deliverablemod LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (modificationid, deliverableid)) LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) WHERE (deliverablemodstatus.deliverablestatusid = 10) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (modificationid, deliverableid)) JOIN deliverable USING (deliverableid)) JOIN person ON ((deliverablemod.personid = person.contactid))) JOIN modification USING (modificationid)) JOIN projectlist USING (projectid)) WHERE ((deliverable.deliverabletypeid = ANY (ARRAY[4, 7])) AND ((NOT deliverablemod.invalid) AND (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))))) ORDER BY deliverablemod.duedate DESC;

COMMENT ON VIEW task IS 'Lists all tasks that are not invalid or modified';

CREATE OR REPLACE VIEW report.noticesent AS
	SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate, d.title, d.description, notice.code AS lastnotice, deliverablenotice.datesent, projectlist.projectcode, project.shorttitle AS project, (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact, personlist.priemail AS email, (((folist.firstname)::text || ' '::text) || (folist.lastname)::text) AS fofficer, folist.priemail AS foemail, CASE WHEN (status.deliverablestatusid >= 10) THEN 0 WHEN (status.deliverablestatusid = 0) THEN ((('now'::text)::date - status.effectivedate) + 1) ELSE (('now'::text)::date - dm.duedate) END AS dayspastdue, COALESCE(status.status, 'Not Received'::character varying) AS status, modification.projectid, dm.modificationid, d.deliverableid FROM (((((((((((pts.deliverable d JOIN (SELECT deliverablemod.modificationid, deliverablemod.deliverableid, deliverablemod.duedate, deliverablemod.receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverablemod.personid FROM pts.deliverablemod WHERE ((NOT deliverablemod.invalid) OR (NOT (EXISTS (SELECT 1 FROM pts.deliverablemod dp WHERE ((dp.modificationid = dp.parentmodificationid) AND (dp.deliverableid = dp.parentdeliverableid))))))) dm USING (deliverableid)) JOIN pts.modification USING (modificationid)) JOIN pts.projectlist USING (projectid)) JOIN pts.project USING (projectid)) LEFT JOIN (SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid FROM pts.projectcontact WHERE (projectcontact.roletypeid = ANY (ARRAY[7]))) projectcontact USING (projectid)) LEFT JOIN pts.personlist USING (contactid)) LEFT JOIN (SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid FROM pts.projectcontact WHERE (projectcontact.roletypeid = 5) ORDER BY projectcontact.priority) focontact USING (projectid)) LEFT JOIN pts.personlist folist ON ((focontact.contactid = folist.contactid))) LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment FROM (pts.deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (modificationid, deliverableid)) LEFT JOIN pts.deliverablenotice USING (deliverableid)) LEFT JOIN cvl.notice USING (noticeid)) WHERE ((((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT COALESCE((status.deliverablestatusid >= 10), false))) AND (CASE WHEN (status.deliverablestatusid >= 10) THEN 0 WHEN (status.deliverablestatusid = 0) THEN ((('now'::text)::date - status.effectivedate) + 1) ELSE (('now'::text)::date - dm.duedate) END > (-30))) AND (NOT (EXISTS (SELECT 1 FROM pts.deliverablemod d WHERE ((dm.modificationid = d.parentmodificationid) AND (dm.deliverableid = d.parentdeliverableid)))))) ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;

--update auto-invalidated deliverablemod tuples, set to false
--make sure to investigate for any remaining invalid deliverables
UPDATE deliverablemod d
SET invalid = false
WHERE d.invalid AND
 EXISTS ( SELECT 1
    FROM deliverablemod dm
    WHERE d.modificationid = dm.parentmodificationid AND d.deliverableid = dm.parentdeliverableid
);

--add leveraged to project list
CREATE OR REPLACE VIEW projectlist AS
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated, COALESCE(invoice.amount, 0.00) AS invoiced, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00) AS difference, project.shorttitle, status.status, project.exportmetadata
,COALESCE(leveraged, 0.00) as leveraged  FROM project

   JOIN contactgroup ON project.orgid = contactgroup.contactid
   JOIN status ON project_status(project.projectid) = status.statusid
   LEFT JOIN modification USING (projectid)
   LEFT JOIN funding ON funding.modificationid = modification.modificationid AND funding.fundingtypeid = 1
   LEFT JOIN ( SELECT modification.projectid, sum(invoice.amount) AS amount
   FROM invoice
   JOIN funding USING (fundingid)
   JOIN modification USING (modificationid)
  WHERE funding.fundingtypeid = 1
  GROUP BY modification.projectid) invoice USING (projectid)
LEFT JOIN (SELECT DISTINCT projectid, sum(amount) OVER (PARTITION BY projectid) AS leveraged FROM funding
JOIN modification USING(modificationid)
WHERE NOT fundingtypeid = 1) leveraged USING(projectid);

-- View: report.projectfunding

-- DROP VIEW report.projectfunding;

CREATE OR REPLACE VIEW report.projectfunding AS
 SELECT DISTINCT form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.fiscalyear, project.number, project.title, project.shorttitle, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated, COALESCE(invoice.amount, 0.00) AS invoiced, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00) AS difference, COALESCE(leveraged.leveraged, 0.00) AS leveraged, COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS total, status.status
   FROM project
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   JOIN status ON project_status(project.projectid) = status.statusid
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
  ORDER BY project.fiscalyear, project.number;

ALTER TABLE report.projectfunding
  OWNER TO bradley;
GRANT ALL ON TABLE report.projectfunding TO bradley;
GRANT SELECT ON TABLE report.projectfunding TO pts_read;
GRANT SELECT ON TABLE report.projectfunding TO pts_write;

-- View: report.projectkeywords

-- DROP VIEW report.projectkeywords;

CREATE OR REPLACE VIEW report.projectkeywords AS
 SELECT form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.shorttitle, kw.keywords, kw.joined
   FROM project
   JOIN ( SELECT projectkeyword.projectid, string_agg(keyword.preflabel::text, ', '::text) AS keywords, string_agg(replace(keyword.preflabel::text, ' '::text, '-'::text), ', '::text) AS joined
           FROM projectkeyword
      JOIN keyword USING (keywordid)
     GROUP BY projectkeyword.projectid) kw USING (projectid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   ORDER BY fiscalyear, number;

ALTER TABLE report.projectkeywords
  OWNER TO bradley;
GRANT ALL ON TABLE report.projectkeywords TO bradley;
GRANT SELECT ON TABLE report.projectkeywords TO pts_read;

-- View: report.projectagreementnumbers

-- DROP VIEW report.projectagreementnumbers;

CREATE OR REPLACE VIEW report.projectagreementnumbers AS
 SELECT form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.shorttitle, modification.modificationcode AS agreementnumber, modification.title AS agreementtitle
   FROM project
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   JOIN modification USING (projectid)
  WHERE modification.modificationcode IS NOT NULL AND (modification.modtypeid <> ALL (ARRAY[4, 9, 10]))
  ORDER BY project.fiscalyear, project.number;

ALTER TABLE report.projectagreementnumbers
  OWNER TO bradley;
GRANT ALL ON TABLE report.projectagreementnumbers TO bradley;
GRANT SELECT ON TABLE report.projectagreementnumbers TO pts_read;

-- add project status
-- View: report.shortprojectsummary

-- DROP VIEW report.shortprojectsummary;

CREATE OR REPLACE VIEW report.shortprojectsummary AS
 SELECT DISTINCT project.projectid, project.orgid, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators, project.shorttitle, project.abstract, project.description, status.status
   FROM project
   JOIN status ON project_status(project.projectid) = status.statusid
   LEFT JOIN projectcontact pc ON project.projectid = pc.projectid AND pc.roletypeid = 7
   LEFT JOIN ( SELECT person.contactid, ((person.firstname::text || ' '::text) || person.lastname::text) || COALESCE(', '::text || cg.name::text, ''::text) AS fullname
   FROM person
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid) pi USING (contactid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid
  ORDER BY project.fiscalyear, project.number;

--support for contact group tree queries
-- View: contactgrouplist

-- DROP VIEW contactgrouplist;

CREATE OR REPLACE VIEW contactgrouplist AS
 WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid, contactgroup.organization, contactgroup.name, contactgroup.acronym, contactcontactgroup.groupid, contactgroup.name::text AS fullname, NULL::text AS parentname, ARRAY[contactgroup.contactid] AS contactids
                   FROM contactgroup
              LEFT JOIN contactcontactgroup USING (contactid)
             WHERE contactcontactgroup.groupid IS NULL
        UNION ALL
                 SELECT ccg.contactid, cg.organization, cg.name, cg.acronym, gt.contactid, (gt.fullname || ' -> '::text) || cg.name::text AS full_name, gt.name, array_append(gt.contactids, cg.contactid) AS array_append
                   FROM contactgroup cg
              JOIN contactcontactgroup ccg USING (contactid)
         JOIN grouptree gt ON ccg.groupid = gt.contactid
        )
 SELECT grouptree.contactid, grouptree.groupid AS parentgroupid, grouptree.organization, grouptree.name, grouptree.acronym, grouptree.fullname, grouptree.parentname, grouptree.contactids
   FROM grouptree;

ALTER TABLE contactgrouplist
  OWNER TO bradley;
GRANT ALL ON TABLE contactgrouplist TO bradley;
GRANT SELECT ON TABLE contactgrouplist TO pts_read;

-- View: projectcontactfull

-- DROP VIEW projectcontactfull;

CREATE OR REPLACE VIEW projectcontactfull AS
 SELECT pc.projectcontactid, pc.projectid, pc.contactid, pc.roletypeid, pc.priority, pc.contactprojectcode, pc.partner, pc.name, roletype.code AS role, pc.type, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, project.shorttitle, pc.contactids
   FROM (         SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, pg_catalog.concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name, 'person'::text AS type, ARRAY[person.contactid] AS contactids
                   FROM projectcontact
              JOIN person USING (contactid)
        UNION
                 SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, contactgrouplist.fullname, 'group'::text AS type, contactgrouplist.contactids
                   FROM projectcontact
              JOIN contactgrouplist USING (contactid)) pc
   JOIN roletype USING (roletypeid)
   JOIN project USING (projectid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid
  ORDER BY pc.priority;

ALTER TABLE projectcontactfull
  OWNER TO bradley;
GRANT ALL ON TABLE projectcontactfull TO bradley;
GRANT SELECT ON TABLE projectcontactfull TO pts_read;

-- View: grouppersonfull

-- DROP VIEW grouppersonfull;

CREATE OR REPLACE VIEW grouppersonfull AS
 WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid AS groupid, contactgroup.name::text AS fullname, contactgroup.acronym, contactgroup.name, ARRAY[contactgroup.contactid] AS groupids
                   FROM contactgroup
              LEFT JOIN contactcontactgroup USING (contactid)
             WHERE contactcontactgroup.groupid IS NULL
        UNION ALL
                 SELECT ccg.contactid, (gt.fullname || ' -> '::text) || cg.name::text AS full_name, cg.acronym, cg.name, array_append(gt.groupids, cg.contactid) AS array_append
                   FROM contactgroup cg
              JOIN contactcontactgroup ccg USING (contactid)
         JOIN grouptree gt ON ccg.groupid = gt.groupid
        )
 SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, grouptree.groupid, grouptree.fullname AS groupfullname, grouptree.acronym, grouptree.name AS groupname, "position".code AS "position", contactcontactgroup.positionid, grouptree.groupids
   FROM grouptree
   JOIN contactcontactgroup USING (groupid)
   JOIN "position" USING (positionid)
   JOIN person ON person.contactid = contactcontactgroup.contactid;

ALTER TABLE grouppersonfull
  OWNER TO bradley;
GRANT ALL ON TABLE grouppersonfull TO bradley;
GRANT SELECT ON TABLE grouppersonfull TO pts_read;
