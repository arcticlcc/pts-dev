--PTS schema v0.4.1 => v0.5

SET search_path = pts, pg_catalog;

-- Table: projectkeyword

-- DROP TABLE projectkeyword;

CREATE TABLE projectkeyword
(
  projectid integer NOT NULL,
  keywordid uuid NOT NULL, -- GCMD concept UUID
  projectkeywordid serial NOT NULL,
  CONSTRAINT projectconcept_pk PRIMARY KEY (projectkeywordid ),
  CONSTRAINT concept_projectconcept_fk FOREIGN KEY (keywordid)
      REFERENCES gcmd.keyword (keywordid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT project_projectconcept_fk FOREIGN KEY (projectid)
      REFERENCES project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE,
  CONSTRAINT projectkeyword_conceptid_projectid_key UNIQUE (keywordid , projectid )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE projectkeyword
  OWNER TO bradley;
GRANT ALL ON TABLE projectkeyword TO bradley;
GRANT SELECT ON TABLE projectkeyword TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE projectkeyword TO pts_write;
COMMENT ON TABLE projectkeyword
  IS 'Identify project GCMD concepts(keywords)';
COMMENT ON COLUMN projectkeyword.keywordid IS 'GCMD concept UUID';

COMMENT ON COLUMN deliverablemod.receiveddate IS '***Deprecated use DELIVERABLEMODSTATUS*** Date the deliverable is delivered';

-- View: projectkeywordlist

-- DROP VIEW projectkeywordlist;

CREATE OR REPLACE VIEW projectkeywordlist AS
 SELECT projectkeyword.keywordid, projectkeyword.projectid, projectkeyword.projectkeywordid, keyword.preflabel AS text, keyword.definition, keyword.parentkeywordid
   FROM projectkeyword
   JOIN gcmd.keyword USING (keywordid);

ALTER TABLE projectkeywordlist
  OWNER TO bradley;
GRANT ALL ON TABLE projectkeywordlist TO bradley;
GRANT SELECT ON TABLE projectkeywordlist TO pts_read;

GRANT SELECT ON TABLE projectkeyword_projectkeywordid_seq TO GROUP pts_read;
GRANT SELECT, UPDATE ON TABLE projectkeyword_projectkeywordid_seq TO GROUP pts_write;


SET search_path = report, pts, pg_catalog;

-- View: report.shortprojectsummary

DROP VIEW report.shortprojectsummary;

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
