-- Version 0.11.2

-- View: modificationlist

-- DROP VIEW modificationlist;

CREATE OR REPLACE VIEW modificationlist AS
 SELECT m.modificationid, m.projectid, m.personid, m.modtypeid, m.title, m.description, m.modificationcode, m.effectivedate, m.startdate, m.enddate, m.datecreated, m.parentmodificationid, mt.type AS typetext, mt.code AS typecode, (EXISTS ( SELECT 1
           FROM modification mod
          WHERE m.modificationid = mod.parentmodificationid)) AS ismodified, p.modificationcode AS parentcode, m.shorttitle
   FROM modification m
   JOIN modtype mt USING (modtypeid)
   LEFT JOIN modification p ON p.modificationid = m.parentmodificationid;

-- View: grouppersonlist

-- DROP VIEW grouppersonlist;

CREATE OR REPLACE VIEW grouppersonlist AS
 SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, contactcontactgroup.groupid, contactgroup.acronym, contactgroup.name, contactcontactgroup.positionid, contact.inactive
   FROM contactcontactgroup
   JOIN contact USING (contactid)
   JOIN contactgroup ON contactgroup.contactid = contactcontactgroup.groupid
   JOIN person ON person.contactid = contactcontactgroup.contactid;

-- Index: modstatus_modificationid_statusid_idx

DROP INDEX modstatus_modificationid_statusid_idx;

CREATE UNIQUE INDEX modstatus_modificationid_statusid_idx
  ON modstatus
  USING btree
  (modificationid , statusid, effectivedate );

-- Function: project_status(integer)

-- DROP FUNCTION project_status(integer);

CREATE OR REPLACE FUNCTION project_status(pid integer)
  RETURNS integer AS
$BODY$
DECLARE status integer;
BEGIN
    IF EXISTS(SELECT 1 FROM modification WHERE projectid = pid)
    THEN --mods exist
        --test for agreements
        IF NOT EXISTS(SELECT 1 FROM modification WHERE projectid = pid AND modtypeid NOT IN (4,9))
        THEN --no agreements, check for proposal status
            status = statusid FROM modification JOIN modstatus USING(modificationid)
		JOIN status USING (statusid)
		WHERE projectid = pid
                ORDER BY modstatus.effectivedate DESC, status.weight DESC LIMIT 1;
            IF status IS NOT NULL
            THEN
                --return latest effective proposal status
                RETURN status;
            ELSE
                --no proposal status recorded, default to 'proposed'
                RETURN 7;
            END IF;
        --test for agreement status
        ELSEIF EXISTS(SELECT 1 FROM modification JOIN modstatus USING(modificationid) WHERE projectid = pid
             AND modtypeid NOT IN (4,9))
        THEN --has status
            -- check for latest status not eq cancelled or completed
            status = statusid FROM modification JOIN (SELECT *,
             row_number() OVER (PARTITION BY modificationid ORDER BY effectivedate DESC, weight DESC) AS rank
            FROM modstatus
            JOIN cvl.status USING(statusid)) AS modstatus USING(modificationid)
            WHERE projectid = pid
             AND modtypeid NOT IN (4,9) AND statusid NOT IN(1,2) AND RANK = 1
            ORDER BY CASE statusid
                WHEN 4 THEN 1
                WHEN 8 THEN 2
                WHEN 5 THEN 3
                ELSE 4
            END
            LIMIT 1;
            IF status IN(4,8,5)
                THEN --return ordered status
                    RETURN status;
            ELSEIF status IS NOT NULL
                THEN-- not ongoing or supsended, default to funded
                RETURN 3;
            ELSEIF EXISTS(SELECT 1 FROM modification JOIN modstatus USING(modificationid) WHERE projectid = pid
                   AND modtypeid NOT IN (4,9) AND statusid IN(2))
                THEN --completed
                    RETURN 2;
            ELSE --cancelled
                RETURN 1;
            END IF;
        ELSE --no agreement status defaults to 'funded'
            RETURN 3;
        END IF;
    ELSE
        --no modifications, status is 'proposed'
        RETURN 7;
    END IF;
END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100;
ALTER FUNCTION project_status(integer)
  OWNER TO bradley;


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
        END AS status, status.effectivedate, COALESCE(status.deliverablestatusid >= 40, false) AS completed, modification.modificationcode AS agreementnumber, dlc.staffcomments, dm.startdate, dm.enddate
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
        END AS dayspastdue, COALESCE(status.status, 'Not Received'::character varying) AS status, modification.projectid, dm.modificationid, d.deliverableid, modification.modificationcode AS agreementnumber, dlc.staffcomments, dm.startdate, dm.enddate
   FROM deliverable d
   LEFT JOIN delcomment dlc USING (deliverableid)
   JOIN ( SELECT deliverablemod.modificationid, deliverablemod.deliverableid, deliverablemod.duedate, deliverablemod.receiveddate, deliverablemod.devinterval, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverablemod.personid, deliverablemod.startdate, deliverablemod.enddate
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
  ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status USING (deliverableid)
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
