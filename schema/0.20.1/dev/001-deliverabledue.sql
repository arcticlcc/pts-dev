-- View: dev.deliverabledue

-- DROP VIEW dev.deliverabledue;

CREATE OR REPLACE VIEW dev.deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
    (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact,
    personlist.priemail AS email,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) > 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE(status.deliverablestatusid >= 40, false) AS completed,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN deliverablemod dm USING (deliverableid)
     JOIN modification USING (modificationid)
     JOIN project USING (projectid)
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[6, 7])) projectcontact USING (projectid)
     LEFT JOIN personlist ON personlist.contactid = projectcontact.contactid
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

ALTER TABLE dev.deliverabledue
  OWNER TO bradley;
GRANT ALL ON TABLE dev.deliverabledue TO bradley;
GRANT SELECT ON TABLE dev.deliverabledue TO pts_read;
GRANT ALL ON TABLE dev.deliverabledue TO pts_admin;
