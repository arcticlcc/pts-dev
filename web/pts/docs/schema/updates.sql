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
