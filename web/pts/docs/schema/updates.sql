--version 0.10.0

-- Add project shorttitle
-- View: deliverablecalendar

-- DROP VIEW deliverablecalendar;

CREATE OR REPLACE VIEW deliverablecalendar AS 
 SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverable.title, deliverable.description, (person.firstname::text || ' '::text) || person.lastname::text AS manager, deliverabletype.type, form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode, modification.projectid, 
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed, project.shorttitle
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

ALTER TABLE login
   ADD COLUMN openid character varying;
COMMENT ON COLUMN login.openid IS 'Identifier to use with OpenId.';

ALTER TABLE login ADD UNIQUE (openid);

-- Column: taskcode

-- ALTER TABLE cvl.deliverablestatus DROP COLUMN taskcode;

ALTER TABLE cvl.deliverablestatus ADD COLUMN taskcode character varying;
COMMENT ON COLUMN cvl.deliverablestatus.taskcode IS 'Alternative code for task status.';

-- View: cvl.taskstatus

-- DROP VIEW cvl.taskstatus;

CREATE OR REPLACE VIEW cvl.taskstatus AS 
 SELECT deliverablestatus.deliverablestatusid, COALESCE(deliverablestatus.taskcode, deliverablestatus.code) AS code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
   FROM deliverablestatus
  ORDER BY deliverablestatus.deliverablestatusid;

ALTER TABLE cvl.taskstatus
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.taskstatus TO bradley;
GRANT SELECT ON TABLE cvl.taskstatus TO pts_read;

-- View: task

-- DROP VIEW task;

CREATE OR REPLACE VIEW task AS 
 SELECT deliverablemod.duedate, deliverable.title, efd.effectivedate AS receiveddate, (person.firstname::text || ' '::text) || person.lastname::text AS assignee, deliverable.description, deliverablemod.deliverableid, person.contactid, modification.projectid, deliverablemod.modificationid, 
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) > 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - deliverablemod.duedate
        END AS dayspastdue, 
        CASE
            WHEN status.code IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) < 0) THEN status.code
            ELSE 'Not Started'::character varying
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed, projectlist.projectcode, projectlist.shorttitle
   FROM deliverablemod
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, taskstatus.code, taskstatus.status, taskstatus.description, taskstatus.comment
           FROM deliverablemodstatus
      JOIN taskstatus USING (deliverablestatusid)
     ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (modificationid, deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid
      FROM deliverablemodstatus
   JOIN taskstatus USING (deliverablestatusid)
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