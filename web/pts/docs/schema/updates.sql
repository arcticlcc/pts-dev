-- Version 0.14.1

SET search_path = alcc, pg_catalog;

CREATE OR REPLACE VIEW projectlist AS
    SELECT DISTINCT project.projectid,
    project.orgid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    project.shorttitle,
    status.status,
    project.exportmetadata,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged
   FROM ((((((alcc.project
     JOIN alcc.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN alcc.modification USING (projectid))
     LEFT JOIN alcc.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((alcc.invoice invoice_1
             JOIN alcc.funding funding_1 USING (fundingid))
             JOIN alcc.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (alcc.funding funding_1
             JOIN alcc.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid));

CREATE OR REPLACE VIEW longprojectsummary AS
    SELECT DISTINCT project.projectid,
    project.orgid,
    project.projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators,
    project.shorttitle,
    project.abstract,
    project.description,
    project.status,
    project.allocated,
    project.invoiced,
    project.difference,
    project.leveraged,
    project.total
   FROM ((( SELECT DISTINCT project_1.projectid,
            project_1.orgid,
            common.form_projectcode((project_1.number)::integer, (project_1.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
            project_1.title,
            project_1.parentprojectid,
            project_1.fiscalyear,
            project_1.number,
            project_1.startdate,
            project_1.enddate,
            project_1.uuid,
            project_1.shorttitle,
            project_1.abstract,
            project_1.description,
            status.status,
            COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) AS allocated,
            COALESCE(invoice.amount, 0.00) AS invoiced,
            (COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
            COALESCE(leveraged.leveraged, 0.00) AS leveraged,
            (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00)) AS total
           FROM ((((((alcc.project project_1
             LEFT JOIN alcc.modification USING (projectid))
             LEFT JOIN alcc.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
             LEFT JOIN ( SELECT modification_1.projectid,
                    sum(invoice_1.amount) AS amount
                   FROM ((alcc.invoice invoice_1
                     JOIN alcc.funding funding_1 USING (fundingid))
                     JOIN alcc.modification modification_1 USING (modificationid))
                  WHERE (funding_1.fundingtypeid = 1)
                  GROUP BY modification_1.projectid) invoice USING (projectid))
             LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
                    sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
                   FROM (alcc.funding funding_1
                     JOIN alcc.modification modification_1 USING (modificationid))
                  WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
             JOIN cvl.status ON ((common.project_status(project_1.projectid) = status.statusid)))
             JOIN alcc.contactgroup ON ((project_1.orgid = contactgroup.contactid)))) project
     LEFT JOIN ( SELECT projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.projectcontactid,
            row_number() OVER (PARTITION BY projectcontact.projectid, projectcontact.roletypeid ORDER BY projectcontact.priority) AS rank
           FROM alcc.projectcontact) pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid,
                    contactgroup.organization,
                    contactgroup.name,
                    contactgroup.acronym,
                    contactcontactgroup.groupid,
                    (contactgroup.name)::text AS fullname,
                    NULL::text AS parentname,
                    ARRAY[contactgroup.contactid] AS contactids
                   FROM (alcc.contactgroup
                     LEFT JOIN alcc.contactcontactgroup USING (contactid))
                  WHERE (contactcontactgroup.groupid IS NULL)
                UNION ALL
                 SELECT ccg_1.contactid,
                    cg_1.organization,
                    cg_1.name,
                    cg_1.acronym,
                    gt.contactid,
                    (((gt.acronym)::text || ' -> '::text) || (cg_1.name)::text) AS full_name,
                    gt.name,
                    array_append(gt.contactids, cg_1.contactid) AS array_append
                   FROM ((alcc.contactgroup cg_1
                     JOIN alcc.contactcontactgroup ccg_1 USING (contactid))
                     JOIN grouptree gt ON ((ccg_1.groupid = gt.contactid)))
                )
         SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || cg.fullname), ''::text)) AS fullname
           FROM ((alcc.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM alcc.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN grouptree cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
  ORDER BY project.fiscalyear, project.number;

CREATE OR REPLACE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            contactgroup_1.name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            (contactgroup_1.name)::text AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (alcc.contactgroup contactgroup_1
             LEFT JOIN alcc.contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            cg.name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' -> '::text) || (cg.name)::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((alcc.contactgroup cg
             JOIN alcc.contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), funds AS (
         SELECT modification.projectid,
            common.getfiscalyear(modification.startdate) AS fiscalyear,
            grouptree.fullname,
            projectcontact.contactid,
            sum(funding.amount) AS funds
           FROM (((alcc.modification
             JOIN alcc.funding USING (modificationid))
             JOIN alcc.projectcontact USING (projectcontactid))
             JOIN grouptree USING (contactid))
          WHERE (NOT (funding.fundingtypeid = 4))
          GROUP BY modification.projectid, common.getfiscalyear(modification.startdate), grouptree.fullname, projectcontact.contactid
        ), cofund AS (
         SELECT projectcontact.projectid,
            grouptree.fullname,
            row_number() OVER (PARTITION BY projectcontact.projectid) AS rank
           FROM (((alcc.projectcontact
             JOIN alcc.contactgroup contactgroup_1 USING (contactid))
             JOIN alcc.contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = 42))) AND (contact.contacttypeid = 5))
          ORDER BY projectcontact.projectid, projectcontact.priority
        ), deltype AS (
         SELECT d.projectid,
            d.catalog,
            d.type,
            row_number() OVER (PARTITION BY d.projectid) AS rank
           FROM ( SELECT DISTINCT modification.projectid,
                    deliverabletype.catalog,
                        CASE
                            WHEN (deliverabletype.catalog IS NOT NULL) THEN NULL::character varying
                            ELSE deliverabletype.type
                        END AS type
                   FROM (((alcc.deliverablemod
                     JOIN alcc.deliverable USING (deliverableid))
                     JOIN cvl.deliverabletype USING (deliverabletypeid))
                     JOIN alcc.modification USING (modificationid))
                  WHERE (((NOT deliverablemod.invalid) OR (NOT (EXISTS ( SELECT 1
                           FROM alcc.deliverablemod dm
                          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))))) AND (deliverable.deliverabletypeid <> ALL (ARRAY[4, 6, 7, 13])))
                  ORDER BY modification.projectid, deliverabletype.catalog) d
        )
 SELECT DISTINCT replace((contactgroup.name)::text, ' Landscape Conservation Cooperative'::text, ''::text) AS lccname,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS id,
    project.title AS ptitle,
    project.description,
    status.status AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    ('http://arcticlcc.org/projects/'::text || (common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym))::text) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((alcc.projectcontact
             JOIN alcc.contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    NULL::text AS endusers,
    fy.fiscalyears,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 1))) AS cofundlcc1,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 2))) AS cofundlcc2,
    NULL::text AS scibaseq,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = 42))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = 42)))
          GROUP BY funds.projectid) AS matchfundall,
    matchfundby.matchfundby,
    NULL::text AS matchfundnote,
    catalogprojectcategory.category1,
    catalogprojectcategory.category2,
    catalogprojectcategory.category3,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 1))) AS deliver1,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 2))) AS deliver2,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 3))) AS deliver3,
    lower(subject.keywords) AS subject,
    ('arctic'::text || COALESCE((','::text || commongeom.name), ''::text)) AS geog,
    NULL::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM ((((((((((alcc.project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((alcc.projectcontact pc_1
             JOIN alcc.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 7))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM alcc.eaddress eaddress_1) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM alcc.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN alcc.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pi USING (projectid))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((alcc.projectcontact pc_1
             JOIN alcc.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 6))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM alcc.eaddress eaddress_1) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM alcc.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN alcc.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pc USING (projectid))
     JOIN alcc.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN ( SELECT mod.projectid,
            string_agg((common.getfiscalyear(mod.startdate))::text, ','::text ORDER BY mod.startdate) AS fiscalyears
           FROM ( SELECT DISTINCT ON (modification.projectid, common.getfiscalyear(modification.startdate)) modification.modificationid,
                    modification.projectid,
                    modification.personid,
                    modification.modtypeid,
                    modification.title,
                    modification.description,
                    modification.modificationcode,
                    modification.effectivedate,
                    modification.startdate,
                    modification.enddate,
                    modification.datecreated,
                    modification.parentmodificationid,
                    modification.shorttitle,
                    funding.fundingid,
                    funding.fundingtypeid,
                    funding.title,
                    funding.amount,
                    funding.projectcontactid,
                    funding.fundingrecipientid
                   FROM (alcc.modification
                     JOIN alcc.funding USING (modificationid))
                  WHERE (modification.startdate IS NOT NULL)) mod(modificationid, projectid, personid, modtypeid, title, description, modificationcode, effectivedate, startdate, enddate, datecreated, parentmodificationid, shorttitle, fundingid, fundingtypeid, title_1, amount, projectcontactid, fundingrecipientid)
          GROUP BY mod.projectid) fy ON ((fy.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg(((((funds.funds)::text || ','::text) || funds.fiscalyear) || ',USFWS'::text), '; '::text) AS lccfundby
           FROM funds
          WHERE (funds.contactid = 42)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds
          WHERE (NOT (funds.contactid = 42))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, ', '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), ', '::text) AS joined
           FROM (alcc.projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT string_agg((commonpolygon.name)::text, ','::text) AS name,
            projectpolygon.projectid
           FROM alcc.projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN alcc.catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

CREATE OR REPLACE VIEW projectfunding AS
    SELECT DISTINCT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.fiscalyear,
    project.number,
    project.title,
    project.shorttitle,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00)) AS total,
    status.status
   FROM ((((((alcc.project
     JOIN alcc.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN alcc.modification USING (projectid))
     LEFT JOIN alcc.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((alcc.invoice invoice_1
             JOIN alcc.funding funding_1 USING (fundingid))
             JOIN alcc.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (alcc.funding funding_1
             JOIN alcc.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
  ORDER BY project.fiscalyear, project.number;

SET search_path = dev, pg_catalog;

CREATE OR REPLACE VIEW projectlist AS
    SELECT DISTINCT project.projectid,
    project.orgid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    project.shorttitle,
    status.status,
    project.exportmetadata,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged
   FROM ((((((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN modification USING (projectid))
     LEFT JOIN funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((invoice invoice_1
             JOIN funding funding_1 USING (fundingid))
             JOIN modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (funding funding_1
             JOIN modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid));

CREATE OR REPLACE VIEW longprojectsummary AS
    SELECT DISTINCT project.projectid,
    project.orgid,
    project.projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators,
    project.shorttitle,
    project.abstract,
    project.description,
    project.status,
    project.allocated,
    project.invoiced,
    project.difference,
    project.leveraged,
    project.total
   FROM ((( SELECT DISTINCT project_1.projectid,
            project_1.orgid,
            common.form_projectcode((project_1.number)::integer, (project_1.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
            project_1.title,
            project_1.parentprojectid,
            project_1.fiscalyear,
            project_1.number,
            project_1.startdate,
            project_1.enddate,
            project_1.uuid,
            project_1.shorttitle,
            project_1.abstract,
            project_1.description,
            status.status,
            COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) AS allocated,
            COALESCE(invoice.amount, 0.00) AS invoiced,
            (COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
            COALESCE(leveraged.leveraged, 0.00) AS leveraged,
            (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00)) AS total
           FROM ((((((project project_1
             LEFT JOIN modification USING (projectid))
             LEFT JOIN funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
             LEFT JOIN ( SELECT modification_1.projectid,
                    sum(invoice_1.amount) AS amount
                   FROM ((invoice invoice_1
                     JOIN funding funding_1 USING (fundingid))
                     JOIN modification modification_1 USING (modificationid))
                  WHERE (funding_1.fundingtypeid = 1)
                  GROUP BY modification_1.projectid) invoice USING (projectid))
             LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
                    sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
                   FROM (funding funding_1
                     JOIN modification modification_1 USING (modificationid))
                  WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
             JOIN cvl.status ON ((common.project_status(project_1.projectid) = status.statusid)))
             JOIN contactgroup ON ((project_1.orgid = contactgroup.contactid)))) project
     LEFT JOIN ( SELECT projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.projectcontactid,
            row_number() OVER (PARTITION BY projectcontact.projectid, projectcontact.roletypeid ORDER BY projectcontact.priority) AS rank
           FROM projectcontact) pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid,
                    contactgroup.organization,
                    contactgroup.name,
                    contactgroup.acronym,
                    contactcontactgroup.groupid,
                    (contactgroup.name)::text AS fullname,
                    NULL::text AS parentname,
                    ARRAY[contactgroup.contactid] AS contactids
                   FROM (contactgroup
                     LEFT JOIN contactcontactgroup USING (contactid))
                  WHERE (contactcontactgroup.groupid IS NULL)
                UNION ALL
                 SELECT ccg_1.contactid,
                    cg_1.organization,
                    cg_1.name,
                    cg_1.acronym,
                    gt.contactid,
                    (((gt.acronym)::text || ' -> '::text) || (cg_1.name)::text) AS full_name,
                    gt.name,
                    array_append(gt.contactids, cg_1.contactid) AS array_append
                   FROM ((contactgroup cg_1
                     JOIN contactcontactgroup ccg_1 USING (contactid))
                     JOIN grouptree gt ON ((ccg_1.groupid = gt.contactid)))
                )
         SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || cg.fullname), ''::text)) AS fullname
           FROM ((person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN grouptree cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
  ORDER BY project.fiscalyear, project.number;

CREATE OR REPLACE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            contactgroup_1.name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            (contactgroup_1.name)::text AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            cg.name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' -> '::text) || (cg.name)::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), funds AS (
         SELECT modification.projectid,
            common.getfiscalyear(modification.startdate) AS fiscalyear,
            grouptree.fullname,
            projectcontact.contactid,
            sum(funding.amount) AS funds
           FROM (((modification
             JOIN funding USING (modificationid))
             JOIN projectcontact USING (projectcontactid))
             JOIN grouptree USING (contactid))
          WHERE (NOT (funding.fundingtypeid = 4))
          GROUP BY modification.projectid, common.getfiscalyear(modification.startdate), grouptree.fullname, projectcontact.contactid
        ), cofund AS (
         SELECT projectcontact.projectid,
            grouptree.fullname,
            row_number() OVER (PARTITION BY projectcontact.projectid) AS rank
           FROM (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = 42))) AND (contact.contacttypeid = 5))
          ORDER BY projectcontact.projectid, projectcontact.priority
        ), deltype AS (
         SELECT d.projectid,
            d.catalog,
            d.type,
            row_number() OVER (PARTITION BY d.projectid) AS rank
           FROM ( SELECT DISTINCT modification.projectid,
                    deliverabletype.catalog,
                        CASE
                            WHEN (deliverabletype.catalog IS NOT NULL) THEN NULL::character varying
                            ELSE deliverabletype.type
                        END AS type
                   FROM (((deliverablemod
                     JOIN deliverable USING (deliverableid))
                     JOIN cvl.deliverabletype USING (deliverabletypeid))
                     JOIN modification USING (modificationid))
                  WHERE (((NOT deliverablemod.invalid) OR (NOT (EXISTS ( SELECT 1
                           FROM deliverablemod dm
                          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))))) AND (deliverable.deliverabletypeid <> ALL (ARRAY[4, 6, 7, 13])))
                  ORDER BY modification.projectid, deliverabletype.catalog) d
        )
 SELECT DISTINCT replace((contactgroup.name)::text, ' Landscape Conservation Cooperative'::text, ''::text) AS lccname,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS id,
    project.title AS ptitle,
    project.description,
    status.status AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    ('http://arcticlcc.org/projects/'::text || (common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym))::text) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    NULL::text AS endusers,
    fy.fiscalyears,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 1))) AS cofundlcc1,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 2))) AS cofundlcc2,
    NULL::text AS scibaseq,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = 42))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = 42)))
          GROUP BY funds.projectid) AS matchfundall,
    matchfundby.matchfundby,
    NULL::text AS matchfundnote,
    catalogprojectcategory.category1,
    catalogprojectcategory.category2,
    catalogprojectcategory.category3,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 1))) AS deliver1,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 2))) AS deliver2,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 3))) AS deliver3,
    lower(subject.keywords) AS subject,
    ('arctic'::text || COALESCE((','::text || commongeom.name), ''::text)) AS geog,
    NULL::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM ((((((((((project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((projectcontact pc_1
             JOIN person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 7))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM eaddress eaddress_1) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pi USING (projectid))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((projectcontact pc_1
             JOIN person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 6))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM eaddress eaddress_1) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pc USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN ( SELECT mod.projectid,
            string_agg((common.getfiscalyear(mod.startdate))::text, ','::text ORDER BY mod.startdate) AS fiscalyears
           FROM ( SELECT DISTINCT ON (modification.projectid, common.getfiscalyear(modification.startdate)) modification.modificationid,
                    modification.projectid,
                    modification.personid,
                    modification.modtypeid,
                    modification.title,
                    modification.description,
                    modification.modificationcode,
                    modification.effectivedate,
                    modification.startdate,
                    modification.enddate,
                    modification.datecreated,
                    modification.parentmodificationid,
                    modification.shorttitle,
                    funding.fundingid,
                    funding.fundingtypeid,
                    funding.title,
                    funding.amount,
                    funding.projectcontactid,
                    funding.fundingrecipientid
                   FROM (modification
                     JOIN funding USING (modificationid))
                  WHERE (modification.startdate IS NOT NULL)) mod(modificationid, projectid, personid, modtypeid, title, description, modificationcode, effectivedate, startdate, enddate, datecreated, parentmodificationid, shorttitle, fundingid, fundingtypeid, title_1, amount, projectcontactid, fundingrecipientid)
          GROUP BY mod.projectid) fy ON ((fy.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg(((((funds.funds)::text || ','::text) || funds.fiscalyear) || ',USFWS'::text), '; '::text) AS lccfundby
           FROM funds
          WHERE (funds.contactid = 42)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds
          WHERE (NOT (funds.contactid = 42))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, ', '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), ', '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT string_agg((commonpolygon.name)::text, ','::text) AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

CREATE OR REPLACE VIEW projectfunding AS
    SELECT DISTINCT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.fiscalyear,
    project.number,
    project.title,
    project.shorttitle,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00)) AS total,
    status.status
   FROM ((((((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN modification USING (projectid))
     LEFT JOIN funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((invoice invoice_1
             JOIN funding funding_1 USING (fundingid))
             JOIN modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (funding funding_1
             JOIN modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
  ORDER BY project.fiscalyear, project.number;

SET search_path = walcc, pg_catalog;

CREATE OR REPLACE VIEW projectlist AS
    SELECT DISTINCT project.projectid,
    project.orgid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    project.shorttitle,
    status.status,
    project.exportmetadata,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged
   FROM ((((((walcc.project
     JOIN walcc.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN walcc.modification USING (projectid))
     LEFT JOIN walcc.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((walcc.invoice invoice_1
             JOIN walcc.funding funding_1 USING (fundingid))
             JOIN walcc.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (walcc.funding funding_1
             JOIN walcc.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid));

CREATE OR REPLACE VIEW longprojectsummary AS
    SELECT DISTINCT project.projectid,
    project.orgid,
    project.projectcode,
    project.title,
    project.parentprojectid,
    project.fiscalyear,
    project.number,
    project.startdate,
    project.enddate,
    project.uuid,
    COALESCE(string_agg(pi.fullname, '; '::text) OVER (PARTITION BY project.projectid), 'No PI listed'::text) AS principalinvestigators,
    project.shorttitle,
    project.abstract,
    project.description,
    project.status,
    project.allocated,
    project.invoiced,
    project.difference,
    project.leveraged,
    project.total
   FROM ((( SELECT DISTINCT project_1.projectid,
            project_1.orgid,
            common.form_projectcode((project_1.number)::integer, (project_1.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
            project_1.title,
            project_1.parentprojectid,
            project_1.fiscalyear,
            project_1.number,
            project_1.startdate,
            project_1.enddate,
            project_1.uuid,
            project_1.shorttitle,
            project_1.abstract,
            project_1.description,
            status.status,
            COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) AS allocated,
            COALESCE(invoice.amount, 0.00) AS invoiced,
            (COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
            COALESCE(leveraged.leveraged, 0.00) AS leveraged,
            (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project_1.projectid), 0.00)) AS total
           FROM ((((((walcc.project project_1
             LEFT JOIN walcc.modification USING (projectid))
             LEFT JOIN walcc.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
             LEFT JOIN ( SELECT modification_1.projectid,
                    sum(invoice_1.amount) AS amount
                   FROM ((walcc.invoice invoice_1
                     JOIN walcc.funding funding_1 USING (fundingid))
                     JOIN walcc.modification modification_1 USING (modificationid))
                  WHERE (funding_1.fundingtypeid = 1)
                  GROUP BY modification_1.projectid) invoice USING (projectid))
             LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
                    sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
                   FROM (walcc.funding funding_1
                     JOIN walcc.modification modification_1 USING (modificationid))
                  WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
             JOIN cvl.status ON ((common.project_status(project_1.projectid) = status.statusid)))
             JOIN walcc.contactgroup ON ((project_1.orgid = contactgroup.contactid)))) project
     LEFT JOIN ( SELECT projectcontact.projectid,
            projectcontact.contactid,
            projectcontact.roletypeid,
            projectcontact.priority,
            projectcontact.contactprojectcode,
            projectcontact.partner,
            projectcontact.projectcontactid,
            row_number() OVER (PARTITION BY projectcontact.projectid, projectcontact.roletypeid ORDER BY projectcontact.priority) AS rank
           FROM walcc.projectcontact) pc ON (((project.projectid = pc.projectid) AND (pc.roletypeid = 7))))
     LEFT JOIN ( WITH RECURSIVE grouptree AS (
                 SELECT contactgroup.contactid,
                    contactgroup.organization,
                    contactgroup.name,
                    contactgroup.acronym,
                    contactcontactgroup.groupid,
                    (contactgroup.name)::text AS fullname,
                    NULL::text AS parentname,
                    ARRAY[contactgroup.contactid] AS contactids
                   FROM (walcc.contactgroup
                     LEFT JOIN walcc.contactcontactgroup USING (contactid))
                  WHERE (contactcontactgroup.groupid IS NULL)
                UNION ALL
                 SELECT ccg_1.contactid,
                    cg_1.organization,
                    cg_1.name,
                    cg_1.acronym,
                    gt.contactid,
                    (((gt.acronym)::text || ' -> '::text) || (cg_1.name)::text) AS full_name,
                    gt.name,
                    array_append(gt.contactids, cg_1.contactid) AS array_append
                   FROM ((walcc.contactgroup cg_1
                     JOIN walcc.contactcontactgroup ccg_1 USING (contactid))
                     JOIN grouptree gt ON ((ccg_1.groupid = gt.contactid)))
                )
         SELECT person.contactid,
            ((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((', '::text || cg.fullname), ''::text)) AS fullname
           FROM ((walcc.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM walcc.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN grouptree cg ON ((cg.contactid = ccg.groupid)))) pi USING (contactid))
  ORDER BY project.fiscalyear, project.number;

CREATE OR REPLACE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            contactgroup_1.name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            (contactgroup_1.name)::text AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (walcc.contactgroup contactgroup_1
             LEFT JOIN walcc.contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            cg.name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' -> '::text) || (cg.name)::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((walcc.contactgroup cg
             JOIN walcc.contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), funds AS (
         SELECT modification.projectid,
            common.getfiscalyear(modification.startdate) AS fiscalyear,
            grouptree.fullname,
            projectcontact.contactid,
            sum(funding.amount) AS funds
           FROM (((walcc.modification
             JOIN walcc.funding USING (modificationid))
             JOIN walcc.projectcontact USING (projectcontactid))
             JOIN grouptree USING (contactid))
          WHERE (NOT (funding.fundingtypeid = 4))
          GROUP BY modification.projectid, common.getfiscalyear(modification.startdate), grouptree.fullname, projectcontact.contactid
        ), cofund AS (
         SELECT projectcontact.projectid,
            grouptree.fullname,
            row_number() OVER (PARTITION BY projectcontact.projectid) AS rank
           FROM (((walcc.projectcontact
             JOIN walcc.contactgroup contactgroup_1 USING (contactid))
             JOIN walcc.contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = 42))) AND (contact.contacttypeid = 5))
          ORDER BY projectcontact.projectid, projectcontact.priority
        ), deltype AS (
         SELECT d.projectid,
            d.catalog,
            d.type,
            row_number() OVER (PARTITION BY d.projectid) AS rank
           FROM ( SELECT DISTINCT modification.projectid,
                    deliverabletype.catalog,
                        CASE
                            WHEN (deliverabletype.catalog IS NOT NULL) THEN NULL::character varying
                            ELSE deliverabletype.type
                        END AS type
                   FROM (((walcc.deliverablemod
                     JOIN walcc.deliverable USING (deliverableid))
                     JOIN cvl.deliverabletype USING (deliverabletypeid))
                     JOIN walcc.modification USING (modificationid))
                  WHERE (((NOT deliverablemod.invalid) OR (NOT (EXISTS ( SELECT 1
                           FROM walcc.deliverablemod dm
                          WHERE ((deliverablemod.modificationid = dm.parentmodificationid) AND (deliverablemod.deliverableid = dm.parentdeliverableid)))))) AND (deliverable.deliverabletypeid <> ALL (ARRAY[4, 6, 7, 13])))
                  ORDER BY modification.projectid, deliverabletype.catalog) d
        )
 SELECT DISTINCT replace((contactgroup.name)::text, ' Landscape Conservation Cooperative'::text, ''::text) AS lccname,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS id,
    project.title AS ptitle,
    project.description,
    status.status AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    ('http://arcticlcc.org/projects/'::text || (common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym))::text) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((walcc.projectcontact
             JOIN walcc.contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    NULL::text AS endusers,
    fy.fiscalyears,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 1))) AS cofundlcc1,
    ( SELECT replace(cofund.fullname, ' Landscape Conservation Cooperative'::text, ''::text) AS replace
           FROM cofund
          WHERE ((cofund.projectid = project.projectid) AND (cofund.rank = 2))) AS cofundlcc2,
    NULL::text AS scibaseq,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = 42))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = 42)))
          GROUP BY funds.projectid) AS matchfundall,
    matchfundby.matchfundby,
    NULL::text AS matchfundnote,
    catalogprojectcategory.category1,
    catalogprojectcategory.category2,
    catalogprojectcategory.category3,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 1))) AS deliver1,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 2))) AS deliver2,
    ( SELECT deltype.catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 3))) AS deliver3,
    lower(subject.keywords) AS subject,
    ('arctic'::text || COALESCE((','::text || commongeom.name), ''::text)) AS geog,
    NULL::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM ((((((((((walcc.project
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((walcc.projectcontact pc_1
             JOIN walcc.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 7))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM walcc.eaddress eaddress_1) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM walcc.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN walcc.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pi USING (projectid))
     LEFT JOIN ( SELECT DISTINCT pc_1.projectid,
            COALESCE(string_agg(((((person.firstname)::text || ' '::text) || (person.lastname)::text) || COALESCE((','::text || (eaddress.uri)::text), ''::text)), '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS principalinvestigators,
            COALESCE(string_agg(grouptree.fullname, '; '::text) OVER (PARTITION BY pc_1.projectid), 'No PI listed'::text) AS leadorg
           FROM (((((walcc.projectcontact pc_1
             JOIN walcc.person ON (((person.contactid = pc_1.contactid) AND (pc_1.roletypeid = 6))))
             LEFT JOIN ( SELECT eaddress_1.eaddressid,
                    eaddress_1.contactid,
                    eaddress_1.eaddresstypeid,
                    eaddress_1.uri,
                    eaddress_1.priority,
                    eaddress_1.comment,
                    row_number() OVER (PARTITION BY eaddress_1.contactid, eaddress_1.eaddresstypeid ORDER BY eaddress_1.priority) AS rank
                   FROM walcc.eaddress eaddress_1) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM walcc.contactcontactgroup) ccg ON (((person.contactid = ccg.contactid) AND (ccg.rank = 1))))
             LEFT JOIN walcc.contactgroup cg ON ((cg.contactid = ccg.groupid)))
             JOIN grouptree ON ((cg.contactid = grouptree.contactid)))) pc USING (projectid))
     JOIN walcc.contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN ( SELECT mod.projectid,
            string_agg((common.getfiscalyear(mod.startdate))::text, ','::text ORDER BY mod.startdate) AS fiscalyears
           FROM ( SELECT DISTINCT ON (modification.projectid, common.getfiscalyear(modification.startdate)) modification.modificationid,
                    modification.projectid,
                    modification.personid,
                    modification.modtypeid,
                    modification.title,
                    modification.description,
                    modification.modificationcode,
                    modification.effectivedate,
                    modification.startdate,
                    modification.enddate,
                    modification.datecreated,
                    modification.parentmodificationid,
                    modification.shorttitle,
                    funding.fundingid,
                    funding.fundingtypeid,
                    funding.title,
                    funding.amount,
                    funding.projectcontactid,
                    funding.fundingrecipientid
                   FROM (walcc.modification
                     JOIN walcc.funding USING (modificationid))
                  WHERE (modification.startdate IS NOT NULL)) mod(modificationid, projectid, personid, modtypeid, title, description, modificationcode, effectivedate, startdate, enddate, datecreated, parentmodificationid, shorttitle, fundingid, fundingtypeid, title_1, amount, projectcontactid, fundingrecipientid)
          GROUP BY mod.projectid) fy ON ((fy.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg(((((funds.funds)::text || ','::text) || funds.fiscalyear) || ',USFWS'::text), '; '::text) AS lccfundby
           FROM funds
          WHERE (funds.contactid = 42)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds
          WHERE (NOT (funds.contactid = 42))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, ', '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), ', '::text) AS joined
           FROM (walcc.projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT string_agg((commonpolygon.name)::text, ','::text) AS name,
            projectpolygon.projectid
           FROM walcc.projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN walcc.catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

CREATE OR REPLACE VIEW projectfunding AS
    SELECT DISTINCT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.fiscalyear,
    project.number,
    project.title,
    project.shorttitle,
    COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY project.projectid), 0.00)) AS total,
    status.status
   FROM ((((((walcc.project
     JOIN walcc.contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((common.project_status(project.projectid) = status.statusid)))
     LEFT JOIN walcc.modification USING (projectid))
     LEFT JOIN walcc.funding ON (((funding.modificationid = modification.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT modification_1.projectid,
            sum(invoice_1.amount) AS amount
           FROM ((walcc.invoice invoice_1
             JOIN walcc.funding funding_1 USING (fundingid))
             JOIN walcc.modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY modification_1.projectid) invoice USING (projectid))
     LEFT JOIN ( SELECT DISTINCT modification_1.projectid,
            sum(funding_1.amount) OVER (PARTITION BY modification_1.projectid) AS leveraged
           FROM (walcc.funding funding_1
             JOIN walcc.modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))) leveraged USING (projectid))
  ORDER BY project.fiscalyear, project.number;

SET search_path = alcc, pg_catalog;

CREATE VIEW fundingtotals AS
    SELECT DISTINCT mod.fiscalyear,
    COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00)) AS total
   FROM (((( SELECT modification.modificationid,
            modification.projectid,
            modification.personid,
            modification.modtypeid,
            modification.title,
            modification.description,
            modification.modificationcode,
            modification.effectivedate,
            modification.startdate,
            modification.enddate,
            modification.datecreated,
            modification.parentmodificationid,
            modification.shorttitle,
            common.getfiscalyear(modification.startdate) AS fiscalyear
           FROM modification) mod
     LEFT JOIN funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(invoice_1.amount) AS amount
           FROM ((invoice invoice_1
             JOIN funding funding_1 USING (fundingid))
             JOIN modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY common.getfiscalyear(modification_1.startdate)) invoice USING (fiscalyear))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(funding_1.amount) AS leveraged
           FROM (funding funding_1
             JOIN modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))
          GROUP BY common.getfiscalyear(modification_1.startdate)) leveraged USING (fiscalyear))
  ORDER BY mod.fiscalyear;

CREATE OR REPLACE VIEW projectagreementnumbers AS
    SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    modification.modificationcode AS agreementnumber,
    modification.title AS agreementtitle,
    modification.startdate,
    modification.enddate
   FROM ((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN modification USING (projectid))
  WHERE ((modification.modificationcode IS NOT NULL) AND (modification.modtypeid <> ALL (ARRAY[4, 9, 10])))
  ORDER BY project.fiscalyear, project.number;

SET search_path = dev, pg_catalog;

CREATE VIEW fundingtotals AS
    SELECT DISTINCT mod.fiscalyear,
    COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00)) AS total
   FROM (((( SELECT modification.modificationid,
            modification.projectid,
            modification.personid,
            modification.modtypeid,
            modification.title,
            modification.description,
            modification.modificationcode,
            modification.effectivedate,
            modification.startdate,
            modification.enddate,
            modification.datecreated,
            modification.parentmodificationid,
            modification.shorttitle,
            common.getfiscalyear(modification.startdate) AS fiscalyear
           FROM modification) mod
     LEFT JOIN funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(invoice_1.amount) AS amount
           FROM ((invoice invoice_1
             JOIN funding funding_1 USING (fundingid))
             JOIN modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY common.getfiscalyear(modification_1.startdate)) invoice USING (fiscalyear))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(funding_1.amount) AS leveraged
           FROM (funding funding_1
             JOIN modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))
          GROUP BY common.getfiscalyear(modification_1.startdate)) leveraged USING (fiscalyear))
  ORDER BY mod.fiscalyear;

CREATE OR REPLACE VIEW projectagreementnumbers AS
    SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    modification.modificationcode AS agreementnumber,
    modification.title AS agreementtitle,
    modification.startdate,
    modification.enddate
   FROM ((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN modification USING (projectid))
  WHERE ((modification.modificationcode IS NOT NULL) AND (modification.modtypeid <> ALL (ARRAY[4, 9, 10])))
  ORDER BY project.fiscalyear, project.number;

SET search_path = walcc, pg_catalog;

CREATE VIEW fundingtotals AS
    SELECT DISTINCT mod.fiscalyear,
    COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) AS allocated,
    COALESCE(invoice.amount, 0.00) AS invoiced,
    (COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00) - COALESCE(invoice.amount, 0.00)) AS difference,
    COALESCE(leveraged.leveraged, 0.00) AS leveraged,
    (COALESCE(leveraged.leveraged, 0.00) + COALESCE(sum(funding.amount) OVER (PARTITION BY mod.fiscalyear), 0.00)) AS total
   FROM (((( SELECT modification.modificationid,
            modification.projectid,
            modification.personid,
            modification.modtypeid,
            modification.title,
            modification.description,
            modification.modificationcode,
            modification.effectivedate,
            modification.startdate,
            modification.enddate,
            modification.datecreated,
            modification.parentmodificationid,
            modification.shorttitle,
            common.getfiscalyear(modification.startdate) AS fiscalyear
           FROM modification) mod
     LEFT JOIN funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(invoice_1.amount) AS amount
           FROM ((invoice invoice_1
             JOIN funding funding_1 USING (fundingid))
             JOIN modification modification_1 USING (modificationid))
          WHERE (funding_1.fundingtypeid = 1)
          GROUP BY common.getfiscalyear(modification_1.startdate)) invoice USING (fiscalyear))
     LEFT JOIN ( SELECT common.getfiscalyear(modification_1.startdate) AS fiscalyear,
            sum(funding_1.amount) AS leveraged
           FROM (funding funding_1
             JOIN modification modification_1 USING (modificationid))
          WHERE (NOT (funding_1.fundingtypeid = ANY (ARRAY[1, 4])))
          GROUP BY common.getfiscalyear(modification_1.startdate)) leveraged USING (fiscalyear))
  ORDER BY mod.fiscalyear;

CREATE OR REPLACE VIEW projectagreementnumbers AS
    SELECT common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.shorttitle,
    modification.modificationcode AS agreementnumber,
    modification.title AS agreementtitle,
    modification.startdate,
    modification.enddate
   FROM ((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN modification USING (projectid))
  WHERE ((modification.modificationcode IS NOT NULL) AND (modification.modtypeid <> ALL (ARRAY[4, 9, 10])))
  ORDER BY project.fiscalyear, project.number;

GRANT SELECT ON TABLE dev.fundingtotals TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.fundingtotals TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.fundingtotals TO GROUP pts_read;
