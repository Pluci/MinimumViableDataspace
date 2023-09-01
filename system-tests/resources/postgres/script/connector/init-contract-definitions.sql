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