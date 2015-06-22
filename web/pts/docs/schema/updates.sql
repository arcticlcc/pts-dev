-- Version 0.16.0


SET search_path = common, pg_catalog;

CREATE SEQUENCE onlineresource_onlineresourceid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE product_productid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE productcontact_productcontactid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE productkeyword_productkeywordid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE productline_productlineid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE productpoint_productpointid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE productpolygon_productpolygonid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE productstatus_productstatusid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER TABLE groupschema
	ADD COLUMN producturiformat character varying;

COMMENT ON COLUMN groupschema.producturiformat IS 'A string to be used with the format function to generate the product web URL.';

SET search_path = cvl, pg_catalog;

CREATE SEQUENCE datetype_datetypeid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE isoprogresstype_isoprogresstypeid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE isoroletype_isoroletypeid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE SEQUENCE onlinefunction_onlinefunctionid_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

CREATE TABLE datetype (
	datetypeid integer DEFAULT nextval('datetype_datetypeid_seq'::regclass) NOT NULL,
	code character varying NOT NULL,
	codename character varying NOT NULL,
	description character varying NOT NULL
);

COMMENT ON TABLE datetype IS 'List of date types, corresponds to ADIwg mdCodes types(https://github.com/adiwg/mdCodes/blob/master/resources/iso_dateType.yml).';

COMMENT ON COLUMN datetype.datetypeid IS 'PK for DATETYPE';

COMMENT ON COLUMN datetype.code IS 'Code for datetype';

COMMENT ON COLUMN datetype.codename IS 'Name of datetype';

COMMENT ON COLUMN datetype.description IS 'Description of date type.';

CREATE TABLE isoprogresstype (
	isoprogresstypeid integer DEFAULT nextval('isoprogresstype_isoprogresstypeid_seq'::regclass) NOT NULL,
	code character varying NOT NULL,
	codename character varying NOT NULL,
	description character varying NOT NULL,
	product boolean DEFAULT false NOT NULL
);

COMMENT ON TABLE isoprogresstype IS 'List of progress types, corresponds to ADIwg mdCodes types(https://github.com/adiwg/mdCodes/blob/master/resources/iso_progress.yml).';

COMMENT ON COLUMN isoprogresstype.isoprogresstypeid IS 'PK for isoprogresstype';

COMMENT ON COLUMN isoprogresstype.codename IS 'Plain name of isoprogresstype';

COMMENT ON COLUMN isoprogresstype.product IS 'Indicates whether type is valid for products.';

CREATE TABLE isoroletype (
	isoroletypeid integer DEFAULT nextval('isoroletype_isoroletypeid_seq'::regclass) NOT NULL,
	code character varying NOT NULL,
	codename character varying NOT NULL,
	description character varying NOT NULL
);

COMMENT ON TABLE isoroletype IS 'List of role types, corresponds to ADIwg mdCodes types(https://github.com/adiwg/mdCodes/blob/master/resources/iso_role.yml).';

COMMENT ON COLUMN isoroletype.isoroletypeid IS 'PK for isoroletype';

COMMENT ON COLUMN isoroletype.codename IS 'Plain name of isoroletype';

CREATE TABLE onlinefunction (
	onlinefunctionid integer DEFAULT nextval('onlinefunction_onlinefunctionid_seq'::regclass) NOT NULL,
	code character varying NOT NULL,
	codename character varying NOT NULL,
	description character varying NOT NULL
);

COMMENT ON TABLE onlinefunction IS 'List of date types, corresponds to ADIwg mdCodes types(https://github.com/adiwg/mdCodes/blob/master/resources/iso_onlineFunction.yml).';

COMMENT ON COLUMN onlinefunction.onlinefunctionid IS 'PK for ONLINEFUNCTION';

COMMENT ON COLUMN onlinefunction.codename IS 'Plain name of onlinefunction';

ALTER TABLE deliverabletype
	ADD COLUMN isocodename character varying,
	ADD COLUMN product boolean DEFAULT false;

COMMENT ON COLUMN deliverabletype.isocodename IS 'Code equivalent for ADIwg iso_scope codelist (https://github.com/adiwg/mdCodes/blob/master/resources/iso_scope.yml).';

COMMENT ON COLUMN deliverabletype.product IS 'Indicates whether type is valid for products.';

ALTER SEQUENCE datetype_datetypeid_seq
	OWNED BY datetype.datetypeid;

ALTER SEQUENCE onlinefunction_onlinefunctionid_seq
	OWNED BY onlinefunction.onlinefunctionid;

ALTER TABLE datetype
	ADD CONSTRAINT datetype_pk PRIMARY KEY (datetypeid);

ALTER TABLE isoprogresstype
	ADD CONSTRAINT isoprogresstypeid_pk PRIMARY KEY (isoprogresstypeid);

ALTER TABLE isoroletype
	ADD CONSTRAINT isoroletypeid_pk PRIMARY KEY (isoroletypeid);

ALTER TABLE onlinefunction
	ADD CONSTRAINT onlinefunctionid_pk PRIMARY KEY (onlinefunctionid);

CREATE VIEW productprogresstype AS
	SELECT isoprogresstype.isoprogresstypeid,
    isoprogresstype.code,
    isoprogresstype.codename,
    isoprogresstype.description,
    isoprogresstype.product
   FROM isoprogresstype
  WHERE isoprogresstype.product;

SET search_path = dev, pg_catalog;

DROP VIEW metadataproject;

CREATE TABLE product (
	productid integer DEFAULT nextval('common.product_productid_seq'::regclass) NOT NULL,
	projectid integer NOT NULL,
	uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	title character varying(150) NOT NULL,
	description character varying(300) NOT NULL,
	abstract character varying NOT NULL,
	purpose character varying(300),
	startdate date,
	enddate date,
	exportmetadata boolean DEFAULT false NOT NULL,
	deliverabletypeid integer NOT NULL,
	isoprogresstypeid integer NOT NULL,
	metadataupdate timestamp without time zone
);

COMMENT ON TABLE product IS 'A distributable product produced by a project.';

COMMENT ON COLUMN product.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN product.uuid IS 'Universally unique identifier for product';

COMMENT ON COLUMN product.title IS 'Title of Product';

COMMENT ON COLUMN product.description IS 'Short description of product';

COMMENT ON COLUMN product.abstract IS 'Long description of product';

COMMENT ON COLUMN product.purpose IS 'A summary of intentions for which the product was created.';

COMMENT ON COLUMN product.startdate IS 'Start date for period of validity or relevance';

COMMENT ON COLUMN product.enddate IS 'End date for period of validity or relevance';

COMMENT ON COLUMN product.exportmetadata IS 'Specifies whether product metadata should be exported.';

COMMENT ON COLUMN product.metadataupdate IS 'Date when metadata was last updated (published).';

CREATE TABLE productkeyword (
	productkeywordid integer DEFAULT nextval('common.productkeyword_productkeywordid_seq'::regclass) NOT NULL,
	keywordid uuid NOT NULL,
	productid integer NOT NULL
);

COMMENT ON TABLE productkeyword IS 'Identifies product GCMD concepts(keywords).';

COMMENT ON COLUMN productkeyword.productkeywordid IS 'PK for PRODUCTKEYWORD';

COMMENT ON COLUMN productkeyword.keywordid IS 'GCMD concept UUID';

COMMENT ON COLUMN productkeyword.productid IS 'PK for PRODUCT';

CREATE TABLE productline (
	productid integer NOT NULL,
	productlineid integer DEFAULT nextval('common.productline_productlineid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE productpoint (
	productid integer NOT NULL,
	productpointid integer DEFAULT nextval('common.productpoint_productpointid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE productpolygon (
	productid integer NOT NULL,
	productpolygonid integer DEFAULT nextval('common.productpolygon_productpolygonid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE producttopiccategory (
	productid integer NOT NULL,
	topiccategoryid integer NOT NULL
);

CREATE TABLE onlineresource (
	onlineresourceid integer DEFAULT nextval('common.onlineresource_onlineresourceid_seq'::regclass) NOT NULL,
	onlinefunctionid integer NOT NULL,
	productid integer NOT NULL,
	uri character varying NOT NULL,
	title character varying NOT NULL,
	description character varying(300) NOT NULL
);

COMMENT ON TABLE onlineresource IS 'Information about accessing on-line resources and services. This may be a website, profile page, GitHub page, etc.';

COMMENT ON COLUMN onlineresource.onlineresourceid IS 'PK for ONLINERESOURCE';

COMMENT ON COLUMN onlineresource.onlinefunctionid IS 'PK for ONLINEFUNCTION';

COMMENT ON COLUMN onlineresource.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN onlineresource.uri IS 'Location (address) for on-line access using a Uniform Resource Identifier, usually in the form of a Uniform Resource Locator (URL).';

COMMENT ON COLUMN onlineresource.title IS 'Descriptive title for onlineresource.';

COMMENT ON COLUMN onlineresource.description IS 'Short description of onlineresource';

CREATE TABLE productcontact (
	productid integer NOT NULL,
	contactid integer NOT NULL,
	isoroletypeid integer NOT NULL,
	productcontactid integer DEFAULT nextval('common.productcontact_productcontactid_seq'::regclass) NOT NULL
);

COMMENT ON TABLE productcontact IS 'Identifies product contacts and roles';

COMMENT ON COLUMN productcontact.isoroletypeid IS 'PK for ISOROLETYPE';

COMMENT ON COLUMN productcontact.productcontactid IS 'PK for PRODUCTCONTACT';

CREATE TABLE productstatus (
	productstatusid integer DEFAULT nextval('common.productstatus_productstatusid_seq'::regclass) NOT NULL,
	productid integer NOT NULL,
	datetypeid integer NOT NULL,
	contactid integer NOT NULL,
	effectivedate date NOT NULL,
	comment character varying
);

COMMENT ON TABLE productstatus IS 'Status of product';

COMMENT ON COLUMN productstatus.productstatusid IS 'PK for PRODUCTSTATUS';

COMMENT ON COLUMN productstatus.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN productstatus.datetypeid IS 'PK for DATETYPE';

COMMENT ON COLUMN productstatus.effectivedate IS 'Date of status change';

ALTER TABLE project
	ADD COLUMN metadataupdate timestamp without time zone;

COMMENT ON COLUMN project.metadataupdate IS 'Date when metadata was last updated (published).';

ALTER TABLE projectprojectcategory
	ALTER COLUMN projectid DROP DEFAULT;

ALTER TABLE projecttopiccategory
	ALTER COLUMN projectid DROP DEFAULT,
	ALTER COLUMN topiccategoryid DROP DEFAULT;

ALTER TABLE product
	ADD CONSTRAINT product_pk PRIMARY KEY (productid);

ALTER TABLE productkeyword
	ADD CONSTRAINT productkeyword_pk PRIMARY KEY (productkeywordid);

ALTER TABLE productline
	ADD CONSTRAINT productline_pk PRIMARY KEY (productlineid);

ALTER TABLE productpoint
	ADD CONSTRAINT productpoint_pk PRIMARY KEY (productpointid);

ALTER TABLE productpolygon
	ADD CONSTRAINT productpolygon_pk PRIMARY KEY (productpolygonid);

ALTER TABLE producttopiccategory
	ADD CONSTRAINT producttopiccategory_pk PRIMARY KEY (productid, topiccategoryid);

ALTER TABLE onlineresource
	ADD CONSTRAINT onlineresourceid_pk PRIMARY KEY (onlineresourceid);

ALTER TABLE productcontact
	ADD CONSTRAINT productcontact_pk PRIMARY KEY (productcontactid);

ALTER TABLE productstatus
	ADD CONSTRAINT productstatus_pk PRIMARY KEY (productstatusid);

ALTER TABLE product
	ADD CONSTRAINT deliverabletype_product_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);

ALTER TABLE product
	ADD CONSTRAINT isoprogresstype_product_fk FOREIGN KEY (isoprogresstypeid) REFERENCES cvl.isoprogresstype(isoprogresstypeid);

ALTER TABLE product
	ADD CONSTRAINT project_product_fk FOREIGN KEY (projectid) REFERENCES project(projectid);

ALTER TABLE productkeyword
	ADD CONSTRAINT keyword_productkeyword_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);

ALTER TABLE productkeyword
	ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE productline
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productline
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL)));

ALTER TABLE productline
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productline
	ADD CONSTRAINT product_productline_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL)));

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productpoint
	ADD CONSTRAINT product_productpoint_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL)));

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productpolygon
	ADD CONSTRAINT product_productpolygon_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE producttopiccategory
	ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE producttopiccategory
	ADD CONSTRAINT topiccategory_producttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);

ALTER TABLE onlineresource
	ADD CONSTRAINT onlinefunction_onlineresource_fk FOREIGN KEY (onlinefunctionid) REFERENCES cvl.onlinefunction(onlinefunctionid);

ALTER TABLE onlineresource
	ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE productcontact
	ADD CONSTRAINT productcontact_productid_roletypeid_contactid_key UNIQUE (productid, isoroletypeid, contactid);

ALTER TABLE productcontact
	ADD CONSTRAINT contact_productcontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;

ALTER TABLE productcontact
	ADD CONSTRAINT isoroletype_productcontact_fk FOREIGN KEY (isoroletypeid) REFERENCES cvl.isoroletype(isoroletypeid);

ALTER TABLE productcontact
	ADD CONSTRAINT product_productcontact_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productstatus
	ADD CONSTRAINT datetype_productstatus_fk FOREIGN KEY (datetypeid) REFERENCES cvl.datetype(datetypeid);

ALTER TABLE productstatus
	ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid) REFERENCES product(productid);

CREATE INDEX fki_isoroletype_productcontact_fk ON productcontact USING btree (isoroletypeid);

CREATE VIEW metadataproduct AS
	SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
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
    product.metadataupdate
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((product
     JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

CREATE VIEW metadataproject AS
	WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
        )
 SELECT project.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE (m.projectid = project.projectid)
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate
   FROM gschema,
    (((((((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((status.statusid = common.project_status(project.projectid))))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((projectkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM (projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((usertype.usertype)::text, '|'::text) AS usertype
           FROM (projectusertype
             JOIN cvl.usertype USING (usertypeid))
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (projecttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectcategory.category)::text, '|'::text) AS projectcategory
           FROM (projectprojectcategory
             JOIN cvl.projectcategory USING (projectcategoryid))
          GROUP BY projectprojectcategory.projectid) pc USING (projectid))
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            ('point-'::text || projectpoint.projectpointid) AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            ('polygon-'::text || projectpolygon.projectpolygonid) AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            ('line-'::text || projectline.projectlineid) AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid));

CREATE VIEW productcontactlist AS
	SELECT pc.productcontactid,
    pc.productid,
    pc.contactid,
    pc.isoroletypeid,
    pc.name,
    isoroletype.codename AS role
   FROM (( SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name
           FROM (productcontact
             JOIN person USING (contactid))
        UNION
         SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            contactgroup.name
           FROM (productcontact
             JOIN contactgroup USING (contactid))) pc
     JOIN cvl.isoroletype USING (isoroletypeid))
  ORDER BY isoroletype.code;

CREATE VIEW productfeature AS
	SELECT productpoint.productid,
    ('Point-'::text || productpoint.productpointid) AS id,
    productpoint.name,
    productpoint.comment,
    public.st_asgeojson(productpoint.the_geom, 8) AS geom
   FROM productpoint
UNION
 SELECT productpolygon.productid,
    ('Polygon-'::text || productpolygon.productpolygonid) AS id,
    productpolygon.name,
    productpolygon.comment,
    public.st_asgeojson(productpolygon.the_geom, 8) AS geom
   FROM productpolygon
UNION
 SELECT productline.productid,
    ('LineString-'::text || productline.productlineid) AS id,
    productline.name,
    productline.comment,
    public.st_asgeojson(productline.the_geom, 8) AS geom
   FROM productline;

CREATE VIEW productkeywordlist AS
	SELECT productkeyword.keywordid,
    productkeyword.productid,
    productkeyword.productkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (productkeyword
     JOIN gcmd.keyword USING (keywordid));

CREATE VIEW productlist AS
	SELECT p.productid,
    p.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress
   FROM ((((product p
     JOIN project USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN cvl.isoprogresstype USING (isoprogresstypeid));

CREATE VIEW productmetadata AS
	SELECT product.productid,
    tc.topiccategory
   FROM (product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid));


SET search_path = alcc, pg_catalog;

DROP VIEW metadataproject;

CREATE TABLE product (
	productid integer DEFAULT nextval('common.product_productid_seq'::regclass) NOT NULL,
	projectid integer NOT NULL,
	uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	title character varying(150) NOT NULL,
	description character varying(300) NOT NULL,
	abstract character varying NOT NULL,
	purpose character varying(300),
	startdate date,
	enddate date,
	exportmetadata boolean DEFAULT false NOT NULL,
	deliverabletypeid integer NOT NULL,
	isoprogresstypeid integer NOT NULL,
	metadataupdate timestamp without time zone
);

COMMENT ON TABLE product IS 'A distributable product produced by a project.';

COMMENT ON COLUMN product.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN product.uuid IS 'Universally unique identifier for product';

COMMENT ON COLUMN product.title IS 'Title of Product';

COMMENT ON COLUMN product.description IS 'Short description of product';

COMMENT ON COLUMN product.abstract IS 'Long description of product';

COMMENT ON COLUMN product.purpose IS 'A summary of intentions for which the product was created.';

COMMENT ON COLUMN product.startdate IS 'Start date for period of validity or relevance';

COMMENT ON COLUMN product.enddate IS 'End date for period of validity or relevance';

COMMENT ON COLUMN product.exportmetadata IS 'Specifies whether product metadata should be exported.';

COMMENT ON COLUMN product.metadataupdate IS 'Date when metadata was last updated (published).';

CREATE TABLE productkeyword (
	productkeywordid integer DEFAULT nextval('common.productkeyword_productkeywordid_seq'::regclass) NOT NULL,
	keywordid uuid NOT NULL,
	productid integer NOT NULL
);

COMMENT ON TABLE productkeyword IS 'Identifies product GCMD concepts(keywords).';

COMMENT ON COLUMN productkeyword.productkeywordid IS 'PK for PRODUCTKEYWORD';

COMMENT ON COLUMN productkeyword.keywordid IS 'GCMD concept UUID';

COMMENT ON COLUMN productkeyword.productid IS 'PK for PRODUCT';

CREATE TABLE productline (
	productid integer NOT NULL,
	productlineid integer DEFAULT nextval('common.productline_productlineid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE productpoint (
	productid integer NOT NULL,
	productpointid integer DEFAULT nextval('common.productpoint_productpointid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE productpolygon (
	productid integer NOT NULL,
	productpolygonid integer DEFAULT nextval('common.productpolygon_productpolygonid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE producttopiccategory (
	productid integer NOT NULL,
	topiccategoryid integer NOT NULL
);

CREATE TABLE onlineresource (
	onlineresourceid integer DEFAULT nextval('common.onlineresource_onlineresourceid_seq'::regclass) NOT NULL,
	onlinefunctionid integer NOT NULL,
	productid integer NOT NULL,
	uri character varying NOT NULL,
	title character varying NOT NULL,
	description character varying(300) NOT NULL
);

COMMENT ON TABLE onlineresource IS 'Information about accessing on-line resources and services. This may be a website, profile page, GitHub page, etc.';

COMMENT ON COLUMN onlineresource.onlineresourceid IS 'PK for ONLINERESOURCE';

COMMENT ON COLUMN onlineresource.onlinefunctionid IS 'PK for ONLINEFUNCTION';

COMMENT ON COLUMN onlineresource.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN onlineresource.uri IS 'Location (address) for on-line access using a Uniform Resource Identifier, usually in the form of a Uniform Resource Locator (URL).';

COMMENT ON COLUMN onlineresource.title IS 'Descriptive title for onlineresource.';

COMMENT ON COLUMN onlineresource.description IS 'Short description of onlineresource';

CREATE TABLE productcontact (
	productid integer NOT NULL,
	contactid integer NOT NULL,
	isoroletypeid integer NOT NULL,
	productcontactid integer DEFAULT nextval('common.productcontact_productcontactid_seq'::regclass) NOT NULL
);

COMMENT ON TABLE productcontact IS 'Identifies product contacts and roles';

COMMENT ON COLUMN productcontact.isoroletypeid IS 'PK for ISOROLETYPE';

COMMENT ON COLUMN productcontact.productcontactid IS 'PK for PRODUCTCONTACT';

CREATE TABLE productstatus (
	productstatusid integer DEFAULT nextval('common.productstatus_productstatusid_seq'::regclass) NOT NULL,
	productid integer NOT NULL,
	datetypeid integer NOT NULL,
	contactid integer NOT NULL,
	effectivedate date NOT NULL,
	comment character varying
);

COMMENT ON TABLE productstatus IS 'Status of product';

COMMENT ON COLUMN productstatus.productstatusid IS 'PK for PRODUCTSTATUS';

COMMENT ON COLUMN productstatus.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN productstatus.datetypeid IS 'PK for DATETYPE';

COMMENT ON COLUMN productstatus.effectivedate IS 'Date of status change';

ALTER TABLE project
	ADD COLUMN metadataupdate timestamp without time zone;

COMMENT ON COLUMN project.metadataupdate IS 'Date when metadata was last updated (published).';

ALTER TABLE projectprojectcategory
	ALTER COLUMN projectid DROP DEFAULT;

ALTER TABLE projecttopiccategory
	ALTER COLUMN projectid DROP DEFAULT,
	ALTER COLUMN topiccategoryid DROP DEFAULT;

ALTER TABLE product
	ADD CONSTRAINT product_pk PRIMARY KEY (productid);

ALTER TABLE productkeyword
	ADD CONSTRAINT productkeyword_pk PRIMARY KEY (productkeywordid);

ALTER TABLE productline
	ADD CONSTRAINT productline_pk PRIMARY KEY (productlineid);

ALTER TABLE productpoint
	ADD CONSTRAINT productpoint_pk PRIMARY KEY (productpointid);

ALTER TABLE productpolygon
	ADD CONSTRAINT productpolygon_pk PRIMARY KEY (productpolygonid);

ALTER TABLE producttopiccategory
	ADD CONSTRAINT producttopiccategory_pk PRIMARY KEY (productid, topiccategoryid);

ALTER TABLE onlineresource
	ADD CONSTRAINT onlineresourceid_pk PRIMARY KEY (onlineresourceid);

ALTER TABLE productcontact
	ADD CONSTRAINT productcontact_pk PRIMARY KEY (productcontactid);

ALTER TABLE productstatus
	ADD CONSTRAINT productstatus_pk PRIMARY KEY (productstatusid);

ALTER TABLE product
	ADD CONSTRAINT deliverabletype_product_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);

ALTER TABLE product
	ADD CONSTRAINT isoprogresstype_product_fk FOREIGN KEY (isoprogresstypeid) REFERENCES cvl.isoprogresstype(isoprogresstypeid);

ALTER TABLE product
	ADD CONSTRAINT project_product_fk FOREIGN KEY (projectid) REFERENCES project(projectid);

ALTER TABLE productkeyword
	ADD CONSTRAINT keyword_productkeyword_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);

ALTER TABLE productkeyword
	ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE productline
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productline
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL)));

ALTER TABLE productline
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productline
	ADD CONSTRAINT product_productline_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL)));

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productpoint
	ADD CONSTRAINT product_productpoint_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL)));

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productpolygon
	ADD CONSTRAINT product_productpolygon_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE producttopiccategory
	ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE producttopiccategory
	ADD CONSTRAINT topiccategory_producttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);

ALTER TABLE onlineresource
	ADD CONSTRAINT onlinefunction_onlineresource_fk FOREIGN KEY (onlinefunctionid) REFERENCES cvl.onlinefunction(onlinefunctionid);

ALTER TABLE onlineresource
	ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE productcontact
	ADD CONSTRAINT productcontact_productid_roletypeid_contactid_key UNIQUE (productid, isoroletypeid, contactid);

ALTER TABLE productcontact
	ADD CONSTRAINT contact_productcontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;

ALTER TABLE productcontact
	ADD CONSTRAINT isoroletype_productcontact_fk FOREIGN KEY (isoroletypeid) REFERENCES cvl.isoroletype(isoroletypeid);

ALTER TABLE productcontact
	ADD CONSTRAINT product_productcontact_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productstatus
	ADD CONSTRAINT datetype_productstatus_fk FOREIGN KEY (datetypeid) REFERENCES cvl.datetype(datetypeid);

ALTER TABLE productstatus
	ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid) REFERENCES product(productid);

CREATE INDEX fki_isoroletype_productcontact_fk ON productcontact USING btree (isoroletypeid);

CREATE VIEW metadataproduct AS
	SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
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
    product.metadataupdate
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((product
     JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

CREATE VIEW metadataproject AS
	WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
        )
 SELECT project.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE (m.projectid = project.projectid)
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate
   FROM gschema,
    (((((((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((status.statusid = common.project_status(project.projectid))))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((projectkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM (projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((usertype.usertype)::text, '|'::text) AS usertype
           FROM (projectusertype
             JOIN cvl.usertype USING (usertypeid))
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (projecttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectcategory.category)::text, '|'::text) AS projectcategory
           FROM (projectprojectcategory
             JOIN cvl.projectcategory USING (projectcategoryid))
          GROUP BY projectprojectcategory.projectid) pc USING (projectid))
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            ('point-'::text || projectpoint.projectpointid) AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            ('polygon-'::text || projectpolygon.projectpolygonid) AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            ('line-'::text || projectline.projectlineid) AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid));

CREATE VIEW productcontactlist AS
	SELECT pc.productcontactid,
    pc.productid,
    pc.contactid,
    pc.isoroletypeid,
    pc.name,
    isoroletype.codename AS role
   FROM (( SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name
           FROM (productcontact
             JOIN person USING (contactid))
        UNION
         SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            contactgroup.name
           FROM (productcontact
             JOIN contactgroup USING (contactid))) pc
     JOIN cvl.isoroletype USING (isoroletypeid))
  ORDER BY isoroletype.code;

CREATE VIEW productfeature AS
	SELECT productpoint.productid,
    ('Point-'::text || productpoint.productpointid) AS id,
    productpoint.name,
    productpoint.comment,
    public.st_asgeojson(productpoint.the_geom, 8) AS geom
   FROM productpoint
UNION
 SELECT productpolygon.productid,
    ('Polygon-'::text || productpolygon.productpolygonid) AS id,
    productpolygon.name,
    productpolygon.comment,
    public.st_asgeojson(productpolygon.the_geom, 8) AS geom
   FROM productpolygon
UNION
 SELECT productline.productid,
    ('LineString-'::text || productline.productlineid) AS id,
    productline.name,
    productline.comment,
    public.st_asgeojson(productline.the_geom, 8) AS geom
   FROM productline;

CREATE VIEW productkeywordlist AS
	SELECT productkeyword.keywordid,
    productkeyword.productid,
    productkeyword.productkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (productkeyword
     JOIN gcmd.keyword USING (keywordid));

CREATE VIEW productlist AS
	SELECT p.productid,
    p.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress
   FROM ((((product p
     JOIN project USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN cvl.isoprogresstype USING (isoprogresstypeid));

CREATE VIEW productmetadata AS
	SELECT product.productid,
    tc.topiccategory
   FROM (product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid));

SET search_path = walcc, pg_catalog;

DROP VIEW metadataproject;

CREATE TABLE product (
	productid integer DEFAULT nextval('common.product_productid_seq'::regclass) NOT NULL,
	projectid integer NOT NULL,
	uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	title character varying(150) NOT NULL,
	description character varying(300) NOT NULL,
	abstract character varying NOT NULL,
	purpose character varying(300),
	startdate date,
	enddate date,
	exportmetadata boolean DEFAULT false NOT NULL,
	deliverabletypeid integer NOT NULL,
	isoprogresstypeid integer NOT NULL,
	metadataupdate timestamp without time zone
);

COMMENT ON TABLE product IS 'A distributable product produced by a project.';

COMMENT ON COLUMN product.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN product.uuid IS 'Universally unique identifier for product';

COMMENT ON COLUMN product.title IS 'Title of Product';

COMMENT ON COLUMN product.description IS 'Short description of product';

COMMENT ON COLUMN product.abstract IS 'Long description of product';

COMMENT ON COLUMN product.purpose IS 'A summary of intentions for which the product was created.';

COMMENT ON COLUMN product.startdate IS 'Start date for period of validity or relevance';

COMMENT ON COLUMN product.enddate IS 'End date for period of validity or relevance';

COMMENT ON COLUMN product.exportmetadata IS 'Specifies whether product metadata should be exported.';

COMMENT ON COLUMN product.metadataupdate IS 'Date when metadata was last updated (published).';

CREATE TABLE productkeyword (
	productkeywordid integer DEFAULT nextval('common.productkeyword_productkeywordid_seq'::regclass) NOT NULL,
	keywordid uuid NOT NULL,
	productid integer NOT NULL
);

COMMENT ON TABLE productkeyword IS 'Identifies product GCMD concepts(keywords).';

COMMENT ON COLUMN productkeyword.productkeywordid IS 'PK for PRODUCTKEYWORD';

COMMENT ON COLUMN productkeyword.keywordid IS 'GCMD concept UUID';

COMMENT ON COLUMN productkeyword.productid IS 'PK for PRODUCT';

CREATE TABLE productline (
	productid integer NOT NULL,
	productlineid integer DEFAULT nextval('common.productline_productlineid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE productpoint (
	productid integer NOT NULL,
	productpointid integer DEFAULT nextval('common.productpoint_productpointid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE productpolygon (
	productid integer NOT NULL,
	productpolygonid integer DEFAULT nextval('common.productpolygon_productpolygonid_seq'::regclass) NOT NULL,
	name character varying NOT NULL,
	comment character varying,
	the_geom public.geometry
);

CREATE TABLE producttopiccategory (
	productid integer NOT NULL,
	topiccategoryid integer NOT NULL
);

CREATE TABLE onlineresource (
	onlineresourceid integer DEFAULT nextval('common.onlineresource_onlineresourceid_seq'::regclass) NOT NULL,
	onlinefunctionid integer NOT NULL,
	productid integer NOT NULL,
	uri character varying NOT NULL,
	title character varying NOT NULL,
	description character varying(300) NOT NULL
);

COMMENT ON TABLE onlineresource IS 'Information about accessing on-line resources and services. This may be a website, profile page, GitHub page, etc.';

COMMENT ON COLUMN onlineresource.onlineresourceid IS 'PK for ONLINERESOURCE';

COMMENT ON COLUMN onlineresource.onlinefunctionid IS 'PK for ONLINEFUNCTION';

COMMENT ON COLUMN onlineresource.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN onlineresource.uri IS 'Location (address) for on-line access using a Uniform Resource Identifier, usually in the form of a Uniform Resource Locator (URL).';

COMMENT ON COLUMN onlineresource.title IS 'Descriptive title for onlineresource.';

COMMENT ON COLUMN onlineresource.description IS 'Short description of onlineresource';

CREATE TABLE productcontact (
	productid integer NOT NULL,
	contactid integer NOT NULL,
	isoroletypeid integer NOT NULL,
	productcontactid integer DEFAULT nextval('common.productcontact_productcontactid_seq'::regclass) NOT NULL
);

COMMENT ON TABLE productcontact IS 'Identifies product contacts and roles';

COMMENT ON COLUMN productcontact.isoroletypeid IS 'PK for ISOROLETYPE';

COMMENT ON COLUMN productcontact.productcontactid IS 'PK for PRODUCTCONTACT';

CREATE TABLE productstatus (
	productstatusid integer DEFAULT nextval('common.productstatus_productstatusid_seq'::regclass) NOT NULL,
	productid integer NOT NULL,
	datetypeid integer NOT NULL,
	contactid integer NOT NULL,
	effectivedate date NOT NULL,
	comment character varying
);

COMMENT ON TABLE productstatus IS 'Status of product';

COMMENT ON COLUMN productstatus.productstatusid IS 'PK for PRODUCTSTATUS';

COMMENT ON COLUMN productstatus.productid IS 'PK for PRODUCT';

COMMENT ON COLUMN productstatus.datetypeid IS 'PK for DATETYPE';

COMMENT ON COLUMN productstatus.effectivedate IS 'Date of status change';

ALTER TABLE project
	ADD COLUMN metadataupdate timestamp without time zone;

COMMENT ON COLUMN project.metadataupdate IS 'Date when metadata was last updated (published).';

ALTER TABLE projectprojectcategory
	ALTER COLUMN projectid DROP DEFAULT;

ALTER TABLE projecttopiccategory
	ALTER COLUMN projectid DROP DEFAULT,
	ALTER COLUMN topiccategoryid DROP DEFAULT;

ALTER TABLE product
	ADD CONSTRAINT product_pk PRIMARY KEY (productid);

ALTER TABLE productkeyword
	ADD CONSTRAINT productkeyword_pk PRIMARY KEY (productkeywordid);

ALTER TABLE productline
	ADD CONSTRAINT productline_pk PRIMARY KEY (productlineid);

ALTER TABLE productpoint
	ADD CONSTRAINT productpoint_pk PRIMARY KEY (productpointid);

ALTER TABLE productpolygon
	ADD CONSTRAINT productpolygon_pk PRIMARY KEY (productpolygonid);

ALTER TABLE producttopiccategory
	ADD CONSTRAINT producttopiccategory_pk PRIMARY KEY (productid, topiccategoryid);

ALTER TABLE onlineresource
	ADD CONSTRAINT onlineresourceid_pk PRIMARY KEY (onlineresourceid);

ALTER TABLE productcontact
	ADD CONSTRAINT productcontact_pk PRIMARY KEY (productcontactid);

ALTER TABLE productstatus
	ADD CONSTRAINT productstatus_pk PRIMARY KEY (productstatusid);

ALTER TABLE product
	ADD CONSTRAINT deliverabletype_product_fk FOREIGN KEY (deliverabletypeid) REFERENCES cvl.deliverabletype(deliverabletypeid);

ALTER TABLE product
	ADD CONSTRAINT isoprogresstype_product_fk FOREIGN KEY (isoprogresstypeid) REFERENCES cvl.isoprogresstype(isoprogresstypeid);

ALTER TABLE product
	ADD CONSTRAINT project_product_fk FOREIGN KEY (projectid) REFERENCES project(projectid);

ALTER TABLE productkeyword
	ADD CONSTRAINT keyword_productkeyword_fk FOREIGN KEY (keywordid) REFERENCES gcmd.keyword(keywordid);

ALTER TABLE productkeyword
	ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE productline
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productline
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'LINESTRING'::text) OR (the_geom IS NULL)));

ALTER TABLE productline
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productline
	ADD CONSTRAINT product_productline_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POINT'::text) OR (the_geom IS NULL)));

ALTER TABLE productpoint
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productpoint
	ADD CONSTRAINT product_productpoint_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_dims_the_geom CHECK ((public.st_ndims(the_geom) = 2));

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_geotype_the_geom CHECK (((public.geometrytype(the_geom) = 'POLYGON'::text) OR (the_geom IS NULL)));

ALTER TABLE productpolygon
	ADD CONSTRAINT enforce_srid_the_geom CHECK ((public.st_srid(the_geom) = 3857));

ALTER TABLE productpolygon
	ADD CONSTRAINT product_productpolygon_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE producttopiccategory
	ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE producttopiccategory
	ADD CONSTRAINT topiccategory_producttopiccategory_fk FOREIGN KEY (topiccategoryid) REFERENCES cvl.topiccategory(topiccategoryid);

ALTER TABLE onlineresource
	ADD CONSTRAINT onlinefunction_onlineresource_fk FOREIGN KEY (onlinefunctionid) REFERENCES cvl.onlinefunction(onlinefunctionid);

ALTER TABLE onlineresource
	ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid) REFERENCES product(productid);

ALTER TABLE productcontact
	ADD CONSTRAINT productcontact_productid_roletypeid_contactid_key UNIQUE (productid, isoroletypeid, contactid);

ALTER TABLE productcontact
	ADD CONSTRAINT contact_productcontact_fk FOREIGN KEY (contactid) REFERENCES contact(contactid) ON DELETE CASCADE;

ALTER TABLE productcontact
	ADD CONSTRAINT isoroletype_productcontact_fk FOREIGN KEY (isoroletypeid) REFERENCES cvl.isoroletype(isoroletypeid);

ALTER TABLE productcontact
	ADD CONSTRAINT product_productcontact_fk FOREIGN KEY (productid) REFERENCES product(productid) ON DELETE CASCADE;

ALTER TABLE productstatus
	ADD CONSTRAINT datetype_productstatus_fk FOREIGN KEY (datetypeid) REFERENCES cvl.datetype(datetypeid);

ALTER TABLE productstatus
	ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid) REFERENCES product(productid);

CREATE INDEX fki_isoroletype_productcontact_fk ON productcontact USING btree (isoroletypeid);

CREATE VIEW metadataproduct AS
	SELECT product.productid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    project.orgid,
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
    product.metadataupdate
   FROM ( SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.producturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))) gschema,
    (((((((product
     JOIN project USING (projectid))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
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

CREATE VIEW metadataproject AS
	WITH gschema AS (
         SELECT groupschema.groupschemaid,
            groupschema.groupid,
            groupschema.displayname,
            groupschema.deliverablecalendarid,
            groupschema.projecturiformat
           FROM common.groupschema
          WHERE ((groupschema.groupschemaid)::name = ANY (current_schemas(false)))
        )
 SELECT project.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
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
    format((gschema.projecturiformat)::text, project.fiscalyear, btrim(to_char((project.number)::double precision, '999909'::text))) AS uri,
    ( SELECT m.datecreated
           FROM modification m
          WHERE (m.projectid = project.projectid)
          ORDER BY m.datecreated
         LIMIT 1) AS datecreated,
    status.adiwg AS status,
    kw.keywords,
    to_json(ARRAY[public.st_xmin((fea.extent)::public.box3d), public.st_ymin((fea.extent)::public.box3d), public.st_xmax((fea.extent)::public.box3d), public.st_ymax((fea.extent)::public.box3d)]) AS bbox,
    fea.features,
    project.supplemental,
    ut.usertype,
    tc.topiccategory,
    pc.projectcategory,
    project.metadataupdate
   FROM gschema,
    (((((((project
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.status ON ((status.statusid = common.project_status(project.projectid))))
     LEFT JOIN ( SELECT projectkeyword.projectid,
            string_agg((projectkeyword.preflabel)::text, '|'::text) AS keywords
           FROM ( SELECT projectkeyword_1.projectid,
                    keyword.preflabel
                   FROM (projectkeyword projectkeyword_1
                     JOIN gcmd.keyword USING (keywordid))
                  GROUP BY projectkeyword_1.projectid, keyword.preflabel) projectkeyword
          GROUP BY projectkeyword.projectid) kw USING (projectid))
     LEFT JOIN ( SELECT projectusertype.projectid,
            string_agg((usertype.usertype)::text, '|'::text) AS usertype
           FROM (projectusertype
             JOIN cvl.usertype USING (usertypeid))
          GROUP BY projectusertype.projectid) ut USING (projectid))
     LEFT JOIN ( SELECT projecttopiccategory.projectid,
            string_agg((topiccategory.codename)::text, '|'::text) AS topiccategory
           FROM (projecttopiccategory
             JOIN cvl.topiccategory USING (topiccategoryid))
          GROUP BY projecttopiccategory.projectid) tc USING (projectid))
     LEFT JOIN ( SELECT projectprojectcategory.projectid,
            string_agg((projectcategory.category)::text, '|'::text) AS projectcategory
           FROM (projectprojectcategory
             JOIN cvl.projectcategory USING (projectcategoryid))
          GROUP BY projectprojectcategory.projectid) pc USING (projectid))
     LEFT JOIN ( SELECT f.projectid,
            array_to_json(array_agg(( SELECT fj.*::record AS fj
                   FROM ( SELECT f.type,
                            f.id,
                            f.geometry,
                            f.properties) fj))) AS features,
            public.st_extent(public.st_transform(f.the_geom, 4326)) AS extent
           FROM ( SELECT lg.projectid,
                    lg.the_geom,
                    'Feature' AS type,
                    lg.id,
                    (public.st_asgeojson(public.st_transform(lg.the_geom, 4326), 6))::json AS geometry,
                    row_to_json(( SELECT l.*::record AS l
                           FROM ( SELECT COALESCE(lg.name, ''::character varying) AS "featureName",
                                    COALESCE(lg.comment, ''::character varying) AS description) l)) AS properties
                   FROM ( SELECT projectpoint.projectid,
                            ('point-'::text || projectpoint.projectpointid) AS id,
                            projectpoint.name,
                            projectpoint.comment,
                            projectpoint.the_geom
                           FROM projectpoint
                        UNION
                         SELECT projectpolygon.projectid,
                            ('polygon-'::text || projectpolygon.projectpolygonid) AS id,
                            projectpolygon.name,
                            projectpolygon.comment,
                            projectpolygon.the_geom
                           FROM projectpolygon
                        UNION
                         SELECT projectline.projectid,
                            ('line-'::text || projectline.projectlineid) AS id,
                            projectline.name,
                            projectline.comment,
                            projectline.the_geom
                           FROM projectline) lg) f
          GROUP BY f.projectid) fea USING (projectid));

CREATE VIEW productcontactlist AS
	SELECT pc.productcontactid,
    pc.productid,
    pc.contactid,
    pc.isoroletypeid,
    pc.name,
    isoroletype.codename AS role
   FROM (( SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            concat(person.lastname, ', ', person.firstname, ' ', person.middlename) AS name
           FROM (productcontact
             JOIN person USING (contactid))
        UNION
         SELECT productcontact.productcontactid,
            productcontact.productid,
            productcontact.contactid,
            productcontact.isoroletypeid,
            contactgroup.name
           FROM (productcontact
             JOIN contactgroup USING (contactid))) pc
     JOIN cvl.isoroletype USING (isoroletypeid))
  ORDER BY isoroletype.code;

CREATE VIEW productfeature AS
	SELECT productpoint.productid,
    ('Point-'::text || productpoint.productpointid) AS id,
    productpoint.name,
    productpoint.comment,
    public.st_asgeojson(productpoint.the_geom, 8) AS geom
   FROM productpoint
UNION
 SELECT productpolygon.productid,
    ('Polygon-'::text || productpolygon.productpolygonid) AS id,
    productpolygon.name,
    productpolygon.comment,
    public.st_asgeojson(productpolygon.the_geom, 8) AS geom
   FROM productpolygon
UNION
 SELECT productline.productid,
    ('LineString-'::text || productline.productlineid) AS id,
    productline.name,
    productline.comment,
    public.st_asgeojson(productline.the_geom, 8) AS geom
   FROM productline;

CREATE VIEW productkeywordlist AS
	SELECT productkeyword.keywordid,
    productkeyword.productid,
    productkeyword.productkeywordid,
    keyword.preflabel AS text,
    keyword.definition,
    keyword.parentkeywordid
   FROM (productkeyword
     JOIN gcmd.keyword USING (keywordid));

CREATE VIEW productlist AS
	SELECT p.productid,
    p.projectid,
    common.form_projectcode((project.number)::integer, (project.fiscalyear)::integer, contactgroup.acronym) AS projectcode,
    p.uuid,
    p.title,
    p.description,
    p.abstract,
    p.purpose,
    p.startdate,
    p.enddate,
    p.exportmetadata,
    deliverabletype.code AS type,
    p.deliverabletypeid,
    p.isoprogresstypeid,
    isoprogresstype.codename AS progress
   FROM ((((product p
     JOIN project USING (projectid))
     JOIN contactgroup ON ((project.orgid = contactgroup.contactid)))
     JOIN cvl.deliverabletype USING (deliverabletypeid))
     JOIN cvl.isoprogresstype USING (isoprogresstypeid));

CREATE VIEW productmetadata AS
	SELECT product.productid,
    tc.topiccategory
   FROM (product
     LEFT JOIN ( SELECT producttopiccategory.productid,
            string_agg((producttopiccategory.topiccategoryid)::text, ','::text) AS topiccategory
           FROM producttopiccategory
          GROUP BY producttopiccategory.productid) tc USING (productid));

ALTER TABLE dev.projectprojectcategory DROP CONSTRAINT project_projectprojectcategory_fk;

ALTER TABLE dev.projectprojectcategory
  ADD CONSTRAINT project_projectprojectcategory_fk FOREIGN KEY (projectid)
      REFERENCES dev.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.projecttopiccategory DROP CONSTRAINT project_projecttopiccategory_fk;

ALTER TABLE dev.projecttopiccategory
  ADD CONSTRAINT project_projecttopiccategory_fk FOREIGN KEY (projectid)
      REFERENCES dev.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.projectusertype DROP CONSTRAINT project_projectusertype_fk;

ALTER TABLE dev.projectusertype
  ADD CONSTRAINT project_projectusertype_fk FOREIGN KEY (projectid)
      REFERENCES dev.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.producttopiccategory DROP CONSTRAINT product_producttopiccategory_fk;

ALTER TABLE dev.producttopiccategory
  ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid)
      REFERENCES dev.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.productstatus DROP CONSTRAINT product_productstatus_fk;

ALTER TABLE dev.productstatus
  ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid)
      REFERENCES dev.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.productkeyword DROP CONSTRAINT product_productkeyword_fk;

ALTER TABLE dev.productkeyword
  ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid)
      REFERENCES dev.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.onlineresource DROP CONSTRAINT product_onlineresource_fk;

ALTER TABLE dev.onlineresource
  ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid)
      REFERENCES dev.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.projectprojectcategory DROP CONSTRAINT project_projectprojectcategory_fk;

ALTER TABLE alcc.projectprojectcategory
  ADD CONSTRAINT project_projectprojectcategory_fk FOREIGN KEY (projectid)
      REFERENCES alcc.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.projecttopiccategory DROP CONSTRAINT project_projecttopiccategory_fk;

ALTER TABLE alcc.projecttopiccategory
  ADD CONSTRAINT project_projecttopiccategory_fk FOREIGN KEY (projectid)
      REFERENCES alcc.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.projectusertype DROP CONSTRAINT project_projectusertype_fk;

ALTER TABLE alcc.projectusertype
  ADD CONSTRAINT project_projectusertype_fk FOREIGN KEY (projectid)
      REFERENCES alcc.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.producttopiccategory DROP CONSTRAINT product_producttopiccategory_fk;

ALTER TABLE alcc.producttopiccategory
  ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid)
      REFERENCES alcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.productstatus DROP CONSTRAINT product_productstatus_fk;

ALTER TABLE alcc.productstatus
  ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid)
      REFERENCES alcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.productkeyword DROP CONSTRAINT product_productkeyword_fk;

ALTER TABLE alcc.productkeyword
  ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid)
      REFERENCES alcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.onlineresource DROP CONSTRAINT product_onlineresource_fk;

ALTER TABLE alcc.onlineresource
  ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid)
      REFERENCES alcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.projectprojectcategory DROP CONSTRAINT project_projectprojectcategory_fk;

ALTER TABLE walcc.projectprojectcategory
  ADD CONSTRAINT project_projectprojectcategory_fk FOREIGN KEY (projectid)
      REFERENCES walcc.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.projecttopiccategory DROP CONSTRAINT project_projecttopiccategory_fk;

ALTER TABLE walcc.projecttopiccategory
  ADD CONSTRAINT project_projecttopiccategory_fk FOREIGN KEY (projectid)
      REFERENCES walcc.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.projectusertype DROP CONSTRAINT project_projectusertype_fk;

ALTER TABLE walcc.projectusertype
  ADD CONSTRAINT project_projectusertype_fk FOREIGN KEY (projectid)
      REFERENCES walcc.project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.producttopiccategory DROP CONSTRAINT product_producttopiccategory_fk;

ALTER TABLE walcc.producttopiccategory
  ADD CONSTRAINT product_producttopiccategory_fk FOREIGN KEY (productid)
      REFERENCES walcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.productstatus DROP CONSTRAINT product_productstatus_fk;

ALTER TABLE walcc.productstatus
  ADD CONSTRAINT product_productstatus_fk FOREIGN KEY (productid)
      REFERENCES walcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.productkeyword DROP CONSTRAINT product_productkeyword_fk;

ALTER TABLE walcc.productkeyword
  ADD CONSTRAINT product_productkeyword_fk FOREIGN KEY (productid)
      REFERENCES walcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.onlineresource DROP CONSTRAINT product_onlineresource_fk;

ALTER TABLE walcc.onlineresource
  ADD CONSTRAINT product_onlineresource_fk FOREIGN KEY (productid)
      REFERENCES walcc.product (productid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE dev.funding DROP CONSTRAINT projectcontact_funding_fk;

ALTER TABLE dev.funding
  ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid)
      REFERENCES dev.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE alcc.funding DROP CONSTRAINT projectcontact_funding_fk;

ALTER TABLE alcc.funding
  ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid)
      REFERENCES alcc.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

ALTER TABLE walcc.funding DROP CONSTRAINT projectcontact_funding_fk;

ALTER TABLE walcc.funding
  ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid)
      REFERENCES walcc.projectcontact (projectcontactid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE;

GRANT SELECT ON TABLE dev.onlineresource TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.onlineresource TO GROUP pts_write;
GRANT SELECT ON TABLE dev.product TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.product TO GROUP pts_write;
GRANT SELECT ON TABLE dev.productcontact TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productcontact TO GROUP pts_write;
GRANT SELECT ON TABLE dev.productkeyword TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productkeyword TO GROUP pts_write;
GRANT SELECT ON TABLE dev.productline TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productline TO GROUP pts_write;
GRANT SELECT ON TABLE dev.productpoint TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productpoint TO GROUP pts_write;
GRANT SELECT ON TABLE dev.productpolygon TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productpolygon TO GROUP pts_write;
GRANT SELECT ON TABLE dev.productstatus TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.productstatus TO GROUP pts_write;
GRANT SELECT ON TABLE dev.producttopiccategory TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE dev.producttopiccategory TO GROUP pts_write;
GRANT SELECT ON TABLE dev.metadataproduct TO GROUP pts_read;
GRANT SELECT ON TABLE dev.metadataproject TO GROUP pts_read;
GRANT SELECT ON TABLE dev.productcontactlist TO GROUP pts_read;
GRANT SELECT ON TABLE dev.productfeature TO GROUP pts_read;
GRANT SELECT ON TABLE dev.productkeywordlist TO GROUP pts_read;
GRANT SELECT ON TABLE dev.productlist TO GROUP pts_read;
GRANT SELECT ON TABLE dev.productmetadata TO GROUP pts_read;

GRANT SELECT ON TABLE alcc.onlineresource TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.onlineresource TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.product TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.product TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.productcontact TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productcontact TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.productkeyword TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productkeyword TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.productline TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productline TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.productpoint TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productpoint TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.productpolygon TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productpolygon TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.productstatus TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.productstatus TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.producttopiccategory TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE alcc.producttopiccategory TO GROUP pts_write;
GRANT SELECT ON TABLE alcc.metadataproduct TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.metadataproject TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.productcontactlist TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.productfeature TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.productkeywordlist TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.productlist TO GROUP pts_read;
GRANT SELECT ON TABLE alcc.productmetadata TO GROUP pts_read;

GRANT SELECT ON TABLE walcc.onlineresource TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.onlineresource TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.product TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.product TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.productcontact TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productcontact TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.productkeyword TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productkeyword TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.productline TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productline TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.productpoint TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productpoint TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.productpolygon TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productpolygon TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.productstatus TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.productstatus TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.producttopiccategory TO GROUP pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE walcc.producttopiccategory TO GROUP pts_write;
GRANT SELECT ON TABLE walcc.metadataproduct TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.metadataproject TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.productcontactlist TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.productfeature TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.productkeywordlist TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.productlist TO GROUP pts_read;
GRANT SELECT ON TABLE walcc.productmetadata TO GROUP pts_read;

GRANT SELECT ON TABLE cvl.datetype TO GROUP pts_read;
GRANT SELECT ON TABLE cvl.isoprogresstype TO GROUP pts_read;
GRANT SELECT ON TABLE cvl.isoroletype TO GROUP pts_read;
GRANT SELECT ON TABLE cvl.onlinefunction TO GROUP pts_read;
GRANT SELECT ON TABLE cvl.productprogresstype TO GROUP pts_read;

GRANT SELECT, UPDATE ON SEQUENCE onlineresource_onlineresourceid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE product_productid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE productcontact_productcontactid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE productkeyword_productkeywordid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE productline_productlineid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE productpoint_productpointid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE productpolygon_productpolygonid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON SEQUENCE productstatus_productstatusid_seq TO GROUP pts_write;

