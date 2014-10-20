-- Version 0.14.0

--add supplemental

ALTER TABLE alcc.project
   ADD COLUMN supplemental character varying;
COMMENT ON COLUMN alcc.project.supplemental
  IS 'Additional information about the project that is not included in the abstract.';

ALTER TABLE walcc.project
   ADD COLUMN supplemental character varying;
COMMENT ON COLUMN walcc.project.supplemental
  IS 'Additional information about the project that is not included in the abstract.';

ALTER TABLE dev.project
   ADD COLUMN supplemental character varying;
COMMENT ON COLUMN dev.project.supplemental
  IS 'Additional information about the project that is not included in the abstract.';

-- View: alcc.metadataproject

-- DROP VIEW alcc.metadataproject;

CREATE OR REPLACE VIEW alcc.metadataproject AS
 SELECT project.projectid,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "projectIdentifier",
    project.shorttitle,
    project.exportmetadata,
    'http://arcticlcc.org/projects/'::text || form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym)::text AS uri,
    ( SELECT m.datecreated
           FROM alcc.modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental
   FROM alcc.project
     JOIN alcc.contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM alcc.projectkeyword projectkeyword_1
                     JOIN keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM alcc.projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM alcc.projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM alcc.projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

-- View: walcc.metadataproject

-- DROP VIEW walcc.metadataproject;

CREATE OR REPLACE VIEW walcc.metadataproject AS
 SELECT project.projectid,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "projectIdentifier",
    project.shorttitle,
    project.exportmetadata,
    ('https://westernalaskalcc.org/projects/SitePages/'::text || replace(form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym)::text, '-'::text, '_'::text)) || '.aspx'::text AS uri,
    ( SELECT m.datecreated
           FROM walcc.modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental
   FROM walcc.project
     JOIN walcc.contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM walcc.projectkeyword projectkeyword_1
                     JOIN keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM walcc.projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM walcc.projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM walcc.projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

-- View: dev.metadataproject

-- DROP VIEW dev.metadataproject;

CREATE OR REPLACE VIEW dev.metadataproject AS
 SELECT project.projectid,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "projectIdentifier",
    project.shorttitle,
    project.exportmetadata,
    'http://arcticlcc.org/projects/'::text || form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym)::text AS uri,
    ( SELECT m.datecreated
           FROM dev.modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental
   FROM dev.project
     JOIN dev.contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM dev.projectkeyword projectkeyword_1
                     JOIN keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            st_extent(st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    st_asgeojson(st_transform(lg.the_geom, 4326), 6)::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM dev.projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM dev.projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM dev.projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

--sc position
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
    position.title
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
     JOIN alcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND sc.positionid IN (85, 96)
     JOIN position ON (sc.positionid = position.positionid)
  ORDER BY person.lastname;

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
    position.title
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
     JOIN walcc.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND sc.positionid IN (85, 96)
     JOIN position ON (sc.positionid = position.positionid)
  ORDER BY person.lastname;

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
    position.title
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
     JOIN dev.contactcontactgroup sc ON person.contactid = sc.contactid AND sc.groupid = 42 AND sc.positionid IN (85, 96)
     JOIN position ON (sc.positionid = position.positionid)
  ORDER BY person.lastname;

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
    e.uri AS priemail
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
    e.uri AS priemail
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
    e.uri AS priemail
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


