--add fundingrecipientid
ALTER TABLE pts.funding
   ADD COLUMN fundingrecipientid integer;
COMMENT ON COLUMN pts.funding.fundingrecipientid IS 'Entity receiving funds';
--don't allow contact to be it's own parent
ALTER TABLE pts.contactcontactgroup ADD CHECK (NOT groupid = contactid);
