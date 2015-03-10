-- Version 0.15.2

SET search_path = cvl, pg_catalog;

ALTER TABLE moddoctype
    ADD COLUMN inactive boolean DEFAULT false;

COMMENT ON COLUMN moddoctype.inactive IS 'Whether the doctype is currently in use.';
