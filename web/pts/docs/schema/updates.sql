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

﻿-- Table: report.catalogprojectcategory

-- DROP TABLE report.catalogprojectcategory;

CREATE TABLE report.catalogprojectcategory
(
  projectcode character varying,
  category1 character varying,
  category2 character varying,
  category3 character varying,
  projectid integer NOT NULL,
  CONSTRAINT catalogprojectcategory_pkey PRIMARY KEY (projectid)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE report.catalogprojectcategory
  OWNER TO bradley;
COMMENT ON TABLE report.catalogprojectcategory
  IS 'Project Categories for the Simple National Project Catalog';

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.6
-- Dumped by pg_dump version 9.1.6
-- Started on 2013-04-23 08:31:06 AKDT

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = report, pg_catalog;

--
-- TOC entry 3278 (class 0 OID 93173)
-- Dependencies: 326 3279
-- Data for Name: catalogprojectcategory; Type: TABLE DATA; Schema: report; Owner: bradley
--

INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-22', 'Monitoring', 'Traditional Ecological Knowledge', NULL, 82);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-02', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 60);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-08', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 66);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-15', 'Population & Habitat Evaluation/Projection', NULL, NULL, 77);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-16', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 78);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-18', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 79);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-04', 'Data Acquisition and Development', 'Conservation Planning', NULL, 87);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-08', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 99);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-05', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 50);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-03', 'Data Acquisition and Development', 'Data Management and Integration', 'Informing Conservation Delivery', 47);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-10', 'Monitoring', 'Population & Habitat Evaluation/Projection', NULL, 73);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-03', 'Conservation Planning', NULL, NULL, 86);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-1001', 'Data Management and Integration', NULL, NULL, 108);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-08', 'Monitoring', NULL, NULL, 53);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-12', 'Monitoring', NULL, NULL, 57);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-06', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 51);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-04', 'Data Management and Integration', 'Decision Support', NULL, 49);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-01', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', 'Conservation Planning', 45);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-07', 'Monitoring', 'Socio-economics/Ecosystem Services', NULL, 65);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-06', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 43);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-10', 'Data Acquisition and Development', 'Informing Conservation Delivery', 'Data Management and Integration', 55);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-12', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 104);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-15', 'Monitoring', NULL, NULL, 106);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-05', 'Data Acquisition and Development', NULL, NULL, 101);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-09', 'Population & Habitat Evaluation/Projection', NULL, NULL, 54);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-11', 'Population & Habitat Evaluation/Projection', 'Conservation Planning', 'Vulnerability Assessment', 56);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-07', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 44);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-13', 'Monitoring', NULL, NULL, 58);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-21', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 81);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-09', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 103);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-11', 'Vulnerability Assessment', 'Conservation Planning', NULL, 74);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-02', 'Population & Habitat Evaluation/Projection', 'Conservation Planning', NULL, 46);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-14', 'Data Acquisition and Development', NULL, NULL, 76);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2010-07', 'Monitoring', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', 52);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-19', 'Data Management and Integration', NULL, NULL, 80);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-10', 'Data Acquisition and Development', 'Data Management and Integration', NULL, 100);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-05', 'Monitoring', NULL, NULL, 63);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-01', 'Informing Conservation Delivery', 'Data Acquisition and Development', NULL, 59);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-11', 'Data Acquisition and Development', NULL, NULL, 88);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-13', 'Monitoring', NULL, NULL, 105);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-03', 'Population & Habitat Evaluation/Projection', 'Vulnerability Assessment', NULL, 61);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-09', 'Data Acquisition and Development', NULL, NULL, 72);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-13', 'Conservation Planning', NULL, NULL, 75);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-02', 'Data Acquisition and Development', 'Population & Habitat Evaluation/Projection', NULL, 85);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2012-01', 'Data Acquisition and Development', 'Conservation Planning', NULL, 84);
INSERT INTO catalogprojectcategory (projectcode, category1, category2, category3, projectid) VALUES ('ALCC2011-06', 'Data Acquisition and Development', 'Data Management and Integration', 'Conservation Planning', 64);


-- Completed on 2013-04-23 08:31:06 AKDT

--
-- PostgreSQL database dump complete

-- View: report.projectcatalog

-- DROP VIEW report.projectcatalog;

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
