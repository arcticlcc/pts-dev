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

-- View: deliverabledue

-- DROP VIEW deliverabledue;

CREATE OR REPLACE VIEW deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid, string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate, efd.effectivedate AS receiveddate, d.title, d.description, projectlist.projectcode, project.shorttitle AS project, (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact, personlist.priemail AS email,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) > 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue, modification.projectid, dm.modificationid, d.deliverableid,
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed, modification.modificationcode AS agreementnumber, dlc.staffcomments
   FROM deliverable d
   LEFT JOIN delcomment dlc USING (deliverableid)
   JOIN deliverablemod dm USING (deliverableid)
   JOIN modification USING (modificationid)
   JOIN projectlist USING (projectid)
   JOIN project USING (projectid)
   LEFT JOIN ( SELECT projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, projectcontact.projectcontactid
   FROM projectcontact
  WHERE projectcontact.roletypeid = ANY (ARRAY[6, 7])) projectcontact USING (projectid)
   LEFT JOIN personlist USING (contactid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid, deliverablemodstatus.deliverablemodstatusid, deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate, deliverablemodstatus.comment, deliverablemodstatus.contactid, deliverablestatus.code, deliverablestatus.status, deliverablestatus.description, deliverablestatus.comment
   FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)
   LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.deliverableid
   FROM deliverablemodstatus
   JOIN deliverablestatus USING (deliverablestatusid)
  WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT (EXISTS ( SELECT 1
   FROM deliverablemod dp
  WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

ALTER TABLE deliverabledue
  OWNER TO bradley;
GRANT ALL ON TABLE deliverabledue TO bradley;
GRANT SELECT ON TABLE deliverabledue TO pts_read;

-- View: report.noticesent

-- DROP VIEW report.noticesent;

CREATE OR REPLACE VIEW report.noticesent AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid, string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate, d.title, d.description, notice.code AS lastnotice, deliverablenotice.datesent, projectlist.projectcode, project.shorttitle AS project, (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact, personlist.priemail AS email, (folist.firstname::text || ' '::text) || folist.lastname::text AS fofficer, folist.priemail AS foemail,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue, COALESCE(status.status, 'Not Received'::character varying) AS status, modification.projectid, dm.modificationid, d.deliverableid, modification.modificationcode AS agreementnumber, dlc.staffcomments
   FROM deliverable d
   LEFT JOIN delcomment dlc USING (deliverableid)
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
