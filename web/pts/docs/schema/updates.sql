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

-- Column: description

-- ALTER TABLE polygon DROP COLUMN description;

ALTER TABLE polygon ADD COLUMN description character varying;
COMMENT ON COLUMN polygon.description IS 'Description of vector feature.';

SELECT AddGeometryColumn ('pts','polygon','the_geom',3857,'POLYGON',2);
