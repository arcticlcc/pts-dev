-- Column: uuid

ALTER TABLE dev.contact ADD COLUMN uuid uuid;

UPDATE dev.contact SET uuid = uuid_generate_v4();

ALTER TABLE dev.contact ALTER COLUMN uuid SET NOT NULL;
ALTER TABLE dev.contact ALTER COLUMN uuid SET DEFAULT uuid_generate_v4();
COMMENT ON COLUMN dev.contact.uuid IS 'Universally unique identifier for contact (from ADiwg specification)';
