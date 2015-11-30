SET search_path = common, public;

-- Column: config

-- ALTER TABLE login DROP COLUMN config;

ALTER TABLE login ADD COLUMN config jsonb;
COMMENT ON COLUMN login.config IS 'Application settings for the login role.';
GRANT UPDATE(config) ON login TO GROUP pts_write;

