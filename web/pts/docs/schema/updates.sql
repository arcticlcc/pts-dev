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
     JOIN funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
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
     JOIN funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
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
     JOIN funding ON (((funding.modificationid = mod.modificationid) AND (funding.fundingtypeid = 1))))
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

SET search_path = dev, pg_catalog;

DROP VIEW projectawardinfo;

CREATE VIEW projectawardinfo AS
    SELECT common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (((pi.firstname)::text || ' '::text) || (pi.lastname)::text) AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (((fc.firstname)::text || ' '::text) || (fc.lastname)::text) AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso
   FROM (((((((((((((project p
     LEFT JOIN contactgroup ON ((p.orgid = contactgroup.contactid)))
     LEFT JOIN modification USING (projectid))
     LEFT JOIN cvl.status ON ((status.statusid = common.project_status(p.projectid))))
     LEFT JOIN funding USING (modificationid))
     LEFT JOIN projectcontact pc USING (projectcontactid))
     LEFT JOIN projectcontact rpc ON ((rpc.projectcontactid = funding.fundingrecipientid)))
     JOIN contactgrouplist rpg ON ((rpc.contactid = rpg.contactid)))
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM ((((projectcontact
             JOIN personlist pl USING (contactid))
             JOIN contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = 7)) pi ON ((((p.projectid = pi.projectid) AND (pi.rank = 1)) AND (rpg.contactids[1] = pi.contactids[1]))))
     LEFT JOIN address add ON (((add.contactid = pi.contactid) AND (add.addresstypeid = 1))))
     LEFT JOIN cvl.govunit ON ((govunit.featureid = add.stateid)))
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM ((((projectcontact
             JOIN personlist pl USING (contactid))
             JOIN contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = ANY (ARRAY[5, 13]))) fc ON ((((p.projectid = fc.projectid) AND (fc.rank = 1)) AND (rpg.contactids[1] = fc.contactids[1]))))
     LEFT JOIN address fadd ON (((fadd.contactid = fc.contactid) AND (fadd.addresstypeid = 1))))
     LEFT JOIN cvl.govunit fg ON ((fg.featureid = fadd.stateid)))
  WHERE (((((modification.parentmodificationid IS NULL) AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5]))) AND (status.weight >= 30)) AND (status.weight <= 60)) AND (pc.contactid = p.orgid))
  ORDER BY common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym);

  SET search_path = alcc, pg_catalog;

DROP VIEW projectawardinfo;

CREATE VIEW projectawardinfo AS
    SELECT common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (((pi.firstname)::text || ' '::text) || (pi.lastname)::text) AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (((fc.firstname)::text || ' '::text) || (fc.lastname)::text) AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso
   FROM (((((((((((((project p
     LEFT JOIN contactgroup ON ((p.orgid = contactgroup.contactid)))
     LEFT JOIN modification USING (projectid))
     LEFT JOIN cvl.status ON ((status.statusid = common.project_status(p.projectid))))
     LEFT JOIN funding USING (modificationid))
     LEFT JOIN projectcontact pc USING (projectcontactid))
     LEFT JOIN projectcontact rpc ON ((rpc.projectcontactid = funding.fundingrecipientid)))
     JOIN contactgrouplist rpg ON ((rpc.contactid = rpg.contactid)))
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM ((((projectcontact
             JOIN personlist pl USING (contactid))
             JOIN contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = 7)) pi ON ((((p.projectid = pi.projectid) AND (pi.rank = 1)) AND (rpg.contactids[1] = pi.contactids[1]))))
     LEFT JOIN address add ON (((add.contactid = pi.contactid) AND (add.addresstypeid = 1))))
     LEFT JOIN cvl.govunit ON ((govunit.featureid = add.stateid)))
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM ((((projectcontact
             JOIN personlist pl USING (contactid))
             JOIN contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = ANY (ARRAY[5, 13]))) fc ON ((((p.projectid = fc.projectid) AND (fc.rank = 1)) AND (rpg.contactids[1] = fc.contactids[1]))))
     LEFT JOIN address fadd ON (((fadd.contactid = fc.contactid) AND (fadd.addresstypeid = 1))))
     LEFT JOIN cvl.govunit fg ON ((fg.featureid = fadd.stateid)))
  WHERE (((((modification.parentmodificationid IS NULL) AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5]))) AND (status.weight >= 30)) AND (status.weight <= 60)) AND (pc.contactid = p.orgid))
  ORDER BY common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym);

  SET search_path = walcc, pg_catalog;

DROP VIEW projectawardinfo;

CREATE VIEW projectawardinfo AS
    SELECT common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (((pi.firstname)::text || ' '::text) || (pi.lastname)::text) AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (((fc.firstname)::text || ' '::text) || (fc.lastname)::text) AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso
   FROM (((((((((((((project p
     LEFT JOIN contactgroup ON ((p.orgid = contactgroup.contactid)))
     LEFT JOIN modification USING (projectid))
     LEFT JOIN cvl.status ON ((status.statusid = common.project_status(p.projectid))))
     LEFT JOIN funding USING (modificationid))
     LEFT JOIN projectcontact pc USING (projectcontactid))
     LEFT JOIN projectcontact rpc ON ((rpc.projectcontactid = funding.fundingrecipientid)))
     JOIN contactgrouplist rpg ON ((rpc.contactid = rpg.contactid)))
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM ((((projectcontact
             JOIN personlist pl USING (contactid))
             JOIN contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = 7)) pi ON ((((p.projectid = pi.projectid) AND (pi.rank = 1)) AND (rpg.contactids[1] = pi.contactids[1]))))
     LEFT JOIN address add ON (((add.contactid = pi.contactid) AND (add.addresstypeid = 1))))
     LEFT JOIN cvl.govunit ON ((govunit.featureid = add.stateid)))
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM ((((projectcontact
             JOIN personlist pl USING (contactid))
             JOIN contactgrouplist ON ((pl.prigroupid = contactgrouplist.contactid)))
             LEFT JOIN contactcontactgroup ccg ON (((pl.contactid = ccg.contactid) AND (ccg.groupid = pl.prigroupid))))
             LEFT JOIN cvl."position" USING (positionid))
          WHERE (projectcontact.roletypeid = ANY (ARRAY[5, 13]))) fc ON ((((p.projectid = fc.projectid) AND (fc.rank = 1)) AND (rpg.contactids[1] = fc.contactids[1]))))
     LEFT JOIN address fadd ON (((fadd.contactid = fc.contactid) AND (fadd.addresstypeid = 1))))
     LEFT JOIN cvl.govunit fg ON ((fg.featureid = fadd.stateid)))
  WHERE (((((modification.parentmodificationid IS NULL) AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5]))) AND (status.weight >= 30)) AND (status.weight <= 60)) AND (pc.contactid = p.orgid))
  ORDER BY common.form_projectcode((p.number)::integer, (p.fiscalyear)::integer, contactgroup.acronym);

GRANT SELECT ON TABLE alcc.projectawardinfo TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.projectawardinfo TO GROUP pts_read;
GRANT SELECT ON TABLE dev.projectawardinfo TO GROUP pts_read;

COMMENT ON VIEW dev.projectawardinfo
  IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';
COMMENT ON VIEW alcc.projectawardinfo
  IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';
COMMENT ON VIEW walcc.projectawardinfo
  IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';

DROP VIEW alcc.alccstaff;
DROP VIEW alcc.alccsteeringcommittee;
DROP VIEW alcc.metadatacontact;
DROP VIEW alcc.deliverabledue;
DROP VIEW alcc.noticesent;
DROP VIEW alcc.projectawardinfo;
DROP VIEW alcc.personlist;
DROP VIEW alcc.projectadmin;

ALTER TABLE alcc.phone
    ALTER COLUMN extension SET DATA TYPE integer;

-- View: alcc.alccstaff

-- DROP VIEW alcc.alccstaff;

CREATE OR REPLACE VIEW alcc.alccstaff AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM alcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM alcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM alcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM alcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN alcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN alcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42
     JOIN alcc.contact ON contact.contactid = person.contactid AND contact.contacttypeid = 5
  ORDER BY person.lastname;

ALTER TABLE alcc.alccstaff
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.alccstaff TO bradley;
GRANT SELECT ON TABLE alcc.alccstaff TO pts_read;

    -- View: alcc.alccsteeringcommittee

-- DROP VIEW alcc.alccsteeringcommittee;

CREATE OR REPLACE VIEW alcc.alccsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM alcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM alcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM alcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM alcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN alcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN alcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND (sc.positionid = ANY (ARRAY[85, 96]))
     JOIN "position" ON sc.positionid = "position".positionid
  ORDER BY person.lastname;

ALTER TABLE alcc.alccsteeringcommittee
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.alccsteeringcommittee TO bradley;
GRANT SELECT ON TABLE alcc.alccsteeringcommittee TO pts_read;

-- View: alcc.metadatacontact

-- DROP VIEW alcc.metadatacontact;

CREATE OR REPLACE VIEW alcc.metadatacontact AS
 SELECT c.contactid AS "contactId",
    c."individualName",
    c."organizationName",
    c."positionName",
    c.uri,
    ((((('+'::text || p.code::text) || ' '::text) || p.areacode) || ' '::text) || p.phnumber) || COALESCE(' x'::text || p.extension, ''::text) AS "officePhone",
    add.street1 AS "deliveryPoint1",
    add.street2 AS "deliveryPoint2",
    add.city,
    govunit.statename AS "administrativeArea",
    add.postalcode::text || COALESCE('-'::text || add.postal4, ''::text) AS "postalCode",
    govunit.countryname AS country,
    e.uri AS email
   FROM ( SELECT person.contactid,
            (((person.firstname::text || COALESCE(' '::text || person.middlename::text, ''::text)) || ' '::text) || person.lastname::text) || COALESCE(', '::text || person.suffix::text, ''::text) AS "individualName",
            cg.fullname AS "organizationName",
            pos.code AS "positionName",
            web.uri
           FROM alcc.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM alcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
             LEFT JOIN alcc.contactgrouplist cg ON cg.contactid = ccg.groupid
             LEFT JOIN "position" pos ON ccg.positionid = pos.positionid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM alcc.eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = ccg.groupid
        UNION
         SELECT cg.contactid,
            NULL::text AS "individualName",
            cl.fullname AS "organizationName",
            NULL::character varying AS "positionName",
            web.uri
           FROM alcc.contactgroup cg
             LEFT JOIN alcc.contactgrouplist cl ON cl.contactid = cg.contactid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM alcc.eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = cg.contactid) c
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            country.phone AS code,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM alcc.phone
             JOIN country USING (countryiso)
          WHERE phone.phonetypeid = 3) p ON c.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM alcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON c.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT address.addressid,
            address.contactid,
            address.addresstypeid,
            address.street1,
            address.street2,
            address.postalcode,
            address.postal4,
            address.stateid,
            address.countyid,
            address.countryiso,
            address.comment,
            address.latitude,
            address.longitude,
            address.priority,
            address.city,
            row_number() OVER (PARTITION BY address.contactid ORDER BY address.addresstypeid DESC, address.priority) AS rank
           FROM alcc.address) add ON c.contactid = add.contactid AND add.rank = 1
     LEFT JOIN govunit ON add.stateid = govunit.featureid;

ALTER TABLE alcc.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.metadatacontact TO bradley;
GRANT SELECT ON TABLE alcc.metadatacontact TO pts_read;

-- View: alcc.projectadmin

-- DROP VIEW alcc.projectadmin;

CREATE OR REPLACE VIEW alcc.projectadmin AS
 SELECT DISTINCT ON (person.lastname, person.contactid) person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
        CASE
            WHEN project_status(pc.projectid) = ANY (ARRAY[1, 2, 5]) THEN 'No'::text
            ELSE 'Yes'::text
        END AS active
   FROM alcc.person
     JOIN alcc.contact USING (contactid)
     JOIN alcc.projectcontact pc ON person.contactid = pc.contactid
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM alcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM alcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM alcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN alcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN roletype USING (roletypeid)
  WHERE (pc.roletypeid = ANY (ARRAY[7, 5, 13, 6])) AND NOT contact.inactive
  ORDER BY person.lastname, person.contactid;

ALTER TABLE alcc.projectadmin
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.projectadmin TO bradley;
GRANT SELECT ON TABLE alcc.projectadmin TO pts_read;
COMMENT ON VIEW alcc.projectadmin
  IS 'Contacts serving in an admin role for projects (i.e. Financial Officer, Primary Contact, Principal Investigator, Grants Admin).';

-- View: alcc.personlist

-- DROP VIEW alcc.personlist;

CREATE OR REPLACE VIEW alcc.personlist AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM alcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM alcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM alcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM alcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN alcc.contactgroup cg ON cg.contactid = ccg.groupid
  ORDER BY person.lastname, person.contactid;

ALTER TABLE alcc.personlist
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.personlist TO bradley;
GRANT SELECT ON TABLE alcc.personlist TO pts_read;

-- View: alcc.projectawardinfo

-- DROP VIEW alcc.projectawardinfo;

CREATE OR REPLACE VIEW alcc.projectawardinfo AS
 SELECT form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (pi.firstname::text || ' '::text) || pi.lastname::text AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (fc.firstname::text || ' '::text) || fc.lastname::text AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso
   FROM alcc.project p
     LEFT JOIN alcc.contactgroup ON p.orgid = contactgroup.contactid
     LEFT JOIN alcc.modification USING (projectid)
     LEFT JOIN status ON status.statusid = project_status(p.projectid)
     LEFT JOIN alcc.funding USING (modificationid)
     LEFT JOIN alcc.projectcontact pc USING (projectcontactid)
     LEFT JOIN alcc.projectcontact rpc ON rpc.projectcontactid = funding.fundingrecipientid
     JOIN alcc.contactgrouplist rpg ON rpc.contactid = rpg.contactid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM alcc.projectcontact
             JOIN alcc.personlist pl USING (contactid)
             JOIN alcc.contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN alcc.contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN "position" USING (positionid)
          WHERE projectcontact.roletypeid = 7) pi ON p.projectid = pi.projectid AND pi.rank = 1 AND rpg.contactids[1] = pi.contactids[1]
     LEFT JOIN alcc.address add ON add.contactid = pi.contactid AND add.addresstypeid = 1
     LEFT JOIN govunit ON govunit.featureid = add.stateid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM alcc.projectcontact
             JOIN alcc.personlist pl USING (contactid)
             JOIN alcc.contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN alcc.contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN "position" USING (positionid)
          WHERE projectcontact.roletypeid = ANY (ARRAY[5, 13])) fc ON p.projectid = fc.projectid AND fc.rank = 1 AND rpg.contactids[1] = fc.contactids[1]
     LEFT JOIN alcc.address fadd ON fadd.contactid = fc.contactid AND fadd.addresstypeid = 1
     LEFT JOIN govunit fg ON fg.featureid = fadd.stateid
  WHERE modification.parentmodificationid IS NULL AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5])) AND status.weight >= 30 AND status.weight <= 60 AND pc.contactid = p.orgid
  ORDER BY form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym);

ALTER TABLE alcc.projectawardinfo
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.projectawardinfo TO bradley;
GRANT SELECT ON TABLE alcc.projectawardinfo TO pts_read;
COMMENT ON VIEW alcc.projectawardinfo
  IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';

-- View: alcc.noticesent

-- DROP VIEW alcc.noticesent;

CREATE OR REPLACE VIEW alcc.noticesent AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM alcc.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    d.title,
    d.description,
    notice.code AS lastnotice,
    deliverablenotice.datesent,
    projectlist.projectcode,
    project.shorttitle AS project,
    (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact,
    personlist.priemail AS email,
    (folist.firstname::text || ' '::text) || folist.lastname::text AS fofficer,
    folist.priemail AS foemail,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue,
    COALESCE(status.status, 'Not Received'::character varying) AS status,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate
   FROM alcc.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN ( SELECT deliverablemod.modificationid,
            deliverablemod.deliverableid,
            deliverablemod.duedate,
            deliverablemod.receiveddate,
            deliverablemod.devinterval,
            deliverablemod.publish,
            deliverablemod.restricted,
            deliverablemod.accessdescription,
            deliverablemod.parentmodificationid,
            deliverablemod.parentdeliverableid,
            deliverablemod.personid,
            deliverablemod.startdate,
            deliverablemod.enddate
           FROM alcc.deliverablemod
          WHERE NOT (EXISTS ( SELECT 1
                   FROM alcc.deliverablemod dp
                  WHERE dp.modificationid = dp.parentmodificationid AND dp.deliverableid = dp.parentdeliverableid))) dm USING (deliverableid)
     JOIN alcc.modification USING (modificationid)
     JOIN alcc.projectlist USING (projectid)
     JOIN alcc.project USING (projectid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM alcc.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[7])) projectcontact USING (projectid)
     LEFT JOIN alcc.personlist USING (contactid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM alcc.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = 5
          ORDER BY projectcontact_1.priority) focontact USING (projectid)
     LEFT JOIN alcc.personlist folist ON focontact.contactid = folist.contactid
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM alcc.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN alcc.deliverablenotice USING (deliverableid)
     LEFT JOIN notice USING (noticeid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT COALESCE(status.deliverablestatusid >= 10, false) AND
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END > (-30) AND NOT (EXISTS ( SELECT 1
           FROM alcc.deliverablemod d_1
          WHERE dm.modificationid = d_1.parentmodificationid AND dm.deliverableid = d_1.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;

ALTER TABLE alcc.noticesent
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.noticesent TO bradley;
GRANT SELECT ON TABLE alcc.noticesent TO pts_read;

-- View: alcc.deliverabledue

-- DROP VIEW alcc.deliverabledue;

CREATE OR REPLACE VIEW alcc.deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM alcc.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    projectlist.projectcode,
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
    dm.enddate
   FROM alcc.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN alcc.deliverablemod dm USING (deliverableid)
     JOIN alcc.modification USING (modificationid)
     JOIN alcc.projectlist USING (projectid)
     JOIN alcc.project USING (projectid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM alcc.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[6, 7])) projectcontact USING (projectid)
     LEFT JOIN alcc.personlist USING (contactid)
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
           FROM alcc.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM alcc.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT (EXISTS ( SELECT 1
           FROM alcc.deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

ALTER TABLE alcc.deliverabledue
  OWNER TO bradley;
GRANT ALL ON TABLE alcc.deliverabledue TO bradley;
GRANT SELECT ON TABLE alcc.deliverabledue TO pts_read;


----dev----
DROP VIEW dev.alccstaff;
DROP VIEW dev.alccsteeringcommittee;
DROP VIEW dev.metadatacontact;
DROP VIEW dev.deliverabledue;
DROP VIEW dev.noticesent;
DROP VIEW dev.projectawardinfo;
DROP VIEW dev.devsteeringcommittee;
DROP VIEW dev.personlist;
DROP VIEW dev.projectadmin;

ALTER TABLE dev.phone
    ALTER COLUMN extension SET DATA TYPE integer;

-- View: dev.alccstaff

-- DROP VIEW dev.alccstaff;

CREATE OR REPLACE VIEW dev.alccstaff AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM dev.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM dev.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM dev.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM dev.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN dev.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN dev.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42
     JOIN dev.contact ON contact.contactid = person.contactid AND contact.contacttypeid = 5
  ORDER BY person.lastname;

ALTER TABLE dev.alccstaff
  OWNER TO bradley;
GRANT ALL ON TABLE dev.alccstaff TO bradley;
GRANT SELECT ON TABLE dev.alccstaff TO pts_read;

    -- View: dev.alccsteeringcommittee

-- DROP VIEW dev.alccsteeringcommittee;

CREATE OR REPLACE VIEW dev.alccsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM dev.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM dev.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM dev.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM dev.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN dev.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN dev.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND (sc.positionid = ANY (ARRAY[85, 96]))
     JOIN "position" ON sc.positionid = "position".positionid
  ORDER BY person.lastname;

ALTER TABLE dev.alccsteeringcommittee
  OWNER TO bradley;
GRANT ALL ON TABLE dev.alccsteeringcommittee TO bradley;
GRANT SELECT ON TABLE dev.alccsteeringcommittee TO pts_read;

-- View: dev.metadatacontact

-- DROP VIEW dev.metadatacontact;

CREATE OR REPLACE VIEW dev.metadatacontact AS
 SELECT c.contactid AS "contactId",
    c."individualName",
    c."organizationName",
    c."positionName",
    c.uri,
    ((((('+'::text || p.code::text) || ' '::text) || p.areacode) || ' '::text) || p.phnumber) || COALESCE(' x'::text || p.extension, ''::text) AS "officePhone",
    add.street1 AS "deliveryPoint1",
    add.street2 AS "deliveryPoint2",
    add.city,
    govunit.statename AS "administrativeArea",
    add.postalcode::text || COALESCE('-'::text || add.postal4, ''::text) AS "postalCode",
    govunit.countryname AS country,
    e.uri AS email
   FROM ( SELECT person.contactid,
            (((person.firstname::text || COALESCE(' '::text || person.middlename::text, ''::text)) || ' '::text) || person.lastname::text) || COALESCE(', '::text || person.suffix::text, ''::text) AS "individualName",
            cg.fullname AS "organizationName",
            pos.code AS "positionName",
            web.uri
           FROM dev.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM dev.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
             LEFT JOIN dev.contactgrouplist cg ON cg.contactid = ccg.groupid
             LEFT JOIN "position" pos ON ccg.positionid = pos.positionid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM dev.eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = ccg.groupid
        UNION
         SELECT cg.contactid,
            NULL::text AS "individualName",
            cl.fullname AS "organizationName",
            NULL::character varying AS "positionName",
            web.uri
           FROM dev.contactgroup cg
             LEFT JOIN dev.contactgrouplist cl ON cl.contactid = cg.contactid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM dev.eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = cg.contactid) c
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            country.phone AS code,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM dev.phone
             JOIN country USING (countryiso)
          WHERE phone.phonetypeid = 3) p ON c.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM dev.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON c.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT address.addressid,
            address.contactid,
            address.addresstypeid,
            address.street1,
            address.street2,
            address.postalcode,
            address.postal4,
            address.stateid,
            address.countyid,
            address.countryiso,
            address.comment,
            address.latitude,
            address.longitude,
            address.priority,
            address.city,
            row_number() OVER (PARTITION BY address.contactid ORDER BY address.addresstypeid DESC, address.priority) AS rank
           FROM dev.address) add ON c.contactid = add.contactid AND add.rank = 1
     LEFT JOIN govunit ON add.stateid = govunit.featureid;

ALTER TABLE dev.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE dev.metadatacontact TO bradley;
GRANT SELECT ON TABLE dev.metadatacontact TO pts_read;

-- View: dev.projectadmin

-- DROP VIEW dev.projectadmin;

CREATE OR REPLACE VIEW dev.projectadmin AS
 SELECT DISTINCT ON (person.lastname, person.contactid) person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
        CASE
            WHEN project_status(pc.projectid) = ANY (ARRAY[1, 2, 5]) THEN 'No'::text
            ELSE 'Yes'::text
        END AS active
   FROM dev.person
     JOIN dev.contact USING (contactid)
     JOIN dev.projectcontact pc ON person.contactid = pc.contactid
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM dev.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM dev.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM dev.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN dev.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN roletype USING (roletypeid)
  WHERE (pc.roletypeid = ANY (ARRAY[7, 5, 13, 6])) AND NOT contact.inactive
  ORDER BY person.lastname, person.contactid;

ALTER TABLE dev.projectadmin
  OWNER TO bradley;
GRANT ALL ON TABLE dev.projectadmin TO bradley;
GRANT SELECT ON TABLE dev.projectadmin TO pts_read;
COMMENT ON VIEW dev.projectadmin
  IS 'Contacts serving in an admin role for projects (i.e. Financial Officer, Primary Contact, Principal Investigator, Grants Admin).';

-- View: dev.personlist

-- DROP VIEW dev.personlist;

CREATE OR REPLACE VIEW dev.personlist AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM dev.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM dev.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM dev.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM dev.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN dev.contactgroup cg ON cg.contactid = ccg.groupid
  ORDER BY person.lastname, person.contactid;

ALTER TABLE dev.personlist
  OWNER TO bradley;
GRANT ALL ON TABLE dev.personlist TO bradley;
GRANT SELECT ON TABLE dev.personlist TO pts_read;

-- View: dev.projectawardinfo

-- DROP VIEW dev.projectawardinfo;

CREATE OR REPLACE VIEW dev.projectawardinfo AS
 SELECT form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (pi.firstname::text || ' '::text) || pi.lastname::text AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (fc.firstname::text || ' '::text) || fc.lastname::text AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso
   FROM dev.project p
     LEFT JOIN dev.contactgroup ON p.orgid = contactgroup.contactid
     LEFT JOIN dev.modification USING (projectid)
     LEFT JOIN status ON status.statusid = project_status(p.projectid)
     LEFT JOIN dev.funding USING (modificationid)
     LEFT JOIN dev.projectcontact pc USING (projectcontactid)
     LEFT JOIN dev.projectcontact rpc ON rpc.projectcontactid = funding.fundingrecipientid
     JOIN dev.contactgrouplist rpg ON rpc.contactid = rpg.contactid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM dev.projectcontact
             JOIN dev.personlist pl USING (contactid)
             JOIN dev.contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN dev.contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN "position" USING (positionid)
          WHERE projectcontact.roletypeid = 7) pi ON p.projectid = pi.projectid AND pi.rank = 1 AND rpg.contactids[1] = pi.contactids[1]
     LEFT JOIN dev.address add ON add.contactid = pi.contactid AND add.addresstypeid = 1
     LEFT JOIN govunit ON govunit.featureid = add.stateid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM dev.projectcontact
             JOIN dev.personlist pl USING (contactid)
             JOIN dev.contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN dev.contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN "position" USING (positionid)
          WHERE projectcontact.roletypeid = ANY (ARRAY[5, 13])) fc ON p.projectid = fc.projectid AND fc.rank = 1 AND rpg.contactids[1] = fc.contactids[1]
     LEFT JOIN dev.address fadd ON fadd.contactid = fc.contactid AND fadd.addresstypeid = 1
     LEFT JOIN govunit fg ON fg.featureid = fadd.stateid
  WHERE modification.parentmodificationid IS NULL AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5])) AND status.weight >= 30 AND status.weight <= 60 AND pc.contactid = p.orgid
  ORDER BY form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym);

ALTER TABLE dev.projectawardinfo
  OWNER TO bradley;
GRANT ALL ON TABLE dev.projectawardinfo TO bradley;
GRANT SELECT ON TABLE dev.projectawardinfo TO pts_read;
COMMENT ON VIEW dev.projectawardinfo
  IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';

-- View: dev.noticesent

-- DROP VIEW dev.noticesent;

CREATE OR REPLACE VIEW dev.noticesent AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM dev.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    d.title,
    d.description,
    notice.code AS lastnotice,
    deliverablenotice.datesent,
    projectlist.projectcode,
    project.shorttitle AS project,
    (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact,
    personlist.priemail AS email,
    (folist.firstname::text || ' '::text) || folist.lastname::text AS fofficer,
    folist.priemail AS foemail,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue,
    COALESCE(status.status, 'Not Received'::character varying) AS status,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate
   FROM dev.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN ( SELECT deliverablemod.modificationid,
            deliverablemod.deliverableid,
            deliverablemod.duedate,
            deliverablemod.receiveddate,
            deliverablemod.devinterval,
            deliverablemod.publish,
            deliverablemod.restricted,
            deliverablemod.accessdescription,
            deliverablemod.parentmodificationid,
            deliverablemod.parentdeliverableid,
            deliverablemod.personid,
            deliverablemod.startdate,
            deliverablemod.enddate
           FROM dev.deliverablemod
          WHERE NOT (EXISTS ( SELECT 1
                   FROM dev.deliverablemod dp
                  WHERE dp.modificationid = dp.parentmodificationid AND dp.deliverableid = dp.parentdeliverableid))) dm USING (deliverableid)
     JOIN dev.modification USING (modificationid)
     JOIN dev.projectlist USING (projectid)
     JOIN dev.project USING (projectid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM dev.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[7])) projectcontact USING (projectid)
     LEFT JOIN dev.personlist USING (contactid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM dev.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = 5
          ORDER BY projectcontact_1.priority) focontact USING (projectid)
     LEFT JOIN dev.personlist folist ON focontact.contactid = folist.contactid
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM dev.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN dev.deliverablenotice USING (deliverableid)
     LEFT JOIN notice USING (noticeid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT COALESCE(status.deliverablestatusid >= 10, false) AND
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END > (-30) AND NOT (EXISTS ( SELECT 1
           FROM dev.deliverablemod d_1
          WHERE dm.modificationid = d_1.parentmodificationid AND dm.deliverableid = d_1.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;

ALTER TABLE dev.noticesent
  OWNER TO bradley;
GRANT ALL ON TABLE dev.noticesent TO bradley;
GRANT SELECT ON TABLE dev.noticesent TO pts_read;

-- View: dev.deliverabledue

-- DROP VIEW dev.deliverabledue;

CREATE OR REPLACE VIEW dev.deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM dev.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    projectlist.projectcode,
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
    dm.enddate
   FROM dev.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN dev.deliverablemod dm USING (deliverableid)
     JOIN dev.modification USING (modificationid)
     JOIN dev.projectlist USING (projectid)
     JOIN dev.project USING (projectid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM dev.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[6, 7])) projectcontact USING (projectid)
     LEFT JOIN dev.personlist USING (contactid)
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
           FROM dev.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM dev.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT (EXISTS ( SELECT 1
           FROM dev.deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

ALTER TABLE dev.deliverabledue
  OWNER TO bradley;
GRANT ALL ON TABLE dev.deliverabledue TO bradley;
GRANT SELECT ON TABLE dev.deliverabledue TO pts_read;

-- View: dev.devsteeringcommittee

-- DROP VIEW dev.devsteeringcommittee;

CREATE OR REPLACE VIEW dev.devsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM dev.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM dev.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM dev.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM dev.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN dev.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN dev.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND (sc.positionid = ANY (ARRAY[85, 96]))
     JOIN "position" ON sc.positionid = "position".positionid
  ORDER BY person.lastname;

ALTER TABLE dev.devsteeringcommittee
  OWNER TO bradley;

----walcc----
DROP VIEW walcc.alccstaff;
DROP VIEW walcc.alccsteeringcommittee;
DROP VIEW walcc.metadatacontact;
DROP VIEW walcc.deliverabledue;
DROP VIEW walcc.noticesent;
DROP VIEW walcc.projectawardinfo;
DROP VIEW walcc.walccsteeringcommittee;
DROP VIEW walcc.personlist;
DROP VIEW walcc.projectadmin;

ALTER TABLE walcc.phone
    ALTER COLUMN extension SET DATA TYPE integer;

-- View: walcc.alccstaff

-- DROP VIEW walcc.alccstaff;

CREATE OR REPLACE VIEW walcc.alccstaff AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM walcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM walcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM walcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM walcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN walcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN walcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42
     JOIN walcc.contact ON contact.contactid = person.contactid AND contact.contacttypeid = 5
  ORDER BY person.lastname;

ALTER TABLE walcc.alccstaff
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.alccstaff TO bradley;
GRANT SELECT ON TABLE walcc.alccstaff TO pts_read;

    -- View: walcc.alccsteeringcommittee

-- DROP VIEW walcc.alccsteeringcommittee;

CREATE OR REPLACE VIEW walcc.alccsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM walcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM walcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM walcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM walcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN walcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN walcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND (sc.positionid = ANY (ARRAY[85, 96]))
     JOIN "position" ON sc.positionid = "position".positionid
  ORDER BY person.lastname;

ALTER TABLE walcc.alccsteeringcommittee
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.alccsteeringcommittee TO bradley;
GRANT SELECT ON TABLE walcc.alccsteeringcommittee TO pts_read;

-- View: walcc.metadatacontact

-- DROP VIEW walcc.metadatacontact;

CREATE OR REPLACE VIEW walcc.metadatacontact AS
 SELECT c.contactid AS "contactId",
    c."individualName",
    c."organizationName",
    c."positionName",
    c.uri,
    ((((('+'::text || p.code::text) || ' '::text) || p.areacode) || ' '::text) || p.phnumber) || COALESCE(' x'::text || p.extension, ''::text) AS "officePhone",
    add.street1 AS "deliveryPoint1",
    add.street2 AS "deliveryPoint2",
    add.city,
    govunit.statename AS "administrativeArea",
    add.postalcode::text || COALESCE('-'::text || add.postal4, ''::text) AS "postalCode",
    govunit.countryname AS country,
    e.uri AS email
   FROM ( SELECT person.contactid,
            (((person.firstname::text || COALESCE(' '::text || person.middlename::text, ''::text)) || ' '::text) || person.lastname::text) || COALESCE(', '::text || person.suffix::text, ''::text) AS "individualName",
            cg.fullname AS "organizationName",
            pos.code AS "positionName",
            web.uri
           FROM walcc.person
             LEFT JOIN ( SELECT contactcontactgroup.groupid,
                    contactcontactgroup.contactid,
                    contactcontactgroup.positionid,
                    contactcontactgroup.contactcontactgroupid,
                    contactcontactgroup.priority,
                    row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
                   FROM walcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
             LEFT JOIN walcc.contactgrouplist cg ON cg.contactid = ccg.groupid
             LEFT JOIN "position" pos ON ccg.positionid = pos.positionid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM walcc.eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = ccg.groupid
        UNION
         SELECT cg.contactid,
            NULL::text AS "individualName",
            cl.fullname AS "organizationName",
            NULL::character varying AS "positionName",
            web.uri
           FROM walcc.contactgroup cg
             LEFT JOIN walcc.contactgrouplist cl ON cl.contactid = cg.contactid
             LEFT JOIN ( SELECT eaddress.eaddressid,
                    eaddress.contactid,
                    eaddress.eaddresstypeid,
                    eaddress.uri,
                    eaddress.priority,
                    eaddress.comment
                   FROM walcc.eaddress
                  WHERE eaddress.eaddresstypeid = 2
                  ORDER BY eaddress.priority) web ON web.contactid = cg.contactid) c
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            country.phone AS code,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM walcc.phone
             JOIN country USING (countryiso)
          WHERE phone.phonetypeid = 3) p ON c.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM walcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON c.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT address.addressid,
            address.contactid,
            address.addresstypeid,
            address.street1,
            address.street2,
            address.postalcode,
            address.postal4,
            address.stateid,
            address.countyid,
            address.countryiso,
            address.comment,
            address.latitude,
            address.longitude,
            address.priority,
            address.city,
            row_number() OVER (PARTITION BY address.contactid ORDER BY address.addresstypeid DESC, address.priority) AS rank
           FROM walcc.address) add ON c.contactid = add.contactid AND add.rank = 1
     LEFT JOIN govunit ON add.stateid = govunit.featureid;

ALTER TABLE walcc.metadatacontact
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.metadatacontact TO bradley;
GRANT SELECT ON TABLE walcc.metadatacontact TO pts_read;

-- View: walcc.projectadmin

-- DROP VIEW walcc.projectadmin;

CREATE OR REPLACE VIEW walcc.projectadmin AS
 SELECT DISTINCT ON (person.lastname, person.contactid) person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
        CASE
            WHEN project_status(pc.projectid) = ANY (ARRAY[1, 2, 5]) THEN 'No'::text
            ELSE 'Yes'::text
        END AS active
   FROM walcc.person
     JOIN walcc.contact USING (contactid)
     JOIN walcc.projectcontact pc ON person.contactid = pc.contactid
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM walcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM walcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM walcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN walcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN roletype USING (roletypeid)
  WHERE (pc.roletypeid = ANY (ARRAY[7, 5, 13, 6])) AND NOT contact.inactive
  ORDER BY person.lastname, person.contactid;

ALTER TABLE walcc.projectadmin
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.projectadmin TO bradley;
GRANT SELECT ON TABLE walcc.projectadmin TO pts_read;
COMMENT ON VIEW walcc.projectadmin
  IS 'Contacts serving in an admin role for projects (i.e. Financial Officer, Primary Contact, Principal Investigator, Grants Admin).';

-- View: walcc.personlist

-- DROP VIEW walcc.personlist;

CREATE OR REPLACE VIEW walcc.personlist AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail
   FROM walcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM walcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM walcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM walcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN walcc.contactgroup cg ON cg.contactid = ccg.groupid
  ORDER BY person.lastname, person.contactid;

ALTER TABLE walcc.personlist
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.personlist TO bradley;
GRANT SELECT ON TABLE walcc.personlist TO pts_read;

-- View: walcc.projectawardinfo

-- DROP VIEW walcc.projectawardinfo;

CREATE OR REPLACE VIEW walcc.projectawardinfo AS
 SELECT form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    p.title,
    modification.modificationcode AS agreementcode,
    (pi.firstname::text || ' '::text) || pi.lastname::text AS piname,
    pi.title AS pititle,
    rpg.fullname AS organization,
    pi.priareacode AS areacode,
    pi.priphnumber AS phone,
    pi.priextension AS phoneext,
    pi.pricountryiso AS phonecountry,
    pi.priemail AS email,
    add.street1,
    add.street2,
    add.city,
    govunit.statename,
    add.postalcode,
    add.countryiso,
    (fc.firstname::text || ' '::text) || fc.lastname::text AS admincontact,
    fc.title AS admintitle,
    fc.priareacode AS adminareacode,
    fc.priphnumber AS adminphone,
    fc.priextension AS adminphoneext,
    fc.pricountryiso AS adminphonecountry,
    fc.priemail AS adminemail,
    fadd.street1 AS adminstreet1,
    fadd.street2 AS adminstreet2,
    fadd.city AS admincity,
    fg.statename AS adminstatename,
    fadd.postalcode AS adminpostalcode,
    fadd.countryiso AS admincountryiso
   FROM walcc.project p
     LEFT JOIN walcc.contactgroup ON p.orgid = contactgroup.contactid
     LEFT JOIN walcc.modification USING (projectid)
     LEFT JOIN status ON status.statusid = project_status(p.projectid)
     LEFT JOIN walcc.funding USING (modificationid)
     LEFT JOIN walcc.projectcontact pc USING (projectcontactid)
     LEFT JOIN walcc.projectcontact rpc ON rpc.projectcontactid = funding.fundingrecipientid
     JOIN walcc.contactgrouplist rpg ON rpc.contactid = rpg.contactid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority) AS rank
           FROM walcc.projectcontact
             JOIN walcc.personlist pl USING (contactid)
             JOIN walcc.contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN walcc.contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN "position" USING (positionid)
          WHERE projectcontact.roletypeid = 7) pi ON p.projectid = pi.projectid AND pi.rank = 1 AND rpg.contactids[1] = pi.contactids[1]
     LEFT JOIN walcc.address add ON add.contactid = pi.contactid AND add.addresstypeid = 1
     LEFT JOIN govunit ON govunit.featureid = add.stateid
     LEFT JOIN ( SELECT pl.contactid,
            pl.firstname,
            pl.lastname,
            pl.middlename,
            pl.suffix,
            pl.prigroupid,
            pl.priacronym,
            pl.prigroupname,
            pl.priareacode,
            pl.priphnumber,
            pl.priextension,
            pl.pricountryiso,
            pl.priemail,
            contactgrouplist.contactids,
            projectcontact.projectid,
            "position".title,
            row_number() OVER (PARTITION BY projectcontact.projectid, contactgrouplist.contactids[1] ORDER BY projectcontact.priority, projectcontact.roletypeid) AS rank
           FROM walcc.projectcontact
             JOIN walcc.personlist pl USING (contactid)
             JOIN walcc.contactgrouplist ON pl.prigroupid = contactgrouplist.contactid
             LEFT JOIN walcc.contactcontactgroup ccg ON pl.contactid = ccg.contactid AND ccg.groupid = pl.prigroupid
             LEFT JOIN "position" USING (positionid)
          WHERE projectcontact.roletypeid = ANY (ARRAY[5, 13])) fc ON p.projectid = fc.projectid AND fc.rank = 1 AND rpg.contactids[1] = fc.contactids[1]
     LEFT JOIN walcc.address fadd ON fadd.contactid = fc.contactid AND fadd.addresstypeid = 1
     LEFT JOIN govunit fg ON fg.featureid = fadd.stateid
  WHERE modification.parentmodificationid IS NULL AND (modification.modtypeid = ANY (ARRAY[1, 2, 3, 5])) AND status.weight >= 30 AND status.weight <= 60 AND pc.contactid = p.orgid
  ORDER BY form_projectcode(p.number::integer, p.fiscalyear::integer, contactgroup.acronym);

ALTER TABLE walcc.projectawardinfo
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.projectawardinfo TO bradley;
GRANT SELECT ON TABLE walcc.projectawardinfo TO pts_read;
COMMENT ON VIEW walcc.projectawardinfo
  IS 'Contact information related to projeect award documents. Useful for performing mail merge operations.';

-- View: walcc.noticesent

-- DROP VIEW walcc.noticesent;

CREATE OR REPLACE VIEW walcc.noticesent AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM walcc.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    d.title,
    d.description,
    notice.code AS lastnotice,
    deliverablenotice.datesent,
    projectlist.projectcode,
    project.shorttitle AS project,
    (personlist.firstname::text || ' '::text) || personlist.lastname::text AS contact,
    personlist.priemail AS email,
    (folist.firstname::text || ' '::text) || folist.lastname::text AS fofficer,
    folist.priemail AS foemail,
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END AS dayspastdue,
    COALESCE(status.status, 'Not Received'::character varying) AS status,
    modification.projectid,
    dm.modificationid,
    d.deliverableid,
    modification.modificationcode AS agreementnumber,
    dlc.staffcomments,
    dm.startdate,
    dm.enddate
   FROM walcc.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN ( SELECT deliverablemod.modificationid,
            deliverablemod.deliverableid,
            deliverablemod.duedate,
            deliverablemod.receiveddate,
            deliverablemod.devinterval,
            deliverablemod.publish,
            deliverablemod.restricted,
            deliverablemod.accessdescription,
            deliverablemod.parentmodificationid,
            deliverablemod.parentdeliverableid,
            deliverablemod.personid,
            deliverablemod.startdate,
            deliverablemod.enddate
           FROM walcc.deliverablemod
          WHERE NOT (EXISTS ( SELECT 1
                   FROM walcc.deliverablemod dp
                  WHERE dp.modificationid = dp.parentmodificationid AND dp.deliverableid = dp.parentdeliverableid))) dm USING (deliverableid)
     JOIN walcc.modification USING (modificationid)
     JOIN walcc.projectlist USING (projectid)
     JOIN walcc.project USING (projectid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM walcc.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[7])) projectcontact USING (projectid)
     LEFT JOIN walcc.personlist USING (contactid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM walcc.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = 5
          ORDER BY projectcontact_1.priority) focontact USING (projectid)
     LEFT JOIN walcc.personlist folist ON focontact.contactid = folist.contactid
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.deliverablestatusid,
            deliverablemodstatus.deliverablemodstatusid,
            deliverablemodstatus.modificationid,
            deliverablemodstatus.deliverableid,
            deliverablemodstatus.effectivedate,
            deliverablemodstatus.comment,
            deliverablemodstatus.contactid,
            deliverablestatus.code,
            deliverablestatus.status,
            deliverablestatus.description,
            deliverablestatus.comment
           FROM walcc.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, modificationid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN walcc.deliverablenotice USING (deliverableid)
     LEFT JOIN notice USING (noticeid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT COALESCE(status.deliverablestatusid >= 10, false) AND
        CASE
            WHEN status.deliverablestatusid >= 10 THEN 0
            WHEN status.deliverablestatusid = 0 THEN 'now'::text::date - status.effectivedate + 1
            ELSE 'now'::text::date - dm.duedate
        END > (-30) AND NOT (EXISTS ( SELECT 1
           FROM walcc.deliverablemod d_1
          WHERE dm.modificationid = d_1.parentmodificationid AND dm.deliverableid = d_1.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority, deliverablenotice.datesent DESC;

ALTER TABLE walcc.noticesent
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.noticesent TO bradley;
GRANT SELECT ON TABLE walcc.noticesent TO pts_read;

-- View: walcc.deliverabledue

-- DROP VIEW walcc.deliverabledue;

CREATE OR REPLACE VIEW walcc.deliverabledue AS
 WITH delcomment AS (
         SELECT DISTINCT deliverablecomment.deliverableid,
            string_agg((deliverablecomment.datemodified || ': '::text) || deliverablecomment.comment::text, '
'::text) OVER (PARTITION BY deliverablecomment.deliverableid ORDER BY deliverablecomment.datemodified DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS staffcomments
           FROM walcc.deliverablecomment
        )
 SELECT DISTINCT ON (dm.duedate, d.deliverableid) dm.duedate,
    efd.effectivedate AS receiveddate,
    d.title,
    d.description,
    projectlist.projectcode,
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
    dm.enddate
   FROM walcc.deliverable d
     LEFT JOIN delcomment dlc USING (deliverableid)
     JOIN walcc.deliverablemod dm USING (deliverableid)
     JOIN walcc.modification USING (modificationid)
     JOIN walcc.projectlist USING (projectid)
     JOIN walcc.project USING (projectid)
     LEFT JOIN ( SELECT projectcontact_1.projectid,
            projectcontact_1.contactid,
            projectcontact_1.roletypeid,
            projectcontact_1.priority,
            projectcontact_1.contactprojectcode,
            projectcontact_1.partner,
            projectcontact_1.projectcontactid
           FROM walcc.projectcontact projectcontact_1
          WHERE projectcontact_1.roletypeid = ANY (ARRAY[6, 7])) projectcontact USING (projectid)
     LEFT JOIN walcc.personlist USING (contactid)
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
           FROM walcc.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.effectivedate DESC, deliverablemodstatus.deliverablestatusid DESC) status(deliverablestatusid, deliverablemodstatusid, deliverableid, effectivedate, comment, contactid, code, status, description, comment_1) USING (deliverableid)
     LEFT JOIN ( SELECT DISTINCT ON (deliverablemodstatus.deliverableid) deliverablemodstatus.effectivedate,
            deliverablemodstatus.deliverableid
           FROM walcc.deliverablemodstatus
             JOIN deliverablestatus USING (deliverablestatusid)
          WHERE deliverablemodstatus.deliverablestatusid = ANY (ARRAY[10, 40])
          ORDER BY deliverablemodstatus.deliverableid, deliverablemodstatus.deliverablestatusid, deliverablemodstatus.effectivedate DESC) efd USING (deliverableid)
  WHERE NOT (d.deliverabletypeid = ANY (ARRAY[4, 7])) AND NOT (EXISTS ( SELECT 1
           FROM walcc.deliverablemod dp
          WHERE dm.modificationid = dp.parentmodificationid AND dm.deliverableid = dp.parentdeliverableid))
  ORDER BY dm.duedate, d.deliverableid, projectcontact.roletypeid, projectcontact.priority;

ALTER TABLE walcc.deliverabledue
  OWNER TO bradley;
GRANT ALL ON TABLE walcc.deliverabledue TO bradley;
GRANT SELECT ON TABLE walcc.deliverabledue TO pts_read;

-- View: walcc.walccsteeringcommittee

-- DROP VIEW walcc.walccsteeringcommittee;

CREATE OR REPLACE VIEW walcc.walccsteeringcommittee AS
 SELECT person.contactid,
    person.firstname,
    person.lastname,
    person.middlename,
    person.suffix,
    ccg.groupid AS prigroupid,
    cg.acronym AS priacronym,
    cg.name AS prigroupname,
    p.areacode AS priareacode,
    p.phnumber AS priphnumber,
    p.extension AS priextension,
    p.countryiso AS pricountryiso,
    e.uri AS priemail,
    "position".title
   FROM walcc.person
     LEFT JOIN ( SELECT phone.phoneid,
            phone.contactid,
            phone.addressid,
            phone.phonetypeid,
            phone.countryiso,
            phone.areacode,
            phone.phnumber,
            phone.extension,
            phone.priority,
            row_number() OVER (PARTITION BY phone.contactid ORDER BY phone.priority) AS rank
           FROM walcc.phone
          WHERE phone.phonetypeid = 3) p ON person.contactid = p.contactid AND p.rank = 1
     LEFT JOIN ( SELECT eaddress.eaddressid,
            eaddress.contactid,
            eaddress.eaddresstypeid,
            eaddress.uri,
            eaddress.priority,
            eaddress.comment,
            row_number() OVER (PARTITION BY eaddress.contactid ORDER BY eaddress.priority) AS rank
           FROM walcc.eaddress
          WHERE eaddress.eaddresstypeid = 1) e ON person.contactid = e.contactid AND e.rank = 1
     LEFT JOIN ( SELECT contactcontactgroup.groupid,
            contactcontactgroup.contactid,
            contactcontactgroup.positionid,
            contactcontactgroup.contactcontactgroupid,
            contactcontactgroup.priority,
            row_number() OVER (PARTITION BY contactcontactgroup.contactid ORDER BY contactcontactgroup.priority) AS rank
           FROM walcc.contactcontactgroup) ccg ON person.contactid = ccg.contactid AND ccg.rank = 1
     LEFT JOIN walcc.contactgroup cg ON cg.contactid = ccg.groupid
     JOIN walcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND (sc.positionid = ANY (ARRAY[85, 96]))
     JOIN "position" ON sc.positionid = "position".positionid
  ORDER BY person.lastname;

ALTER TABLE walcc.walccsteeringcommittee
  OWNER TO bradley;

-----Update catalogprojectcategory--------

ALTER TABLE dev.catalogprojectcategory
   ADD COLUMN usertype1 character varying;
COMMENT ON COLUMN dev.catalogprojectcategory.usertype1
  IS 'Who will benefit from this project.';

ALTER TABLE dev.catalogprojectcategory
   ADD COLUMN usertype2 character varying;
COMMENT ON COLUMN dev.catalogprojectcategory.usertype2
  IS 'Who will benefit from this project.';

ALTER TABLE dev.catalogprojectcategory
   ADD COLUMN usertype3 character varying;
COMMENT ON COLUMN alcc.catalogprojectcategory.usertype3
  IS 'Who will benefit from this project.';


ALTER TABLE alcc.catalogprojectcategory
   ADD COLUMN usertype1 character varying;
COMMENT ON COLUMN alcc.catalogprojectcategory.usertype1
  IS 'Who will benefit from this project.';

ALTER TABLE alcc.catalogprojectcategory
   ADD COLUMN usertype2 character varying;
COMMENT ON COLUMN alcc.catalogprojectcategory.usertype2
  IS 'Who will benefit from this project.';

ALTER TABLE alcc.catalogprojectcategory
   ADD COLUMN usertype3 character varying;
COMMENT ON COLUMN alcc.catalogprojectcategory.usertype3
  IS 'Who will benefit from this project.';


ALTER TABLE walcc.catalogprojectcategory
   ADD COLUMN usertype1 character varying;
COMMENT ON COLUMN walcc.catalogprojectcategory.usertype1
  IS 'Who will benefit from this project.';

ALTER TABLE walcc.catalogprojectcategory
   ADD COLUMN usertype2 character varying;
COMMENT ON COLUMN walcc.catalogprojectcategory.usertype2
  IS 'Who will benefit from this project.';


ALTER TABLE walcc.catalogprojectcategory
   ADD COLUMN usertype3 character varying;
COMMENT ON COLUMN walcc.catalogprojectcategory.usertype3
  IS 'Who will benefit from this project.';

-- Column: lcc

-- ALTER TABLE cvl.status DROP COLUMN lcc;

ALTER TABLE cvl.status ADD COLUMN lcc character varying;
COMMENT ON COLUMN cvl.status.lcc IS 'Equivalent value for the LCC Project Catalog.';

-- Column: projecturiformat

-- ALTER TABLE groupschema DROP COLUMN projecturiformat;

ALTER TABLE groupschema ADD COLUMN projecturiformat character varying;
COMMENT ON COLUMN groupschema.projecturiformat IS 'A string to be used with the format function to generate the project web URL.';

SET search_path = dev, pg_catalog;

DROP VIEW projectcatalog;

CREATE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace(contactgroup_1.name, ',', '') as name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace(contactgroup_1.name, ',', '') AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace(cg.name, ',', '') as name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace(cg.name, ',', '')::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
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
           FROM gschema gschema_1,
            (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid))) AND (contact.contacttypeid = 5))
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
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
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
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
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
    ('arctic'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((project
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
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
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text),',','') AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

  GRANT SELECT ON TABLE projectcatalog TO pts_read;

SET search_path = alcc, pg_catalog;

DROP VIEW projectcatalog;

CREATE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace(contactgroup_1.name, ',', '') as name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace(contactgroup_1.name, ',', '') AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace(cg.name, ',', '') as name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace(cg.name, ',', '')::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
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
           FROM gschema gschema_1,
            (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid))) AND (contact.contacttypeid = 5))
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
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
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
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
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
    ('arctic'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((project
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
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
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text),',','') AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

  GRANT SELECT ON TABLE projectcatalog TO pts_read;

SET search_path = walcc, pg_catalog;

DROP VIEW projectcatalog;

CREATE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace(contactgroup_1.name, ',', '') as name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace(contactgroup_1.name, ',', '') AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace(cg.name, ',', '') as name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace(cg.name, ',', '')::text) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
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
           FROM gschema gschema_1,
            (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid))) AND (contact.contacttypeid = 5))
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
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
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
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
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
    ('western alaska'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((project
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
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
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text),',','') AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

  GRANT SELECT ON TABLE projectcatalog TO pts_read;



SET search_path = alcc, pg_catalog;

DROP VIEW projectcatalog;

ALTER TABLE catalogprojectcategory
    ADD COLUMN endusers character varying;

COMMENT ON COLUMN catalogprojectcategory.endusers IS 'Target Audience/End Users';

CREATE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace((cg.name)::text, ','::text, ''::text) AS name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace((cg.name)::text, ','::text, ''::text)) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
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
           FROM gschema gschema_1,
            (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid))) AND (contact.contacttypeid = 5))
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
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
    catalogprojectcategory.endusers,
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
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
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
    ('arctic'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((project
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
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
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text), ','::text, ''::text) AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

SET search_path = dev, pg_catalog;

ALTER TABLE catalogprojectcategory
    ADD COLUMN endusers character varying;

COMMENT ON COLUMN catalogprojectcategory.endusers IS 'Target Audience/End Users';

CREATE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace((cg.name)::text, ','::text, ''::text) AS name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace((cg.name)::text, ','::text, ''::text)) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
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
           FROM gschema gschema_1,
            (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid))) AND (contact.contacttypeid = 5))
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
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
    catalogprojectcategory.endusers,
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
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
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
    ('arctic'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((project
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
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
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text), ','::text, ''::text) AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

SET search_path = walcc, pg_catalog;

DROP VIEW projectcatalog;

ALTER TABLE catalogprojectcategory
    ADD COLUMN endusers character varying;

COMMENT ON COLUMN catalogprojectcategory.endusers IS 'Target Audience/End Users';

CREATE VIEW projectcatalog AS
    WITH RECURSIVE grouptree AS (
         SELECT contactgroup_1.contactid,
            contactgroup_1.organization,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS name,
            contactgroup_1.acronym,
            contactcontactgroup.groupid,
            replace((contactgroup_1.name)::text, ','::text, ''::text) AS fullname,
            NULL::text AS parentname,
            ARRAY[contactgroup_1.contactid] AS contactids
           FROM (contactgroup contactgroup_1
             LEFT JOIN contactcontactgroup USING (contactid))
          WHERE (contactcontactgroup.groupid IS NULL)
        UNION ALL
         SELECT ccg.contactid,
            cg.organization,
            replace((cg.name)::text, ','::text, ''::text) AS name,
            cg.acronym,
            gt.contactid,
            ((gt.fullname || ' - '::text) || replace((cg.name)::text, ','::text, ''::text)) AS full_name,
            gt.name,
            array_append(gt.contactids, cg.contactid) AS array_append
           FROM ((contactgroup cg
             JOIN contactcontactgroup ccg USING (contactid))
             JOIN grouptree gt ON ((ccg.groupid = gt.contactid)))
        ), gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
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
           FROM gschema gschema_1,
            (((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN contact USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE (((projectcontact.roletypeid = 4) AND (NOT (projectcontact.contactid = gschema_1.groupid))) AND (contact.contacttypeid = 5))
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
    status.lcc AS pstatus,
    project.startdate AS pstart,
    project.enddate AS pend,
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS purl,
    COALESCE(pc.principalinvestigators, pi.principalinvestigators) AS leadcontact,
    COALESCE(pc.leadorg, pi.leadorg) AS leadorg,
    ( SELECT string_agg(grouptree.fullname, '; '::text) AS string_agg
           FROM ((projectcontact
             JOIN contactgroup contactgroup_1 USING (contactid))
             JOIN grouptree USING (contactid))
          WHERE ((projectcontact.partner AND (projectcontact.projectid = project.projectid)) AND (NOT ("position"(COALESCE(pc.leadorg, pi.leadorg), grouptree.fullname) > 0)))
          GROUP BY projectcontact.projectid) AS partnerorg,
    catalogprojectcategory.usertype1,
    catalogprojectcategory.usertype2,
    catalogprojectcategory.usertype3,
    catalogprojectcategory.endusers,
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
          WHERE ((funds.projectid = project.projectid) AND (funds.contactid = gschema.groupid))
          GROUP BY funds.projectid) AS lccfundall,
    lccfundby.lccfundby,
    ( SELECT sum(funds.funds) AS sum
           FROM funds
          WHERE ((funds.projectid = project.projectid) AND (NOT (funds.contactid = gschema.groupid)))
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
    ('western alaska'::text || COALESCE((';'::text || commongeom.name), ''::text)) AS geog,
    'AK-ALL'::text AS congdist,
    ((COALESCE((('Additional deliverabletypes: '::text || ( SELECT string_agg((deltype.type)::text, ','::text) AS string_agg
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (NOT ((deltype.type)::text = 'Other'::text))))) || ';'::text), ''::text) || COALESCE((('Additional deliverables: '::text || ( SELECT (deltype.catalog)::text AS catalog
           FROM deltype
          WHERE ((deltype.projectid = project.projectid) AND (deltype.rank = 4)))) || ';'::text), ''::text)) ||
        CASE
            WHEN (project.number > 1000) THEN 'Internal Project;'::text
            ELSE ''::text
        END) AS comments
   FROM gschema,
    ((((((((((project
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
                   FROM eaddress eaddress_1
                  WHERE (eaddress_1.eaddresstypeid = 1)) eaddress ON (((person.contactid = eaddress.contactid) AND (eaddress.rank = 1))))
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
            string_agg((common.getfiscalyear(mod.startdate))::text, ';'::text ORDER BY mod.startdate) AS fiscalyears
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
           FROM funds,
            gschema gschema_1
          WHERE (funds.contactid = gschema_1.groupid)
          GROUP BY funds.projectid) lccfundby ON ((lccfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT funds.projectid,
            string_agg((((((funds.funds)::text || ','::text) || funds.fiscalyear) || ','::text) || funds.fullname), '; '::text) AS matchfundby
           FROM funds,
            gschema gschema_1
          WHERE (NOT (funds.contactid = gschema_1.groupid))
          GROUP BY funds.projectid) matchfundby ON ((matchfundby.projectid = project.projectid)))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((keyword.preflabel)::text, '; '::text) AS keywords,
            string_agg(replace((keyword.preflabel)::text, ' '::text, '-'::text), '; '::text) AS joined
           FROM (projectkeyword
             JOIN gcmd.keyword USING (keywordid))
          GROUP BY projectkeyword.projectid) subject ON ((subject.projectid = project.projectid)))
     LEFT JOIN ( SELECT replace(string_agg((commonpolygon.name)::text, ';'::text), ','::text, ''::text) AS name,
            projectpolygon.projectid
           FROM projectpolygon,
            cvl.commonpolygon
          WHERE (projectpolygon.the_geom OPERATOR(public.=) commonpolygon.the_geom)
          GROUP BY projectpolygon.projectid) commongeom ON ((commongeom.projectid = project.projectid)))
     LEFT JOIN catalogprojectcategory ON ((catalogprojectcategory.projectid = project.projectid)))
  ORDER BY common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym);

GRANT SELECT ON TABLE alcc.projectcatalog TO pts_read;
GRANT SELECT ON TABLE walcc.projectcatalog TO pts_read;
GRANT SELECT ON TABLE dev.projectcatalog TO pts_read;