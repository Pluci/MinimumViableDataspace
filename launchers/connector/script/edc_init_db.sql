00_init_db.sql: |
          create database edc_db;
        01_init_contract_negotiation.sql: |
          \c edc_db;
          CREATE TABLE IF NOT EXISTS edc_lease
          (
          leased_by      VARCHAR               NOT NULL,
          leased_at      BIGINT,
          lease_duration INTEGER DEFAULT 60000 NOT NULL,
          lease_id       VARCHAR               NOT NULL
          CONSTRAINT lease_pk
          PRIMARY KEY
          );
          
          COMMENT ON COLUMN edc_lease.leased_at IS 'posix timestamp of lease';
          
          COMMENT ON COLUMN edc_lease.lease_duration IS 'duration of lease in milliseconds';
          
          
          CREATE UNIQUE INDEX IF NOT EXISTS lease_lease_id_uindex
          ON edc_lease (lease_id);
          
          
          
          CREATE TABLE IF NOT EXISTS edc_contract_agreement
          (
          agr_id            VARCHAR NOT NULL
          CONSTRAINT contract_agreement_pk
          PRIMARY KEY,
          provider_agent_id VARCHAR,
          consumer_agent_id VARCHAR,
          signing_date      BIGINT,
          start_date        BIGINT,
          end_date          INTEGER,
          asset_id          VARCHAR NOT NULL,
          policy            JSON
          );
          
          
          CREATE TABLE IF NOT EXISTS edc_contract_negotiation
          (
          id                   VARCHAR                                            NOT NULL
          CONSTRAINT contract_negotiation_pk
          PRIMARY KEY,
          created_at           BIGINT                                             NOT NULL,
          updated_at           BIGINT                                             NOT NULL,
          correlation_id       VARCHAR,
          counterparty_id      VARCHAR                                            NOT NULL,
          counterparty_address VARCHAR                                            NOT NULL,
          protocol             VARCHAR DEFAULT 'ids-multipart'::CHARACTER VARYING NOT NULL,
          type                 INTEGER DEFAULT 0                                  NOT NULL,
          state                INTEGER DEFAULT 0                                  NOT NULL,
          state_count          INTEGER DEFAULT 0,
          state_timestamp      BIGINT,
          error_detail         VARCHAR,
          agreement_id         VARCHAR
          CONSTRAINT contract_negotiation_contract_agreement_id_fk
          REFERENCES edc_contract_agreement,
          contract_offers      JSON,
          trace_context        JSON,
          lease_id             VARCHAR
          CONSTRAINT contract_negotiation_lease_lease_id_fk
          REFERENCES edc_lease
          ON DELETE SET NULL,
          CONSTRAINT provider_correlation_id CHECK (type = '0' OR correlation_id IS NOT NULL)
          );
          
          COMMENT ON COLUMN edc_contract_negotiation.agreement_id IS 'ContractAgreement serialized as JSON';
          
          COMMENT ON COLUMN edc_contract_negotiation.contract_offers IS 'List<ContractOffer> serialized as JSON';
          
          COMMENT ON COLUMN edc_contract_negotiation.trace_context IS 'Map<String,String> serialized as JSON';
          
          
          CREATE INDEX IF NOT EXISTS contract_negotiation_correlationid_index
          ON edc_contract_negotiation (correlation_id);
          
          CREATE UNIQUE INDEX IF NOT EXISTS contract_negotiation_id_uindex
          ON edc_contract_negotiation (id);
          
          CREATE UNIQUE INDEX IF NOT EXISTS contract_agreement_id_uindex
          ON edc_contract_agreement (agr_id);
        02_init_contract_definition.sql: |
          \c edc_db;
          CREATE TABLE IF NOT EXISTS edc_contract_definitions
          (
          created_at             BIGINT NOT NULL,
          contract_definition_id VARCHAR NOT NULL,
          access_policy_id       VARCHAR NOT NULL,
          contract_policy_id     VARCHAR NOT NULL,
          selector_expression    JSON NOT NULL,
          validity               BIGINT NOT NULL,
          PRIMARY KEY (contract_definition_id)
          );
        03_init_policy.sql: |
          \c edc_db;
          CREATE TABLE IF NOT EXISTS edc_policydefinitions
          (
          policy_id             VARCHAR NOT NULL,
          created_at            BIGINT  NOT NULL,
          permissions           JSON,
          prohibitions          JSON,
          duties                JSON,
          extensible_properties JSON,
          inherits_from         VARCHAR,
          assigner              VARCHAR,
          assignee              VARCHAR,
          target                VARCHAR,
          policy_type           VARCHAR NOT NULL,
          PRIMARY KEY (policy_id)
          );
          
          COMMENT ON COLUMN edc_policydefinitions.permissions IS 'Java List<Permission> serialized as JSON';
          COMMENT ON COLUMN edc_policydefinitions.prohibitions IS 'Java List<Prohibition> serialized as JSON';
          COMMENT ON COLUMN edc_policydefinitions.duties IS 'Java List<Duty> serialized as JSON';
          COMMENT ON COLUMN edc_policydefinitions.extensible_properties IS 'Java Map<String, Object> serialized as JSON';
          COMMENT ON COLUMN edc_policydefinitions.policy_type IS 'Java PolicyType serialized as JSON';
          
          CREATE UNIQUE INDEX IF NOT EXISTS edc_policydefinitions_id_uindex
          ON edc_policydefinitions (policy_id);
        04_init_transfer_process.sql: |
          \c edc_db;
          CREATE TABLE IF NOT EXISTS edc_lease
          (
              leased_by      VARCHAR NOT NULL,
              leased_at      BIGINT,
              lease_duration INTEGER NOT NULL,
              lease_id       VARCHAR NOT NULL
                  CONSTRAINT lease_pk
                      PRIMARY KEY
          );
          
          COMMENT ON COLUMN edc_lease.leased_at IS 'posix timestamp of lease';
          
          COMMENT ON COLUMN edc_lease.lease_duration IS 'duration of lease in milliseconds';
          
          CREATE TABLE IF NOT EXISTS edc_transfer_process
          (
              transferprocess_id       VARCHAR           NOT NULL
                  CONSTRAINT transfer_process_pk
                      PRIMARY KEY,
              type                     VARCHAR           NOT NULL,
              state                    INTEGER           NOT NULL,
              state_count              INTEGER DEFAULT 0 NOT NULL,
              state_time_stamp         BIGINT,
              created_at               BIGINT            NOT NULL,
              updated_at               BIGINT            NOT NULL,
              trace_context            JSON,
              error_detail             VARCHAR,
              resource_manifest        JSON,
              provisioned_resource_set JSON,
              content_data_address     JSON,
              deprovisioned_resources  JSON,
              lease_id                 VARCHAR
                  CONSTRAINT transfer_process_lease_lease_id_fk
                      REFERENCES edc_lease
                      ON DELETE SET NULL
          );
          
          COMMENT ON COLUMN edc_transfer_process.trace_context IS 'Java Map serialized as JSON';
          
          COMMENT ON COLUMN edc_transfer_process.resource_manifest IS 'java ResourceManifest serialized as JSON';
          
          COMMENT ON COLUMN edc_transfer_process.provisioned_resource_set IS 'ProvisionedResourceSet serialized as JSON';
          
          COMMENT ON COLUMN edc_transfer_process.content_data_address IS 'DataAddress serialized as JSON';
          
          COMMENT ON COLUMN edc_transfer_process.deprovisioned_resources IS 'List of deprovisioned resources, serialized as JSON';
          
          
          CREATE UNIQUE INDEX IF NOT EXISTS transfer_process_id_uindex
              ON edc_transfer_process (transferprocess_id);
          
          CREATE TABLE IF NOT EXISTS edc_data_request
          (
              datarequest_id      VARCHAR NOT NULL
                  CONSTRAINT data_request_pk
                      PRIMARY KEY,
              process_id          VARCHAR NOT NULL,
              connector_address   VARCHAR NOT NULL,
              protocol            VARCHAR NOT NULL,
              connector_id        VARCHAR,
              asset_id            VARCHAR NOT NULL,
              contract_id         VARCHAR NOT NULL,
              data_destination    JSON    NOT NULL,
              managed_resources   BOOLEAN DEFAULT TRUE,
              properties          JSON,
              transfer_type       JSON,
              transfer_process_id VARCHAR NOT NULL
                  CONSTRAINT data_request_transfer_process_id_fk
                      REFERENCES edc_transfer_process
                      ON UPDATE RESTRICT ON DELETE CASCADE
          );
          
          COMMENT ON COLUMN edc_data_request.data_destination IS 'DataAddress serialized as JSON';
          
          COMMENT ON COLUMN edc_data_request.properties IS 'java Map serialized as JSON';
          
          COMMENT ON COLUMN edc_data_request.transfer_type IS 'TransferType serialized as JSON';
          
          
          CREATE UNIQUE INDEX IF NOT EXISTS data_request_id_uindex
              ON edc_data_request (datarequest_id);
          
          CREATE UNIQUE INDEX IF NOT EXISTS lease_lease_id_uindex
              ON edc_lease (lease_id);
        05_init_assets.sql: |
          \c edc_db;
          CREATE TABLE IF NOT EXISTS edc_asset
          (
          asset_id   VARCHAR NOT NULL,
          created_at BIGINT  NOT NULL,
          PRIMARY KEY (asset_id)
          );           
          
          CREATE TABLE IF NOT EXISTS edc_asset_dataaddress
          (
          asset_id_fk VARCHAR NOT NULL,
          properties  JSON    NOT NULL,
          PRIMARY KEY (asset_id_fk),
          FOREIGN KEY (asset_id_fk) REFERENCES edc_asset (asset_id) ON DELETE CASCADE
          );
          COMMENT ON COLUMN edc_asset_dataaddress.properties IS 'DataAddress properties serialized as JSON';
          
          CREATE TABLE IF NOT EXISTS edc_asset_property
          (
          asset_id_fk    VARCHAR NOT NULL,
          property_name  VARCHAR NOT NULL,
          property_value VARCHAR NOT NULL,
          property_type  VARCHAR NOT NULL,
          PRIMARY KEY (asset_id_fk, property_name),
          FOREIGN KEY (asset_id_fk) REFERENCES edc_asset (asset_id) ON DELETE CASCADE
          );
          
          COMMENT ON COLUMN edc_asset_property.property_name IS
          'Asset property key';
          COMMENT ON COLUMN edc_asset_property.property_value IS
          'Asset property value';
          COMMENT ON COLUMN edc_asset_property.property_type IS
          'Asset property class name';
          
          CREATE INDEX IF NOT EXISTS idx_edc_asset_property_value
          ON edc_asset_property (property_name, property_value);
        06_init_identityhub.sql: |
          \c edc_db;
          CREATE TABLE IF NOT EXISTS edc_identityhub
          (
              id                   VARCHAR NOT NULL PRIMARY KEY,
              payload              VARCHAR NOT NULL UNIQUE,
              payloadFormat        VARCHAR NOT NULL,
              created_at           BIGINT NOT NULL
          );
