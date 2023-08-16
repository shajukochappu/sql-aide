// deno-lint-ignore no-explicit-any
type Any = any;

export type Transformers = {
  readonly transform: (value: string, vn: ValueNature) => Any;
};

export type Emitters = {
  readonly emitTsType: (vn: ValueNature) => string;
  readonly emitTsValue: (value: string, vn: ValueNature) => string;
};

export type ValueNature =
  | { readonly nature: "custom" } & Emitters & Transformers
  | { readonly nature: "undefined" } & Emitters & Transformers
  | { readonly nature: "number" } & Emitters & Transformers
  | { readonly nature: "string" } & Emitters & Transformers
  | { readonly nature: "boolean" } & Emitters & Transformers
  | { readonly nature: "Date" } & Emitters & Transformers
  | { readonly nature: "bigint" } & Emitters & Transformers
  | { readonly nature: "union" } & Emitters & Transformers & {
    readonly accumulate: (unionable?: string) => string[];
  };

export const detectedValueNature = (sampleValue?: string): ValueNature => {
  if (typeof sampleValue === "undefined") {
    return {
      nature: "undefined",
      transform: () => undefined,
      emitTsType: () => `undefined`,
      emitTsValue: () => `undefined`,
    };
  }

  const normalizedValue = sampleValue.trim().toLowerCase();
  const defaultEmitters: Emitters = {
    emitTsType: (type) => type.nature,
    emitTsValue: (value) => value,
  };

  // Check for number
  if (!isNaN(Number(sampleValue))) {
    return {
      nature: "number",
      ...defaultEmitters,
      transform: (value) => Number(value),
    };
  } // Check for boolean
  else if (
    ["true", "on", "yes", "false", "off", "no"].includes(normalizedValue)
  ) {
    return {
      nature: "boolean",
      ...defaultEmitters,
      emitTsValue: (value) =>
        ["true", "on", "yes"].includes(value.trim().toLowerCase())
          ? "true"
          : "false",
      transform: (value) =>
        ["true", "on", "yes"].includes(value.trim().toLowerCase())
          ? true
          : false,
    };
  } // Check for date using Date.parse
  else if (!isNaN(Date.parse(sampleValue))) {
    return {
      nature: "Date",
      ...defaultEmitters,
      emitTsValue: (value) => `Date.parse("${value}")`,
      transform: (value) => Date.parse(value),
    };
  } // Check for BigInt (e.g., 123n)
  else if (/^\d+n$/.test(sampleValue)) {
    return {
      nature: "bigint",
      ...defaultEmitters,
      transform: (value) => BigInt(value),
    };
  } // Check for union types (using a convention)
  else if (sampleValue.startsWith("{") && sampleValue.endsWith("}")) {
    const accumlated: string[] = [];
    return {
      nature: "union",
      accumulate: (unionable) => {
        if (unionable && !accumlated.includes(unionable)) {
          accumlated.push(unionable);
        }
        return accumlated;
      },
      emitTsType: () => accumlated.join(" | "),
      emitTsValue: (value) => `"${value.slice(1, -1)}"`,
      transform: (value) => value.slice(1, -1),
    };
  }

  return {
    nature: "string",
    ...defaultEmitters,
    emitTsValue: (value) => `"${value}"`,
    transform: (value) => value,
  };
};

/**
 * Given a sample row of data, try to figure out what the value types should be
 * @param sampleRow the values to use for auto-detection
 * @returns the array of emitters and transformers that cells can use
 */
export function autoDetectValueNatures(sampleRow: string[]) {
  const valueNatures: ValueNature[] = [];
  for (let i = 0; i < sampleRow.length; i++) {
    valueNatures[i] = detectedValueNature(sampleRow[i]);
  }
  return valueNatures;
}
