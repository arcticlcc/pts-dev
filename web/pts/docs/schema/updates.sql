--version 0.9.2

SET search_path = pts, pg_catalog;

-- View: deliverableall

DROP VIEW deliverableall;

CREATE OR REPLACE VIEW deliverableall AS
 SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverablemod.devinterval, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description, (EXISTS ( SELECT 1
           FROM deliverablemod dm
          WHERE dm.parentdeliverableid = deliverablemod.deliverableid AND dm.parentmodificationid = deliverablemod.modificationid)) AS modified, status.status, status.effectivedate, status.deliverablestatusid
   FROM deliverablemod
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
           FROM deliverablemodstatus
      JOIN deliverablestatus USING (deliverablestatusid)
     ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid
      FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  WHERE deliverablemodstatus.deliverablestatusid = 10
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)
   JOIN deliverable USING (deliverableid);

ALTER TABLE deliverableall
  OWNER TO bradley;
GRANT ALL ON TABLE deliverableall TO bradley;
GRANT SELECT ON TABLE deliverableall TO pts_read;

-- View: deliverablecalendar

DROP VIEW deliverablecalendar;

CREATE OR REPLACE VIEW deliverablecalendar AS
 SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverable.title, deliverable.description, (person.firstname::text || ' '::text) || person.lastname::text AS manager, deliverabletype.type, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, modification.projectid,
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed
   FROM deliverablemod
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
           FROM deliverablemodstatus
      JOIN deliverablestatus USING (deliverablestatusid)
     ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.deliverableid
      FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  WHERE deliverablemodstatus.deliverablestatusid = 10
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)
   JOIN modification USING (modificationid)
   JOIN project USING (projectid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   JOIN deliverable USING (deliverableid)
   JOIN deliverabletype USING (deliverabletypeid)
   JOIN person ON deliverablemod.personid = person.contactid
  WHERE NOT (EXISTS ( SELECT 1
   FROM deliverablemod dm
  WHERE deliverablemod.modificationid = dm.parentmodificationid AND deliverablemod.deliverableid = dm.parentdeliverableid));

ALTER TABLE deliverablecalendar
  OWNER TO bradley;
GRANT ALL ON TABLE deliverablecalendar TO bradley;
GRANT SELECT ON TABLE deliverablecalendar TO pts_read;

-- View: deliverablelist

DROP VIEW deliverablelist;

CREATE OR REPLACE VIEW deliverablelist AS
 SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverablemod.devinterval, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description, modification.projectid
   FROM deliverablemod
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
      JOIN deliverablestatus USING (deliverablestatusid)
     WHERE deliverablemodstatus.deliverablestatusid = 10
     ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)
   JOIN deliverable USING (deliverableid)
   JOIN modification USING (modificationid)
  WHERE NOT (EXISTS ( SELECT 1
   FROM deliverablemod dm
  WHERE deliverablemod.modificationid = dm.parentmodificationid AND deliverablemod.deliverableid = dm.parentdeliverableid));

ALTER TABLE deliverablelist
  OWNER TO bradley;
GRANT ALL ON TABLE deliverablelist TO bradley;
GRANT SELECT ON TABLE deliverablelist TO pts_read;
COMMENT ON VIEW deliverablelist
  IS 'List of all valid, non-modified deliverables';

-- View: task

DROP VIEW task;

CREATE OR REPLACE VIEW task AS
 SELECT deliverablemod.duedate, deliverable.title, efd.effectivedate AS receiveddate, (person.firstname::text || ' '::text) || person.lastname::text AS assignee, deliverable.description, deliverablemod.deliverableid, person.contactid, modification.projectid, deliverablemod.modificationid,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) > 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - deliverablemod.duedate
        END AS dayspastdue,
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed, projectlist.projectcode
   FROM deliverablemod
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
           FROM deliverablemodstatus
      JOIN deliverablestatus USING (deliverablestatusid)
     ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (modificationid, deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid
      FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  WHERE deliverablemodstatus.deliverablestatusid = 10
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (modificationid, deliverableid)
   JOIN deliverable USING (deliverableid)
   JOIN person ON deliverablemod.personid = person.contactid
   JOIN modification USING (modificationid)
   JOIN projectlist USING (projectid)
  WHERE (deliverable.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT (EXISTS ( SELECT 1
   FROM deliverablemod dm
  WHERE deliverablemod.modificationid = dm.parentmodificationid AND deliverablemod.deliverableid = dm.parentdeliverableid))
  ORDER BY deliverablemod.duedate DESC;

ALTER TABLE task
  OWNER TO bradley;
GRANT ALL ON TABLE task TO bradley;
GRANT SELECT ON TABLE task TO pts_read;
COMMENT ON VIEW task
  IS 'Lists all tasks that are not invalid or modified';

-- Function: deliverable_status(integer)

-- DROP FUNCTION deliverable_status(integer);

CREATE OR REPLACE FUNCTION deliverable_status(sid integer)
  RETURNS character varying AS
$BODY$

   SELECT
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status
   FROM deliverable d
   JOIN deliverablemod dm USING (deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) *
   FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)
  WHERE NOT (EXISTS ( SELECT 1
   FROM deliverablemod dp
  WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid)) AND deliverableid = $1
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION deliverable_status(integer)
  OWNER TO bradley;

-- Function: deliverable_statusid(integer)

-- DROP FUNCTION deliverable_statusid(integer);

CREATE OR REPLACE FUNCTION deliverable_statusid(sid integer)
  RETURNS integer AS
$BODY$

   SELECT status.deliverablestatusid
   FROM deliverable d
   JOIN deliverablemod dm USING (deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) *
   FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)
  WHERE NOT (EXISTS ( SELECT 1
   FROM deliverablemod dp
  WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid)) AND deliverableid = $1
$BODY$
  LANGUAGE sql IMMUTABLE
  COST 100;
ALTER FUNCTION deliverable_statusid(integer)
  OWNER TO bradley;

SET search_path = report, pg_catalog;

-- View: report.noticesent

DROP VIEW report.noticesent;

CREATE OR REPLACE VIEW report.noticesent AS
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate, d.title, d.description, notice.code AS lastnotice, deliverablenotice.datesent, projectlist.projectcode, project.shorttitle AS project, (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact, personlist.priemail AS email, (folist.firstname::text || ' '::text) || folist.lastname::text AS fofficer, folist.priemail AS foemail,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue, COALESCE(status.status, 'Not Received'::character varying) AS status, modification.projectid, dm.modificationid, d.deliverableid
   FROM deliverable d
   JOIN ( SELECT deliverablemod.modificationid, deliverablemod.deliverableid, deliverablemod.duedate, deliverablemod.receiveddate, deliverablemod.devinterval, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverablemod.personid
           FROM deliverablemod
          WHERE NOT (EXISTS ( SELECT 1
                   FROM deliverablemod dp
                  WHERE dp.modificationid = dp.parentmodificationid AND dp.deliverableid = dp.parentdeliverableid))) dm USING (deliverableid)
   JOIN modification USING (modificationid)
   JOIN projectlist USING (projectid)
   JOIN project USING (projectid)
   LEFT JOIN ( SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid
   FROM projectcontact
  WHERE projectcontact.roletypeid = ANY (ARRAY[7])) projectcontact USING (projectid)
   LEFT JOIN personlist USING (contactid)
   LEFT JOIN ( SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid
   FROM projectcontact
  WHERE projectcontact.roletypeid = 5
  ORDER BY projectcontact.priority) focontact USING (projectid)
   LEFT JOIN personlist folist ON focontact.contactid = folist.contactid
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
   FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (modificationid, deliverableid)
   LEFT JOIN deliverablenotice USING (deliverableid)
   LEFT JOIN notice USING (noticeid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT COALESCE(status.deliverablestatusid >= 10, false) AND
CASE
    WHEN status.deliverablestatusid >= 10 THEN 0
    WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
    ELSE 'now'::text::date - dm.duedate
END > (-30) AND NOT (EXISTS ( SELECT 1
   FROM deliverablemod d
  WHERE dm.modificationid = d.parentmodificationid AND dm.deliverableid = d.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;

ALTER TABLE report.noticesent
  OWNER TO bradley;
GRANT ALL ON TABLE report.noticesent TO bradley;
GRANT SELECT ON TABLE report.noticesent TO pts_read;

-- View: report.projectcatalog

DROP VIEW report.projectcatalog;

CREATE OR REPLACE VIEW report.projectcatalog AS
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
        ), funds AS (
         SELECT modification.projectid, getfiscalyear(modification.startdate) AS fiscalyear, grouptree.fullname, projectcontact.contactid, sum(funding.amount) AS funds
           FROM modification
      JOIN funding USING (modificationid)
   JOIN projectcontact USING (projectcontactid)
   JOIN grouptree USING (contactid)
  GROUP BY modification.projectid, getfiscalyear(modification.startdate), grouptree.fullname, projectcontact.contactid
        ), cofund AS (
         SELECT projectcontact.projectid, grouptree.fullname, row_number() OVER (PARTITION BY projectcontact.projectid) AS rank
           FROM projectcontact
      JOIN contactgroup USING (contactid)
   JOIN contact USING (contactid)
   JOIN grouptree USING (contactid)
  WHERE projectcontact.roletypeid = 4 AND NOT projectcontact.contactid = 42 AND contact.contacttypeid = 5
  ORDER BY projectcontact.projectid, projectcontact.priority
        ), deltype AS (
         SELECT d.projectid, d.catalog, d.type, row_number() OVER (PARTITION BY d.projectid) AS rank
           FROM ( SELECT DISTINCT modification.projectid, deliverabletype.catalog,
                        CASE
                            WHEN deliverabletype.catalog IS NOT NULL THEN NULL::character varying
                            ELSE deliverabletype.type
                        END AS type
                   FROM deliverablemod
              JOIN deliverable USING (deliverableid)
         JOIN deliverabletype USING (deliverabletypeid)
    JOIN modification USING (modificationid)
   WHERE (NOT deliverablemod.invalid OR NOT (EXISTS ( SELECT 1
            FROM deliverablemod dm
           WHERE deliverablemod.modificationid = dm.parentmodificationid AND deliverablemod.deliverableid = dm.parentdeliverableid))) AND (deliverable.deliverabletypeid <> ALL (ARRAY[4, 6, 7, 13]))
   ORDER BY modification.projectid, deliverabletype.catalog) d
        )
 SELECT DISTINCT replace(contactgroup.name::text, ' Landscape Conservation Cooperative'::text, ''::text) AS lccname, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS id, project.title AS ptitle, project.description, status.status AS pstatus, project.startdate AS pstart, project.enddate AS pend, 'http://arcticlcc.org/projects/'::text || form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym)::text AS purl, COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact, COALESCE(pc.leadorg, pi.leadorg) AS leadorg, ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM projectcontact
      JOIN contactgroup USING (contactid)
   JOIN grouptree USING (contactid)
  WHERE projectcontact.partner AND projectcontact.projectid = project.projectid AND NOT "position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0
  GROUP BY projectcontact.projectid) AS partnerorg, NULL::text AS endusers, fy.fiscalyears, ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE cofund.projectid = project.projectid AND cofund.rank = 1) AS cofundlcc1, ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE cofund.projectid = project.projectid AND cofund.rank = 2) AS cofundlcc2, NULL::text AS scibaseq, ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE funds.projectid = project.projectid AND funds.contactid = 42
          GROUP BY funds.projectid) AS lccfundall, lccfundby.lccfundby, ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE funds.projectid = project.projectid AND NOT funds.contactid = 42
          GROUP BY funds.projectid) AS matchfundall, matchfundby.matchfundby, NULL::text AS matchfundnote, catalogprojectcategory.category1, catalogprojectcategory.category2, catalogprojectcategory.category3, ( SELECT deltype.catalog
           FROM deltype
          WHERE deltype.projectid = project.projectid AND deltype.rank = 1) AS deliver1, ( SELECT deltype.catalog
           FROM deltype
          WHERE deltype.projectid = project.projectid AND deltype.rank = 2) AS deliver2, ( SELECT deltype.catalog
           FROM deltype
          WHERE deltype.projectid = project.projectid AND deltype.rank = 3) AS deliver3, lower(subject.keywords) AS subject, 'arctic'::text || COALESCE(','::text || commongeom.name, ''::text) AS geog, NULL::text AS congdist, (COALESCE(('Additional deliverabletypes: '::text || (( SELECT string_agg(deltype.type::text, ','::text) AS string_agg
           FROM deltype
          WHERE deltype.projectid = project.projectid AND NOT deltype.type::text = 'Other'::text))) || ';'::text, ''::text) || COALESCE(('Additional deliverables: '::text || (( SELECT deltype.catalog::text AS catalog
           FROM deltype
          WHERE deltype.projectid = project.projectid AND deltype.rank = 4))) || ';'::text, ''::text)) ||
        CASE
            WHEN project.number > 1000 THEN 'Internal Project;'::text
            ELSE ''::text
        END AS comments
   FROM project
   JOIN status ON project_status(project.projectid) = status.statusid
   LEFT JOIN ( SELECT DISTINCT pc.projectid, COALESCE(string_agg(((person.firstname::text || ' '::text) || person.lastname::text) || COALESCE(','::text || eaddress.uri::text, ''::text), '; '::text) OVER (PARTITION BY pc.projectid), 'No PI listed'::text) AS principalinvestigators, COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc.projectid), 'No PI listed'::text) AS leadorg
      FROM projectcontact pc
   JOIN person ON person.contactid = pc.contactid AND pc.roletypeid = 7
   LEFT JOIN eaddress ON person.contactid = eaddress.contactid AND eaddress.eaddresstypeid = 1 AND eaddress.priority = 1
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
    FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid
   JOIN grouptree ON cg.contactid = grouptree.contactid) pi USING (projectid)
   LEFT JOIN ( SELECT DISTINCT pc.projectid, COALESCE(string_agg(((person.firstname::text || ' '::text) || person.lastname::text) || COALESCE(','::text || eaddress.uri::text, ''::text), '; '::text) OVER (PARTITION BY pc.projectid), 'No PI listed'::text) AS principalinvestigators, COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc.projectid), 'No PI listed'::text) AS leadorg
   FROM projectcontact pc
   JOIN person ON person.contactid = pc.contactid AND pc.roletypeid = 6
   LEFT JOIN eaddress ON person.contactid = eaddress.contactid AND eaddress.eaddresstypeid = 1 AND eaddress.priority = 1
   LEFT JOIN ( SELECT contactcontactgroup.groupid, contactcontactgroup.contactid, contactcontactgroup.positionid, contactcontactgroup.contactcontactgroupid, contactcontactgroup.priority, row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
   FROM contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
   LEFT JOIN contactgroup cg ON cg.contactid = ccg.groupid
   JOIN grouptree ON cg.contactid = grouptree.contactid) pc USING (projectid)
   JOIN contactgroup ON project.orgid = contactgroup.contactid
   LEFT JOIN ( SELECT mod.projectid, string_agg(getfiscalyear(mod.startdate)::text, ','::text ORDER BY mod.startdate) AS fiscalyears
   FROM ( SELECT DISTINCT ON (modification.projectid, getfiscalyear(modification.startdate)) modification.modificationid, modification.projectid, modification.personid, modification.modtypeid, modification.title, modification.description, modification.modificationcode, modification.effectivedate, modification.startdate, modification.enddate, modification.datecreated, modification.parentmodificationid, modification.shorttitle, funding.fundingid, funding.fundingtypeid, funding.title, funding.amount, funding.projectcontactid, funding.fundingrecipientid
           FROM modification
      JOIN funding USING (modificationid)
     WHERE modification.startdate IS NOT NULL) mod
  GROUP BY mod.projectid) fy ON fy.projectid = project.projectid
   LEFT JOIN ( SELECT funds.projectid, string_agg(((funds.funds::text || ','::text) || funds.fiscalyear) || ',USFWS'::text, '; '::text) AS lccfundby
   FROM funds
  WHERE funds.contactid = 42
  GROUP BY funds.projectid) lccfundby ON lccfundby.projectid = project.projectid
   LEFT JOIN ( SELECT funds.projectid, string_agg((((funds.funds::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname, '; '::text) AS matchfundby
   FROM funds
  WHERE NOT funds.contactid = 42
  GROUP BY funds.projectid) matchfundby ON matchfundby.projectid = project.projectid
   LEFT JOIN ( SELECT projectkeyword.projectid, string_agg(keyword.preflabel::text, ', '::text) AS keywords, string_agg(replace(keyword.preflabel::text, ' '::text, '-'::text), ', '::text) AS joined
   FROM projectkeyword
   JOIN keyword USING (keywordid)
  GROUP BY projectkeyword.projectid) subject ON subject.projectid = project.projectid
   LEFT JOIN ( SELECT string_agg(commonpolygon.name::text, ','::text) AS name, projectpolygon.projectid
   FROM projectpolygon, commonpolygon
  WHERE projectpolygon.the_geom = commonpolygon.the_geom
  GROUP BY projectpolygon.projectid) commongeom ON commongeom.projectid = project.projectid
   LEFT JOIN catalogprojectcategory ON catalogprojectcategory.projectid = project.projectid
  ORDER BY form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym);

ALTER TABLE report.projectcatalog
  OWNER TO bradley;
GRANT ALL ON TABLE report.projectcatalog TO bradley;
GRANT SELECT ON TABLE report.projectcatalog TO pts_read;
