-- ======================================================================
-- STEP 2: Database, Schema, External Stage and Snowpipe Setup
-- ======================================================================

USE ROLE SYSADMIN;

-- Create Database and Schema
CREATE OR REPLACE DATABASE ECOMMERCE_DB;
CREATE OR REPLACE SCHEMA ECOMMERCE_DB.RAW;

USE DATABASE ECOMMERCE_DB;
USE SCHEMA RAW;

-- Create File Format for the incoming CSV data
CREATE OR REPLACE FILE FORMAT csv_format
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  NULL_IF = ('NULL', 'null', '')
  EMPTY_FIELD_AS_NULL = TRUE
  FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- Create the External Stage pointing to the Azure container
-- Uses the integration we created in step 01
CREATE OR REPLACE STAGE my_azure_stage
  STORAGE_INTEGRATION = azure_adls_integration
  URL = 'azure://stdatalakesnowflake.blob.core.windows.net/raw-data/sales/'
  FILE_FORMAT = csv_format;

-- Create the Target Table for the Raw data
CREATE OR REPLACE TABLE raw_sales (
    transaction_id VARCHAR,
    customer_name VARCHAR,
    customer_email VARCHAR,
    product_name VARCHAR,
    quantity NUMBER(10,0),
    unit_price FLOAT,
    total_amount FLOAT,
    transaction_date TIMESTAMP_NTZ
);

-- ======================================================================
-- Create Snowpipe with Auto-Ingest
-- ======================================================================
-- NOTE: Auto-ingest for Azure requires configuring Event Grid in the Azure Portal.
-- The Snowflake notification URL / Event Grid info can be retrieved with `DESC PIPE`.

CREATE OR REPLACE PIPE sales_snowpipe
  AUTO_INGEST = TRUE
  AS
  COPY INTO raw_sales
  FROM @my_azure_stage
  FILE_FORMAT = (FORMAT_NAME = csv_format);

-- Verify the pipe configuration and copy the notification channel
DESC PIPE sales_snowpipe;
