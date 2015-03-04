-- Version 0.15.1


SET search_path = alcc, pg_catalog;

ALTER TABLE deliverablenotice
    DROP CONSTRAINT recipient_deliverablenotice_fk;

ALTER TABLE deliverablemod
    ADD COLUMN staffonly boolean DEFAULT false;

COMMENT ON COLUMN deliverablemod.staffonly IS 'Whether to limit reminders to staff.';

ALTER TABLE deliverablenotice
    ADD CONSTRAINT recipient_deliverablenotice_fk FOREIGN KEY (recipientid) REFERENCES contact(contactid);

CREATE  OR REPLACE VIEW deliverableall AS
    SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.devinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    (EXISTS ( SELECT 1
           FROM deliverablemod dm
          WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly
   FROM (((deliverablemod
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN deliverable USING (deliverableid));

CREATE  OR REPLACE VIEW deliverabledue AS
    WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    projectlist.projectcode,
    project.shorttitle AS project,
    (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact,
    personlist.priemail AS email,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM (((((((((deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN deliverablemod dm USING (deliverableid))
     JOIN modification USING (modificationid))
     JOIN projectlist USING (projectid))
     JOIN project USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN personlist USING (contactid))
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

CREATE  OR REPLACE VIEW deliverablereminder AS
    SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    d.deliverabletypeid,
    status.deliverablestatusid,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.contactid
            WHEN (piemail.email IS NOT NULL) THEN projectcontact.contactid
            ELSE project.orgid
        END AS contactid,
    efd.effectivedate AS receiveddate,
    d.title,
    dt.type,
    d.description,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.name
            ELSE contactprimaryinfo.name
        END AS contact,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN (man.priemail)::text
            WHEN (piemail.email IS NOT NULL) THEN piemail.email
            ELSE (groupschema.email)::text
        END AS email,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN ccemail.email
            ELSE NULL::text
        END AS ccemail,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN adminemail.email
            ELSE NULL::text
        END AS adminemail,
    (((po.firstname)::text || ' '::text) || (po.lastname)::text) AS projectofficer,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM ((((((((((((((((deliverable d
     JOIN deliverablemod dm USING (deliverableid))
     JOIN cvl.deliverabletype dt USING (deliverabletypeid))
     JOIN modification USING (modificationid))
     JOIN project USING (projectid))
     JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) OVER (PARTITION BY projectcontact_1.projectid ORDER BY projectcontact_1.roletypeid DESC, projectcontact_1.priority ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[6, 7])))) piemail USING (projectid))
     LEFT JOIN contactprimaryinfo USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (NOT (projectcontact_1.roletypeid = ANY (ARRAY[6, 7, 5, 13]))))
          GROUP BY projectcontact_1.projectid) ccemail USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[5, 13])))
          GROUP BY projectcontact_1.projectid) adminemail USING (projectid))
     LEFT JOIN projectcontact poc ON (((poc.projectid = project.projectid) AND (poc.roletypeid = 12))))
     LEFT JOIN person po ON ((poc.contactid = po.contactid)))
     LEFT JOIN contactprimaryinfo man ON ((man.contactid = dm.personid)))
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN common.groupschema ON ((((project.orgid = groupschema.groupid) AND (NOT ((groupschema.groupschemaid)::text = 'dev'::text))) AND ((groupschema.groupschemaid)::name = ANY (current_schemas(false))))))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

CREATE  OR REPLACE VIEW projectcontactfull AS
    SELECT pc.projectcontactid,
    pc.projectid,
    pc.contactid,
    pc.roletypeid,
    pc.priority,
    pc.contactprojectcode,
    pc.partner,
    pc.name,
    roletype.code AS role,
    pc.type,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    pc.contactids,
    pc.reminder
   FROM (((( SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
            'person'::text AS type,
            ARRAY[person.contactid] AS contactids
           FROM (projectcontact
             JOIN person USING (contactid))
        UNION
         SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            contactgrouplist.fullname,
            'group'::text AS type,
            contactgrouplist.contactids
           FROM (projectcontact
             JOIN contactgrouplist USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
     JOIN project USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY pc.priority;

SET search_path = cvl, pg_catalog;

ALTER TABLE notice
    ADD COLUMN priority integer;

SET search_path = dev, pg_catalog;



ALTER TABLE deliverablenotice
    DROP CONSTRAINT recipient_deliverablenotice_fk;

ALTER TABLE deliverablemod
    ADD COLUMN staffonly boolean DEFAULT false;

COMMENT ON COLUMN deliverablemod.staffonly IS 'Whether to limit reminders to staff.';

ALTER TABLE deliverablenotice
    ADD CONSTRAINT recipient_deliverablenotice_fk FOREIGN KEY (recipientid) REFERENCES contact(contactid);

CREATE  OR REPLACE VIEW deliverableall AS
    SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.devinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    (EXISTS ( SELECT 1
           FROM deliverablemod dm
          WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly
   FROM (((deliverablemod
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN deliverable USING (deliverableid));

CREATE  OR REPLACE VIEW deliverabledue AS
    WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    projectlist.projectcode,
    project.shorttitle AS project,
    (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact,
    personlist.priemail AS email,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM (((((((((deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN deliverablemod dm USING (deliverableid))
     JOIN modification USING (modificationid))
     JOIN projectlist USING (projectid))
     JOIN project USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN personlist USING (contactid))
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

CREATE  OR REPLACE VIEW deliverablereminder AS
    SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    d.deliverabletypeid,
    status.deliverablestatusid,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.contactid
            WHEN (piemail.email IS NOT NULL) THEN projectcontact.contactid
            ELSE project.orgid
        END AS contactid,
    efd.effectivedate AS receiveddate,
    d.title,
    dt.type,
    d.description,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.name
            ELSE contactprimaryinfo.name
        END AS contact,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN (man.priemail)::text
            WHEN (piemail.email IS NOT NULL) THEN piemail.email
            ELSE (groupschema.email)::text
        END AS email,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN ccemail.email
            ELSE NULL::text
        END AS ccemail,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN adminemail.email
            ELSE NULL::text
        END AS adminemail,
    (((po.firstname)::text || ' '::text) || (po.lastname)::text) AS projectofficer,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM ((((((((((((((((deliverable d
     JOIN deliverablemod dm USING (deliverableid))
     JOIN cvl.deliverabletype dt USING (deliverabletypeid))
     JOIN modification USING (modificationid))
     JOIN project USING (projectid))
     JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) OVER (PARTITION BY projectcontact_1.projectid ORDER BY projectcontact_1.roletypeid DESC, projectcontact_1.priority ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[6, 7])))) piemail USING (projectid))
     LEFT JOIN contactprimaryinfo USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (NOT (projectcontact_1.roletypeid = ANY (ARRAY[6, 7, 5, 13]))))
          GROUP BY projectcontact_1.projectid) ccemail USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[5, 13])))
          GROUP BY projectcontact_1.projectid) adminemail USING (projectid))
     LEFT JOIN projectcontact poc ON (((poc.projectid = project.projectid) AND (poc.roletypeid = 12))))
     LEFT JOIN person po ON ((poc.contactid = po.contactid)))
     LEFT JOIN contactprimaryinfo man ON ((man.contactid = dm.personid)))
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN common.groupschema ON ((((project.orgid = groupschema.groupid) AND (NOT ((groupschema.groupschemaid)::text = 'dev'::text))) AND ((groupschema.groupschemaid)::name = ANY (current_schemas(false))))))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

CREATE  OR REPLACE VIEW projectcontactfull AS
    SELECT pc.projectcontactid,
    pc.projectid,
    pc.contactid,
    pc.roletypeid,
    pc.priority,
    pc.contactprojectcode,
    pc.partner,
    pc.name,
    roletype.code AS role,
    pc.type,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    pc.contactids,
    pc.reminder
   FROM (((( SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
            'person'::text AS type,
            ARRAY[person.contactid] AS contactids
           FROM (projectcontact
             JOIN person USING (contactid))
        UNION
         SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            contactgrouplist.fullname,
            'group'::text AS type,
            contactgrouplist.contactids
           FROM (projectcontact
             JOIN contactgrouplist USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
     JOIN project USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY pc.priority;

SET search_path = walcc, pg_catalog;



ALTER TABLE deliverablenotice
    DROP CONSTRAINT recipient_deliverablenotice_fk;

ALTER TABLE deliverablemod
    ADD COLUMN staffonly boolean DEFAULT false;

COMMENT ON COLUMN deliverablemod.staffonly IS 'Whether to limit reminders to staff.';

ALTER TABLE deliverablenotice
    ADD CONSTRAINT recipient_deliverablenotice_fk FOREIGN KEY (recipientid) REFERENCES contact(contactid);

CREATE  OR REPLACE VIEW deliverableall AS
    SELECT deliverablemod.personid,
    deliverablemod.deliverableid,
    deliverablemod.modificationid,
    deliverablemod.duedate,
    efd.effectivedate AS receiveddate,
    deliverablemod.devinterval,
    deliverablemod.publish,
    deliverablemod.restricted,
    deliverablemod.accessdescription,
    deliverablemod.parentmodificationid,
    deliverablemod.parentdeliverableid,
    deliverable.deliverabletypeid,
    deliverable.title,
    deliverable.description,
    (EXISTS ( SELECT 1
           FROM deliverablemod dm
          WHERE ((dm.parentdeliverableid = deliverablemod.deliverableid) AND (dm.parentmodificationid = deliverablemod.modificationid)))) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly
   FROM (((deliverablemod
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = 10)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid))
     JOIN deliverable USING (deliverableid));

CREATE  OR REPLACE VIEW deliverabledue AS
    WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg(((deliverablecomment.datemodified || ': '::text) || (deliverablecomment.comment)::text), '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    projectlist.projectcode,
    project.shorttitle AS project,
    (((personlist.firstname)::text || ' '::text) || (personlist.lastname)::text) AS contact,
    personlist.priemail AS email,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM (((((((((deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid))
     JOIN deliverablemod dm USING (deliverableid))
     JOIN modification USING (modificationid))
     JOIN projectlist USING (projectid))
     JOIN project USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN personlist USING (contactid))
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
  WHERE ((NOT (d.deliverabletypeid = ANY (ARRAY[4, 7]))) AND (NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid))))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

CREATE  OR REPLACE VIEW deliverablereminder AS
    SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    d.deliverabletypeid,
    status.deliverablestatusid,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.contactid
            WHEN (piemail.email IS NOT NULL) THEN projectcontact.contactid
            ELSE project.orgid
        END AS contactid,
    efd.effectivedate AS receiveddate,
    d.title,
    dt.type,
    d.description,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle AS project,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN man.name
            ELSE contactprimaryinfo.name
        END AS contact,
        CASE
            WHEN (d.deliverabletypeid = 7) THEN (man.priemail)::text
            WHEN (piemail.email IS NOT NULL) THEN piemail.email
            ELSE (groupschema.email)::text
        END AS email,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN ccemail.email
            ELSE NULL::text
        END AS ccemail,
        CASE
            WHEN (NOT (d.deliverabletypeid = 7)) THEN adminemail.email
            ELSE NULL::text
        END AS adminemail,
    (((po.firstname)::text || ' '::text) || (po.lastname)::text) AS projectofficer,
        CASE
            WHEN (status.deliverablestatusid >= 10) THEN 0
            WHEN ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) > 0)) THEN ((('now'::text)::date - status.effectivedate) + 1)
            ELSE (('now'::text)::date - dm.duedate)
        END AS dayspastdue,
        CASE
            WHEN ((status.status IS NOT NULL) AND (NOT ((status.deliverablestatusid = 0) AND ((('now'::text)::date - dm.duedate) < 0)))) THEN status.status
            ELSE 'Not Received'::character varying
        END AS status,
    status.effectivedate,
    COALESCE((status.deliverablestatusid >= 40), false) AS completed,
    modification.modificationcode AS agreementnumber,
    dm.startdate,
    dm.enddate,
    dm.reminder,
    dm.staffonly
   FROM ((((((((((((((((deliverable d
     JOIN deliverablemod dm USING (deliverableid))
     JOIN cvl.deliverabletype dt USING (deliverabletypeid))
     JOIN modification USING (modificationid))
     JOIN project USING (projectid))
     JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM projectcontact projectcontact_1
          WHERE (projectcontact_1.roletypeid = ANY (ARRAY[6, 7]))) projectcontact USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) OVER (PARTITION BY projectcontact_1.projectid ORDER BY projectcontact_1.roletypeid DESC, projectcontact_1.priority ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[6, 7])))) piemail USING (projectid))
     LEFT JOIN contactprimaryinfo USING (contactid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (NOT (projectcontact_1.roletypeid = ANY (ARRAY[6, 7, 5, 13]))))
          GROUP BY projectcontact_1.projectid) ccemail USING (projectid))
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            string_agg((contactprimaryinfo_1.priemail)::text, ','::text) AS email
           FROM (projectcontact projectcontact_1
             JOIN contactprimaryinfo contactprimaryinfo_1 USING (contactid))
          WHERE (projectcontact_1.reminder AND (projectcontact_1.roletypeid = ANY (ARRAY[5, 13])))
          GROUP BY projectcontact_1.projectid) adminemail USING (projectid))
     LEFT JOIN projectcontact poc ON (((poc.projectid = project.projectid) AND (poc.roletypeid = 12))))
     LEFT JOIN person po ON ((poc.contactid = po.contactid)))
     LEFT JOIN contactprimaryinfo man ON ((man.contactid = dm.personid)))
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
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid))
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM (deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid))
          WHERE (deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40]))
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN common.groupschema ON ((((project.orgid = groupschema.groupid) AND (NOT ((groupschema.groupschemaid)::text = 'dev'::text))) AND ((groupschema.groupschemaid)::name = ANY (current_schemas(false))))))
  WHERE (NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE ((dm.modificationid = dp.parentmodificationid) AND (dm.deliverableid = dp.parentdeliverableid)))))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

CREATE  OR REPLACE VIEW projectcontactfull AS
    SELECT pc.projectcontactid,
    pc.projectid,
    pc.contactid,
    pc.roletypeid,
    pc.priority,
    pc.contactprojectcode,
    pc.partner,
    pc.name,
    roletype.code AS role,
    pc.type,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    pc.contactids,
    pc.reminder
   FROM (((( SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name,
            'person'::text AS type,
            ARRAY[person.contactid] AS contactids
           FROM (projectcontact
             JOIN person USING (contactid))
        UNION
         SELECT projectcontact.projectcontactid,
            projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.reminder,
            contactgrouplist.fullname,
            'group'::text AS type,
            contactgrouplist.contactids
           FROM (projectcontact
             JOIN contactgrouplist USING (contactid))) pc
     JOIN cvl.roletype USING (roletypeid))
     JOIN project USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
  ORDER BY pc.priority;