import { assertEquals } from "https://deno.land/std@0.224.0/assert/assert_equals.ts";
import { z } from "https://deno.land/x/zod@v3.21.4/mod.ts";
import {
  arrowStyleSqlFieldAccessSqlSupplier,
  dotStyleSqlFieldAccessSqlSupplier,
  snakeCaseColumnSupplier,
  TabularJson,
} from "./tabular-json.ts";
import { unindentWhitespace } from "../universal/whitespace.ts";

// Define a synthetic, complex JSON shape with multiple levels of nesting
const syntheticShape = z.object({
  id: z.string(),
  name: z.string(),
  age: z.number(),
  address: z.object({
    street: z.string(),
    city: z.string(),
    zipcode: z.string(),
    geo: z.object({
      lat: z.number(),
      lng: z.number(),
    }),
  }),
  hobbies: z.array(z.string()),
  isActive: z.boolean(),
  metadata: z.object({
    createdAt: z.string(),
    updatedAt: z.string(),
    history: z.array(
      z.object({
        date: z.string(),
        action: z.string(),
      }),
    ),
  }),
  preferences: z.object({
    notifications: z.object({
      email: z.boolean(),
      sms: z.boolean(),
    }),
  }),
});

Deno.test("tabularJs - should handle flattenArrays option correctly", async (tc) => {
  const tabularJson = new TabularJson(syntheticShape)
    .columnSupplier(snakeCaseColumnSupplier)
    .schemaColumns({
      // rename/define these specific fields differently than defaults
      id: { name: "identity" },
      address: {
        zipcode: {
          name: "postal_code",
        },
      },
    });

  const data = {
    id: "123",
    name: "John Doe",
    age: 30,
    address: {
      street: "123 Main St",
      city: "Anytown",
      zipcode: "12345",
      geo: {
        lat: 40.7128,
        lng: -74.0060,
      },
    },
    hobbies: ["reading", "gaming"],
    isActive: true,
    metadata: {
      createdAt: "2021-01-01T00:00:00Z",
      updatedAt: "2021-01-02T00:00:00Z",
      history: [
        { date: "2021-01-01", action: "created" },
        { date: "2021-01-02", action: "updated" },
      ],
    },
    preferences: {
      notifications: {
        email: true,
        sms: false,
      },
    },
  };

  // deno-lint-ignore require-await
  await tc.step("flattenArrays: true", async () => {
    const flattened = tabularJson.tabularJs({ flattenArrays: true })(data);

    assertEquals(flattened["identity"], "123"); // 'id' renamed 'identity'
    assertEquals(flattened["address_street"], "123 Main St");
    assertEquals(flattened["metadata_created_at"], "2021-01-01T00:00:00Z");
    assertEquals(flattened["hobbies_0"], "reading");
    assertEquals(flattened["hobbies_1"], "gaming");
    assertEquals(flattened["is_active"], true);
    assertEquals(flattened["address_geo_lat"], 40.7128);
    assertEquals(flattened["metadata_history_0_date"], "2021-01-01");
    assertEquals(flattened["metadata_history_0_action"], "created");
    assertEquals(flattened["metadata_history_1_date"], "2021-01-02");
    assertEquals(flattened["metadata_history_1_action"], "updated");
    assertEquals(flattened["preferences_notifications_email"], true);
    assertEquals(flattened["preferences_notifications_sms"], false);
  });

  // deno-lint-ignore require-await
  await tc.step("flattenArrays: false", async () => {
    const flattened = tabularJson.tabularJs({ flattenArrays: false })(data);

    assertEquals(flattened["identity"], "123"); // 'id' renamed 'identity'
    assertEquals(flattened["address_street"], "123 Main St");
    assertEquals(flattened["metadata_created_at"], "2021-01-01T00:00:00Z");
    assertEquals(flattened["hobbies"], ["reading", "gaming"]);
    assertEquals(flattened["is_active"], true);
    assertEquals(flattened["address_geo_lat"], 40.7128);
    assertEquals(flattened["metadata_history"], [
      { date: "2021-01-01", action: "created" },
      { date: "2021-01-02", action: "updated" },
    ]);
    assertEquals(flattened["preferences_notifications_email"], true);
    assertEquals(flattened["preferences_notifications_sms"], false);
  });
});

Deno.test("tabularSqlView - should generate correct SQL for complex shape with arrow accessors", () => {
  // Initialize the TabularJson with the synthetic shape
  const tabularJson = new TabularJson(syntheticShape)
    .columnSupplier(snakeCaseColumnSupplier)
    .schemaColumns({
      // optionally rename/define these specific fields differently than defaults
      address: {
        zipcode: {
          name: "postal_code",
        },
      },
    })
    .jsonFieldAccessSql(arrowStyleSqlFieldAccessSqlSupplier);

  const viewName = "user_view";
  const sqlSelect = "SELECT * FROM users";
  const jsonColumnNameInCTE = "data";

  const { createDDL, dropDDL } = tabularJson.tabularSqlView(
    viewName,
    sqlSelect,
    jsonColumnNameInCTE,
    false,
  );

  assertEquals(dropDDL(), "DROP VIEW IF EXISTS user_view;");
  assertEquals(
    createDDL(),
    unindentWhitespace(`
        CREATE VIEW user_view AS
            WITH jsonSupplierCTE AS (
                SELECT * FROM users
            )
            SELECT
                data ->> 'id' AS id,
                data ->> 'name' AS name,
                data ->> 'age' AS age,
                data -> 'address' ->> 'street' AS address_street,
                data -> 'address' ->> 'city' AS address_city,
                data -> 'address' ->> 'zipcode' AS postal_code,
                data -> 'address' -> 'geo' ->> 'lat' AS address_geo_lat,
                data -> 'address' -> 'geo' ->> 'lng' AS address_geo_lng,
                data ->> 'isActive' AS is_active,
                data -> 'metadata' ->> 'createdAt' AS metadata_created_at,
                data -> 'metadata' ->> 'updatedAt' AS metadata_updated_at,
                data -> 'metadata' -> 'history' ->> 'date' AS metadata_history_date,
                data -> 'metadata' -> 'history' ->> 'action' AS metadata_history_action,
                data -> 'preferences' -> 'notifications' ->> 'email' AS preferences_notifications_email,
                data -> 'preferences' -> 'notifications' ->> 'sms' AS preferences_notifications_sms
            FROM jsonSupplierCTE;`),
  );
});

Deno.test("tabularSqlView - should generate correct SQL for complex shape with dot accessor", () => {
  // Initialize the TabularJson with the synthetic shape
  const tabularJson = new TabularJson(syntheticShape)
    .columnSupplier(snakeCaseColumnSupplier)
    .schemaColumns({
      // optionally rename/define these specific fields differently than defaults
      address: {
        zipcode: {
          name: "postal_code",
        },
      },
    })
    .jsonFieldAccessSql(dotStyleSqlFieldAccessSqlSupplier);

  const viewName = "user_view";
  const sqlSelect = "SELECT * FROM users";
  const jsonColumnNameInCTE = "data";

  const { createDDL, dropDDL } = tabularJson.tabularSqlView(
    viewName,
    sqlSelect,
    jsonColumnNameInCTE,
    false,
  );

  assertEquals(dropDDL(), "DROP VIEW IF EXISTS user_view;");
  assertEquals(
    createDDL(),
    unindentWhitespace(`
        CREATE VIEW user_view AS
            WITH jsonSupplierCTE AS (
                SELECT * FROM users
            )
            SELECT
                data ->> '$.id' AS id,
                data ->> '$.name' AS name,
                data ->> '$.age' AS age,
                data ->> '$.address.street' AS address_street,
                data ->> '$.address.city' AS address_city,
                data ->> '$.address.zipcode' AS postal_code,
                data ->> '$.address.geo.lat' AS address_geo_lat,
                data ->> '$.address.geo.lng' AS address_geo_lng,
                data ->> '$.isActive' AS is_active,
                data ->> '$.metadata.createdAt' AS metadata_created_at,
                data ->> '$.metadata.updatedAt' AS metadata_updated_at,
                data ->> '$.metadata.history.date' AS metadata_history_date,
                data ->> '$.metadata.history.action' AS metadata_history_action,
                data ->> '$.preferences.notifications.email' AS preferences_notifications_email,
                data ->> '$.preferences.notifications.sms' AS preferences_notifications_sms
            FROM jsonSupplierCTE;`),
  );
});
