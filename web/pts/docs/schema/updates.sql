-- Extension: tablefunc

-- DROP EXTENSION tablefunc;

CREATE EXTENSION tablefunc
   SCHEMA pts
   VERSION "1.0"

--version 0.11.0

-- Sequence: cvl.moddocstatustype_moddocstatustypeid_seq

-- DROP SEQUENCE cvl.moddocstatustype_moddocstatustypeid_seq;

CREATE SEQUENCE cvl.moddocstatustype_moddocstatustypeid_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 3
  CACHE 1;
ALTER TABLE cvl.moddocstatustype_moddocstatustypeid_seq
  OWNER TO bradley;

-- Sequence: cvl.moddoctype_moddoctypeid_seq

-- DROP SEQUENCE cvl.moddoctype_moddoctypeid_seq;

CREATE SEQUENCE cvl.moddoctype_moddoctypeid_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 19
  CACHE 1;
ALTER TABLE cvl.moddoctype_moddoctypeid_seq
  OWNER TO bradley;


-- Table: cvl.moddocstatustype

-- DROP TABLE cvl.moddocstatustype;

CREATE TABLE cvl.moddocstatustype
(
  moddocstatustypeid integer NOT NULL DEFAULT nextval('moddocstatustype_moddocstatustypeid_seq'::regclass), -- PK for MODDOCSTATUSTYPE
  status character varying NOT NULL,
  code character varying NOT NULL,
  description character varying NOT NULL,
  weight integer, -- Indicates relative priority of status
  CONSTRAINT moddocstatustype_pk PRIMARY KEY (moddocstatustypeid )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.moddocstatustype
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.moddocstatustype TO bradley;
GRANT SELECT ON TABLE cvl.moddocstatustype TO pts_read;
COMMENT ON TABLE cvl.moddocstatustype
  IS 'List of document statuses';
COMMENT ON COLUMN cvl.moddocstatustype.moddocstatustypeid IS 'PK for MODDOCSTATUSTYPE';
COMMENT ON COLUMN cvl.moddocstatustype.weight IS 'Indicates relative priority of status';

-- Table: cvl.moddoctype

-- DROP TABLE cvl.moddoctype;

CREATE TABLE cvl.moddoctype
(
  moddoctypeid integer NOT NULL DEFAULT nextval('moddoctype_moddoctypeid_seq'::regclass), -- PK for MODDOCTYPE
  type character varying NOT NULL, -- Full name of document.
  code character varying NOT NULL,
  description character varying NOT NULL,
  CONSTRAINT moddoctype_pkey PRIMARY KEY (moddoctypeid )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.moddoctype
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.moddoctype TO bradley;
GRANT SELECT ON TABLE cvl.moddoctype TO pts_read;
COMMENT ON TABLE cvl.moddoctype
  IS 'Defines possible document types required for modification(agreement) contracting.';
COMMENT ON COLUMN cvl.moddoctype.moddoctypeid IS 'PK for MODDOCTYPE';
COMMENT ON COLUMN cvl.moddoctype.type IS 'Full name of document.';

-- Table: cvl.modtypemoddoctype

-- DROP TABLE cvl.modtypemoddoctype;

CREATE TABLE cvl.modtypemoddoctype
(
  modtypeid integer NOT NULL,
  moddoctypeid integer NOT NULL, -- PK for MODDOCTYPE
  inactive boolean NOT NULL DEFAULT false, -- Indicates whether the modification/document type combination is currently applicable.
  CONSTRAINT modtypemoddoctype_pk PRIMARY KEY (modtypeid , moddoctypeid ),
  CONSTRAINT moddoctype_modtypemoddoctype_fk FOREIGN KEY (moddoctypeid)
      REFERENCES cvl.moddoctype (moddoctypeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT modtype_modtypemoddoctype_fk FOREIGN KEY (modtypeid)
      REFERENCES cvl.modtype (modtypeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.modtypemoddoctype
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.modtypemoddoctype TO bradley;
GRANT SELECT ON TABLE cvl.modtypemoddoctype TO pts_read;
COMMENT ON TABLE cvl.modtypemoddoctype
  IS 'Defines which contrcting documents are applicable for each type of modification';
COMMENT ON COLUMN cvl.modtypemoddoctype.moddoctypeid IS 'PK for MODDOCTYPE';
COMMENT ON COLUMN cvl.modtypemoddoctype.inactive IS 'Indicates whether the modification/document type combination is currently applicable.';

-- Table: moddocstatus

-- DROP TABLE moddocstatus;

CREATE TABLE moddocstatus
(
  moddocstatusid serial NOT NULL, -- PK for MODDOCSTATUS
  modificationid integer, -- PK for MODIFICATION
  moddoctypeid integer, -- PK for MODDOCTYPE
  moddocstatustypeid integer NOT NULL, -- FK for MODDOCSTATUSTYPE
  contactid integer NOT NULL, -- PK for PERSON
  comment character varying NOT NULL,
  effectivedate date NOT NULL, -- Date status became effective.
  CONSTRAINT moddocstatus_pk PRIMARY KEY (moddocstatusid ),
  CONSTRAINT moddocstatustype_moddocstatus_fk FOREIGN KEY (moddocstatustypeid)
      REFERENCES cvl.moddocstatustype (moddocstatustypeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT moddoctype_moddocstatus_fk FOREIGN KEY (moddoctypeid)
      REFERENCES cvl.moddoctype (moddoctypeid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT modification_moddocstatus_fk FOREIGN KEY (modificationid)
      REFERENCES modification (modificationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT person_moddocstatus_fk FOREIGN KEY (contactid)
      REFERENCES person (contactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE moddocstatus
  OWNER TO bradley;
GRANT ALL ON TABLE moddocstatus TO bradley;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE moddocstatus TO pts_write;
GRANT SELECT ON TABLE moddocstatus TO pts_read;
COMMENT ON TABLE moddocstatus
  IS 'History of processing status for a modification document';
COMMENT ON COLUMN moddocstatus.moddocstatusid IS 'PK for MODDOCSTATUS';
COMMENT ON COLUMN moddocstatus.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN moddocstatus.moddoctypeid IS 'PK for MODDOCTYPE';
COMMENT ON COLUMN moddocstatus.moddocstatustypeid IS 'FK for MODDOCSTATUSTYPE';
COMMENT ON COLUMN moddocstatus.contactid IS 'PK for PERSON';
COMMENT ON COLUMN moddocstatus.effectivedate IS 'Date status became effective.';

-- View: moddocstatuslist

-- DROP VIEW moddocstatuslist;

CREATE OR REPLACE VIEW moddocstatuslist AS
 SELECT moddocstatus.moddocstatustypeid, moddocstatus.moddocstatusid, moddocstatus.modificationid, moddocstatus.moddoctypeid, moddocstatus.contactid, moddocstatus.comment, moddocstatus.effectivedate, moddocstatustype.status, moddocstatustype.code, moddocstatustype.description, moddocstatustype.weight
   FROM moddocstatus
   JOIN moddocstatustype USING (moddocstatustypeid)
  ORDER BY moddocstatus.modificationid, moddocstatus.moddoctypeid, moddocstatus.effectivedate DESC, moddocstatustype.weight DESC;

ALTER TABLE moddocstatuslist
  OWNER TO bradley;
GRANT ALL ON TABLE moddocstatuslist TO bradley;
GRANT SELECT ON TABLE moddocstatuslist TO pts_read;

-- View: report.allmoddocstatus

-- DROP VIEW report.allmoddocstatus;

CREATE OR REPLACE VIEW report.allmoddocstatus AS
 SELECT q.modificationid, q.projectid, q.modificationcode, p.shorttitle, p.projectcode, q.modtype, q.moddoctypeid, q.code, q.status, q.weight
   FROM ( SELECT m.modificationid, modtypemoddoctype.moddoctypeid, m.projectid, mt.code AS modtype, COALESCE(mdst.code, 'Not Started'::character varying) AS code, m.modificationcode, rank() OVER (PARTITION BY m.modificationid, modtypemoddoctype.moddoctypeid ORDER BY mds.effectivedate DESC, mdst.weight DESC) AS rank, ms.status, ms.weight
           FROM modification m
      LEFT JOIN modificationstatus ms USING (modificationid)
   JOIN modtype mt USING (modtypeid)
   JOIN modtypemoddoctype USING (modtypeid)
   LEFT JOIN moddocstatus mds USING (modificationid, moddoctypeid)
   LEFT JOIN moddocstatustype mdst USING (moddocstatustypeid)
  WHERE NOT modtypemoddoctype.inactive) q
   JOIN projectlist p USING (projectid)
  WHERE q.rank = 1
  ORDER BY q.modificationid, q.moddoctypeid;

ALTER TABLE report.allmoddocstatus
  OWNER TO bradley;
GRANT ALL ON TABLE report.allmoddocstatus TO bradley;
GRANT SELECT ON TABLE report.allmoddocstatus TO pts_read;

/*****LOAD DATA*********/
--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.10
-- Dumped by pg_dump version 9.1.10
-- Started on 2013-12-19 11:27:45 AKST

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = cvl, pg_catalog;

--
-- TOC entry 3389 (class 0 OID 217293)
-- Dependencies: 334 3391
-- Data for Name: moddocstatustype; Type: TABLE DATA; Schema: cvl; Owner: bradley
--

INSERT INTO moddocstatustype VALUES (0, 'Not Started', 'Not Started', 'Work on the document has not begun.', 0);
INSERT INTO moddocstatustype VALUES (1, 'In Progress', 'In Progress', 'Work on the document is on-going.', 10);
INSERT INTO moddocstatustype VALUES (2, 'Completed', 'Completed', 'The document is ready for submission.', 20);
INSERT INTO moddocstatustype VALUES (3, 'Not Applicable', 'Not Applicable', 'The document is not required.', 30);


--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 333
-- Name: moddocstatustype_moddocstatustypeid_seq; Type: SEQUENCE SET; Schema: cvl; Owner: bradley
--

SELECT pg_catalog.setval('moddocstatustype_moddocstatustypeid_seq', 3, true);


--
-- TOC entry 3387 (class 0 OID 217282)
-- Dependencies: 332 3391
-- Data for Name: moddoctype; Type: TABLE DATA; Schema: cvl; Owner: bradley
--

INSERT INTO moddoctype VALUES (1, 'Award Letter NOAL', 'Award Letter NOAL', 'Award Letter NOAL');
INSERT INTO moddoctype VALUES (2, 'IAA Form ', 'IAA Form ', 'IAA Form ');
INSERT INTO moddoctype VALUES (3, 'Project Proposal/Scope of Work/Budget', 'Proposal/SOW/Budget', 'Project Proposal/Scope of Work/Budget');
INSERT INTO moddoctype VALUES (4, 'grants.gov Announcement', 'grants.gov', 'grants.gov Announcement (screen print)');
INSERT INTO moddoctype VALUES (5, 'Sole Source ', 'Sole Source ', 'Sole Source ');
INSERT INTO moddoctype VALUES (6, 'SF-424, 424a, and 424b Package', 'SF-424(a,b)', 'SF-424, 424a, and 424b Package');
INSERT INTO moddoctype VALUES (7, 'Indirect Rate Agreement', 'Indirect Rate Agreement', 'Indirect Rate Agreement');
INSERT INTO moddoctype VALUES (8, 'Purchase Request', 'Purchase Request', 'Purchase Request (PPR-signed)');
INSERT INTO moddoctype VALUES (9, 'Project Officer Summary', 'PO Summary', 'Project Officer Summary');
INSERT INTO moddoctype VALUES (10, 'Determination', 'Determination', 'Determination');
INSERT INTO moddoctype VALUES (11, 'Award Checklist', 'Award Checklist', 'Award Checklist (signed)');
INSERT INTO moddoctype VALUES (12, 'Pre-Award Cost Justification', 'Pre-Award Justification', 'Pre-Award Cost Justification');
INSERT INTO moddoctype VALUES (13, 'NEPA Documentation', 'NEPA', 'NEPA Documentation (signed)');
INSERT INTO moddoctype VALUES (14, 'ESA Section 7 Review', 'Section 7', 'ESA Section 7 Review (signed)');
INSERT INTO moddoctype VALUES (15, 'NHPA Section 106 Review', 'Section 106', 'NHPA Section 106 Review (signed)');
INSERT INTO moddoctype VALUES (16, 'SF-LLL Lobbying or Non-activity Statement', 'SF-LLL', 'SF-LLL Lobbying or Non-activity Statement');
INSERT INTO moddoctype VALUES (17, 'Verify Active DUNS # in sam.gov', 'Active DUNS', 'Verify Active DUNS # in sam.gov (screen print) -this includes excluded parties listing');
INSERT INTO moddoctype VALUES (18, 'Active ASAP registration for payment', 'Active ASAP', 'Active ASAP registration for payment (includes FWS)');
INSERT INTO moddoctype VALUES (19, 'A-133 Audit', 'A-133 Audit', 'A-133 Audit (if required - census.gov)');


--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 331
-- Name: moddoctype_moddoctypeid_seq; Type: SEQUENCE SET; Schema: cvl; Owner: bradley
--

SELECT pg_catalog.setval('moddoctype_moddoctypeid_seq', 19, true);


--
-- TOC entry 3390 (class 0 OID 217313)
-- Dependencies: 337 3387 3391
-- Data for Name: modtypemoddoctype; Type: TABLE DATA; Schema: cvl; Owner: bradley
--

INSERT INTO modtypemoddoctype VALUES (1, 1, false);
INSERT INTO modtypemoddoctype VALUES (1, 2, false);
INSERT INTO modtypemoddoctype VALUES (1, 3, false);
INSERT INTO modtypemoddoctype VALUES (1, 4, false);
INSERT INTO modtypemoddoctype VALUES (1, 5, false);
INSERT INTO modtypemoddoctype VALUES (1, 6, false);
INSERT INTO modtypemoddoctype VALUES (1, 7, false);
INSERT INTO modtypemoddoctype VALUES (1, 8, false);
INSERT INTO modtypemoddoctype VALUES (1, 9, false);
INSERT INTO modtypemoddoctype VALUES (1, 10, false);
INSERT INTO modtypemoddoctype VALUES (1, 11, false);
INSERT INTO modtypemoddoctype VALUES (1, 12, false);
INSERT INTO modtypemoddoctype VALUES (1, 13, false);
INSERT INTO modtypemoddoctype VALUES (1, 14, false);
INSERT INTO modtypemoddoctype VALUES (1, 15, false);
INSERT INTO modtypemoddoctype VALUES (1, 16, false);
INSERT INTO modtypemoddoctype VALUES (1, 17, false);
INSERT INTO modtypemoddoctype VALUES (1, 18, false);
INSERT INTO modtypemoddoctype VALUES (1, 19, false);
INSERT INTO modtypemoddoctype VALUES (2, 1, false);
INSERT INTO modtypemoddoctype VALUES (2, 2, false);
INSERT INTO modtypemoddoctype VALUES (2, 3, false);
INSERT INTO modtypemoddoctype VALUES (2, 4, false);
INSERT INTO modtypemoddoctype VALUES (2, 5, false);
INSERT INTO modtypemoddoctype VALUES (2, 6, false);
INSERT INTO modtypemoddoctype VALUES (2, 7, false);
INSERT INTO modtypemoddoctype VALUES (2, 8, false);
INSERT INTO modtypemoddoctype VALUES (2, 9, false);
INSERT INTO modtypemoddoctype VALUES (2, 10, false);
INSERT INTO modtypemoddoctype VALUES (2, 11, false);
INSERT INTO modtypemoddoctype VALUES (2, 12, false);
INSERT INTO modtypemoddoctype VALUES (2, 13, false);
INSERT INTO modtypemoddoctype VALUES (2, 14, false);
INSERT INTO modtypemoddoctype VALUES (2, 15, false);
INSERT INTO modtypemoddoctype VALUES (2, 16, false);
INSERT INTO modtypemoddoctype VALUES (2, 17, false);
INSERT INTO modtypemoddoctype VALUES (2, 18, false);
INSERT INTO modtypemoddoctype VALUES (2, 19, false);
INSERT INTO modtypemoddoctype VALUES (3, 1, false);
INSERT INTO modtypemoddoctype VALUES (3, 2, false);
INSERT INTO modtypemoddoctype VALUES (3, 3, false);
INSERT INTO modtypemoddoctype VALUES (3, 4, false);
INSERT INTO modtypemoddoctype VALUES (3, 5, false);
INSERT INTO modtypemoddoctype VALUES (3, 6, false);
INSERT INTO modtypemoddoctype VALUES (3, 7, false);
INSERT INTO modtypemoddoctype VALUES (3, 8, false);
INSERT INTO modtypemoddoctype VALUES (3, 9, false);
INSERT INTO modtypemoddoctype VALUES (3, 10, false);
INSERT INTO modtypemoddoctype VALUES (3, 11, false);
INSERT INTO modtypemoddoctype VALUES (3, 12, false);
INSERT INTO modtypemoddoctype VALUES (3, 13, false);
INSERT INTO modtypemoddoctype VALUES (3, 14, false);
INSERT INTO modtypemoddoctype VALUES (3, 15, false);
INSERT INTO modtypemoddoctype VALUES (3, 16, false);
INSERT INTO modtypemoddoctype VALUES (3, 17, false);
INSERT INTO modtypemoddoctype VALUES (3, 18, false);
INSERT INTO modtypemoddoctype VALUES (3, 19, false);
INSERT INTO modtypemoddoctype VALUES (5, 1, false);
INSERT INTO modtypemoddoctype VALUES (5, 2, false);
INSERT INTO modtypemoddoctype VALUES (5, 3, false);
INSERT INTO modtypemoddoctype VALUES (5, 4, false);
INSERT INTO modtypemoddoctype VALUES (5, 5, false);
INSERT INTO modtypemoddoctype VALUES (5, 6, false);
INSERT INTO modtypemoddoctype VALUES (5, 7, false);
INSERT INTO modtypemoddoctype VALUES (5, 8, false);
INSERT INTO modtypemoddoctype VALUES (5, 9, false);
INSERT INTO modtypemoddoctype VALUES (5, 10, false);
INSERT INTO modtypemoddoctype VALUES (5, 11, false);
INSERT INTO modtypemoddoctype VALUES (5, 12, false);
INSERT INTO modtypemoddoctype VALUES (5, 13, false);
INSERT INTO modtypemoddoctype VALUES (5, 14, false);
INSERT INTO modtypemoddoctype VALUES (5, 15, false);
INSERT INTO modtypemoddoctype VALUES (5, 16, false);
INSERT INTO modtypemoddoctype VALUES (5, 17, false);
INSERT INTO modtypemoddoctype VALUES (5, 18, false);
INSERT INTO modtypemoddoctype VALUES (5, 19, false);
INSERT INTO modtypemoddoctype VALUES (6, 1, false);
INSERT INTO modtypemoddoctype VALUES (6, 2, false);
INSERT INTO modtypemoddoctype VALUES (6, 3, false);
INSERT INTO modtypemoddoctype VALUES (6, 4, false);
INSERT INTO modtypemoddoctype VALUES (6, 5, false);
INSERT INTO modtypemoddoctype VALUES (6, 6, false);
INSERT INTO modtypemoddoctype VALUES (6, 7, false);
INSERT INTO modtypemoddoctype VALUES (6, 8, false);
INSERT INTO modtypemoddoctype VALUES (6, 9, false);
INSERT INTO modtypemoddoctype VALUES (6, 10, false);
INSERT INTO modtypemoddoctype VALUES (6, 11, false);
INSERT INTO modtypemoddoctype VALUES (6, 12, false);
INSERT INTO modtypemoddoctype VALUES (6, 13, false);
INSERT INTO modtypemoddoctype VALUES (6, 14, false);
INSERT INTO modtypemoddoctype VALUES (6, 15, false);
INSERT INTO modtypemoddoctype VALUES (6, 16, false);
INSERT INTO modtypemoddoctype VALUES (6, 17, false);
INSERT INTO modtypemoddoctype VALUES (6, 18, false);
INSERT INTO modtypemoddoctype VALUES (6, 19, false);
INSERT INTO modtypemoddoctype VALUES (7, 1, false);
INSERT INTO modtypemoddoctype VALUES (7, 2, false);
INSERT INTO modtypemoddoctype VALUES (7, 3, false);
INSERT INTO modtypemoddoctype VALUES (7, 5, false);
INSERT INTO modtypemoddoctype VALUES (7, 6, false);
INSERT INTO modtypemoddoctype VALUES (7, 7, false);
INSERT INTO modtypemoddoctype VALUES (7, 8, false);
INSERT INTO modtypemoddoctype VALUES (7, 9, false);
INSERT INTO modtypemoddoctype VALUES (7, 10, false);
INSERT INTO modtypemoddoctype VALUES (7, 11, false);
INSERT INTO modtypemoddoctype VALUES (7, 12, false);
INSERT INTO modtypemoddoctype VALUES (7, 13, false);
INSERT INTO modtypemoddoctype VALUES (7, 14, false);
INSERT INTO modtypemoddoctype VALUES (7, 15, false);
INSERT INTO modtypemoddoctype VALUES (7, 16, false);
INSERT INTO modtypemoddoctype VALUES (7, 17, false);
INSERT INTO modtypemoddoctype VALUES (7, 18, false);
INSERT INTO modtypemoddoctype VALUES (7, 19, false);
INSERT INTO modtypemoddoctype VALUES (8, 1, false);
INSERT INTO modtypemoddoctype VALUES (8, 2, false);
INSERT INTO modtypemoddoctype VALUES (8, 3, false);
INSERT INTO modtypemoddoctype VALUES (8, 4, false);
INSERT INTO modtypemoddoctype VALUES (8, 5, false);
INSERT INTO modtypemoddoctype VALUES (8, 6, false);
INSERT INTO modtypemoddoctype VALUES (8, 7, false);
INSERT INTO modtypemoddoctype VALUES (8, 8, false);
INSERT INTO modtypemoddoctype VALUES (8, 9, false);
INSERT INTO modtypemoddoctype VALUES (8, 10, false);
INSERT INTO modtypemoddoctype VALUES (8, 11, false);
INSERT INTO modtypemoddoctype VALUES (8, 12, false);
INSERT INTO modtypemoddoctype VALUES (8, 13, false);
INSERT INTO modtypemoddoctype VALUES (8, 14, false);
INSERT INTO modtypemoddoctype VALUES (8, 15, false);
INSERT INTO modtypemoddoctype VALUES (8, 16, false);
INSERT INTO modtypemoddoctype VALUES (8, 17, false);
INSERT INTO modtypemoddoctype VALUES (8, 18, false);
INSERT INTO modtypemoddoctype VALUES (8, 19, false);
INSERT INTO modtypemoddoctype VALUES (7, 4, true);


-- Completed on 2013-12-19 11:27:45 AKST

--
-- PostgreSQL database dump complete
--
