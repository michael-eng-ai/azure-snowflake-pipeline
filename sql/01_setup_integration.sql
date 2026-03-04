-- ======================================================================
-- STEP 1: Storage Integration (Azure ADLS Gen2 -> Snowflake)
-- ======================================================================

USE ROLE ACCOUNTADMIN;

-- Create the Storage Integration object to establish trust with Azure
CREATE OR REPLACE STORAGE INTEGRATION azure_adls_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  ENABLED = TRUE
  AZURE_TENANT_ID = '<YOUR_AZURE_TENANT_ID>'
  STORAGE_ALLOWED_LOCATIONS = ('azure://stdatalakesnowflake.blob.core.windows.net/raw-data/');

-- Retrieve the Tenant ID and SPN (Service Principal Name) created by Snowflake
-- You must grant this SPN the 'Storage Blob Data Contributor' role in the Azure Portal
DESC STORAGE INTEGRATION azure_adls_integration;
