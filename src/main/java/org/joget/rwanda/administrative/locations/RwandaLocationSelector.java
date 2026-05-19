package org.joget.rwanda.administrative.locations;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import org.joget.apps.app.service.AppUtil;
import org.joget.apps.form.lib.HiddenField;
import org.joget.apps.form.model.Element;
import org.joget.apps.form.model.FormBuilderPaletteElement;
import org.joget.apps.form.model.FormData;
import org.joget.apps.form.model.FormRow;
import org.joget.apps.form.model.FormRowSet;
import org.joget.apps.form.service.FormUtil;

public class RwandaLocationSelector extends Element implements FormBuilderPaletteElement {

    private static final String[] LEVEL_PROPS  = {"districtId", "sectorId", "cellId", "villageId"};
    private static final String[] LEVEL_SUFFIX = {"district",   "sector",   "cell",   "village"};
    private static final List<String> LEVEL_ORDER =
            Arrays.asList("province", "district", "sector", "cell", "village");

    // ── Shadow child element ─────────────────────────────────────────────────────
    //
    // Extends HiddenField so Joget's List Builder / filter palette recognise each
    // sub-level as a real form field.  selfValidate is no-op (parent handles all
    // validation) and continueValidation=false prevents recursion into non-existent
    // grandchildren — both stop the NPE in FormUtil.executeValidators.

    private static final class ShadowHiddenField extends HiddenField {
        @Override
        public Boolean selfValidate(FormData formData) {
            return Boolean.TRUE; // parent's selfValidate handles all required checks
        }
        @Override
        public boolean continueValidation(FormData formData) {
            // Explicit false: skip validator + selfValidate + child recursion for
            // this shadow element. Do NOT call super (which calls isHidden() and
            // may NPE on a context-less dynamically created element).
            return false;
        }
        @Override
        public FormRowSet formatData(FormData formData) {
            return new FormRowSet(); // parent's formatData saves all values
        }
    }

    // ── Joget element identity ──────────────────────────────────────────────────

    @Override public String getName()               { return "Rwanda Administrative Location Selector"; }
    @Override public String getVersion()            { return "1.0.0"; }
    @Override public String getDescription()        { return "Selects Rwanda Province, District, Sector, Cell, and Village."; }
    @Override public String getLabel()              { return "Rwanda Administrative Location Selector"; }
    @Override public String getClassName()          { return getClass().getName(); }
    @Override public String getFormBuilderCategory(){ return "Custom Fields"; }
    @Override public int    getFormBuilderPosition(){ return 100; }
    @Override public String getFormBuilderIcon()    { return null; }
    @Override public String getFormBuilderTemplate(){ return "<label>Rwanda Administrative Location Selector</label>"; }

    @Override
    public String getPropertyOptions() {
        return AppUtil.readPluginResource(getClass().getName(),
                "/properties/rwandaLocationSelector.json", null, true, null);
    }

    @Override
    public String getDefaultPropertyValues() {
        return "[{\"name\":\"label\",\"value\":\"Select Location\"}" +
               ",{\"name\":\"layout\",\"value\":\"vertical\"}" +
               ",{\"name\":\"interaction\",\"value\":\"standard\"}" +
               ",{\"name\":\"stopLevel\",\"value\":\"village\"}]";
    }

    // ── Child elements (sub-level fields) ───────────────────────────────────────

    @Override
    public Collection getChildren() {
        List<Element> children = new ArrayList<>();

        Collection existing = super.getChildren();
        if (existing != null) {
            for (Object e : existing) {
                if (e != null) children.add((Element) e); // guard against null entries
            }
        }

        String elementId = getPropertyString(FormUtil.PROPERTY_ID);
        int stopIndex    = stopLevelIndex();

        for (int i = 0; i < LEVEL_PROPS.length; i++) {
            if ((i + 1) > stopIndex) break;

            String fieldId = resolvedFieldId(i, elementId);
            String label   = Character.toUpperCase(LEVEL_SUFFIX[i].charAt(0))
                             + LEVEL_SUFFIX[i].substring(1);

            ShadowHiddenField hf = new ShadowHiddenField();
            hf.setProperty(FormUtil.PROPERTY_ID, fieldId);
            hf.setProperty("label", label);
            children.add(hf);
        }

        return children;
    }

    // ── Rendering ───────────────────────────────────────────────────────────────

    @Override
    public String renderTemplate(FormData formData, Map dataModel) {
        String locationDataJson = AppUtil.readPluginResource(
                getClass().getName(), "/rwanda-locations.json", null, false, null);
        dataModel.put("locationData", locationDataJson);
        dataModel.put("element", this);

        // All values read from the request-parameter store so selections persist
        // across validation failures (Joget's 'value' FTL var uses the load-binder
        // store, which is empty for new records on re-render after failed submission).
        String elementId = getPropertyString(FormUtil.PROPERTY_ID);
        dataModel.put("provinceValue", coalesce(getParam(formData, elementId)));
        String[] modelKeys  = {"districtValue",  "sectorValue",  "cellValue",  "villageValue"};
        String[] errorKeys  = {"districtError",  "sectorError",  "cellError",  "villageError"};
        for (int i = 0; i < LEVEL_PROPS.length; i++) {
            String fieldId = resolvedFieldId(i, elementId);
            dataModel.put(modelKeys[i], coalesce(getParam(formData, fieldId)));
            // Read per-field errors so the FTL can show them next to the right dropdown
            String err = (formData != null) ? formData.getFormError(fieldId) : null;
            dataModel.put(errorKeys[i], err != null ? err : "");
        }

        return FormUtil.generateElementHtml(this, formData, "rwandaLocationSelector.ftl", dataModel);
    }

    // ── Data persistence ────────────────────────────────────────────────────────

    @Override
    public FormRowSet formatData(FormData formData) {
        FormRowSet rowSet = new FormRowSet();
        FormRow row = new FormRow();

        String id = getPropertyString(FormUtil.PROPERTY_ID);
        row.put(id, coalesce(getParam(formData, id)));

        int stopIndex = stopLevelIndex();
        for (int i = 0; i < LEVEL_PROPS.length; i++) {
            if ((i + 1) > stopIndex) break;
            String fieldId = resolvedFieldId(i, id);
            row.put(fieldId, coalesce(getParam(formData, fieldId)));
        }

        rowSet.add(row);
        return rowSet;
    }

    // ── Validation ──────────────────────────────────────────────────────────────

    @Override
    public Boolean selfValidate(FormData formData) {
        String id = getPropertyString(FormUtil.PROPERTY_ID);

        if ("true".equals(getPropertyString("requiredProvince")) && coalesce(getParam(formData, id)).isEmpty()) {
            String msg = getPropertyString("requiredMessage");
            formData.addFormError(id, msg.isEmpty() ? "This field is required" : msg);
            return false;
        }

        int stopIndex = stopLevelIndex();
        String[] reqProps = {"requiredDistrict", "requiredSector", "requiredCell", "requiredVillage"};
        String[] msgProps = {"requiredMessageDistrict", "requiredMessageSector", "requiredMessageCell", "requiredMessageVillage"};
        String[] defaults  = {"This field is required", "This field is required", "This field is required", "This field is required"};

        for (int i = 0; i < LEVEL_PROPS.length; i++) {
            if ((i + 1) > stopIndex) break;
            if (!"true".equals(getPropertyString(reqProps[i]))) continue;
            String fieldId = resolvedFieldId(i, id);
            if (coalesce(getParam(formData, fieldId)).isEmpty()) {
                String msg = getPropertyString(msgProps[i]);
                // Store under the parent element ID so Joget's AJAX error handler
                // can locate the element; JS showInlineErrors() positions the
                // message next to the correct dropdown client-side.
                formData.addFormError(id, msg.isEmpty() ? defaults[i] : msg);
                return false;
            }
        }

        return Boolean.TRUE;
    }

    // ── Helpers ─────────────────────────────────────────────────────────────────

    private int stopLevelIndex() {
        String stopLevel = getPropertyString("stopLevel");
        if (stopLevel == null || stopLevel.isEmpty()) stopLevel = "village";
        int idx = LEVEL_ORDER.indexOf(stopLevel);
        return idx < 0 ? LEVEL_ORDER.size() - 1 : idx;
    }

    private String resolvedFieldId(int i, String elementId) {
        String configured = getPropertyString(LEVEL_PROPS[i]);
        return (configured != null && !configured.isEmpty())
                ? configured
                : elementId + "_" + LEVEL_SUFFIX[i];
    }

    private String getParam(FormData formData, String name) {
        return (formData != null) ? formData.getRequestParameter(name) : null;
    }

    private String coalesce(String val) {
        return val != null ? val : "";
    }
}
