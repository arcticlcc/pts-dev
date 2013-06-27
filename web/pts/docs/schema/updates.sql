--version 0.9.3

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
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - deliverablemod.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed, projectlist.projectcode, projectlist.shorttitle
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
