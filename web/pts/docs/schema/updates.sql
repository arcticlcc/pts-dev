--version 0.6--

-- Executing query:
-- Table: projectline

 DROP TABLE projectline;

CREATE TABLE projectline
(
  projectid integer NOT NULL,
  projectlineid SERIAL NOT NULL,
  name character varying NOT NULL,
  comment character varying,
  CONSTRAINT projectline_pk PRIMARY KEY (projectlineid ),
  CONSTRAINT project_projectline_fk FOREIGN KEY (projectid)
      REFERENCES project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=TRUE
);
ALTER TABLE projectline
  OWNER TO bradley;
GRANT ALL ON TABLE projectline TO bradley;
GRANT SELECT ON TABLE projectline TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE projectline TO pts_write;


-- Executing query:
-- Table: projectpolygon

 DROP TABLE projectpolygon;

CREATE TABLE projectpolygon
(
  projectid integer NOT NULL,
  projectpolygonid SERIAL NOT NULL,
  name character varying NOT NULL,
  comment character varying,
  CONSTRAINT projectpolygon_pk PRIMARY KEY (projectpolygonid ),
  CONSTRAINT project_projectpolygon_fk FOREIGN KEY (projectid)
      REFERENCES project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=TRUE
);
ALTER TABLE projectpolygon
  OWNER TO bradley;
GRANT ALL ON TABLE projectpolygon TO bradley;
GRANT SELECT ON TABLE projectpolygon TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE projectpolygon TO pts_write;



-- Executing query:
-- Table: projectpoint

 DROP TABLE projectpoint;

CREATE TABLE projectpoint
(
  projectid integer NOT NULL,
  projectpointid SERIAL NOT NULL,
  name character varying NOT NULL,
  comment character varying,
  CONSTRAINT projectpoint_pk PRIMARY KEY (projectpointid ),
  CONSTRAINT project_projectpoint_fk FOREIGN KEY (projectid)
      REFERENCES project (projectid) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE CASCADE
)
WITH (
  OIDS=TRUE
);
ALTER TABLE projectpoint
  OWNER TO bradley;
GRANT ALL ON TABLE projectpoint TO bradley;
GRANT SELECT ON TABLE projectpoint TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE projectpoint TO pts_write;


-- Executing query:
SELECT AddGeometryColumn ('pts','projectpoint','the_geom',3857,'POINT',2);
SELECT AddGeometryColumn ('pts','projectpolygon','the_geom',3857,'POLYGON',2);
SELECT AddGeometryColumn ('pts','projectline','the_geom',3857,'LINESTRING',2);

-- View: projectfeature

-- DROP VIEW projectfeature;

CREATE OR REPLACE VIEW projectfeature AS
        (         SELECT projectpoint.projectid, 'Point-'::text || projectpoint.projectpointid AS id, projectpoint.name, projectpoint.comment, st_asgeojson(projectpoint.the_geom, 8) AS geom
                   FROM projectpoint
        UNION
                 SELECT projectpolygon.projectid, 'Polygon-'::text || projectpolygon.projectpolygonid AS id, projectpolygon.name, projectpolygon.comment, st_asgeojson(projectpolygon.the_geom, 8) AS geom
                   FROM projectpolygon)
UNION
         SELECT projectline.projectid, 'LineString-'::text || projectline.projectlineid AS id, projectline.name, projectline.comment, st_asgeojson(projectline.the_geom, 8) AS geom
           FROM projectline;

ALTER TABLE projectfeature
  OWNER TO bradley;
GRANT ALL ON TABLE projectfeature TO bradley;
GRANT SELECT ON TABLE projectfeature TO pts_read;

-- View: grouppersonlist

-- DROP VIEW grouppersonlist;

CREATE OR REPLACE VIEW grouppersonlist AS
 SELECT person.contactid, person.firstname, person.lastname, person.middlename, person.suffix, contactcontactgroup.groupid, contactgroup.acronym, contactgroup.name, contactcontactgroup.positionid
   FROM contactcontactgroup
   JOIN contactgroup ON contactgroup.contactid = contactcontactgroup.groupid
   JOIN person ON person.contactid = contactcontactgroup.contactid;

ALTER TABLE polygon
	DROP COLUMN fid,
	ADD COLUMN polygonid SERIAL NOT NULL,
	ADD COLUMN description character varying;

ALTER TABLE line
	DROP COLUMN fid,
	ADD COLUMN lineid SERIAL,
	ADD COLUMN description character varying;

ALTER TABLE point
	DROP COLUMN fid,
	ADD COLUMN pointid SERIAL,
	ADD COLUMN description character varying;

ALTER TABLE polygon
	ADD CONSTRAINT polygon_pk PRIMARY KEY (polygonid);

ALTER TABLE line
	ADD CONSTRAINT line_pk PRIMARY KEY (lineid);

ALTER TABLE point
	ADD CONSTRAINT point_pk PRIMARY KEY (pointid);

-- Column: description

COMMENT ON COLUMN polygon.description IS 'Description of vector feature.';

SELECT AddGeometryColumn ('pts','polygon','the_geom',3857,'POLYGON',2);
SELECT AddGeometryColumn ('pts','line','the_geom',3857,'LINESTRING',2);
SELECT AddGeometryColumn ('pts','point','the_geom',3857,'POINT',2);

-- View: commonfeature

-- DROP VIEW commonfeature;

CREATE OR REPLACE VIEW commonfeature AS
 SELECT polygon.polygonid AS id, polygon.name AS text, polygon.description, st_astext(polygon.the_geom) AS wkt
   FROM polygon;

ALTER TABLE commonfeature
  OWNER TO bradley;
GRANT ALL ON TABLE commonfeature TO bradley;
GRANT SELECT ON TABLE commonfeature TO pts_read;

--prevent cascade on projectcontact_funding_fk
ALTER TABLE funding
	DROP CONSTRAINT projectcontact_funding_fk;
ALTER TABLE funding
	ADD CONSTRAINT projectcontact_funding_fk FOREIGN KEY (projectcontactid) REFERENCES projectcontact(projectcontactid);

--move commonfeatures to cvl schema
 DROP VIEW pts.commonfeature;

-- Table: pts.point

 DROP TABLE pts.point;

CREATE TABLE cvl.point
(
  name character varying NOT NULL,
  pointid SERIAL,
  description character varying,
  the_geom geometry,
  CONSTRAINT point_pk PRIMARY KEY (pointid ),
  CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(the_geom) = 2),
  CONSTRAINT enforce_geotype_the_geom CHECK (geometrytype(the_geom) = 'POINT'::text OR the_geom IS NULL),
  CONSTRAINT enforce_srid_the_geom CHECK (st_srid(the_geom) = 3857)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.point
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.point TO bradley;
GRANT SELECT ON TABLE cvl.point TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE cvl.point TO pts_write;

-- Table: cvl.line

DROP TABLE pts.line;

CREATE TABLE cvl.line
(
  name character varying NOT NULL,
  lineid SERIAL,
  description character varying,
  the_geom geometry,
  CONSTRAINT line_pk PRIMARY KEY (lineid ),
  CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(the_geom) = 2),
  CONSTRAINT enforce_geotype_the_geom CHECK (geometrytype(the_geom) = 'LINESTRING'::text OR the_geom IS NULL),
  CONSTRAINT enforce_srid_the_geom CHECK (st_srid(the_geom) = 3857)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.line
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.line TO bradley;
GRANT SELECT ON TABLE cvl.line TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE cvl.line TO pts_write;

-- Table: cvl.polygon

 DROP TABLE pts.polygon;

CREATE TABLE cvl.polygon
(
  name character varying NOT NULL,
  polygonid SERIAL,
  description character varying, -- Description of vector feature.
  the_geom geometry,
  CONSTRAINT polygon_pk PRIMARY KEY (polygonid ),
  CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(the_geom) = 2),
  CONSTRAINT enforce_geotype_the_geom CHECK (geometrytype(the_geom) = 'POLYGON'::text OR the_geom IS NULL),
  CONSTRAINT enforce_srid_the_geom CHECK (st_srid(the_geom) = 3857)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cvl.polygon
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.polygon TO bradley;
GRANT SELECT ON TABLE cvl.polygon TO pts_read;
GRANT SELECT, UPDATE, INSERT, DELETE ON TABLE cvl.polygon TO pts_write;
COMMENT ON COLUMN cvl.polygon.description IS 'Description of vector feature.';

CREATE OR REPLACE VIEW cvl.commonfeature AS
 SELECT polygon.polygonid AS id, polygon.name AS text, polygon.description, st_astext(polygon.the_geom) AS wkt
   FROM polygon;

ALTER TABLE cvl.commonfeature
  OWNER TO bradley;
GRANT ALL ON TABLE cvl.commonfeature TO bradley;
GRANT SELECT ON TABLE cvl.commonfeature TO pts_read;

GRANT SELECT, UPDATE ON TABLE pts.projectline_projectlineid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE pts.projectpoint_projectpointid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE pts.projectpolygon_projectpolygonid_seq TO GROUP pts_write;
