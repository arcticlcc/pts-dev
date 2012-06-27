ALTER TABLE pts.modcomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.modcomment ADD COLUMN modcommentid SERIAL;

ALTER TABLE pts.modcomment DROP CONSTRAINT modcomment_pk;

ALTER TABLE pts.modcomment ADD PRIMARY KEY (modcommentid);

ALTER TABLE pts.filecomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.filecomment ADD COLUMN filecommentid SERIAL;

ALTER TABLE pts.filecomment DROP CONSTRAINT filecomment_pkey;

ALTER TABLE pts.filecomment ADD PRIMARY KEY (filecommentid);

ALTER TABLE pts.projectcomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.projectcomment ADD COLUMN projectcommentid SERIAL;

ALTER TABLE pts.projectcomment DROP CONSTRAINT projectcomment_pk;

ALTER TABLE pts.projectcomment ADD PRIMARY KEY (projectcommentid);

ALTER TABLE pts.deliverablecomment ADD COLUMN deliverablecommentid SERIAL;

ALTER TABLE pts.deliverablecomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.deliverablecomment DROP CONSTRAINT deliverablecomment_pk;

ALTER TABLE pts.deliverablecomment ADD PRIMARY KEY (deliverablecommentid);

ALTER TABLE pts.invoicecomment ADD COLUMN invoicecommentid SERIAL;

ALTER TABLE pts.invoicecomment ADD COLUMN datemodified DATE NOT NULL;

ALTER TABLE pts.invoicecomment DROP CONSTRAINT invoicecomment_pk;

ALTER TABLE pts.invoicecomment ADD PRIMARY KEY (invoicecommentid);

COMMENT ON COLUMN deliverablecomment.datemodified IS 'Date that the comment was modified.';

GRANT SELECT, UPDATE ON TABLE deliverablecomment_deliverablecommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE filecomment_filecommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE invoicecomment_invoicecommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE modcomment_modcommentid_seq TO GROUP pts_write;
GRANT SELECT, UPDATE ON TABLE projectcomment_projectcommentid_seq TO GROUP pts_write;
