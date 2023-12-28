import { testingAsserts as ta } from "../../../deps-test.ts";
import { path } from "../../../deps.ts";
import * as ws from "../../../lib/universal/whitespace.ts";
import * as SQLa from "../../../render/mod.ts";
import * as ddb from "../../../render/dialect/duckdb/mod.ts";
import * as mod from "./assurance.ts";

export class SyntheticAssuranceRules
  extends mod.AssuranceRules<SQLa.SqlEmitContext> {
  constructor(
    readonly govn: {
      readonly SQL: ReturnType<typeof SQLa.SQL<SQLa.SqlEmitContext>>;
    },
  ) {
    super(govn);
  }

  insertIssue(
    from: string,
    typeText: string,
    messageSql: string,
    remediationSql?: string,
  ) {
    return ws.unindentWhitespace(`
      INSERT INTO ingest_issue (session_id, issue_type, issue_message, remediation)
          SELECT (SELECT ingest_session_id FROM ingest_session LIMIT 1),
                 '${typeText}',
                 ${messageSql},
                 ${remediationSql ?? "NULL"}
            FROM ${from}`);
  }

  insertRowValueIssue(
    from: string,
    typeText: string,
    rowNumSql: string,
    columnNameSql: string,
    valueSql: string,
    messageSql: string,
    remediationSql?: string,
  ) {
    return ws.unindentWhitespace(`
      INSERT INTO ingest_issue (session_id, issue_type, issue_row, issue_column, invalid_value, issue_message, remediation)
          SELECT (SELECT ingest_session_id FROM ingest_session LIMIT 1),
                 '${typeText}',
                 ${rowNumSql},
                 ${columnNameSql},
                 ${valueSql},
                 ${messageSql},
                 ${remediationSql ?? "NULL"}
            FROM ${from}`);
  }
}

Deno.test("DuckDB Table Content Assurance", () => {
  const ctx = SQLa.typicalSqlEmitContext({ sqlDialect: SQLa.duckDbDialect() });
  const ddlOptions = SQLa.typicalSqlTextSupplierOptions<typeof ctx>();
  const ar = new SyntheticAssuranceRules({
    SQL: SQLa.SQL<typeof ctx>(ddlOptions),
  });
  const tableName = "synthetic_csv_fail";
  const csvSrcFsPath = "assurance_test-fixture-fail.csv";

  // deno-fmt-ignore
  const ddlDefn = SQLa.SQL<typeof ctx>(ddlOptions)`
    -- you can test this in DuckDB using:
    -- $ cat assurance_test-fixture.duckdb.sql | duckdb ":memory:"

    CREATE TABLE ingest_session (
        ingest_session_id VARCHAR NOT NULL,
        ingest_src VARCHAR NOT NULL,
        ingest_table_name VARCHAR NOT NULL,
    );

    CREATE TABLE ingest_issue (
        session_id VARCHAR NOT NULL,
        issue_row INT,
        issue_type VARCHAR NOT NULL,
        issue_column VARCHAR,
        invalid_value VARCHAR,
        issue_message VARCHAR NOT NULL,
        remediation VARCHAR
    );

    INSERT INTO ingest_session (ingest_session_id, ingest_src, ingest_table_name)
                        VALUES (uuid(), '${csvSrcFsPath}', '${tableName}');

    ${ddb.csvTableIntegration({
      csvSrcFsPath: () => csvSrcFsPath,
      tableName,
      isTempTable: true,
      extraColumnsSql: [
        "row_number() OVER () as src_file_row_number",
        "(SELECT ingest_session_id from ingest_session LIMIT 1) as ingest_session_id",
      ],
    })}

    SELECT * FROM ${tableName};

    ${ar.requiredColumnNamesInTable(tableName,
      ['column1', 'column2', 'column3',
      'column4', 'column5', 'column6',
      'column7', 'column8', 'column9'])}

    -- NOTE: If the above does not pass, meaning not all columns with the proper
    --       names are present, do not run the queries below because they assume
    --       proper names and existence of columns.

    ${ar.intValueInAllTableRows(tableName, 'column4')}

    ${ar.intRangeInAllTableRows(tableName, 'column5', 10, 100)}

    ${ar.uniqueValueInAllTableRows(tableName, 'column6')}

    ${ar.mandatoryValueInAllTableRows(tableName, 'column7')}

    ${ar.patternValueInAllTableRows(tableName, 'column8', '^ABC-[0-9]{4}$', 'ABC-1234')}

    ${ar.onlyAllowedValuesInAllTableRows(tableName, 'column9', "'Yes', 'No', 'Maybe'", 'Yes, No, or Maybe')}

    ${ar.dotComEmailValueInAllTableRows(tableName, 'column2')}

    SELECT * FROM ingest_issue;`;

  ta.assertEquals(
    ddlDefn.SQL(ctx),
    Deno.readTextFileSync(path.fromFileUrl(
      import.meta.resolve("./assurance_test-fixture.duckdb.sql"),
    )),
  );
});