--add fundingrecipientid
ALTER TABLE pts.funding
   ADD COLUMN fundingrecipientid integer;
COMMENT ON COLUMN pts.funding.fundingrecipientid IS 'Entity receiving funds';
