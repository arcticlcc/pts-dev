-- View: dev.metadataproject

-- DROP VIEW dev.metadataproject;

CREATE OR REPLACE VIEW dev.metadataproject AS
 WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM groupschema
          WHERE groupschema.groupschemaid::name = ANY (current_schemas(false))
        )
 SELECT project.projectid,
    form_projectcode(project.number::integer, project.fiscalyear::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
    project.title,
    project.parentprojectid,
    project.startdate,
    project.enddate,
    project.description AS "shortAbstract",
    project.abstract,
    project.uuid AS "resourceIdentifier",
    project.shorttitle,
    project.exportmetadata,
    format(gschema.projecturiformat::text, project.fiscalyear, btrim(to_char(project.number::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE m.projectid = project.projectid
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[st_xmin(fea.extent::box3d), st_ymin(fea.extent::box3d), st_xmax(fea.extent::box3d), st_ymax(fea.extent::box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate,
    project.sciencebaseid
   FROM gschema,
    project
     JOIN contactgroup ON project.orgid = contactgroup.contactid
     JOIN status ON status.statusid = project_status(project.projectid)
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg(projectkeyword.preflabel::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM projectkeyword projectkeyword_1
                     JOIN keyword USING (keywordid)
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid)
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg(usertype.usertype::text, '|'::text) AS usertype
           FROM projectusertype
             JOIN usertype USING (usertypeid)
          GROUP BY projectusertype.projectid) ut USING (projectid)
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg(topiccategory.codename::text, '|'::text) AS topiccategory
           FROM projecttopiccategory
             JOIN topiccategory USING (topiccategoryid)
          GROUP BY projecttopiccategory.projectid) tc USING (projectid)
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg(projectcategory.category::text, '|'::text) AS projectcategory
           FROM projectprojectcategory
             JOIN projectcategory USING (projectcategoryid)
          GROUP BY projectprojectcategory.projectid) pc USING (projectid)
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
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "name",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            'point-'::text || projectpoint.projectpointid AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            'polygon-'::text || projectpolygon.projectpolygonid AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            'line-'::text || projectline.projectlineid AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid);

ALTER TABLE dev.metadataproject
  OWNER TO pts_admin;
GRANT ALL ON TABLE dev.metadataproject TO pts_admin;
GRANT SELECT ON TABLE dev.metadataproject TO pts_read;
