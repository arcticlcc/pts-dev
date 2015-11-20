-- View: dev.deliverablereminder

-- DROP VIEW dev.deliverablereminder;

CREATE OR REPLACE VIEW dev.deliverablereminder AS 
 WITH modcontact AS (
         SELECT m.modificationid,
            pmc.projectid,
            pmc.contactid,
            pmc.roletypeid,
            pmc.priority,
            pmc.contactprojectcode,
            pmc.partner,
            pmc.projectcontactid,
            pmc.reminder
           FROM modification m
             JOIN modificationcontact mc USING (modificationid)
             JOIN projectcontact pmc USING (projectcontactid)
        UNION
         SELECT m.modificationid,
            pc.projectid,
            pc.contactid,
            pc.roletypeid,
            pc.priority,
            pc.contactprojectcode,
            pc.partner,
            pc.projectcontactid,
            pc.reminder
           FROM modification m
             LEFT JOIN modificationcontact mc USING (modificationid)
             LEFT JOIN projectcontact pmc USING (projectcontactid)
             JOIN projectcontact pc ON m.projectid = pc.projectid AND mc.projectcontactid IS NULL
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    d.deliverabletypeid,
    status.deliverablestatusid,
        CASE
            WHEN d.deliverabletypeid = 7 THEN man.contactid
            WHEN piemail.email IS NOT NULL THEN projectcontact.contactid
            ELSE project.orgid
        END AS contactid,
    efd.effectivedate AS receiveddate,
    d.title,
    dt.type,
    d.description,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
        CASE
            WHEN d.deliverabletypeid = 7 THEN man.name
            ELSE contactprimaryinfo.name
        END AS contact,
        CASE
            WHEN d.deliverabletypeid = 7 THEN man.priemail::text
            WHEN piemail.email IS NOT NULL THEN piemail.email
            ELSE groupschema.email::text
        END AS email,
        CASE
            WHEN NOT d.deliverabletypeid = 7 THEN ccemail.email
            ELSE NULL::text
        END AS ccemail,
        CASE
            WHEN NOT d.deliverabletypeid = 7 THEN adminemail.email
            ELSE NULL::text
        END AS adminemail,
    (po.firstname::text || ' '::text) || po.lastname::text AS projectofficer,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) > 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue,
        CASE
            WHEN status.status IS NOT NULL AND NOT (status.deliverablestatusid = 0 AND ('now'::text::date - dm.duedate) < 0) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE(status.deliverablestatusid >= 40, false) AS completed,
    modification.modificationcode AS agreementnumber,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM deliverable d
     JOIN deliverablemod dm USING (deliverableid)
     JOIN deliverabletype dt USING (deliverabletypeid)
     JOIN modification USING (modificationid)
     JOIN project USING (projectid)
     JOIN ( SELECT projectcontact_1.modificationid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM modcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[6, 7])) projectcontact USING (modificationid)
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg(contactprimaryinfo_1.priemail::text, ','::text) OVER (PARTITION BY projectcontact_1.modificationid ORDER BY projectcontact_1.roletypeid DESC, projectcontact_1.priority ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS email
           FROM modcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid)
          WHERE projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) piemail USING (modificationid)
     LEFT JOIN contactprimaryinfo USING (contactid)
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg(contactprimaryinfo_1.priemail::text, ','::text) AS email
           FROM modcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid)
          WHERE projectcontact_1.reminder AND NOT (projectcontact_1.roletypeid = ANY (ARRAY[6, 7, 5, 13]))
          GROUP BY projectcontact_1.modificationid) ccemail USING (modificationid)
     LEFT JOIN ( SELECT projectcontact_1.modificationid,
            string_agg(contactprimaryinfo_1.priemail::text, ','::text) AS email
           FROM modcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid)
          WHERE projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[5, 13]))
          GROUP BY projectcontact_1.modificationid) adminemail USING (modificationid)
     LEFT JOIN projectcontact poc ON poc.projectid = project.projectid AND poc.roletypeid = 12
     LEFT JOIN person po ON poc.contactid = po.contactid
     LEFT JOIN contactprimaryinfo man ON man.contactid = dm.personid
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
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN groupschema ON project.orgid = groupschema.groupid AND NOT groupschema.groupschemaid::text = 'dev'::text AND (groupschema.groupschemaid::name = ANY (current_schemas(false)))
  WHERE NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

ALTER TABLE dev.deliverablereminder
  OWNER TO pts_admin;
GRANT SELECT ON TABLE dev.deliverablereminder TO pts_read;
GRANT ALL ON TABLE dev.deliverablereminder TO pts_admin;

