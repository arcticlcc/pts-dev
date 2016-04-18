CREATE OR REPLACE VIEW metadataproduct AS
 SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    product.orgid,
    product.title,
    deliverabletype.isocodename AS resourcetype,
    product.projectid,
    product.startdate,
    product.enddate,
    product.description AS "shortAbstract",
    product.abstract,
    product.uuid AS "resourceIdentifier",
    product.exportmetadata,
    format((gschema.producturiformat)::text, product.uuid) AS uri,
    isoprogresstype.codename AS status,
    kw.keywords,
        CASE
            WHEN (fea.features IS NOT NULL) THEN to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)])
            ELSE NULL::json
        END AS bbox,
    fea.features,
    product.purpose,
    tc.topiccategory,
    product.metadataupdate,
    sf.spatialformat,
    ep.epsgcode,
    wkt.wkt,
    product.productgroupid,
    product.isgroup,
    product.uselimitation,
    product.perioddescription,
    mf.codename AS frequency
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((((((product
     LEFT JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     LEFT JOIN cvl.maintenancefrequency mf USING (maintenancefrequencyid))
     LEFT JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     LEFT JOIN cvl.isoprogresstype USING (isoprogresstypeid))
     LEFT JOIN ( SELECT productkeyword.productid,
            string_agg((productkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT productkeyword_1.productid,
                    keyword.preflabel
                   FROM (productkeyword productkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY productkeyword_1.productid, keyword.preflabel) productkeyword
          GROUP BY productkeyword.productid) kw USING (productid))
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (producttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY producttopiccategory.productid) tc USING (productid))
     LEFT JOIN ( SELECT productspatialformat.productid,
            string_agg((spatialformat.codename)::text, '|'::text) AS spatialformat
           FROM (productspatialformat
             JOIN cvl.spatialformat USING (spatialformatid))
          GROUP BY productspatialformat.productid) sf USING (productid))
     LEFT JOIN ( SELECT productepsg.productid,
            string_agg((productepsg.srid)::text, '|'::text) AS epsgcode
           FROM productepsg
          GROUP BY productepsg.productid) ep USING (productid))
     LEFT JOIN ( SELECT productwkt.productid,
            string_agg((productwkt.wkt)::text, '|'::text) AS wkt
           FROM productwkt
          GROUP BY productwkt.productid) wkt USING (productid))
     LEFT JOIN ( SELECT f.productid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.productid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT productpoint.productid,
                            ('point-'::text || productpoint.productpointid) AS id,
                            productpoint.name,
                            productpoint.comment,
                            productpoint.the_geom
                           FROM productpoint
                        UNION
                         SELECT productpolygon.productid,
                            ('polygon-'::text || productpolygon.productpolygonid) AS id,
                            productpolygon.name,
                            productpolygon.comment,
                            productpolygon.the_geom
                           FROM productpolygon
                        UNION
                         SELECT productline.productid,
                            ('line-'::text || productline.productlineid) AS id,
                            productline.name,
                            productline.comment,
                            productline.the_geom
                           FROM productline) lg) f
          GROUP BY f.productid) fea USING (productid));
