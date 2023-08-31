00_init_db.sql: |
          create database edc_reg_service_db;
        01_init_participant.sql: |
          \c edc_reg_service_db;
          CREATE TABLE IF NOT EXISTS edc_participant
          (
              id                   VARCHAR NOT NULL PRIMARY KEY,
              did                  VARCHAR NOT NULL UNIQUE,
              state                INTEGER DEFAULT 0 NOT NULL,
              state_count          INTEGER DEFAULT 0 NOT NULL,
              state_timestamp      BIGINT,
              error_detail         VARCHAR,
              trace_context        JSON,
              created_at           BIGINT NOT NULL,
              updated_at           BIGINT NOT NULL
          );
        02_init_identityhub.sql: |
          \c edc_reg_service_db;
          CREATE TABLE IF NOT EXISTS edc_identityhub
          (
              id                   VARCHAR NOT NULL PRIMARY KEY,
              payload              VARCHAR NOT NULL UNIQUE,
              payloadFormat        VARCHAR NOT NULL,
              created_at           BIGINT NOT NULL
          );
