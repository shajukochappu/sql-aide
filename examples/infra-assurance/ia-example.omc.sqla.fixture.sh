#!/bin/bash

destroy_first=0
db_file=""

# Parse command-line options
for arg in "$@"
do
    case $arg in
        --destroy-first)
            destroy_first=1
            shift # Remove --destroy-first from processing
            ;;
        *)
            db_file=$1
            shift # Remove database filename from processing
            break # Stop processing after the filename so we can pass the rest into final SQLite DB
            ;;
    esac
done

# Check if the database file parameter is supplied
if [ -z "$db_file" ]
then
    echo "No database file supplied. Usage: ./driver.sh [--destroy-first] <database_file> [<sqlite3 arguments>...]"
    exit 1
fi

# If the destroy_first flag is set, delete the database file
if [ $destroy_first -eq 1 ] && [ -f "$db_file" ]; then
    rm "$db_file"
fi

SQL=$(cat <<-EOF
    PRAGMA foreign_keys = on; -- check foreign key reference, slightly worst performance

-- reference tables
CREATE TABLE IF NOT EXISTS "execution_context" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_type" (
    "party_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "raci_matrix_assignment_nature" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "proficiency_scale" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "vulnerability_status" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "probability" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "comparison_operator" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "kpi_measurement_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "kpi_status" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "trend" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "auditor_type" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "party_relation_type" (
    "party_relation_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "severity" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS "priority" (
    "code" TEXT PRIMARY KEY NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- content tables
CREATE TABLE IF NOT EXISTS "party_role" (
    "party_role_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "party_identifier_type" (
    "party_identifier_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "person_type" (
    "person_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "contact_type" (
    "contact_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "organization_role_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "party" (
    "party_id" TEXT PRIMARY KEY NOT NULL,
    "party_type_id" TEXT NOT NULL,
    "party_name" TEXT NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_type_id") REFERENCES "party_type"("party_type_id")
);
CREATE TABLE IF NOT EXISTS "party_identifier" (
    "party_identifier_id" TEXT PRIMARY KEY NOT NULL,
    "identifier_name" TEXT NOT NULL,
    "identifier_value" TEXT NOT NULL,
    "party_identifier_type_id" TEXT NOT NULL,
    "party_id" TEXT NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_identifier_type_id") REFERENCES "party_identifier_type"("party_identifier_type_id"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "person" (
    "person_id" TEXT PRIMARY KEY NOT NULL,
    "party_id" TEXT NOT NULL,
    "person_type_id" TEXT NOT NULL,
    "person_first_name" TEXT NOT NULL,
    "person_middle_name" TEXT,
    "person_last_name" TEXT NOT NULL,
    "previous_name" TEXT,
    "honorific_prefix" TEXT,
    "honorific_suffix" TEXT,
    "gender_id" TEXT NOT NULL,
    "sex_id" TEXT NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("person_type_id") REFERENCES "person_type"("person_type_id"),
    FOREIGN KEY("gender_id") REFERENCES "gender_type"("gender_type_id"),
    FOREIGN KEY("sex_id") REFERENCES "sex_type"("sex_type_id")
);
CREATE TABLE IF NOT EXISTS "party_relation" (
    "party_relation_id" TEXT PRIMARY KEY NOT NULL,
    "party_id" TEXT NOT NULL,
    "related_party_id" TEXT NOT NULL,
    "relation_type_id" TEXT NOT NULL,
    "party_role_id" TEXT,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("related_party_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("relation_type_id") REFERENCES "party_relation_type"("party_relation_type_id"),
    FOREIGN KEY("party_role_id") REFERENCES "party_role"("party_role_id")
);
CREATE TABLE IF NOT EXISTS "organization" (
    "organization_id" TEXT PRIMARY KEY NOT NULL,
    "party_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "alias" TEXT,
    "description" TEXT,
    "license" TEXT NOT NULL,
    "federal_tax_id_num" TEXT,
    "registration_date" DATE NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "organization_role" (
    "organization_role_id" TEXT PRIMARY KEY NOT NULL,
    "person_id" TEXT NOT NULL,
    "organization_id" TEXT NOT NULL,
    "organization_role_type_id" TEXT NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("organization_role_type_id") REFERENCES "organization_role_type"("organization_role_type_id")
);
CREATE TABLE IF NOT EXISTS "contact_electronic" (
    "contact_electronic_id" TEXT PRIMARY KEY NOT NULL,
    "contact_type_id" TEXT NOT NULL,
    "party_id" TEXT NOT NULL,
    "electronics_details" TEXT NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("contact_type_id") REFERENCES "contact_type"("contact_type_id"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "contact_land" (
    "contact_land_id" TEXT PRIMARY KEY NOT NULL,
    "contact_type_id" TEXT NOT NULL,
    "party_id" TEXT NOT NULL,
    "address_line1" TEXT NOT NULL,
    "address_line2" TEXT NOT NULL,
    "address_zip" TEXT NOT NULL,
    "address_city" TEXT NOT NULL,
    "address_state" TEXT NOT NULL,
    "address_territory" TEXT,
    "address_country" TEXT NOT NULL,
    "elaboration" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("contact_type_id") REFERENCES "contact_type"("contact_type_id"),
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "contract_status" (
    "contract_status_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "payment_type" (
    "payment_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "periodicity" (
    "periodicity_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "boundary_nature" (
    "boundary_nature_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "time_entry_category" (
    "time_entry_category_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "raci_matrix_subject" (
    "raci_matrix_subject_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "skill_nature" (
    "skill_nature_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "skill" (
    "skill_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "organization_role_type" (
    "organization_role_type_id" TEXT PRIMARY KEY NOT NULL,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "graph" (
    "graph_id" TEXT PRIMARY KEY NOT NULL,
    "graph_nature_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("graph_nature_id") REFERENCES "graph_nature"("graph_nature_id")
);
CREATE TABLE IF NOT EXISTS "boundary" (
    "boundary_id" TEXT PRIMARY KEY NOT NULL,
    "parent_boundary_id" TEXT,
    "graph_id" TEXT NOT NULL,
    "boundary_nature_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("parent_boundary_id") REFERENCES "boundary"("boundary_id"),
    FOREIGN KEY("graph_id") REFERENCES "graph"("graph_id"),
    FOREIGN KEY("boundary_nature_id") REFERENCES "boundary_nature"("boundary_nature_id")
);
CREATE TABLE IF NOT EXISTS "host" (
    "host_id" TEXT PRIMARY KEY NOT NULL,
    "host_name" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "description" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("host_name")
);
CREATE TABLE IF NOT EXISTS "host_boundary" (
    "host_boundary_id" TEXT PRIMARY KEY NOT NULL,
    "host_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("host_id") REFERENCES "host"("host_id")
);
CREATE TABLE IF NOT EXISTS "asset_status" (
    "asset_status_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "asset_service_status" (
    "asset_service_status_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "asset_type" (
    "asset_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "assignment" (
    "assignment_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "raci_matrix" (
    "raci_matrix_id" TEXT PRIMARY KEY NOT NULL,
    "asset" TEXT NOT NULL,
    "responsible" TEXT NOT NULL,
    "accountable" TEXT NOT NULL,
    "consulted" TEXT NOT NULL,
    "informed" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "raci_matrix_subject_boundary" (
    "raci_matrix_subject_boundary_id" TEXT PRIMARY KEY NOT NULL,
    "boundary_id" TEXT NOT NULL,
    "raci_matrix_subject_id" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("boundary_id") REFERENCES "boundary"("boundary_id"),
    FOREIGN KEY("raci_matrix_subject_id") REFERENCES "raci_matrix_subject"("raci_matrix_subject_id")
);
CREATE TABLE IF NOT EXISTS "raci_matrix_activity" (
    "raci_matrix_activity_id" TEXT PRIMARY KEY NOT NULL,
    "activity" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "asset" (
    "asset_id" TEXT PRIMARY KEY NOT NULL,
    "organization_id" TEXT NOT NULL,
    "asset_retired_date" DATE,
    "asset_status_id" INTEGER NOT NULL,
    "asset_tag" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "asset_type_id" INTEGER NOT NULL,
    "asset_workload_category" TEXT NOT NULL,
    "assignment_id" INTEGER NOT NULL,
    "barcode_or_rfid_tag" TEXT NOT NULL,
    "installed_date" DATE,
    "planned_retirement_date" DATE,
    "purchase_delivery_date" DATE,
    "purchase_order_date" DATE,
    "purchase_request_date" DATE,
    "serial_number" TEXT NOT NULL,
    "tco_amount" TEXT NOT NULL,
    "tco_currency" TEXT NOT NULL,
    "criticality" TEXT,
    "asymmetric_keys_encryption_enabled" TEXT,
    "cryptographic_key_encryption_enabled" TEXT,
    "symmetric_keys_encryption_enabled" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("asset_status_id") REFERENCES "asset_status"("asset_status_id"),
    FOREIGN KEY("asset_type_id") REFERENCES "asset_type"("asset_type_id"),
    FOREIGN KEY("assignment_id") REFERENCES "assignment"("assignment_id")
);
CREATE TABLE IF NOT EXISTS "asset_service" (
    "asset_service_id" TEXT PRIMARY KEY NOT NULL,
    "asset_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "asset_service_status_id" INTEGER NOT NULL,
    "port" TEXT NOT NULL,
    "experimental_version" TEXT NOT NULL,
    "production_version" TEXT NOT NULL,
    "latest_vendor_version" TEXT NOT NULL,
    "resource_utilization" TEXT NOT NULL,
    "log_file" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "vendor_link" TEXT NOT NULL,
    "installation_date" DATE,
    "criticality" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("asset_service_status_id") REFERENCES "asset_service_status"("asset_service_status_id")
);
CREATE TABLE IF NOT EXISTS "vulnerability_source" (
    "vulnerability_source_id" TEXT PRIMARY KEY NOT NULL,
    "short_code" TEXT NOT NULL,
    "source_url" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "vulnerability" (
    "vulnerability_id" TEXT PRIMARY KEY NOT NULL,
    "short_name" TEXT NOT NULL,
    "source_id" TEXT NOT NULL,
    "affected_software" TEXT NOT NULL,
    "reference" TEXT NOT NULL,
    "status_id" TEXT NOT NULL,
    "patch_availability" TEXT NOT NULL,
    "severity_id" TEXT NOT NULL,
    "solutions" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("source_id") REFERENCES "vulnerability_source"("vulnerability_source_id"),
    FOREIGN KEY("status_id") REFERENCES "vulnerability_status"("code"),
    FOREIGN KEY("severity_id") REFERENCES "severity"("code")
);
CREATE TABLE IF NOT EXISTS "threat_source" (
    "threat_source_id" TEXT PRIMARY KEY NOT NULL,
    "title" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "threat_source_type_id" INTEGER NOT NULL,
    "source_of_information" TEXT NOT NULL,
    "capability" TEXT NOT NULL,
    "intent" TEXT NOT NULL,
    "targeting" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("threat_source_type_id") REFERENCES "threat_source_type"("threat_source_type_id")
);
CREATE TABLE IF NOT EXISTS "threat_event" (
    "threat_event_id" TEXT PRIMARY KEY NOT NULL,
    "title" TEXT NOT NULL,
    "threat_source_id" TEXT NOT NULL,
    "asset_id" TEXT NOT NULL,
    "identifier" TEXT NOT NULL,
    "threat_event_type_id" INTEGER NOT NULL,
    "event_classification" TEXT NOT NULL,
    "source_of_information" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("threat_source_id") REFERENCES "threat_source"("threat_source_id"),
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("threat_event_type_id") REFERENCES "threat_event_type"("threat_event_type_id")
);
CREATE TABLE IF NOT EXISTS "asset_risk" (
    "asset_risk_id" TEXT PRIMARY KEY NOT NULL,
    "asset_risk_type_id" INTEGER NOT NULL,
    "asset_id" TEXT NOT NULL,
    "threat_event_id" TEXT NOT NULL,
    "relevance_id" TEXT,
    "likelihood_id" TEXT,
    "impact" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_risk_type_id") REFERENCES "asset_risk_type"("asset_risk_type_id"),
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("threat_event_id") REFERENCES "threat_event"("threat_event_id"),
    FOREIGN KEY("relevance_id") REFERENCES "severity"("code"),
    FOREIGN KEY("likelihood_id") REFERENCES "probability"("code")
);
CREATE TABLE IF NOT EXISTS "security_impact_analysis" (
    "security_impact_analysis_id" TEXT PRIMARY KEY NOT NULL,
    "vulnerability_id" TEXT NOT NULL,
    "asset_risk_id" TEXT NOT NULL,
    "risk_level_id" TEXT NOT NULL,
    "impact_level_id" TEXT NOT NULL,
    "existing_controls" TEXT NOT NULL,
    "priority_id" TEXT NOT NULL,
    "reported_date" DATE NOT NULL,
    "reported_by_id" TEXT NOT NULL,
    "responsible_by_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("vulnerability_id") REFERENCES "vulnerability"("vulnerability_id"),
    FOREIGN KEY("asset_risk_id") REFERENCES "asset_risk"("asset_risk_id"),
    FOREIGN KEY("risk_level_id") REFERENCES "probability"("code"),
    FOREIGN KEY("impact_level_id") REFERENCES "probability"("code"),
    FOREIGN KEY("priority_id") REFERENCES "priority"("code"),
    FOREIGN KEY("reported_by_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("responsible_by_id") REFERENCES "person"("person_id")
);
CREATE TABLE IF NOT EXISTS "impact_of_risk" (
    "impact_of_risk_id" TEXT PRIMARY KEY NOT NULL,
    "security_impact_analysis_id" TEXT NOT NULL,
    "impact" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("security_impact_analysis_id") REFERENCES "security_impact_analysis"("security_impact_analysis_id")
);
CREATE TABLE IF NOT EXISTS "proposed_controls" (
    "proposed_controls_id" TEXT PRIMARY KEY NOT NULL,
    "security_impact_analysis_id" TEXT NOT NULL,
    "controls" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("security_impact_analysis_id") REFERENCES "security_impact_analysis"("security_impact_analysis_id")
);
CREATE TABLE IF NOT EXISTS "billing" (
    "billing_id" TEXT PRIMARY KEY NOT NULL,
    "purpose" TEXT NOT NULL,
    "bill_rate" TEXT NOT NULL,
    "period" TEXT NOT NULL,
    "effective_from_date" TIMESTAMPTZ NOT NULL,
    "effective_to_date" TEXT NOT NULL,
    "prorate" INTEGER NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "scheduled_task" (
    "scheduled_task_id" TEXT PRIMARY KEY NOT NULL,
    "description" TEXT NOT NULL,
    "task_date" TIMESTAMPTZ NOT NULL,
    "reminder_date" TIMESTAMPTZ NOT NULL,
    "assigned_to" TEXT NOT NULL,
    "reminder_to" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "timesheet" (
    "timesheet_id" TEXT PRIMARY KEY NOT NULL,
    "date_of_work" TIMESTAMPTZ NOT NULL,
    "is_billable_id" INTEGER NOT NULL,
    "number_of_hours" INTEGER NOT NULL,
    "time_entry_category_id" INTEGER NOT NULL,
    "timesheet_summary" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("is_billable_id") REFERENCES "status_value"("status_value_id"),
    FOREIGN KEY("time_entry_category_id") REFERENCES "time_entry_category"("time_entry_category_id")
);
CREATE TABLE IF NOT EXISTS "certificate" (
    "certificate_id" TEXT PRIMARY KEY NOT NULL,
    "certificate_name" TEXT NOT NULL,
    "short_name" TEXT NOT NULL,
    "certificate_category" TEXT NOT NULL,
    "certificate_type" TEXT NOT NULL,
    "certificate_authority" TEXT NOT NULL,
    "validity" TEXT NOT NULL,
    "expiration_date" TIMESTAMPTZ,
    "domain_name" TEXT NOT NULL,
    "key_size" INTEGER NOT NULL,
    "path" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "device" (
    "device_id" TEXT PRIMARY KEY NOT NULL,
    "device_name" TEXT NOT NULL,
    "short_name" TEXT NOT NULL,
    "barcode" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "serial_number" TEXT NOT NULL,
    "firmware" TEXT NOT NULL,
    "data_center" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "security_incident_response_team" (
    "security_incident_response_team_id" TEXT PRIMARY KEY NOT NULL,
    "training_subject_id" INTEGER,
    "person_id" TEXT NOT NULL,
    "organization_id" TEXT NOT NULL,
    "training_status_id" INTEGER,
    "attended_date" DATE,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("training_subject_id") REFERENCES "training_subject"("training_subject_id"),
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("training_status_id") REFERENCES "status_value"("status_value_id")
);
CREATE TABLE IF NOT EXISTS "awareness_training" (
    "awareness_training_id" TEXT PRIMARY KEY NOT NULL,
    "training_subject_id" INTEGER NOT NULL,
    "person_id" TEXT NOT NULL,
    "organization_id" TEXT NOT NULL,
    "training_status_id" INTEGER NOT NULL,
    "attended_date" DATE NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("training_subject_id") REFERENCES "training_subject"("training_subject_id"),
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("organization_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("training_status_id") REFERENCES "status_value"("status_value_id")
);
CREATE TABLE IF NOT EXISTS "rating" (
    "rating_id" TEXT PRIMARY KEY NOT NULL,
    "author_id" TEXT NOT NULL,
    "rating_given_to_id" TEXT NOT NULL,
    "rating_value_id" INTEGER NOT NULL,
    "best_rating_id" INTEGER,
    "rating_explanation" TEXT NOT NULL,
    "review_aspect" TEXT NOT NULL,
    "worst_rating_id" INTEGER,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("author_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("rating_given_to_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("rating_value_id") REFERENCES "rating_value"("rating_value_id"),
    FOREIGN KEY("best_rating_id") REFERENCES "rating_value"("rating_value_id"),
    FOREIGN KEY("worst_rating_id") REFERENCES "rating_value"("rating_value_id")
);
CREATE TABLE IF NOT EXISTS "note" (
    "note_id" TEXT PRIMARY KEY NOT NULL,
    "party_id" TEXT NOT NULL,
    "note" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("party_id") REFERENCES "party"("party_id")
);
CREATE TABLE IF NOT EXISTS "threat_source_type" (
    "threat_source_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "threat_event_type" (
    "threat_event_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "calendar_period" (
    "calendar_period_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "tracking_period" (
    "tracking_period_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "audit_assertion" (
    "audit_assertion_id" TEXT PRIMARY KEY NOT NULL,
    "auditor_type_id" TEXT NOT NULL,
    "audit_purpose_id" INTEGER NOT NULL,
    "auditor_org_id" TEXT NOT NULL,
    "auditor_person_id" TEXT NOT NULL,
    "auditor_status_type_id" INTEGER NOT NULL,
    "scf_identifier" TEXT NOT NULL,
    "auditor_notes" TEXT NOT NULL,
    "auditor_artifacts" TEXT NOT NULL,
    "assertion_name" TEXT NOT NULL,
    "assertion_description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("auditor_type_id") REFERENCES "auditor_type"("code"),
    FOREIGN KEY("audit_purpose_id") REFERENCES "audit_purpose"("audit_purpose_id"),
    FOREIGN KEY("auditor_org_id") REFERENCES "organization"("organization_id"),
    FOREIGN KEY("auditor_person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("auditor_status_type_id") REFERENCES "audit_status"("audit_status_id")
);
CREATE TABLE IF NOT EXISTS "contract" (
    "contract_id" TEXT PRIMARY KEY NOT NULL,
    "contract_from_id" TEXT NOT NULL,
    "contract_to_id" TEXT NOT NULL,
    "contract_status_id" INTEGER,
    "document_reference" TEXT NOT NULL,
    "payment_type_id" INTEGER,
    "periodicity_id" INTEGER,
    "start_date" TIMESTAMPTZ NOT NULL,
    "end_date" TIMESTAMPTZ,
    "contract_type_id" INTEGER,
    "date_of_last_review" TIMESTAMPTZ,
    "date_of_next_review" TIMESTAMPTZ,
    "date_of_contract_review" TIMESTAMPTZ,
    "date_of_contract_approval" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("contract_from_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("contract_to_id") REFERENCES "party"("party_id"),
    FOREIGN KEY("contract_status_id") REFERENCES "contract_status"("contract_status_id"),
    FOREIGN KEY("payment_type_id") REFERENCES "payment_type"("payment_type_id"),
    FOREIGN KEY("periodicity_id") REFERENCES "periodicity"("periodicity_id"),
    FOREIGN KEY("contract_type_id") REFERENCES "contract_type"("contract_type_id")
);
CREATE TABLE IF NOT EXISTS "risk_register" (
    "risk_register_id" TEXT PRIMARY KEY NOT NULL,
    "description" TEXT NOT NULL,
    "risk_subject_id" INTEGER NOT NULL,
    "risk_type_id" INTEGER NOT NULL,
    "impact_to_the_organization" TEXT NOT NULL,
    "rating_likelihood_id" INTEGER,
    "rating_impact_id" INTEGER,
    "rating_overall_risk_id" INTEGER,
    "controls_in_place" TEXT NOT NULL,
    "control_effectivenes" INTEGER NOT NULL,
    "over_all_residual_risk_rating_id" INTEGER,
    "mitigation_further_actions" TEXT NOT NULL,
    "control_monitor_mitigation_actions_tracking_strategy" TEXT NOT NULL,
    "control_monitor_action_due_date" DATE,
    "control_monitor_risk_owner_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("risk_subject_id") REFERENCES "risk_subject"("risk_subject_id"),
    FOREIGN KEY("risk_type_id") REFERENCES "risk_type"("risk_type_id"),
    FOREIGN KEY("rating_likelihood_id") REFERENCES "rating_value"("rating_value_id"),
    FOREIGN KEY("rating_impact_id") REFERENCES "rating_value"("rating_value_id"),
    FOREIGN KEY("rating_overall_risk_id") REFERENCES "rating_value"("rating_value_id"),
    FOREIGN KEY("over_all_residual_risk_rating_id") REFERENCES "rating_value"("rating_value_id"),
    FOREIGN KEY("control_monitor_risk_owner_id") REFERENCES "person"("person_id")
);
CREATE TABLE IF NOT EXISTS "incident" (
    "incident_id" TEXT PRIMARY KEY NOT NULL,
    "title" TEXT NOT NULL,
    "incident_date" DATE NOT NULL,
    "time_and_time_zone" TIMESTAMPTZ NOT NULL,
    "asset_id" TEXT NOT NULL,
    "category_id" INTEGER NOT NULL,
    "sub_category_id" INTEGER NOT NULL,
    "severity_id" TEXT NOT NULL,
    "priority_id" TEXT,
    "internal_or_external_id" INTEGER,
    "location" TEXT NOT NULL,
    "it_service_impacted" TEXT NOT NULL,
    "impacted_modules" TEXT NOT NULL,
    "impacted_dept" TEXT NOT NULL,
    "reported_by_id" TEXT NOT NULL,
    "reported_to_id" TEXT NOT NULL,
    "brief_description" TEXT NOT NULL,
    "detailed_description" TEXT NOT NULL,
    "assigned_to_id" TEXT NOT NULL,
    "assigned_date" DATE,
    "investigation_details" TEXT NOT NULL,
    "containment_details" TEXT NOT NULL,
    "eradication_details" TEXT NOT NULL,
    "business_impact" TEXT NOT NULL,
    "lessons_learned" TEXT NOT NULL,
    "status_id" INTEGER,
    "closed_date" DATE,
    "reopened_time" TIMESTAMPTZ,
    "feedback_from_business" TEXT NOT NULL,
    "reported_to_regulatory" TEXT NOT NULL,
    "report_date" DATE,
    "report_time" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("category_id") REFERENCES "incident_category"("incident_category_id"),
    FOREIGN KEY("sub_category_id") REFERENCES "incident_sub_category"("incident_sub_category_id"),
    FOREIGN KEY("severity_id") REFERENCES "severity"("code"),
    FOREIGN KEY("priority_id") REFERENCES "priority"("code"),
    FOREIGN KEY("internal_or_external_id") REFERENCES "incident_type"("incident_type_id"),
    FOREIGN KEY("reported_by_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("reported_to_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("assigned_to_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("status_id") REFERENCES "incident_status"("incident_status_id")
);
CREATE TABLE IF NOT EXISTS "incident_root_cause" (
    "incident_root_cause_id" TEXT PRIMARY KEY NOT NULL,
    "incident_id" TEXT,
    "source" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "probability_id" TEXT,
    "testing_analysis" TEXT NOT NULL,
    "solution" TEXT NOT NULL,
    "likelihood_of_risk_id" TEXT,
    "modification_of_the_reported_issue" TEXT NOT NULL,
    "testing_for_modified_issue" TEXT NOT NULL,
    "test_results" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("incident_id") REFERENCES "incident"("incident_id"),
    FOREIGN KEY("probability_id") REFERENCES "priority"("code"),
    FOREIGN KEY("likelihood_of_risk_id") REFERENCES "priority"("code")
);
CREATE TABLE IF NOT EXISTS "raci_matrix_assignment" (
    "raci_matrix_assignment_id" TEXT PRIMARY KEY NOT NULL,
    "person_id" TEXT NOT NULL,
    "subject_id" INTEGER NOT NULL,
    "activity_id" TEXT NOT NULL,
    "raci_matrix_assignment_nature_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("subject_id") REFERENCES "raci_matrix_subject"("raci_matrix_subject_id"),
    FOREIGN KEY("activity_id") REFERENCES "raci_matrix_activity"("raci_matrix_activity_id"),
    FOREIGN KEY("raci_matrix_assignment_nature_id") REFERENCES "raci_matrix_assignment_nature"("code")
);
CREATE TABLE IF NOT EXISTS "person_skill" (
    "person_skill_id" TEXT PRIMARY KEY NOT NULL,
    "person_id" TEXT NOT NULL,
    "skill_nature_id" INTEGER NOT NULL,
    "skill_id" INTEGER NOT NULL,
    "proficiency_scale_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("skill_nature_id") REFERENCES "skill_nature"("skill_nature_id"),
    FOREIGN KEY("skill_id") REFERENCES "skill"("skill_id"),
    FOREIGN KEY("proficiency_scale_id") REFERENCES "proficiency_scale"("code")
);
CREATE TABLE IF NOT EXISTS "key_performance" (
    "key_performance_id" TEXT PRIMARY KEY NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "key_performance_indicator" (
    "key_performance_indicator_id" TEXT PRIMARY KEY NOT NULL,
    "key_performance_id" TEXT NOT NULL,
    "asset_id" TEXT NOT NULL,
    "calendar_period_id" INTEGER NOT NULL,
    "kpi_comparison_operator_id" TEXT NOT NULL,
    "kpi_context" TEXT NOT NULL,
    "kpi_lower_threshold_critical" TEXT NOT NULL,
    "kpi_lower_threshold_major" TEXT NOT NULL,
    "kpi_lower_threshold_minor" TEXT NOT NULL,
    "kpi_lower_threshold_ok" TEXT NOT NULL,
    "kpi_lower_threshold_warning" TEXT NOT NULL,
    "kpi_measurement_type_id" TEXT NOT NULL,
    "kpi_status_id" TEXT NOT NULL,
    "kpi_threshold_critical" TEXT NOT NULL,
    "kpi_threshold_major" TEXT NOT NULL,
    "kpi_threshold_minor" TEXT NOT NULL,
    "kpi_threshold_ok" TEXT NOT NULL,
    "kpi_threshold_warning" TEXT NOT NULL,
    "kpi_unit_of_measure" TEXT NOT NULL,
    "kpi_value" TEXT NOT NULL,
    "score" TEXT NOT NULL,
    "tracking_period_id" INTEGER NOT NULL,
    "trend_id" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("key_performance_id") REFERENCES "key_performance"("key_performance_id"),
    FOREIGN KEY("asset_id") REFERENCES "asset"("asset_id"),
    FOREIGN KEY("calendar_period_id") REFERENCES "calendar_period"("calendar_period_id"),
    FOREIGN KEY("kpi_comparison_operator_id") REFERENCES "comparison_operator"("code"),
    FOREIGN KEY("kpi_measurement_type_id") REFERENCES "kpi_measurement_type"("code"),
    FOREIGN KEY("kpi_status_id") REFERENCES "kpi_status"("code"),
    FOREIGN KEY("tracking_period_id") REFERENCES "tracking_period"("tracking_period_id"),
    FOREIGN KEY("trend_id") REFERENCES "trend"("code")
);
CREATE TABLE IF NOT EXISTS "key_risk" (
    "key_risk_id" TEXT PRIMARY KEY NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "base_value" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "key_risk_indicator" (
    "key_risk_indicator_id" TEXT PRIMARY KEY NOT NULL,
    "key_risk_id" TEXT NOT NULL,
    "entry_date" DATE NOT NULL,
    "entry_value" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("key_risk_id") REFERENCES "key_risk"("key_risk_id")
);
CREATE TABLE IF NOT EXISTS "assertion" (
    "assertion_id" TEXT PRIMARY KEY NOT NULL,
    "foreign_integration" TEXT NOT NULL,
    "assertion" TEXT NOT NULL,
    "assertion_explain" TEXT NOT NULL,
    "assertion_expires_on" DATE,
    "assertion_expires_poam" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT
);
CREATE TABLE IF NOT EXISTS "attestation" (
    "attestation_id" TEXT PRIMARY KEY NOT NULL,
    "assertion_id" TEXT NOT NULL,
    "person_id" TEXT NOT NULL,
    "attestation" TEXT NOT NULL,
    "attestation_explain" TEXT NOT NULL,
    "attested_on" DATE NOT NULL,
    "expires_on" DATE,
    "boundary_id" TEXT,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("assertion_id") REFERENCES "assertion"("assertion_id"),
    FOREIGN KEY("person_id") REFERENCES "person"("person_id"),
    FOREIGN KEY("boundary_id") REFERENCES "boundary"("boundary_id")
);
CREATE TABLE IF NOT EXISTS "attestation_evidence" (
    "attestation_evidence_id" TEXT PRIMARY KEY NOT NULL,
    "attestation_id" TEXT NOT NULL,
    "evidence_nature" TEXT NOT NULL,
    "evidence_summary_markdown" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "attachment" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    FOREIGN KEY("attestation_id") REFERENCES "attestation"("attestation_id")
);
CREATE TABLE IF NOT EXISTS "training_subject" (
    "training_subject_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "status_value" (
    "status_value_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "rating_value" (
    "rating_value_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "contract_type" (
    "contract_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "graph_nature" (
    "graph_nature_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "risk_subject" (
    "risk_subject_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "risk_type" (
    "risk_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "incident_category" (
    "incident_category_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "incident_sub_category" (
    "incident_sub_category_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "incident_type" (
    "incident_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "incident_status" (
    "incident_status_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "asset_risk_type" (
    "asset_risk_type_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "audit_purpose" (
    "audit_purpose_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);
CREATE TABLE IF NOT EXISTS "audit_status" (
    "audit_status_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "code" TEXT /* UNIQUE COLUMN */ NOT NULL,
    "value" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    "created_by" TEXT DEFAULT 'UNKNOWN',
    "updated_at" TIMESTAMPTZ,
    "updated_by" TEXT,
    "deleted_at" TIMESTAMPTZ,
    "deleted_by" TEXT,
    "activity_log" TEXT,
    UNIQUE("code")
);

--content views
CREATE VIEW IF NOT EXISTS "security_incident_response_team_view"("person_name", "organization_name", "team_role", "email") AS
    SELECT p.person_first_name || ' ' || p.person_last_name AS person_name, o.name AS organization_name, ort.value AS team_role,e.electronics_details AS email
    FROM security_incident_response_team sirt
    INNER JOIN person p ON p.person_id = sirt.person_id
    INNER JOIN organization o ON o.organization_id=sirt.organization_id
    INNER JOIN organization_role orl ON orl.person_id = sirt.person_id AND orl.organization_id = sirt.organization_id
    INNER JOIN organization_role_type ort ON ort.organization_role_type_id = orl.organization_role_type_id
    INNER JOIN party pr ON pr.party_id = p.party_id
    INNER JOIN contact_electronic e ON e.party_id=pr.party_id AND e.contact_type_id = (SELECT contact_type_id FROM contact_type WHERE code='OFFICIAL_EMAIL');
CREATE VIEW IF NOT EXISTS "awareness_training_view"("person_name", "person_role", "trainigng_subject", "training_status_id", "attended_date") AS
    SELECT p.person_first_name || ' ' || p.person_last_name AS person_name,ort.value AS person_role,sub.value AS trainigng_subject,at.training_status_id,at.attended_date
    FROM awareness_training at
    INNER JOIN person p ON p.person_id = at.person_id
    INNER JOIN organization_role orl ON orl.person_id = at.person_id AND orl.organization_id = at.organization_id
    INNER JOIN organization_role_type ort ON ort.organization_role_type_id = orl.organization_role_type_id
    INNER JOIN training_subject sub ON sub.code = at.training_subject_id;
CREATE VIEW IF NOT EXISTS "person_skill_view"("person_name", "skill", "proficiency") AS
    SELECT p.person_first_name || ' ' || p.person_last_name AS person_name,s.value AS skill,prs.value AS proficiency
    FROM person_skill ps
    INNER JOIN person p ON p.person_id = ps.person_id
    INNER JOIN skill s ON s.skill_id = ps.skill_id
    INNER JOIN proficiency_scale prs ON prs.code = ps.proficiency_scale_id GROUP BY ps.person_id,ps.skill_id,person_name,s.value,proficiency;
CREATE VIEW IF NOT EXISTS "security_incident_response_view"("incident", "incident_date", "asset_name", "category", "severity", "priority", "internal_or_external", "location", "it_service_impacted", "impacted_modules", "impacted_dept", "reported_by", "reported_to", "brief_description", "detailed_description", "assigned_to", "assigned_date", "investigation_details", "containment_details", "eradication_details", "business_impact", "lessons_learned", "status", "closed_date", "feedback_from_business", "reported_to_regulatory", "report_date", "report_time", "root_cause_of_the_issue", "probability_of_issue", "testing_for_possible_root_cause_analysis", "solution", "likelihood_of_risk", "modification_of_the_reported_issue", "testing_for_modified_issue", "test_results") AS
    SELECT i.title AS incident,i.incident_date,ast.name as asset_name,ic.value AS category,s.value AS severity,
    p.value AS priority,it.value AS internal_or_external,i.location,i.it_service_impacted,
    i.impacted_modules,i.impacted_dept,p1.person_first_name || ' ' || p1.person_last_name AS reported_by,
    p2.person_first_name || ' ' || p2.person_last_name AS reported_to,i.brief_description,
    i.detailed_description,p3.person_first_name || ' ' || p3.person_last_name AS assigned_to,
    i.assigned_date,i.investigation_details,i.containment_details,i.eradication_details,i.business_impact,
    i.lessons_learned,ist.value AS status,i.closed_date,i.feedback_from_business,i.reported_to_regulatory,i.report_date,i.report_time,
    irc.description AS root_cause_of_the_issue,p4.value AS probability_of_issue,irc.testing_analysis AS testing_for_possible_root_cause_analysis,
    irc.solution,p5.value AS likelihood_of_risk,irc.modification_of_the_reported_issue,irc.testing_for_modified_issue,irc.test_results
    FROM incident i
    INNER JOIN asset ast ON ast.asset_id = i.asset_id
    INNER JOIN incident_category ic ON ic.incident_category_id = i.category_id
    INNER JOIN severity s ON s.code = i.severity_id
    INNER JOIN priority p ON p.code = i.priority_id
    INNER JOIN incident_type it ON it.incident_type_id = i.internal_or_external_id
    INNER JOIN person p1 ON p1.person_id = i.reported_by_id
    INNER JOIN person p2 ON p2.person_id = i.reported_to_id
    INNER JOIN person p3 ON p3.person_id = i.assigned_to_id
    INNER JOIN incident_status ist ON ist.incident_status_id = i.status_id
    LEFT JOIN incident_root_cause irc ON irc.incident_id = i.incident_id
    LEFT JOIN priority p4 ON p4.code = irc.probability_id
    LEFT JOIN priority p5 ON p5.code = irc.likelihood_of_risk_id;
CREATE VIEW IF NOT EXISTS "raci_matrix_assignment_view"("person_name", "subject", "activity", "assignment_nature") AS
    SELECT p.person_first_name || ' ' || p.person_last_name AS person_name,rms.value AS subject,rmac.activity,
    rman.value AS assignment_nature
    FROM raci_matrix_assignment rma
    INNER JOIN person p ON p.person_id = rma.person_id
    INNER JOIN raci_matrix_subject rms on rms.raci_matrix_subject_id = rma.subject_id
    INNER JOIN raci_matrix_activity rmac on rmac.raci_matrix_activity_id = rma.activity_id
    INNER JOIN raci_matrix_assignment_nature rman on rman.code = rma.raci_matrix_assignment_nature_id;
CREATE VIEW IF NOT EXISTS "security_impact_analysis_view"("vulnerability", "security_risk", "security_threat", "impact_of_risk", "proposed_controls", "impact_level", "risk_level", "existing_controls", "priority", "reported_date", "reported_by", "responsible_by") AS
    SELECT v.short_name as vulnerability, ast.name as security_risk,te.title as security_threat,
    ir.impact as impact_of_risk,pc.controls as proposed_controls,p1.value as impact_level,
    p2.value as risk_level,sia.existing_controls,pr.value as priority,sia.reported_date,
    pn1.person_first_name || ' ' || pn1.person_last_name AS reported_by,
    pn2.person_first_name || ' ' || pn2.person_last_name AS responsible_by
    FROM security_impact_analysis sia
    INNER JOIN vulnerability v ON v.vulnerability_id = sia.vulnerability_id
    INNER JOIN asset_risk ar ON ar.asset_risk_id = sia.asset_risk_id
    INNER JOIN asset ast ON ast.asset_id = ar.asset_id
    INNER JOIN threat_event te ON te.threat_event_id = ar.threat_event_id
    INNER JOIN impact_of_risk ir ON ir.security_impact_analysis_id = sia.security_impact_analysis_id
    INNER JOIN proposed_controls pc ON pc.security_impact_analysis_id = sia.security_impact_analysis_id
    INNER JOIN probability p1 ON p1.code = sia.impact_level_id
    INNER JOIN probability p2 ON p2.code = sia.risk_level_id
    INNER JOIN priority pr ON pr.code = sia.priority_id
    INNER JOIN person pn1 ON pn1.person_id = sia.reported_by_id
    INNER JOIN person pn2 ON pn2.person_id = sia.responsible_by_id;
CREATE VIEW IF NOT EXISTS "key_performance_indicator_view"("kpi_lower_threshold_critical", "kpi_lower_threshold_major", "kpi_lower_threshold_minor", "kpi_lower_threshold_ok", "kpi_lower_threshold_warning", "kpi_threshold_critical", "kpi_threshold_major", "kpi_threshold_minor", "kpi_threshold_ok", "kpi_threshold_warning", "kpi_value", "score", "kpi_unit_of_measure", "key_performance", "calendar_period", "asset_name", "asset_type", "kpi_comparison_operator", "kpi_measurement_type", "kpi_status", "tracking_period", "trend") AS
    SELECT
    kpi.kpi_lower_threshold_critical,
    kpi.kpi_lower_threshold_major,
    kpi.kpi_lower_threshold_minor,
    kpi.kpi_lower_threshold_ok,
    kpi.kpi_lower_threshold_warning,
    kpi.kpi_threshold_critical,
    kpi.kpi_threshold_major,
    kpi.kpi_threshold_minor,
    kpi.kpi_threshold_ok,
    kpi.kpi_threshold_warning,
    kpi.kpi_value,
    kpi.score,
    kpi.kpi_unit_of_measure,
    kp.title AS key_performance,
    cp.value AS calendar_period,
    ast.name AS asset_name,
    at.value AS asset_type,
    co.value AS kpi_comparison_operator,
    kmt.value AS kpi_measurement_type,
    ks.value AS kpi_status,
    tp.value AS tracking_period,
    t.value AS trend
    FROM key_performance_indicator kpi
    INNER JOIN asset ast ON ast.asset_id = kpi.asset_id
    INNER JOIN asset_type at ON at.asset_type_id = ast.asset_type_id
    INNER JOIN key_performance kp ON kp.key_performance_id = kpi.key_performance_id
    INNER JOIN calendar_period cp ON cp.calendar_period_id = kpi.calendar_period_id
    INNER JOIN comparison_operator co ON co.code = kpi.kpi_comparison_operator_id
    INNER JOIN kpi_measurement_type kmt ON kmt.code = kpi.kpi_measurement_type_id
    INNER JOIN kpi_status ks ON ks.code = kpi.kpi_status_id
    INNER JOIN tracking_period tp ON tp.tracking_period_id = kpi.tracking_period_id
    INNER JOIN trend t ON t.code = kpi.trend_id;
CREATE VIEW IF NOT EXISTS "attestation_view"("attestation", "attestation_explain", "attested_on", "expires_on", "person_name", "foreign_integration", "assertion", "assertion_explain", "assertion_expires_on", "assertion_expires_poam", "boundary") AS
    SELECT
    at.attestation,
    at.attestation_explain,
    at.attested_on,
    at.expires_on,
    p.person_first_name || ' ' || p.person_last_name AS person_name,
    ar.foreign_integration,
    ar.assertion,
    ar.assertion_explain,
    ar.assertion_expires_on,
    ar.assertion_expires_poam,
    b.name as boundary
    FROM attestation at
    INNER JOIN person p ON p.person_id = at.person_id
    INNER JOIN assertion ar ON ar.assertion_id = at.assertion_id
    LEFT JOIN boundary b on b.boundary_id = at.boundary_id;
CREATE VIEW IF NOT EXISTS "root_cause_analysis_view"("issue", "source", "cause_of_the_issue", "testing_analysis", "solution", "modification_of_the_reported_issue", "testing_for_modified_issue", "test_results", "probability_of_issue", "likelihood_of_risk") AS
    SELECT
    i.title as issue,
    irc.source,
    irc.description as cause_of_the_issue,
    irc.testing_analysis,
    irc.solution,
    irc.modification_of_the_reported_issue,
    irc.testing_for_modified_issue,
    irc.test_results,
    p.value as probability_of_issue,
    p1.value as likelihood_of_risk
    FROM incident_root_cause irc
    INNER JOIN incident i on i.incident_id = irc.incident_id
    INNER JOIN priority p on p.code = irc.probability_id
    INNER JOIN priority p1 on p1.code = irc.likelihood_of_risk_id;
CREATE VIEW IF NOT EXISTS "vender_view"("name", "email", "address", "state", "city", "zip", "country") AS
    SELECT pr.party_name as name,
    e.electronics_details as email,
    l.address_line1 as address,
    l.address_state as state,
    l.address_city as city,
    l.address_zip as zip,
    l.address_country as country
    FROM party_relation prl
    INNER JOIN party pr ON pr.party_id = prl.party_id
    INNER JOIN contact_electronic e ON e.party_id = pr.party_id AND e.contact_type_id = (SELECT contact_type_id FROM contact_type WHERE code='OFFICIAL_EMAIL')
    INNER JOIN contact_land l ON l.party_id = pr.party_id AND l.contact_type_id = (SELECT contact_type_id FROM contact_type WHERE code='OFFICIAL_ADDRESS')
    WHERE prl.party_role_id = (SELECT party_role_id FROM party_role WHERE code='VENDOR') AND prl.relation_type_id = 'ORGANIZATION_TO_PERSON';
CREATE VIEW IF NOT EXISTS "contract_view"("contract_by", "contract_to", "payment_type", "contract_status", "contract_type", "document_reference", "periodicity", "start_date", "end_date", "date_of_last_review", "date_of_next_review", "date_of_contract_review", "date_of_contract_approval") AS
    SELECT
    p1.party_name as contract_by,
    p2.party_name as contract_to,
    pt.value as payment_type,
    cs.value as contract_status,
    ctp.value as contract_type,
    ct.document_reference,
    p.value as periodicity,
    ct.start_date,
    ct.end_date,
    ct.date_of_last_review,
    ct.date_of_next_review,
    ct.date_of_contract_review,
    ct.date_of_contract_approval
    FROM contract ct
    INNER JOIN party p1 on p1.party_id = ct.contract_from_id
    INNER JOIN party p2 on p2.party_id = ct.contract_to_id
    INNER JOIN payment_type pt on pt.code = ct.payment_type_id
    INNER JOIN contract_status cs on cs.code = ct.contract_status_id
    INNER JOIN contract_type ctp on ctp.code = ct.contract_type_id
    INNER JOIN periodicity p on p.code = ct.periodicity_id;
CREATE VIEW IF NOT EXISTS "asset_service_view"("name", "server", "description", "port", "experimental_version", "production_version", "latest_vendor_version", "resource_utilization", "log_file", "url", "vendor_link", "installation_date", "criticality", "owner", "tag", "asset_criticality", "asymmetric_keys", "cryptographic_key", "symmetric_keys") AS
    SELECT
    asser.name,ast.name as server,asser.description,asser.port,asser.experimental_version,asser.production_version,asser.latest_vendor_version,asser.resource_utilization,asser.log_file,asser.url,
    asser.vendor_link,asser.installation_date,asser.criticality,o.name AS owner,sta.value as tag, ast.criticality as asset_criticality,ast.asymmetric_keys_encryption_enabled as asymmetric_keys,
    ast.cryptographic_key_encryption_enabled as cryptographic_key,ast.symmetric_keys_encryption_enabled as symmetric_keys
    FROM asset_service asser
    INNER JOIN asset ast ON ast.asset_id = asser.asset_id
    INNER JOIN organization o ON o.organization_id=ast.organization_id
    INNER JOIN asset_status sta ON sta.asset_status_id=ast.asset_status_id;
CREATE VIEW IF NOT EXISTS "risk_register_view"("risk_register_id", "description", "risk_subject", "risk_type", "impact_to_the_organization", "rating_likelihood_id", "rating_impact_id", "rating_overall_risk_id", "controls_in_place", "control_effectivenes", "over_all_residual_risk_rating_id", "mitigation_further_actions", "control_monitor_mitigation_actions_tracking_strategy", "control_monitor_action_due_date", "control_monitor_risk_owner") AS
    SELECT rr.risk_register_id,
    rr.description,
    rs."value" as risk_subject,
    rt."value" as risk_type,
    impact_to_the_organization,
    rating_likelihood_id,
    rating_impact_id,
    rating_overall_risk_id,
    controls_in_place,
    control_effectivenes,
    over_all_residual_risk_rating_id,
    mitigation_further_actions,
    control_monitor_mitigation_actions_tracking_strategy,
    control_monitor_action_due_date,
    p.person_first_name  as control_monitor_risk_owner
    FROM risk_register rr
    INNER JOIN risk_subject rs on rs.risk_subject_id = rr.risk_subject_id
    INNER JOIN risk_type rt on rt.risk_type_id=rr.risk_type_id
    INNER JOIN person p on p.person_id=rr.control_monitor_risk_owner_id;

-- seed Data
INSERT INTO "execution_context" ("code", "value") VALUES ('PRODUCTION', 'production');
INSERT INTO "execution_context" ("code", "value") VALUES ('TEST', 'test');
INSERT INTO "execution_context" ("code", "value") VALUES ('DEVELOPMENT', 'devl');
INSERT INTO "execution_context" ("code", "value") VALUES ('SANDBOX', 'sandbox');
INSERT INTO "execution_context" ("code", "value") VALUES ('EXPERIMENTAL', 'experimental');
undefined
INSERT INTO "raci_matrix_assignment_nature" ("code", "value") VALUES ('RESPONSIBLE', 'Responsible');
INSERT INTO "raci_matrix_assignment_nature" ("code", "value") VALUES ('ACCOUNTABLE', 'Accountable');
INSERT INTO "raci_matrix_assignment_nature" ("code", "value") VALUES ('CONSULTED', 'Consulted');
INSERT INTO "raci_matrix_assignment_nature" ("code", "value") VALUES ('INFORMED', 'Informed');
INSERT INTO "proficiency_scale" ("code", "value") VALUES ('NA', 'Not Applicable');
INSERT INTO "proficiency_scale" ("code", "value") VALUES ('FUNDAMENTAL_AWARENESS', 'Fundamental Awareness (basic knowledge)');
INSERT INTO "proficiency_scale" ("code", "value") VALUES ('NOVICE', 'Novice (limited experience)');
INSERT INTO "proficiency_scale" ("code", "value") VALUES ('INTERMEDIATE', 'Intermediate (practical application)');
INSERT INTO "proficiency_scale" ("code", "value") VALUES ('ADVANCED', 'Advanced (applied theory)');
INSERT INTO "proficiency_scale" ("code", "value") VALUES ('EXPERT', 'Expert (recognized authority)');
INSERT INTO "vulnerability_status" ("code", "value") VALUES ('OPEN', 'Open');
INSERT INTO "vulnerability_status" ("code", "value") VALUES ('CLOSED', 'Closed');
INSERT INTO "vulnerability_status" ("code", "value") VALUES ('ACCEPTED', 'Accepted');
INSERT INTO "vulnerability_status" ("code", "value") VALUES ('OUT_OF_SCOPE', 'Out of Scope');
INSERT INTO "vulnerability_status" ("code", "value") VALUES ('MITIGATED', 'Mitigated');
INSERT INTO "vulnerability_status" ("code", "value") VALUES ('INVALID', 'Invalid');
INSERT INTO "probability" ("code", "value") VALUES ('HIGH', 'High');
INSERT INTO "probability" ("code", "value") VALUES ('MEDIUM', 'Medium');
INSERT INTO "probability" ("code", "value") VALUES ('LOW', 'Low');
INSERT INTO "comparison_operator" ("code", "value") VALUES ('GREATER_THAN', '<');
INSERT INTO "comparison_operator" ("code", "value") VALUES ('GREATER_THAN_EQUAL_TO', '<=');
INSERT INTO "comparison_operator" ("code", "value") VALUES ('EQUAL_TO', '=');
INSERT INTO "comparison_operator" ("code", "value") VALUES ('LESS_THAN', '>');
INSERT INTO "comparison_operator" ("code", "value") VALUES ('LESS_THAN_EQUAL_TO', '>=');
INSERT INTO "comparison_operator" ("code", "value") VALUES ('NA', 'na');
INSERT INTO "kpi_measurement_type" ("code", "value") VALUES ('BANDWIDTH', 'Bandwidth');
INSERT INTO "kpi_measurement_type" ("code", "value") VALUES ('CAPACITY', 'Capacity');
INSERT INTO "kpi_measurement_type" ("code", "value") VALUES ('CURRENCY', 'Currency');
INSERT INTO "kpi_measurement_type" ("code", "value") VALUES ('PERCENTAGE', 'Percentage');
INSERT INTO "kpi_measurement_type" ("code", "value") VALUES ('TIME', 'Time');
INSERT INTO "kpi_measurement_type" ("code", "value") VALUES ('UNITLESS', 'Unitless');
INSERT INTO "kpi_status" ("code", "value") VALUES ('CRITICAL', 'Critical');
INSERT INTO "kpi_status" ("code", "value") VALUES ('MAJOR', 'Major');
INSERT INTO "kpi_status" ("code", "value") VALUES ('MINOR', 'Minor');
INSERT INTO "kpi_status" ("code", "value") VALUES ('OK', 'Ok');
INSERT INTO "kpi_status" ("code", "value") VALUES ('WARNING', 'Warning');
INSERT INTO "trend" ("code", "value") VALUES ('DOWN', 'Down');
INSERT INTO "trend" ("code", "value") VALUES ('NO_CHANGE', 'No Change	');
INSERT INTO "trend" ("code", "value") VALUES ('UP', 'Up');
INSERT INTO "auditor_type" ("code", "value") VALUES ('EXTERNAL', 'external');
INSERT INTO "auditor_type" ("code", "value") VALUES ('INTERNAL', 'internal');
undefined
INSERT INTO "severity" ("code", "value") VALUES ('CRITICAL', 'Critical');
INSERT INTO "severity" ("code", "value") VALUES ('MAJOR', 'Major');
INSERT INTO "severity" ("code", "value") VALUES ('MINOR', 'Minor');
INSERT INTO "severity" ("code", "value") VALUES ('LOW', 'Low');
INSERT INTO "priority" ("code", "value") VALUES ('HIGH', 'High');
INSERT INTO "priority" ("code", "value") VALUES ('MEDIUM', 'Medium');
INSERT INTO "priority" ("code", "value") VALUES ('LOW', 'Low');

INSERT INTO "party_role" ("party_role_id", "code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES (NULL, 'CUSTOMER', 'Customer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'VENDOR', 'Vendor', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "party_identifier_type" ("party_identifier_type_id", "code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES (NULL, 'UUID', 'UUID', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'DRIVING_LICENSE', 'Driving License', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'PASSPORT', 'Passport', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "person_type" ("person_type_id", "code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES (NULL, 'INDIVIDUAL', 'Individual', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'PROFESSIONAL', 'Professional', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "contact_type" ("contact_type_id", "code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES (NULL, 'HOME_ADDRESS', 'Home Address', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'OFFICIAL_ADDRESS', 'Official Address', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'MOBILE_PHONE_NUMBER', 'Mobile Phone Number', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'LAND_PHONE_NUMBER', 'Land Phone Number', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'OFFICIAL_EMAIL', 'Official Email', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'PERSONAL_EMAIL', 'Personal Email', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "organization_role_type" ("organization_role_type_id", "code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES (NULL, 'PROJECT_MANAGER_TECHNOLOGY', 'Project Manager Technology', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'PROJECT_MANAGER_QUALITY', 'Project Manager Quality', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'PROJECT_MANAGER_DEVOPS', 'Project Manager DevOps', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'ASSOCIATE_MANAGER_TECHNOLOGY', 'Associated Manager Technology', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'ASSOCIATE_MANAGER_QUALITY', 'Associate Manager Quality', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'ASSOCIATE_MANAGER_DEVOPS', 'Associate Manager DevOps', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'SENIOR_LEAD_SOFTWARE_ENGINEER_ARCHITECT', 'Senior Lead Software Engineer Architect', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'LEAD_SOFTWARE_ENGINEER_ARCHITECT', 'Lead Software Engineer Architect', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'SENIOR_LEAD_SOFTWARE_QUALITY_ENGINEER', 'Senior Lead Software DevOps Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'LEAD_SOFTWARE_ENGINEER', 'Lead Software Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'LEAD_SOFTWARE_QUALITY_ENGINEER', 'Lead Software Quality Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'LEAD_SOFTWARE_DEVOPS_ENGINEER', 'Lead Software DevOps Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'LEAD_SYSTEM_NETWORK_ENGINEER', 'Lead System Network Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'SENIOR_SOFTWARE_ENGINEER', 'Senior Software Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'SENIOR_SOFTWARE_QUALITY_ENGINEER', 'Senior Software Quality Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'SOFTWARE_QUALITY_ENGINEER', 'Software Quality Engineer', NULL, NULL, NULL, NULL, NULL, NULL),
              (NULL, 'SECURITY_ENGINEER', 'Security Engineer', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "contract_status" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ACTIVE', 'Active', NULL, NULL, NULL, NULL, NULL, NULL),
              ('AWAITING_APPROVAL', 'Awaiting Approval', NULL, NULL, NULL, NULL, NULL, NULL),
              ('AWAITING_APPROVAL_FOR_RENEWAL', 'Awaiting Approval For Renewal', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CANCELED', 'Canceled', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DENIED', 'Denied', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FINISHED', 'Finished', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IN_PREPARATION', 'In Preparation', NULL, NULL, NULL, NULL, NULL, NULL),
              ('QUOTE_REQUESTED', 'Quote Requested', NULL, NULL, NULL, NULL, NULL, NULL),
              ('QUOTED', 'Quoted', NULL, NULL, NULL, NULL, NULL, NULL),
              ('STANDARD_CONTRACT', 'Standard Contract', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SUSPENDED', 'Suspended', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VALIDATED', 'Validated', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "payment_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('BOTH', 'Both', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LOANS', 'Loans', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NONE', 'None', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RENTS', 'Rents', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "periodicity" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ANNUAL', 'Annual', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BI_MONTHLY', 'Bi Monthly', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BI_WEEKLY', 'Bi Weekly', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DAILY', 'Daily', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MONTHLY', 'Monthly', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OTHER', 'Other', NULL, NULL, NULL, NULL, NULL, NULL),
              ('QUARTERLY', 'Quarterly', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SEMI_ANNUAL', 'Semi Annual', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SEMI_MONTHLY', 'Semi Monthly', NULL, NULL, NULL, NULL, NULL, NULL),
              ('WEEKLY', 'Weekly', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "boundary_nature" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('REGULATORY_TAX_ID', 'Regulatory Tax ID', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "time_entry_category" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('MISC_MEETINGS', 'Misc Meetings', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MISC_OTHER', 'Misc Other', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MISC_VACATION', 'Misc Vacation', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MISC_WORK_ITEM', 'Misc Work Item', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PACKAGE', 'Package', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PROJECT', 'Project', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REQUEST', 'Request', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TASK', 'Task', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "raci_matrix_subject" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('PROJECT_LEADERSHIP', 'Project Leadership', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PROJECT_MANAGEMENT', 'Project Management', NULL, NULL, NULL, NULL, NULL, NULL),
              ('APPLICATION_DEVELOPMENT', 'Application Development', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DEV_OPERATIONS', 'Dev Operations', NULL, NULL, NULL, NULL, NULL, NULL),
              ('QUALITY_ASSURANCE', 'Quality Assurance', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SEARCH_ENGINE_OPTIMIZATION', 'Search Engine Optimization', NULL, NULL, NULL, NULL, NULL, NULL),
              ('USER_INTERFASE_USABILITY', 'User Interfase And Usability', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BUSINESS_ANALYST', 'Business Analyst (Abm)', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CURATION_COORDINATION', 'Curation Coordination', NULL, NULL, NULL, NULL, NULL, NULL),
              ('KNOWLEDGE_REPRESENTATION', 'Knowledge Representation', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MARKETING_OUTREACH', 'Marketing Outreach', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CURATION_WORKS', 'Curation Works', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "skill_nature" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('SOFTWARE', 'Software', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HARDWARE', 'Hardware', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "skill" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ANGULAR', 'Angular', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DENO', 'Deno', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TYPESCRIPT', 'Typescript', NULL, NULL, NULL, NULL, NULL, NULL),
              ('POSTGRESQL', 'PostgreSQL', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MYSQL', 'MySQL', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HUGO', 'Hugo', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PHP', 'PHP', NULL, NULL, NULL, NULL, NULL, NULL),
              ('JAVASCRIPT', 'JavaScript', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PYTHON', 'Python', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DOT_NET', '.NET', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ORACLE', 'Oracle', NULL, NULL, NULL, NULL, NULL, NULL),
              ('JAVA', 'Java', NULL, NULL, NULL, NULL, NULL, NULL),
              ('JQUERY', 'jQuery', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OSQUERY', 'Osquery', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REACTJS', 'ReactJs', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "asset_status" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('AWAITING_RECEIPT', 'Awaiting Receipt', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IN_STOCK', 'In Stock', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IN_USE', 'In Use', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MISSING', 'Missing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RETIRED', 'Retired', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RETURNED_FOR_MAINTENANCE', 'Returned For Maintenance', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RETURNED_TO_SUPPLIER', 'Returned To Supplier', NULL, NULL, NULL, NULL, NULL, NULL),
              ('UNDEFINED', 'Undefined', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "asset_service_status" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ACTIVE', 'Active', NULL, NULL, NULL, NULL, NULL, NULL),
              ('INACTIVE', 'Inactive', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DELETED', 'DELETED', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "asset_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ACCOUNT', 'Account', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BUSINESS_SERVICE', 'Business Service', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CABLE', 'Cable', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CABLE_DEVICE', 'Cable Device', NULL, NULL, NULL, NULL, NULL, NULL),
              ('COLLECTIVE_EQUIPMENT', 'Collective Equipment', NULL, NULL, NULL, NULL, NULL, NULL),
              ('COMPUTER', 'Computer', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CPU', 'Cpu', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DOMAIN', 'Domain', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SERVER', 'Server', NULL, NULL, NULL, NULL, NULL, NULL),
              ('EXTENSION_CARD', 'Extension Card', NULL, NULL, NULL, NULL, NULL, NULL),
              ('GLOBAL_SOFTWARE_LICENSE', 'Global Software License', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LAPTOP', 'Laptop', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LASER_PRINTER', 'Laser Printer', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LICENSE_CONTRACT', 'License Contract', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MAINTENANCE_CONTRACT', 'Maintenance Contract', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MASS_STORAGE', 'Mass Storage', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MOBILE_DEVICE', 'Mobile Device', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MONITOR', 'Monitor', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NETWORK_HARDWARE', 'Network Hardware', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NETWORK_INTERFACE', 'Network Interface', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OEM_SOFTWARE_LICENSE', 'Oem Software License', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PRINTER', 'Printer', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RACKMOUNT_MONITOR', 'Rackmount Monitor', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SCANNER', 'Scanner', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_ACCESS_AUTHORIZATION', 'Software Access Authorization', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_ACCESS_REMOVAL', 'Software Access Removal', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_ADD_WORK_ORDER', 'Software Add Work Order', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_INSTALLATION', 'Software Installation', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_LICENSE', 'Software License', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_REMOVAL_WORK_ORDER', 'Software Removal Work Order', NULL, NULL, NULL, NULL, NULL, NULL),
              ('STANDARD_ASSET', 'Standard Asset', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TELECOMMUNICATION_EQUIPMENT', 'Telecommunication Equipment', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TELEPHONE', 'Telephone', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VIRTUAL_MACHINE', 'Virtual Machine', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SECURITY_POLICY', 'Security Policy', NULL, NULL, NULL, NULL, NULL, NULL),
              ('EMPLOYEE_DATA', 'Employee Data', NULL, NULL, NULL, NULL, NULL, NULL),
              ('API', 'Api', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FIREWALL', 'Firewall', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "assignment" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('AWAITING_RECEIPT', 'Awaiting receipt', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IN_STOCK', 'In Stock', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IN_USE', 'In Use', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MISSING', 'Missing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RETURNED_FOR_MAINTENANCE', 'Returned For Maintenance', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RETURNED_TO_SUPPLIER', 'Returned To Supplier', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RETIRED', 'Retired', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "threat_source_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('PHISHING', 'Phishing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SPAM', 'Spam', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SPYWARE_AND_MALWARE_FOR_EXTORTION', 'Spyware and malware for extortion', NULL, NULL, NULL, NULL, NULL, NULL),
              ('THEFT_OF_PRIVATE_INFORMATION', 'Theft of private information', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ONLINE_SCAMS', 'Online scams', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DESTROY_OR_ABUSE_CRITICAL_INFRASTRUCTURE', 'Destroy or abuse critical infrastructure', NULL, NULL, NULL, NULL, NULL, NULL),
              ('THREATEN_NATIONAL_SECURITY', 'Threaten national security', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DISRUPT_ECONOMIES', 'Disrupt economies', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CAUSE_BODILY_HARM_TO_CITIZENS', 'Cause bodily harm to citizens', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DENIAL_OF_SERVICE_ATTACKS', 'Denial-of-Service Attacks', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DOXING', 'Doxing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LEAKING_INFORMATION', 'Leaking Information', NULL, NULL, NULL, NULL, NULL, NULL),
              ('THE_USE_OF_THE_SOFTWARE_RECAP', 'The Use of the Software RECAP', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BLOGGING_ANONYMOUSLY', 'Blogging Anonymously', NULL, NULL, NULL, NULL, NULL, NULL),
              ('GEO_BOMBING', 'Geo-bombing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('WEBSITE_MIRRORING', 'Website Mirroring', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CHANGING_THE_CODE_FOR_WEBSITES_OR_WEBSITE_DEFACEMENTS', 'Changing the Code for Websites or website defacements', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "threat_event_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('VIRUSES', 'Viruses', NULL, NULL, NULL, NULL, NULL, NULL),
              ('WORMS', 'Worms', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TROJANS', 'Trojans', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RANSOMWARE', 'Ransomware', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CRYPTOJACKING', 'Cryptojacking', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SPYWARE', 'Spyware', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ADWARE', 'Adware', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FILELESS_MALWARE', 'Fileless malware', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ROOTKITS', 'Rootkits', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BAITING', 'Baiting', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PRETEXTING', 'Pretexting', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PHISHING', 'Phishing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VISHING', 'Vishing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SMISHING', 'Smishing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PIGGYBACKING', 'Piggybacking', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TAILGATING', 'Tailgating', NULL, NULL, NULL, NULL, NULL, NULL),
              ('EMAIL_HIJACKING', 'Email Hijacking', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DNS_SPOOFING', 'DNS spoofing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IP_SPOOFING', 'IP spoofing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HTTPS_SPOOFING', 'HTTPS spoofing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HTTP_FLOOD_DDOS', 'HTTP flood DDoS', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SYN_FLOOD_DDOS', 'SYN flood DDoS', NULL, NULL, NULL, NULL, NULL, NULL),
              ('UDP_FLOOD_DDOS', 'UDP flood DDoS', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ICMP_FLOOD', 'ICMP flood', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NTP_AMPLIFICATION', 'NTP amplification', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SQL_INJECTION', 'SQL injection', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CODE_INJECTION', 'Code injection', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OS_COMMAND_INJECTION', 'OS Command Injection', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LDAP_INJECTION', 'LDAP injection', NULL, NULL, NULL, NULL, NULL, NULL),
              ('XML_EXTERNAL_ENTITIES_INJECTION', 'XML eXternal Entities (XXE) Injection', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CROSS_SITE_SCRIPTING', 'Cross Site Scripting (XSS)', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BROKEN_ACCESS_CONTROL', 'Broken Access Control', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CRYPTOGRAPHIC_FAILURES', 'Cryptographic Failures', NULL, NULL, NULL, NULL, NULL, NULL),
              ('INSECURE_DESIGN', 'Insecure Design', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SECURITY_MISCONFIGURATION', 'Security Misconfiguration', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VULNERABLE_AND_OUTDATED_COMPONENTS', 'Vulnerable and Outdated Components', NULL, NULL, NULL, NULL, NULL, NULL),
              ('IDENTIFICATION_AND_AUTHENTICATION_FAILURES', 'Identification and Authentication Failures', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SOFTWARE_AND_DATA_INTEGRITY_FAILURES', 'Software and Data Integrity Failures', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SECURITY_LOGGING_AND_MONITORING_FAILURES', 'Security Logging and Monitoring Failures', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SERVER_SIDE_REQUEST_FORGERY', 'Server Side Request Forgery', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "calendar_period" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('TWENTY_FOUR_HOURS_SEVEN_DAYS', '24x7', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BUSINESS_HOURS', 'Business hours', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NON_BUSINESS_HOURS', 'Non-business hours', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "tracking_period" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('DAY', 'Day', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HOUR', 'Hour', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MONTH', 'Month', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OTHER', 'Other', NULL, NULL, NULL, NULL, NULL, NULL),
              ('QUARTER', 'Quarter', NULL, NULL, NULL, NULL, NULL, NULL),
              ('WEEK', 'Week', NULL, NULL, NULL, NULL, NULL, NULL),
              ('YEAR', 'Year', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "audit_purpose" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('MEANING_DRY_RUN', 'exmeaning dry runternal', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OFFICIAL', 'official', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "audit_status" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('OUTSTANDING', 'Outstanding', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FULFILLED', 'Fulfilled', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REJECTED', 'Rejected', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ACCEPTED', 'Accepted', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "training_subject" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('HIPAA', 'HIPAA', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CYBER_SECURITY', 'Cyber Security', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OBSERVABILITY_OPEN_TELEMETRY', 'Observability Open Telemetry', NULL, NULL, NULL, NULL, NULL, NULL),
              ('BEST_PRACTICES_OF_AGILE', 'Practices of Agile Workflow', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "status_value" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('YES', 'Yes', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NO', 'No', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "rating_value" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ONE', '1', NULL, NULL, NULL, NULL, NULL, NULL),
              ('TWO', '2', NULL, NULL, NULL, NULL, NULL, NULL),
              ('THREE', '3', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FOUR', '4', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FIVE', '5', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "contract_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('GENERAL_CONTRACT_FOR_SERVICES', 'General Contract for Services', NULL, NULL, NULL, NULL, NULL, NULL),
              ('EMPLOYMENT_AGREEMENT', 'Employment Agreement', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NONCOMPETE_AGREEMENT', 'Noncompete Agreement', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VENDOR_SLA', 'Vendor SLA', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VENDOR_NDA', 'Vendor NDA', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "graph_nature" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('SERVICE', 'Service', NULL, NULL, NULL, NULL, NULL, NULL),
              ('APP', 'Application', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "asset_risk_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('SECURITY', 'Security', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "risk_subject" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('TECHNICAL_RISK', 'Technical Risk', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "risk_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('BUDGET', 'Budget', NULL, NULL, NULL, NULL, NULL, NULL),
              ('QUALITY', 'Quality', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SCHEDULE', 'Schedule', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SCHEDULE_AND_BUDGET', 'Schedule And Budget', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "incident_category" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ACCESS', 'Access', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DATA', 'Data', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FACILITIES', 'Facilities', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FAILURE', 'Failure', NULL, NULL, NULL, NULL, NULL, NULL),
              ('GENERAL_INFORMATION', 'General Information', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HARDWARE', 'Hardware', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HOW_TO', 'How To', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OTHER', 'Other', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PERFORMANCE', 'Performance', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SECURITY', 'Security', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SERVICE_DELIVERY', 'Service Delivery', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SERVICE_PORTFOLIO', 'Service Portfolio', NULL, NULL, NULL, NULL, NULL, NULL),
              ('STATUS', 'Status', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SUPPORT', 'Support', NULL, NULL, NULL, NULL, NULL, NULL),
              ('THRIFTY', 'Thrifty', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "incident_sub_category" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('AUTHORIZATION_ERROR', 'Authorization Error', NULL, NULL, NULL, NULL, NULL, NULL),
              ('AVAILABILITY', 'Availability', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DATA_OR_FILE_CORRUPTED', 'Data Or File Corrupted', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DATA_OR_FILE_INCORRECT', 'Data Or File Incorrect', NULL, NULL, NULL, NULL, NULL, NULL),
              ('DATA_OR_FILE_MISSING', 'Data Or File Missing', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ERROR_MESSAGE', 'Error Message', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FUNCTION_OR_FEATURE_NOT_WORKING', 'Function Or Feature Not Working', NULL, NULL, NULL, NULL, NULL, NULL),
              ('FUNCTIONALITY', 'Functionality', NULL, NULL, NULL, NULL, NULL, NULL),
              ('GENERAL_INFORMATION', 'General Information', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HARDWARE_FAILURE', 'Hardware Failure', NULL, NULL, NULL, NULL, NULL, NULL),
              ('HOW_TO', 'How To', NULL, NULL, NULL, NULL, NULL, NULL),
              ('INCIDENT_RESOLUTION_QUALITY', 'Incident Resolution Quality', NULL, NULL, NULL, NULL, NULL, NULL),
              ('INCIDENT_RESOLUTION_TIME', 'Incident Resolution Time', NULL, NULL, NULL, NULL, NULL, NULL),
              ('JOB_FAILED', 'Job Failed', NULL, NULL, NULL, NULL, NULL, NULL),
              ('LOGIN_FAILURE', 'Login Failure', NULL, NULL, NULL, NULL, NULL, NULL),
              ('MISSING_OR_STOLEN', 'Missing Or Stolen', NULL, NULL, NULL, NULL, NULL, NULL),
              ('NEW_SERVICE', 'New Service', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PERFORMANCE', 'Performance', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PERFORMANCE_DEGRADATION', 'Performance Degradation', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PERSON', 'Person', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SECURITY_BREACH', 'Security Breach', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SECURITY_EVENT', 'Security Event/Message', NULL, NULL, NULL, NULL, NULL, NULL),
              ('STATUS', 'Status', NULL, NULL, NULL, NULL, NULL, NULL),
              ('STORAGE_LIMIT_EXCEEDED', 'Storage Limit Exceeded', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SYSTEM_DOWN', 'System Down', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SYSTEM_OR_APPLICATION_HANGS', 'System Or Application Hangs', NULL, NULL, NULL, NULL, NULL, NULL),
              ('UPGRADE_NEW_RELEASE', 'Upgrade/New Release', NULL, NULL, NULL, NULL, NULL, NULL),
              ('VIRUS_ALERT', 'Virus Alert', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "incident_type" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('COMPLAINT', 'Complaint', NULL, NULL, NULL, NULL, NULL, NULL),
              ('INCIDENT', 'Incident', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REQUEST_FOR_INFORMATION', 'Request For Information', NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO "incident_status" ("code", "value", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log")
       VALUES ('ACCEPTED', 'Accepted', NULL, NULL, NULL, NULL, NULL, NULL),
              ('ASSIGNED', 'Assigned', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CANCELLED', 'Cancelled', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CATEGORIZE', 'Categorize', NULL, NULL, NULL, NULL, NULL, NULL),
              ('CLOSED', 'Closed', NULL, NULL, NULL, NULL, NULL, NULL),
              ('OPEN', 'Open', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PENDING_CHANGE', 'Pending Change', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PENDING_CUSTOMER', 'Pending Customer', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PENDING_EVIDENCE', 'Pending Evidence', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PENDING_OTHER', 'Pending Other', NULL, NULL, NULL, NULL, NULL, NULL),
              ('PENDING_VENDOR', 'Pending Vendor', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REFERRED', 'Referred', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REJECTED', 'Rejected', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REOPENED', 'Reopened', NULL, NULL, NULL, NULL, NULL, NULL),
              ('REPLACED_PROBLEM', 'Replaced Problem', NULL, NULL, NULL, NULL, NULL, NULL),
              ('RESOLVED', 'Resolved', NULL, NULL, NULL, NULL, NULL, NULL),
              ('SUSPENDED', 'Suspended', NULL, NULL, NULL, NULL, NULL, NULL),
              ('WORK_IN_PROGRESS', 'Work In Progress', NULL, NULL, NULL, NULL, NULL, NULL);
;
INSERT INTO "party" ("party_id", "party_type_id", "party_name", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('11', 'ORGANIZATION', 'Orgnization Name', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "organization" ("organization_id", "party_id", "name", "alias", "description", "license", "federal_tax_id_num", "registration_date", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('12', (SELECT "party_id" FROM "party" WHERE "party_id" = '11' AND "party_type_id" = 'ORGANIZATION' AND "party_name" = 'Orgnization Name'), 'Orgnization Name', NULL, NULL, 'XXXX-XXXXX-XXXX', NULL, '2010-01-15', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "contact_electronic" ("contact_electronic_id", "contact_type_id", "party_id", "electronics_details", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('13', (SELECT "contact_type_id" FROM "contact_type" WHERE "code" = 'OFFICIAL_EMAIL'), (SELECT "party_id" FROM "party" WHERE "party_id" = '11' AND "party_type_id" = 'ORGANIZATION' AND "party_name" = 'Orgnization Name'), 'orgnization@email.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "contact_electronic" ("contact_electronic_id", "contact_type_id", "party_id", "electronics_details", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('14', (SELECT "contact_type_id" FROM "contact_type" WHERE "code" = 'LAND_PHONE_NUMBER'), (SELECT "party_id" FROM "party" WHERE "party_id" = '11' AND "party_type_id" = 'ORGANIZATION' AND "party_name" = 'Orgnization Name'), '0523 852 9945', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
;
INSERT INTO "contact_land" ("contact_land_id", "contact_type_id", "party_id", "address_line1", "address_line2", "address_zip", "address_city", "address_state", "address_territory", "address_country", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('15', (SELECT "contact_type_id" FROM "contact_type" WHERE "code" = 'OFFICIAL_ADDRESS'), (SELECT "party_id" FROM "party" WHERE "party_id" = '11' AND "party_type_id" = 'ORGANIZATION' AND "party_name" = 'Orgnization Name'), 'Address line 1', 'Address line 2', '', 'City', 'State', NULL, 'Country', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "party" ("party_id", "party_type_id", "party_name", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('6', (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person'), 'First Name Last Name', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person" ("person_id", "party_id", "person_type_id", "person_first_name", "person_middle_name", "person_last_name", "previous_name", "honorific_prefix", "honorific_suffix", "gender_id", "sex_id", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('7', (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name'), (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL'), 'First Name', NULL, 'Last Name', NULL, NULL, NULL, (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE'), (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE'), NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "contact_electronic" ("contact_electronic_id", "contact_type_id", "party_id", "electronics_details", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('8', (SELECT "contact_type_id" FROM "contact_type" WHERE "code" = 'OFFICIAL_EMAIL'), (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name'), 'person@org.com', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "contact_electronic" ("contact_electronic_id", "contact_type_id", "party_id", "electronics_details", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('9', (SELECT "contact_type_id" FROM "contact_type" WHERE "code" = 'MOBILE_PHONE_NUMBER'), (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name'), '+911234567890', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
;
INSERT INTO "contact_land" ("contact_land_id", "contact_type_id", "party_id", "address_line1", "address_line2", "address_zip", "address_city", "address_state", "address_territory", "address_country", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('10', (SELECT "contact_type_id" FROM "contact_type" WHERE "code" = 'OFFICIAL_ADDRESS'), (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name'), 'Address line 1', 'Address line 2', '', 'City', 'State', NULL, 'Country', NULL, NULL, NULL, NULL, NULL, NULL, NULL);
;
INSERT INTO "party_relation" ("party_relation_id", "party_id", "related_party_id", "relation_type_id", "party_role_id", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('17', (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name'), (SELECT "party_id" FROM "party" WHERE "party_id" = '11' AND "party_type_id" = 'ORGANIZATION' AND "party_name" = 'Orgnization Name'), 'ORGANIZATION_TO_PERSON', (SELECT "party_role_id" FROM "party_role" WHERE "code" = 'VENDOR'), NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "organization_role" ("organization_role_id", "person_id", "organization_id", "organization_role_type_id", "elaboration", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('18', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "organization_id" FROM "organization" WHERE "name" = 'Orgnization Name' AND "license" = 'XXXX-XXXXX-XXXX'), (SELECT "organization_role_type_id" FROM "organization_role_type" WHERE "code" = 'LEAD_SOFTWARE_ENGINEER'), NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFF864XDA977D36CNCH', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'REACTJS'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFMK30M3RQ8QEXCATV', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'JAVASCRIPT'), 'ADVANCED', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFF3RR8GK0TTA3DZVPT', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'HUGO'), 'FUNDAMENTAL_AWARENESS', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFWD6NCRK2N4R6V2JB', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'DENO'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFF8PQBTKVZVPNGA8MJ', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'ANGULAR'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFV2NFAFZN6P62AJ4V', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'TYPESCRIPT'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFHNR195N1EWXQZM0Y', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'POSTGRESQL'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFDK4RKYWKQ5NCGZ2T', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'MYSQL'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFF9M31BZV4E8ZKQFJC', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'PHP'), 'INTERMEDIATE', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFQVXJ8PJ3KSPDVRW8', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'PYTHON'), 'FUNDAMENTAL_AWARENESS', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFVRWWM5CVS45V4DXD', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'DOT_NET'), 'NA', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFF6HB62S4MTGRVVCQR', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'ORACLE'), 'NA', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFYCY5894FTKY7Y8JP', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'JAVA'), 'FUNDAMENTAL_AWARENESS', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFHFSEFY3K2ETZ0MTQ', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'JQUERY'), 'ADVANCED', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "person_skill" ("person_skill_id", "person_id", "skill_nature_id", "skill_id", "proficiency_scale_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFFJGCQ3QF0TVNRJE4T', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "skill_nature_id" FROM "skill_nature" WHERE "code" = 'SOFTWARE'), (SELECT "skill_id" FROM "skill" WHERE "code" = 'OSQUERY'), 'FUNDAMENTAL_AWARENESS', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "awareness_training" ("awareness_training_id", "training_subject_id", "person_id", "organization_id", "training_status_id", "attended_date", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFF4M81W7FRMG0SH1V3', (SELECT "training_subject_id" FROM "training_subject" WHERE "code" = 'HIPAA'), (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "organization_id" FROM "organization" WHERE "name" = 'Orgnization Name' AND "license" = 'XXXX-XXXXX-XXXX'), (SELECT "status_value_id" FROM "status_value" WHERE "code" = 'YES'), '2022-02-21', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "security_incident_response_team" ("security_incident_response_team_id", "training_subject_id", "person_id", "organization_id", "training_status_id", "attended_date", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGFZDBT4TH6MRC7XPJ', NULL, (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "organization_id" FROM "organization" WHERE "name" = 'Orgnization Name' AND "license" = 'XXXX-XXXXX-XXXX'), NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "rating" ("rating_id", "author_id", "rating_given_to_id", "rating_value_id", "best_rating_id", "rating_explanation", "review_aspect", "worst_rating_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGGDWJ3XQHF06ZCXEV', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "organization_id" FROM "organization" WHERE "name" = 'Orgnization Name' AND "license" = 'XXXX-XXXXX-XXXX'), (SELECT "rating_value_id" FROM "rating_value" WHERE "code" = 'FOUR'), (SELECT "rating_value_id" FROM "rating_value" WHERE "code" = 'FIVE'), 'Good Service', 'Satisfied', (SELECT "rating_value_id" FROM "rating_value" WHERE "code" = 'THREE'), NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "contract" ("contract_id", "contract_from_id", "contract_to_id", "contract_status_id", "document_reference", "payment_type_id", "periodicity_id", "start_date", "end_date", "contract_type_id", "date_of_last_review", "date_of_next_review", "date_of_contract_review", "date_of_contract_approval", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGTXZKV9STC4P35RD8', (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name'), (SELECT "party_id" FROM "party" WHERE "party_id" = '11' AND "party_type_id" = 'ORGANIZATION' AND "party_name" = 'Orgnization Name'), (SELECT "contract_status_id" FROM "contract_status" WHERE "code" = 'FINISHED'), 'google.com', (SELECT "payment_type_id" FROM "payment_type" WHERE "code" = 'RENTS'), (SELECT "periodicity_id" FROM "periodicity" WHERE "code" = 'WEEKLY'), '2021-04-20T00:00:00.000Z', '2021-04-20T00:00:00.000Z', (SELECT "contract_type_id" FROM "contract_type" WHERE "code" = 'GENERAL_CONTRACT_FOR_SERVICES'), '2021-04-20T00:00:00.000Z', '2021-04-20T00:00:00.000Z', '2021-04-20T00:00:00.000Z', '2021-04-20T00:00:00.000Z', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "risk_register" ("risk_register_id", "description", "risk_subject_id", "risk_type_id", "impact_to_the_organization", "rating_likelihood_id", "rating_impact_id", "rating_overall_risk_id", "controls_in_place", "control_effectivenes", "over_all_residual_risk_rating_id", "mitigation_further_actions", "control_monitor_mitigation_actions_tracking_strategy", "control_monitor_action_due_date", "control_monitor_risk_owner_id", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGAEG7EYG6S6N3H1J1', 'Risk description', (SELECT "risk_subject_id" FROM "risk_subject" WHERE "code" = 'TECHNICAL_RISK'), (SELECT "risk_type_id" FROM "risk_type" WHERE "code" = 'QUALITY'), 'Impact to the organization', (SELECT "rating_value_id" FROM "rating_value" WHERE "code" = 'THREE'), (SELECT "rating_value_id" FROM "rating_value" WHERE "code" = 'THREE'), (SELECT "rating_value_id" FROM "rating_value" WHERE "code" = 'THREE'), 'Try forgot password', 1, NULL, 'Mitigation further actions', 'Control monitor mitigation actions tracking strategy', '2022-06-13', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "asset" ("asset_id", "organization_id", "asset_retired_date", "asset_status_id", "asset_tag", "name", "description", "asset_type_id", "asset_workload_category", "assignment_id", "barcode_or_rfid_tag", "installed_date", "planned_retirement_date", "purchase_delivery_date", "purchase_order_date", "purchase_request_date", "serial_number", "tco_amount", "tco_currency", "criticality", "asymmetric_keys_encryption_enabled", "cryptographic_key_encryption_enabled", "symmetric_keys_encryption_enabled", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGVC8QBTM564W0JT93', (SELECT "organization_id" FROM "organization" WHERE "name" = 'Orgnization Name' AND "license" = 'XXXX-XXXXX-XXXX'), NULL, (SELECT "asset_status_id" FROM "asset_status" WHERE "code" = 'IN_USE'), '', 'Asset Name', 'Service used for asset etc', (SELECT "asset_type_id" FROM "asset_type" WHERE "code" = 'VIRTUAL_MACHINE'), '', (SELECT "assignment_id" FROM "assignment" WHERE "code" = 'IN_USE'), '', '2021-04-20', NULL, '2021-04-20', '2021-04-20', '2021-04-20', '', '100', 'dollar', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "incident" ("incident_id", "title", "incident_date", "time_and_time_zone", "asset_id", "category_id", "sub_category_id", "severity_id", "priority_id", "internal_or_external_id", "location", "it_service_impacted", "impacted_modules", "impacted_dept", "reported_by_id", "reported_to_id", "brief_description", "detailed_description", "assigned_to_id", "assigned_date", "investigation_details", "containment_details", "eradication_details", "business_impact", "lessons_learned", "status_id", "closed_date", "reopened_time", "feedback_from_business", "reported_to_regulatory", "report_date", "report_time", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGVVAHMS9GEYBXF7W8', 'Server Down - Due to CPU utilization reached 100%', '2021-04-20', '2021-04-20T00:00:00.000Z', (SELECT "asset_id" FROM "asset" WHERE "name" = 'Asset Name' AND "description" = 'Service used for asset etc' AND "asset_type_id" = (SELECT "asset_type_id" FROM "asset_type" WHERE "code" = 'VIRTUAL_MACHINE')), (SELECT "incident_category_id" FROM "incident_category" WHERE "code" = 'PERFORMANCE'), (SELECT "incident_sub_category_id" FROM "incident_sub_category" WHERE "code" = 'HARDWARE_FAILURE'), 'MAJOR', 'HIGH', (SELECT "incident_type_id" FROM "incident_type" WHERE "code" = 'COMPLAINT'), 'USA', 'Application down', '', 'All', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), 'Server will down due to CPU utilization', 'We got an alert message of server due to CPU utilization reaching 100% on 02-07-2022 07:30 GTM', (SELECT "person_id" FROM "person" WHERE "person_id" = '7' AND "party_id" = (SELECT "party_id" FROM "party" WHERE "party_id" = '6' AND "party_type_id" = (SELECT "party_type_id" FROM "party_type" WHERE "party_type_id" = '1' AND "code" = 'PERSON' AND "value" = 'person') AND "party_name" = 'First Name Last Name') AND "person_type_id" = (SELECT "person_type_id" FROM "person_type" WHERE "code" = 'INDIVIDUAL') AND "person_first_name" = 'First Name' AND "person_last_name" = 'Last Name' AND "gender_id" = (SELECT "gender_type_id" FROM "gender_type" WHERE "code" = 'MALE') AND "sex_id" = (SELECT "sex_type_id" FROM "sex_type" WHERE "code" = 'MALE')), '2021-04-20', 'Server was facing issue using due to insufficient harware specfication which cause high CPU utilization, resulting in Crashing of the application', 'Migrated few services to another server in that network range and Restarted server', 'Migrated few services to another server in that network range', 'Application was completely down', 'We need to evlaute the hardware specification and remaining CPU/Memory resources before deploying new applications', (SELECT "incident_status_id" FROM "incident_status" WHERE "code" = 'CLOSED'), NULL, NULL, '', '', '2021-04-20', '2021-04-20T00:00:00.000Z', NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO "incident_root_cause" ("incident_root_cause_id", "incident_id", "source", "description", "probability_id", "testing_analysis", "solution", "likelihood_of_risk_id", "modification_of_the_reported_issue", "testing_for_modified_issue", "test_results", "created_by", "updated_at", "updated_by", "deleted_at", "deleted_by", "activity_log") VALUES ('01HJV4ETFGVCEQX4KNVC47XJAG', (SELECT "incident_id" FROM "incident" WHERE "title" = 'Server Down - Due to CPU utilization reached 100%' AND "sub_category_id" = (SELECT "incident_sub_category_id" FROM "incident_sub_category" WHERE "code" = 'HARDWARE_FAILURE') AND "severity_id" = 'MAJOR' AND "priority_id" = 'HIGH' AND "internal_or_external_id" = (SELECT "incident_type_id" FROM "incident_type" WHERE "code" = 'COMPLAINT') AND "location" = 'USA'), 'Server', 'Sample description', 'HIGH', 'Sample testing analysis', 'Server restarted', 'HIGH', 'No modifications', 'Sample test case', 'Sample test result', NULL, NULL, NULL, NULL, NULL, NULL);
-- the .dump in the last line is necessary because we load into :memory:
-- first because performance is better and then emit all the SQL for saving
-- into the destination file, e.g. when insert DML uses (select x from y where a = b))
.dump
EOF
)

# Create an in-memory SQLite database, load the first pass for optimal
# performance then export the in-memory database to the given file; this
# two phase approach works because the last line in the SQL is '.dump'.
# All arguments after <database_file> will be passed into the final DB.
sqlite3 "$db_file" "$(echo "$SQL" | sqlite3 ":memory:")" "${@}"
  