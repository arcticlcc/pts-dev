Begin;

---- System ----


SET search_path TO '';

---- File: 001-add-config.sql ----


SET search_path = common, public;

-- Column: config

-- ALTER TABLE login DROP COLUMN config;

ALTER TABLE login ADD COLUMN config jsonb;
COMMENT ON COLUMN login.config IS 'Application settings for the login role.';
GRANT UPDATE(config) ON login TO GROUP pts_write;


SET search_path TO '';

---- File: 002-ptsadmin.sql ----


-- Role: pts_admin

-- DROP ROLE pts_admin;

CREATE ROLE pts_admin
  NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;

ALTER DATABASE pts
  OWNER TO pts_admin;

SET search_path TO '';

---- Schema: dev ----


---- File: 001-add-code.sql ----

SET search_path TO dev, public;

ALTER TABLE dev.deliverable
   ADD COLUMN code character varying;
COMMENT ON COLUMN dev.deliverable.code
  IS 'Code associated with the deliverable.';
---- File: 003-modificationcontact.sql ----

SET search_path TO dev, public;

-- Table: dev.modificationcontact

-- DROP TABLE dev.modificationcontact;

CREATE TABLE dev.modificationcontact
(
  modificationid integer NOT NULL, -- PK for MODIFICATION
  projectcontactid integer NOT NULL, -- PK for PROJECTCONTACT
  priority integer NOT NULL, -- Priority of the contact
  CONSTRAINT modificationcontact_pk PRIMARY KEY (modificationid, projectcontactid),
  CONSTRAINT modification_modificationcontact_fk FOREIGN KEY (modificationid)
      REFERENCES dev.modification (modificationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT projectcontact_modificationcontact_fk FOREIGN KEY (projectcontactid)
      REFERENCES dev.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE dev.modificationcontact
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.modificationcontact TO pts_admin;
GRANT SELECT ON TABLE dev.modificationcontact TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.modificationcontact TO pts_write;
COMMENT ON TABLE dev.modificationcontact
  IS 'Associates project contacts with a modification';
COMMENT ON COLUMN dev.modificationcontact.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN dev.modificationcontact.projectcontactid IS 'PK for PROJECTCONTACT';
COMMENT ON COLUMN dev.modificationcontact.priority IS 'Priority of the contact';
---- File: 004-modificationcontactlist.sql ----

SET search_path TO dev, public;

-- View: dev.modificationcontactlist

-- DROP VIEW dev.modificationcontactlist;

CREATE OR REPLACE VIEW dev.modificationcontactlist AS 
 SELECT modification.modificationid,
    string_agg(q.projectcontactid::text, ','::text) AS modificationcontact
   FROM dev.modification
     LEFT JOIN ( SELECT modificationcontact.modificationid,
            modificationcontact.projectcontactid,
            modificationcontact.priority
           FROM dev.modificationcontact
          ORDER BY modificationcontact.modificationid, modificationcontact.priority) q USING (modificationid)
  GROUP BY modification.modificationid;

ALTER TABLE dev.modificationcontactlist
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.modificationcontactlist TO pts_admin;
GRANT SELECT ON TABLE dev.modificationcontactlist TO pts_read;

---- File: 005-deliverableall.sql ----

SET search_path TO dev, public;

-- View: dev.deliverableall

-- DROP VIEW dev.deliverableall;

CREATE OR REPLACE VIEW dev.deliverableall AS 
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
          WHERE dm.parentdeliverableid = deliverablemod.deliverableid AND dm.parentmodificationid = deliverablemod.modificationid)) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly,
    deliverable.code
   FROM deliverablemod
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
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = 10
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)
     JOIN deliverable USING (deliverableid);

ALTER TABLE dev.deliverableall
  OWNER TO pts_admin;
GRANT SELECT ON TABLE dev.deliverableall TO pts_read;
---- File: 006-deliverablereminder.sql ----

SET search_path TO dev, public;

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
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
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
     JOIN cvl.deliverabletype dt USING (deliverabletypeid)
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
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN common.groupschema ON project.orgid = groupschema.groupid AND NOT groupschema.groupschemaid::text = 'dev'::text AND (groupschema.groupschemaid::name = ANY (current_schemas(false)))
  WHERE NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

ALTER TABLE dev.deliverablereminder
  OWNER TO pts_admin;
GRANT SELECT ON TABLE dev.deliverablereminder TO pts_read;
GRANT ALL ON TABLE dev.deliverablereminder TO pts_admin;

---- File: 007-userinfo.sql ----

SET search_path TO dev, public;

-- View: dev.userinfo

-- DROP VIEW dev.userinfo;

CREATE OR REPLACE VIEW dev.userinfo AS 
 SELECT login.loginid,
    logingroupschema.contactid,
    groupschema.groupid,
    login.username,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    contactgroup.name AS groupname,
    contactgroup.acronym,
    groupschema.projecturiformat,
    groupschema.email AS groupemail,
    login.config
   FROM common.login
     JOIN common.logingroupschema USING (loginid)
     JOIN common.groupschema USING (groupschemaid)
     JOIN contactgroup ON groupschema.groupid = contactgroup.contactid
     JOIN person ON logingroupschema.contactid = person.contactid
  WHERE logingroupschema.groupschemaid::name = ANY (current_schemas(false));

---- Schema: alcc ----


---- File: 001-add-code.sql ----

SET search_path TO alcc, public;

ALTER TABLE alcc.deliverable
   ADD COLUMN code character varying;
COMMENT ON COLUMN alcc.deliverable.code
  IS 'Code associated with the deliverable.';
---- File: 003-modificationcontact.sql ----

SET search_path TO alcc, public;

-- Table: alcc.modificationcontact

-- DROP TABLE alcc.modificationcontact;

CREATE TABLE alcc.modificationcontact
(
  modificationid integer NOT NULL, -- PK for MODIFICATION
  projectcontactid integer NOT NULL, -- PK for PROJECTCONTACT
  priority integer NOT NULL, -- Priority of the contact
  CONSTRAINT modificationcontact_pk PRIMARY KEY (modificationid, projectcontactid),
  CONSTRAINT modification_modificationcontact_fk FOREIGN KEY (modificationid)
      REFERENCES alcc.modification (modificationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT projectcontact_modificationcontact_fk FOREIGN KEY (projectcontactid)
      REFERENCES alcc.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE alcc.modificationcontact
  OWNER TO pts_admin;
GRANT ALL ON TABLE alcc.modificationcontact TO pts_admin;
GRANT SELECT ON TABLE alcc.modificationcontact TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.modificationcontact TO pts_write;
COMMENT ON TABLE alcc.modificationcontact
  IS 'Associates project contacts with a modification';
COMMENT ON COLUMN alcc.modificationcontact.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN alcc.modificationcontact.projectcontactid IS 'PK for PROJECTCONTACT';
COMMENT ON COLUMN alcc.modificationcontact.priority IS 'Priority of the contact';
---- File: 004-modificationcontactlist.sql ----

SET search_path TO alcc, public;

-- View: alcc.modificationcontactlist

-- DROP VIEW alcc.modificationcontactlist;

CREATE OR REPLACE VIEW alcc.modificationcontactlist AS 
 SELECT modification.modificationid,
    string_agg(q.projectcontactid::text, ','::text) AS modificationcontact
   FROM alcc.modification
     LEFT JOIN ( SELECT modificationcontact.modificationid,
            modificationcontact.projectcontactid,
            modificationcontact.priority
           FROM alcc.modificationcontact
          ORDER BY modificationcontact.modificationid, modificationcontact.priority) q USING (modificationid)
  GROUP BY modification.modificationid;

ALTER TABLE alcc.modificationcontactlist
  OWNER TO pts_admin;
GRANT ALL ON TABLE alcc.modificationcontactlist TO pts_admin;
GRANT SELECT ON TABLE alcc.modificationcontactlist TO pts_read;

---- File: 005-deliverableall.sql ----

SET search_path TO alcc, public;

-- View: alcc.deliverableall

-- DROP VIEW alcc.deliverableall;

CREATE OR REPLACE VIEW alcc.deliverableall AS 
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
          WHERE dm.parentdeliverableid = deliverablemod.deliverableid AND dm.parentmodificationid = deliverablemod.modificationid)) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly,
    deliverable.code
   FROM deliverablemod
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
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = 10
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)
     JOIN deliverable USING (deliverableid);

ALTER TABLE alcc.deliverableall
  OWNER TO pts_admin;
GRANT SELECT ON TABLE alcc.deliverableall TO pts_read;
---- File: 006-deliverablereminder.sql ----

SET search_path TO alcc, public;

-- View: alcc.deliverablereminder

-- DROP VIEW alcc.deliverablereminder;

CREATE OR REPLACE VIEW alcc.deliverablereminder AS 
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
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
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
     JOIN cvl.deliverabletype dt USING (deliverabletypeid)
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
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN common.groupschema ON project.orgid = groupschema.groupid AND NOT groupschema.groupschemaid::text = 'dev'::text AND (groupschema.groupschemaid::name = ANY (current_schemas(false)))
  WHERE NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

ALTER TABLE alcc.deliverablereminder
  OWNER TO pts_admin;
GRANT SELECT ON TABLE alcc.deliverablereminder TO pts_read;
GRANT ALL ON TABLE alcc.deliverablereminder TO pts_admin;

---- File: 007-userinfo.sql ----

SET search_path TO alcc, public;

-- View: alcc.userinfo

-- DROP VIEW alcc.userinfo;

CREATE OR REPLACE VIEW alcc.userinfo AS 
 SELECT login.loginid,
    logingroupschema.contactid,
    groupschema.groupid,
    login.username,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    contactgroup.name AS groupname,
    contactgroup.acronym,
    groupschema.projecturiformat,
    groupschema.email AS groupemail,
    login.config
   FROM common.login
     JOIN common.logingroupschema USING (loginid)
     JOIN common.groupschema USING (groupschemaid)
     JOIN contactgroup ON groupschema.groupid = contactgroup.contactid
     JOIN person ON logingroupschema.contactid = person.contactid
  WHERE logingroupschema.groupschemaid::name = ANY (current_schemas(false));

---- Schema: walcc ----


---- File: 001-add-code.sql ----

SET search_path TO walcc, public;

ALTER TABLE walcc.deliverable
   ADD COLUMN code character varying;
COMMENT ON COLUMN walcc.deliverable.code
  IS 'Code associated with the deliverable.';
---- File: 003-modificationcontact.sql ----

SET search_path TO walcc, public;

-- Table: walcc.modificationcontact

-- DROP TABLE walcc.modificationcontact;

CREATE TABLE walcc.modificationcontact
(
  modificationid integer NOT NULL, -- PK for MODIFICATION
  projectcontactid integer NOT NULL, -- PK for PROJECTCONTACT
  priority integer NOT NULL, -- Priority of the contact
  CONSTRAINT modificationcontact_pk PRIMARY KEY (modificationid, projectcontactid),
  CONSTRAINT modification_modificationcontact_fk FOREIGN KEY (modificationid)
      REFERENCES walcc.modification (modificationid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT projectcontact_modificationcontact_fk FOREIGN KEY (projectcontactid)
      REFERENCES walcc.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE walcc.modificationcontact
  OWNER TO pts_admin;
GRANT ALL ON TABLE walcc.modificationcontact TO pts_admin;
GRANT SELECT ON TABLE walcc.modificationcontact TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.modificationcontact TO pts_write;
COMMENT ON TABLE walcc.modificationcontact
  IS 'Associates project contacts with a modification';
COMMENT ON COLUMN walcc.modificationcontact.modificationid IS 'PK for MODIFICATION';
COMMENT ON COLUMN walcc.modificationcontact.projectcontactid IS 'PK for PROJECTCONTACT';
COMMENT ON COLUMN walcc.modificationcontact.priority IS 'Priority of the contact';
---- File: 004-modificationcontactlist.sql ----

SET search_path TO walcc, public;

-- View: walcc.modificationcontactlist

-- DROP VIEW walcc.modificationcontactlist;

CREATE OR REPLACE VIEW walcc.modificationcontactlist AS 
 SELECT modification.modificationid,
    string_agg(q.projectcontactid::text, ','::text) AS modificationcontact
   FROM walcc.modification
     LEFT JOIN ( SELECT modificationcontact.modificationid,
            modificationcontact.projectcontactid,
            modificationcontact.priority
           FROM walcc.modificationcontact
          ORDER BY modificationcontact.modificationid, modificationcontact.priority) q USING (modificationid)
  GROUP BY modification.modificationid;

ALTER TABLE walcc.modificationcontactlist
  OWNER TO pts_admin;
GRANT ALL ON TABLE walcc.modificationcontactlist TO pts_admin;
GRANT SELECT ON TABLE walcc.modificationcontactlist TO pts_read;

---- File: 005-deliverableall.sql ----

SET search_path TO walcc, public;

-- View: walcc.deliverableall

-- DROP VIEW walcc.deliverableall;

CREATE OR REPLACE VIEW walcc.deliverableall AS 
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
          WHERE dm.parentdeliverableid = deliverablemod.deliverableid AND dm.parentmodificationid = deliverablemod.modificationid)) AS modified,
    status.status,
    status.effectivedate,
    status.deliverablestatusid,
    deliverablemod.startdate,
    deliverablemod.enddate,
    deliverablemod.reminder,
    deliverablemod.staffonly,
    deliverable.code
   FROM deliverablemod
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
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = 10
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (deliverableid)
     JOIN deliverable USING (deliverableid);

ALTER TABLE walcc.deliverableall
  OWNER TO pts_admin;
GRANT SELECT ON TABLE walcc.deliverableall TO pts_read;
---- File: 006-deliverablereminder.sql ----

SET search_path TO walcc, public;

-- View: walcc.deliverablereminder

-- DROP VIEW walcc.deliverablereminder;

CREATE OR REPLACE VIEW walcc.deliverablereminder AS 
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
    common.form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
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
     JOIN cvl.deliverabletype dt USING (deliverabletypeid)
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
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM deliverablemodstatus
             JOIN cvl.deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN common.groupschema ON project.orgid = groupschema.groupid AND NOT groupschema.groupschemaid::text = 'dev'::text AND (groupschema.groupschemaid::name = ANY (current_schemas(false)))
  WHERE NOT (EXISTS ( SELECT 1
           FROM deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid DESC, projectcontact.priority, poc.priority;

ALTER TABLE walcc.deliverablereminder
  OWNER TO pts_admin;
GRANT SELECT ON TABLE walcc.deliverablereminder TO pts_read;
GRANT ALL ON TABLE walcc.deliverablereminder TO pts_admin;

---- File: 007-userinfo.sql ----

SET search_path TO walcc, public;

-- View: walcc.userinfo

-- DROP VIEW walcc.userinfo;

CREATE OR REPLACE VIEW walcc.userinfo AS 
 SELECT login.loginid,
    logingroupschema.contactid,
    groupschema.groupid,
    login.username,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    contactgroup.name AS groupname,
    contactgroup.acronym,
    groupschema.projecturiformat,
    groupschema.email AS groupemail,
    login.config
   FROM common.login
     JOIN common.logingroupschema USING (loginid)
     JOIN common.groupschema USING (groupschemaid)
     JOIN contactgroup ON groupschema.groupid = contactgroup.contactid
     JOIN person ON logingroupschema.contactid = person.contactid
  WHERE logingroupschema.groupschemaid::name = ANY (current_schemas(false));

