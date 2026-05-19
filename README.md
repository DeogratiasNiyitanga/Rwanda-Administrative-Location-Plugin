# Rwanda Administrative Location Selector — Joget DX 8 Plugin

A custom form element that lets users select Rwanda administrative locations in a cascading hierarchy: **Province → District → Sector → Cell → Village**. Each level is stored in its own database column and is fully configurable.

---

## Table of Contents

1. [What it Does](#what-it-does)
2. [Installation](#installation)
3. [Adding the Element to a Form](#adding-the-element-to-a-form)
4. [Configuration Reference](#configuration-reference)
   - [Basic Settings](#basic-settings)
   - [Interaction Mode](#interaction-mode)
   - [Stop Selection At](#stop-selection-at)
   - [Kinyarwanda Names](#kinyarwanda-names)
   - [Validation (Required Fields)](#validation-required-fields)
   - [Sub-level DB Column IDs](#sub-level-db-column-ids)
5. [Database Columns](#database-columns)
6. [Using Location Data in List Builder & Filters](#using-location-data-in-list-builder--filters)
7. [Validation Behaviour](#validation-behaviour)
8. [For Developers — Modifying the Plugin](#for-developers--modifying-the-plugin)
   - [Project Structure](#project-structure)
   - [Key Files](#key-files)
   - [Build](#build)
   - [Updating the Location Data](#updating-the-location-data)
   - [How the Plugin Works Internally](#how-the-plugin-works-internally)

---

## What it Does

- Renders cascading dropdown menus (Province through Village) inside a Joget form.
- Each level is only populated after the parent level is selected.
- Saves each level to a **separate DB column** so data can be filtered, reported on, and displayed individually.
- Supports optional **Kinyarwanda province display names** (the stored value matches the display language).
- Validates required levels with per-field messages and inline error display.
- Works in both **standard** (all dropdowns visible) and **stepped** (one level revealed at a time) interaction modes.
- Compatible with Joget **List Builder** and **filter palettes** — all sub-level columns appear as searchable fields.

---

## Installation

1. Build the JAR (or obtain the pre-built one):

   ```
   target/Rwanda-Administrative-Locations-1.0.0.jar
   ```

2. In Joget DX 8, go to **Admin Panel → Manage Plugins → Upload Plugin**.

3. Upload the JAR file and click **Upload**.

4. The plugin appears in the Form Builder palette under **Custom Fields → Rwanda Administrative Location Selector**.

---

## Adding the Element to a Form

1. Open your app in the Joget App Center.
2. Navigate to **Design → Forms** and open (or create) a form.
3. In the Form Builder, find **Rwanda Administrative Location Selector** in the **Custom Fields** palette on the left.
4. Drag it onto the canvas.
5. Click the element to open its properties panel and configure it (see below).
6. Save the form.

---

## Configuration Reference

### Basic Settings

| Field | Description |
|---|---|
| **ID** | The element ID. This becomes the DB column name for the **province** value. Required. |
| **Label** | The label displayed above the dropdowns (e.g., `Select Location`). |

### Interaction Mode

| Option | Behaviour |
|---|---|
| **Standard (Show All)** | All dropdowns are visible at once. Deeper levels are disabled until the parent is selected. |
| **Stepped (One by One)** | Only the province dropdown is shown initially. Each subsequent level appears only after the level above it is filled. |

### Stop Selection At

Controls the deepest level that is shown and saved. Choose from:

| Value | Levels shown |
|---|---|
| Province | Province only |
| District | Province, District |
| Sector | Province, District, Sector |
| Cell | Province, District, Sector, Cell |
| Village | Province, District, Sector, Cell, Village *(default)* |

> Setting this to **District** hides Sector, Cell, and Village entirely — they are not rendered and not saved.

### Kinyarwanda Names

**Use Kinyarwanda Province Names** — when checked:

- Province dropdown labels **and saved values** are in Kinyarwanda.
- The five province names used are:

  | English | Kinyarwanda |
  |---|---|
  | Kigali City | Umugi wa Kigali |
  | Eastern Province | Intara y'Iburasirazuba |
  | Western Province | Intara y'Iburengerazuba |
  | Southern Province | Intara y'Amajyepfo |
  | Northern Province | Intara y'Amajyaruguru |

- District through Village remain in English (no translations exist in the data).

> **Important:** If you switch this setting after data has already been saved, existing rows will have the old language value. The dropdown will not pre-select correctly for those rows unless the stored values match the new language. Pick a language and stick with it.

### Validation (Required Fields)

Each level has its own **Required** checkbox and **Validation Message** field:

- **Province - Required** — Province must be selected before the form can be submitted.
- **District - Required** — District must be selected (only visible when Stop Level includes District).
- **Sector / Cell / Village** — follow the same pattern.

**How errors appear:**

- Clicking **Save** immediately shows all outstanding required-field errors at once (one error per empty required field, displayed directly under its dropdown).
- As the user selects values, errors clear level by level.
- If Province has a value but District is still empty, only the District error shows — not Province.

**Validation Message** — the text shown under the empty dropdown. Defaults to `This field is required`. Customise per level (e.g., "Please select a District").

> Each level's message must describe its own level. Avoid copying the Province message into the District field — they will be shown next to different dropdowns.

### Sub-level DB Column IDs

By default, sub-levels are saved to columns named `{elementId}_district`, `{elementId}_sector`, etc. These override fields let you use custom column names.

| Field | Default column name |
|---|---|
| **District Field ID** | `{id}_district` |
| **Sector Field ID** | `{id}_sector` |
| **Cell Field ID** | `{id}_cell` |
| **Village Field ID** | `{id}_village` |

Leave blank to use the defaults. Enter a value to override (e.g., `province_code`, `home_district`).

> The IDs you enter here must be valid database column names (letters, digits, underscores; no spaces).

---

## Database Columns

When the form is submitted, the plugin writes to one column per active level. Given element ID `location` and Stop Level = Village, the saved columns are:

| Column | Contains |
|---|---|
| `location` | Province name |
| `location_district` | District name |
| `location_sector` | Sector name |
| `location_cell` | Cell name |
| `location_village` | Village name |

If you used the **Sub-level DB Column IDs** override, replace the default names above with your configured values.

---

## Using Location Data in List Builder & Filters

Because each sub-level is registered as a hidden child element, **all five columns appear in the Joget List Builder** and can be used as:

- **Displayed columns** — add `location`, `location_district`, etc. to the list columns.
- **Filter fields** — add them to the filter palette so users can search by any level.
- **Datalist conditions** — use them in conditional visibility or process variables.

No extra configuration is needed; Joget picks up sub-level fields automatically.

---

## Validation Behaviour

| Scenario | Result |
|---|---|
| Save clicked, all required fields empty | All required-field errors shown at once, form blocked by server |
| Save clicked, Province filled, District empty (and required) | Province error clears, District error shown |
| User selects a level after a failed save | That level's error clears immediately |
| Form re-loaded after a failed save | Previously selected values are restored; errors re-appear at the correct positions |
| All required fields filled | No errors; form submits successfully |

---

## For Developers — Modifying the Plugin

### Project Structure

```
Rwanda-Administrative-Locations/
├── pom.xml                                         Maven OSGi bundle config
└── src/main/
    ├── java/org/joget/rwanda/administrative/locations/
    │   ├── Activator.java                          OSGi bundle activator (registers the plugin)
    │   └── RwandaLocationSelector.java             Main plugin class
    └── resources/
        ├── rwanda-locations.json                   Full Rwanda location data tree
        ├── properties/
        │   └── rwandaLocationSelector.json         Form Builder property panel definition
        └── templates/
            └── rwandaLocationSelector.ftl          FreeMarker HTML + JS template
```

### Key Files

#### `RwandaLocationSelector.java`

The plugin's core class. Extends `Element` and implements `FormBuilderPaletteElement`.

| Method | Purpose |
|---|---|
| `renderTemplate()` | Passes location JSON, persisted values, and error state to the FTL. |
| `formatData()` | Reads all level values from the HTTP request and writes them to the DB row. |
| `selfValidate()` | Checks each required level; stores the error under the parent element ID so Joget's AJAX mechanism can locate it. |
| `getChildren()` | Injects `ShadowHiddenField` children for each active sub-level so they appear in List Builder and filter palettes. |

The inner class `ShadowHiddenField` is a no-op `HiddenField` used only for List Builder introspection. It deliberately skips all validation (`continueValidation → false`) and data saving (`formatData → empty`) — the parent handles both.

#### `rwandaLocationSelector.ftl`

FreeMarker template. Responsible for:

- Rendering hidden inputs for each level's value (persisted across validation failures).
- Rendering `<select>` dropdowns with stable IDs.
- Rendering empty error `<div>` elements (JS fills them in; FTL never writes error text directly).
- Emitting the `rwReqConfig` JavaScript object (required flags + messages per level).
- Running the `window[ns]` JavaScript object that drives all cascade, persistence, and error logic.

#### `rwanda-locations.json`

A nested JSON object with the full Rwanda hierarchy:

```json
{
  "Kigali City": {
    "Gasabo": {
      "Bumbogo": {
        "Gasizi": ["Agaseke", "Akabahizi", ...]
      }
    }
  }
}
```

Structure: `Province → District → Sector → Cell → [Village, ...]`

#### `rwandaLocationSelector.json`

Defines every field shown in the Form Builder properties panel. Key patterns used:

- `control_field` + `control_value` + `control_use_regex` — conditionally show/hide a property based on another property's value (e.g., hide District fields when Stop Level = Province).
- Pipe-separated `control_value` with `control_use_regex: "true"` for multi-value matching (e.g., `"district|sector|cell|village"`).

### Build

Requirements: Java 8+, Maven 3.x, Joget DX 8 libraries in local Maven repo (or accessible via the Joget Archiva server configured in `pom.xml`).

```bash
cd Rwanda-Administrative-Locations
mvn package
# Output: target/Rwanda-Administrative-Locations-1.0.0.jar
```

Upload the JAR via **Admin Panel → Manage Plugins → Upload Plugin**.

> After re-uploading, Joget hot-reloads the OSGi bundle — no server restart needed in most cases.

### Updating the Location Data

The entire Rwanda administrative hierarchy is in `src/main/resources/rwanda-locations.json`. To add, rename, or remove locations:

1. Edit `rwanda-locations.json` following the existing nested structure.
2. Rebuild with `mvn package`.
3. Re-upload the JAR.

No Java code changes are needed for data-only updates.

### How the Plugin Works Internally

**Data flow on form submit:**

1. Browser POSTs hidden inputs (`location`, `location_district`, etc.) alongside the visible select values.
2. `formatData()` reads each value from `formData.getRequestParameter(fieldId)` and writes it to the DB row.
3. `selfValidate()` reads the same request parameters to check required fields. On failure it calls `formData.addFormError(id, message)` (always under the province/parent element ID) and returns `Boolean.FALSE`.

**Why errors are stored under the province ID:**
Joget's AJAX error handler finds form elements by their registered ID. Only the parent element is registered in Joget's form tree (sub-levels are `ShadowHiddenField` no-ops). Storing all errors under the parent ID ensures the AJAX handler can mark the element as errored and stop submission. The JavaScript `showInlineErrors()` function then repositions the message visually under the correct dropdown.

**Value persistence across validation failures:**
Joget's `value` FTL variable is populated from the load-binder store (which is empty for new records on re-render). The plugin reads from `formData.getRequestParameter()` instead, which preserves the HTTP POST values, and passes them to the FTL via `provinceValue`, `districtValue`, etc.

**Kinyarwanda province values:**
When Kinyarwanda is enabled, province `<option value="...">` uses the Kinyarwanda name (e.g., `"Umugi wa Kigali"`). A reverse map (`kinyarwandaToEnglish`) translates stored values back to English keys at runtime for child-level data lookups in the JSON tree. District through Village are unaffected.
