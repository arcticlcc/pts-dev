--version 0.8

SET search_path = cvl, pg_catalog;

ALTER TABLE addresstype
	ADD COLUMN adiwg character varying;

ALTER TABLE contacttype
	ADD COLUMN adiwg character varying;

ALTER TABLE roletype
	ADD COLUMN adiwg character varying;

ALTER TABLE status
	ADD COLUMN weight integer;

SET search_path = pts, pg_catalog;

--DROP VIEW projectlist;

--DROP VIEW deliverablelist;

--DROP VIEW projectcontactlist;

ALTER TABLE project
	ADD COLUMN exportmetadata boolean DEFAULT false NOT NULL;

COMMENT ON COLUMN project.exportmetadata IS 'Specifies whether project metadata should be exported.';

CREATE OR REPLACE FUNCTION project_status(pid integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE status integer;
BEGIN
    IF EXISTS(SELECT 1 FROM modification WHERE projectid = pid)
    THEN --mods exist
        --test for agreements
        IF NOT EXISTS(SELECT 1 FROM modification WHERE projectid = pid AND modtypeid NOT IN (4,9))
        THEN --no agreements, check for proposal status
            status = statusid FROM modification JOIN modstatus USING(modificationid) WHERE projectid = pid
                ORDER BY modstatus.effectivedate DESC LIMIT 1;
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
$$;


CREATE INDEX fki_project_modification_fk ON modification USING btree (projectid);

CREATE INDEX project_status_idx ON project USING btree (project_status(projectid));

CREATE INDEX fki_roletype_projectcontact_fk ON projectcontact USING btree (roletypeid);

CREATE OR REPLACE VIEW projectlist AS
	SELECT DISTINCT project.projectid, project.orgid, form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode, project.title, project.parentprojectid, project.fiscalyear, project.number, project.startdate, project.enddate, project.uuid, COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated, COALESCE(invoice.amount, 0.00) AS invoiced, (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference, project.shorttitle, status.status, project.exportmetadata FROM (((((project JOIN contactgroup ON ((project.orgid = contactgroup.contactid))) JOIN cvl.status ON ((project_status(project.projectid) = status.statusid))) LEFT JOIN modification USING (projectid)) LEFT JOIN funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1)))) LEFT JOIN (SELECT modification.projectid, sum(invoice.amount) AS amount FROM ((invoice JOIN funding USING (fundingid)) JOIN modification USING (modificationid)) WHERE (funding.fundingtypeid = 1) GROUP BY modification.projectid) invoice USING (projectid));

CREATE OR REPLACE VIEW deliverablelist AS
	SELECT deliverablemod.personid, deliverablemod.deliverableid, deliverablemod.modificationid, deliverablemod.duedate, efd.effectivedate AS receiveddate, deliverablemod.devinterval, deliverablemod.invalid, deliverablemod.publish, deliverablemod.restricted, deliverablemod.accessdescription, deliverablemod.parentmodificationid, deliverablemod.parentdeliverableid, deliverable.deliverabletypeid, deliverable.title, deliverable.description, modification.projectid FROM (((deliverablemod LEFT JOIN (SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate, deliverablemodstatus.modificationid, deliverablemodstatus.deliverableid FROM (deliverablemodstatus JOIN cvl.deliverablestatus USING (deliverablestatusid)) WHERE (deliverablemodstatus.deliverablestatusid = 10) ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) efd USING (modificationid, deliverableid)) JOIN deliverable USING (deliverableid)) JOIN modification USING (modificationid)) WHERE ((NOT deliverablemod.invalid) OR (NOT (EXISTS (SELECT 1 FROM deliverablemod dm WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid))))));

COMMENT ON VIEW deliverablelist IS 'List of all valid, non-modified deliverables';

CREATE VIEW projectcontactfull AS
	SELECT pc.projectcontactid, pc.projectid, pc.contactid, pc.roletypeid, pc.priority, pc.contactprojectcode, pc.partner, pc.name, roletype.code AS role, pc.type FROM ((SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, pg_catalog.concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name, 'person'::text AS type FROM (projectcontact JOIN person USING (contactid)) UNION SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, contactgrouplist.fullname, 'group'::text AS type FROM (projectcontact JOIN contactgrouplist USING (contactid))) pc JOIN cvl.roletype USING (roletypeid)) ORDER BY pc.priority;

ALTER TABLE projectcontactfull
  OWNER TO bradley;
GRANT ALL ON TABLE projectcontactfull TO bradley;
GRANT SELECT ON TABLE projectcontactfull TO pts_read;

CREATE OR REPLACE VIEW projectcontactlist AS
	SELECT pc.projectcontactid, pc.projectid, pc.contactid, pc.roletypeid, pc.priority, pc.contactprojectcode, pc.partner, pc.name, roletype.code AS role FROM ((SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, pg_catalog.concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name FROM (projectcontact JOIN person USING (contactid)) UNION SELECT projectcontact.projectcontactid, projectcontact.projectid, projectcontact.contactid, projectcontact.roletypeid, projectcontact.priority, projectcontact.contactprojectcode, projectcontact.partner, contactgroup.name FROM (projectcontact JOIN contactgroup USING (contactid))) pc JOIN cvl.roletype USING (roletypeid)) ORDER BY pc.priority;
