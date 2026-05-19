<style>
    .rwanda-form-cell {
        display: block;
        width: 100%;
        box-sizing: border-box;
    }
    .rwanda-loc-container {
        width: 100%;
        margin-top: 5px;
    }
    /* Group = one field + its error message; this is the flex/grid item */
    .rw-field-group {
        display: flex;
        flex-direction: column;
        margin-bottom: 8px;
    }
    /* Each select is wrapped so the asterisk can sit flush to its right */
    .rw-field-wrapper {
        display: flex;
        align-items: center;
    }
    .rw-field-wrapper select {
        flex: 1;
        padding: 5px;
        box-sizing: border-box;
    }
    .rw-required-star {
        color: #cc0000;
        font-weight: bold;
        font-size: 16px;
        margin-left: 6px;
        flex-shrink: 0;
        line-height: 1;
    }
    .rw-error-msg {
        color: #cc0000;
        font-size: 12px;
        margin-top: 3px;
        min-height: 0;
    }
    /* Layout Variants — target the group, not the inner wrapper */
    .rwanda-loc-horizontal {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
        align-items: flex-start;
    }
    .rwanda-loc-horizontal .rw-field-group {
        flex: 1;
        min-width: 150px;
        margin-bottom: 0;
    }
    .rwanda-loc-grid2 {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 10px;
    }
    .rwanda-loc-grid2 .rw-field-group {
        margin-bottom: 0;
    }
    .rwanda-loc-grid3 {
        display: grid;
        grid-template-columns: 1fr 1fr 1fr;
        gap: 10px;
    }
    .rwanda-loc-grid3 .rw-field-group {
        margin-bottom: 0;
    }
    .rwanda-loc-hidden {
        display: none !important;
    }
</style>

<div class="form-cell rwanda-form-cell" ${elementMetaData!}>
    <label class="label">${(element.properties.label)!''}</label>
    <div class="form-cell-value">
        <#assign stopLevel    = (element.properties.stopLevel)!'village'>
        <#assign isProvinceRequired = ((element.properties.requiredProvince)!'') == "true">
        <#assign isDistrictRequired = ((element.properties.requiredDistrict)!'') == "true">
        <#assign isSectorRequired   = ((element.properties.requiredSector)!'') == "true">
        <#assign isCellRequired     = ((element.properties.requiredCell)!'') == "true">
        <#assign isVillageRequired  = ((element.properties.requiredVillage)!'') == "true">
        <#assign stepped      = ((element.properties.interaction)!'standard') == "stepped">
        <#assign layoutClass  = "">
        <#if element.properties.layout??>
            <#if element.properties.layout == "horizontal">
                <#assign layoutClass = "rwanda-loc-horizontal">
            <#elseif element.properties.layout == "grid2">
                <#assign layoutClass = "rwanda-loc-grid2">
            <#elseif element.properties.layout == "grid3">
                <#assign layoutClass = "rwanda-loc-grid3">
            </#if>
        </#if>

        <#assign eid            = element.properties.id>
        <#assign districtFieldId = ((element.properties.districtId)?has_content)?then(element.properties.districtId, eid + "_district")>
        <#assign sectorFieldId   = ((element.properties.sectorId)?has_content)?then(element.properties.sectorId,     eid + "_sector")>
        <#assign cellFieldId     = ((element.properties.cellId)?has_content)?then(element.properties.cellId,         eid + "_cell")>
        <#assign villageFieldId  = ((element.properties.villageId)?has_content)?then(element.properties.villageId,   eid + "_village")>
        <#assign useKinyarwanda  = ((element.properties.useKinyarwanda)!'') == "true">

        <#-- Province hidden input -->
        <input type="hidden" name="${eid}" id="${eid}" value="${(provinceValue)!''?html}">

        <#-- Sub-level hidden inputs -->
        <#if stopLevel != "province">
        <input type="hidden" name="${districtFieldId}" id="_rw_d_${eid}" value="${(districtValue)!''?html}">
        </#if>
        <#if stopLevel != "province" && stopLevel != "district">
        <input type="hidden" name="${sectorFieldId}" id="_rw_s_${eid}" value="${(sectorValue)!''?html}">
        </#if>
        <#if stopLevel != "province" && stopLevel != "district" && stopLevel != "sector">
        <input type="hidden" name="${cellFieldId}" id="_rw_c_${eid}" value="${(cellValue)!''?html}">
        </#if>
        <#if stopLevel == "village">
        <input type="hidden" name="${villageFieldId}" id="_rw_v_${eid}" value="${(villageValue)!''?html}">
        </#if>

        <div class="rwanda-loc-container ${layoutClass}" id="rw-cont-${eid}">

            <#-- Province: group wraps wrapper + error so they stay together in flex/grid -->
            <div class="rw-field-group">
                <div class="rw-field-wrapper">
                    <select id="p_${eid}" data-level="province"><option value=""></option></select>
                    <#if isProvinceRequired><span class="rw-required-star">*</span></#if>
                </div>
                <div class="rw-error-msg" id="rw-err-p_${eid}"></div>
            </div>

            <#-- District -->
            <#if stopLevel != "province">
            <div class="rw-field-group<#if stepped> rwanda-loc-hidden</#if>" id="wrap_d_${eid}">
                <div class="rw-field-wrapper">
                    <select id="d_${eid}" data-level="district" disabled><option value=""></option></select>
                    <#if isDistrictRequired><span class="rw-required-star">*</span></#if>
                </div>
                <div class="rw-error-msg" id="rw-err-d_${eid}"></div>
            </div>
            </#if>

            <#-- Sector -->
            <#if stopLevel != "province" && stopLevel != "district">
            <div class="rw-field-group<#if stepped> rwanda-loc-hidden</#if>" id="wrap_s_${eid}">
                <div class="rw-field-wrapper">
                    <select id="s_${eid}" data-level="sector" disabled><option value=""></option></select>
                    <#if isSectorRequired><span class="rw-required-star">*</span></#if>
                </div>
                <div class="rw-error-msg" id="rw-err-s_${eid}"></div>
            </div>
            </#if>

            <#-- Cell -->
            <#if stopLevel != "province" && stopLevel != "district" && stopLevel != "sector">
            <div class="rw-field-group<#if stepped> rwanda-loc-hidden</#if>" id="wrap_c_${eid}">
                <div class="rw-field-wrapper">
                    <select id="c_${eid}" data-level="cell" disabled><option value=""></option></select>
                    <#if isCellRequired><span class="rw-required-star">*</span></#if>
                </div>
                <div class="rw-error-msg" id="rw-err-c_${eid}"></div>
            </div>
            </#if>

            <#-- Village -->
            <#if stopLevel == "village">
            <div class="rw-field-group<#if stepped> rwanda-loc-hidden</#if>" id="wrap_v_${eid}">
                <div class="rw-field-wrapper">
                    <select id="v_${eid}" data-level="village" disabled><option value=""></option></select>
                    <#if isVillageRequired><span class="rw-required-star">*</span></#if>
                </div>
                <div class="rw-error-msg" id="rw-err-v_${eid}"></div>
            </div>
            </#if>

        </div>

    </div>
</div>

<script>
(function() {
    var id = "${eid}";
    var ns = "RW_" + id.replace(/[^a-z0-9]/gi, '_');

    if (window[ns] && window[ns].destroy) window[ns].destroy();

    var kinyarwandaNames = {
        "Kigali City":       "Umugi wa Kigali",
        "Eastern Province":  "Intara y'Iburasirazuba",
        "Western Province":  "Intara y'Iburengerazuba",
        "Southern Province": "Intara y'Amajyepfo",
        "Northern Province": "Intara y'Amajyaruguru"
    };
    var useKinyarwanda = ${useKinyarwanda?string('true','false')};

    // Reverse map: Kinyarwanda name → English key (needed for data lookups)
    var kinyarwandaToEnglish = {};
    Object.keys(kinyarwandaNames).forEach(function(en) {
        kinyarwandaToEnglish[kinyarwandaNames[en]] = en;
    });
    // Translate a province value (may be Kinyarwanda or English) to the English
    // key used in the location JSON tree.
    function toEnglishKey(v) {
        if (!v) return v;
        return (useKinyarwanda && kinyarwandaToEnglish[v]) ? kinyarwandaToEnglish[v] : v;
    }

    var rwReqConfig = {
        p: { req: ${isProvinceRequired?string('true','false')}, msg: "${((element.properties.requiredMessage)!'This field is required')?js_string}" },
        d: { req: ${isDistrictRequired?string('true','false')}, msg: "${((element.properties.requiredMessageDistrict)!'This field is required')?js_string}" },
        s: { req: ${isSectorRequired?string('true','false')},   msg: "${((element.properties.requiredMessageSector)!'This field is required')?js_string}" },
        c: { req: ${isCellRequired?string('true','false')},     msg: "${((element.properties.requiredMessageCell)!'This field is required')?js_string}" },
        v: { req: ${isVillageRequired?string('true','false')},  msg: "${((element.properties.requiredMessageVillage)!'This field is required')?js_string}" }
    };
    // Fix empty messages to default
    ['p','d','s','c','v'].forEach(function(k) {
        if (!rwReqConfig[k].msg) rwReqConfig[k].msg = 'This field is required';
    });
    // True when server rejected a previous submission — activates error display on re-render
    var hasServerError = ${(error?? && error != "")?string('true','false')};

    window[ns] = {
        data: ${locationData},
        mode: "${(element.properties.interaction)!'standard'}",
        submitted: false,

        init: function() {
            var self = this;
            this.p = document.getElementById("p_" + id);
            this.d = document.getElementById("d_" + id);
            this.s = document.getElementById("s_" + id);
            this.c = document.getElementById("c_" + id);
            this.v = document.getElementById("v_" + id);
            this.h = document.getElementById(id);

            if (!this.p) return;

            this.p.onchange = function() { self.update('p', this.value); };
            if (this.d) this.d.onchange = function() { self.update('d', this.value); };
            if (this.s) this.s.onchange = function() { self.update('s', this.value); };
            if (this.c) this.c.onchange = function() { self.update('c', this.value); };
            if (this.v) this.v.onchange = function() { self.persist(); };

            this.p.innerHTML = '<option value=""></option>';
            Object.keys(this.data).forEach(function(k) {
                var display = useKinyarwanda && kinyarwandaNames[k] ? kinyarwandaNames[k] : k;
                // value = Kinyarwanda when enabled so the saved DB column stores Kinyarwanda
                self.p.add(new Option(display, display));
            });

            var dh = document.getElementById("_rw_d_" + id);
            var sh = document.getElementById("_rw_s_" + id);
            var ch = document.getElementById("_rw_c_" + id);
            var vh = document.getElementById("_rw_v_" + id);

            if (this.h.value) {
                this.p.value = this.h.value;
                self.update('p', this.h.value, true);
                if (dh && dh.value && this.d) { this.d.value = dh.value; self.update('d', dh.value, true); }
                if (sh && sh.value && this.s) { this.s.value = sh.value; self.update('s', sh.value, true); }
                if (ch && ch.value && this.c) { this.c.value = ch.value; self.update('c', ch.value, true); }
                if (vh && vh.value && this.v) { this.v.value = vh.value; }
            }

            // Re-render after server rejection: show errors at correct positions
            if (hasServerError) {
                this.submitted = true;
                this.showInlineErrors(false);
            }

            this.hookSubmit();
            this.syncVisible();
        },

        // Hook the submit button to show errors immediately when Save is clicked.
        // We do NOT prevent or stop the submission — server-side selfValidate() is the
        // real gate. Blocking here causes Joget's "Please wait..." overlay to hang
        // because Joget shows the overlay via an inline onclick that fires before any
        // addEventListener, so our capture handler can't undo it.
        hookSubmit: function() {
            var self = this;
            var el = document.getElementById(id);
            var formEl = el;
            while (formEl && formEl.tagName !== 'FORM') formEl = formEl.parentElement;
            if (!formEl) return;

            var handler = function() {
                self.submitted = true;
                self.showInlineErrors(true);
            };

            formEl.addEventListener('submit', handler, true);
            var btns = formEl.querySelectorAll('[type="submit"]');
            for (var i = 0; i < btns.length; i++) {
                btns[i].addEventListener('click', handler, true);
            }
        },

        update: function(lvl, v, skipPersist) {
            var self = this;
            if (lvl === 'p') {
                if (this.d) {
                    this.d.innerHTML = '<option value=""></option>';
                    var ek = toEnglishKey(v);
                    if (ek && this.data[ek]) Object.keys(this.data[ek]).forEach(function(k) { self.d.add(new Option(k, k)); });
                    this.d.disabled = !v;
                }
                this.reset(['s', 'c', 'v']);
            } else if (lvl === 'd') {
                if (this.s) {
                    this.s.innerHTML = '<option value=""></option>';
                    var pek = toEnglishKey(this.p.value);
                    if (v && this.data[pek] && this.data[pek][v]) Object.keys(this.data[pek][v]).forEach(function(k) { self.s.add(new Option(k, k)); });
                    this.s.disabled = !v;
                }
                this.reset(['c', 'v']);
            } else if (lvl === 's') {
                if (this.c) {
                    this.c.innerHTML = '<option value=""></option>';
                    var pek = toEnglishKey(this.p.value), dv = this.d.value;
                    if (v && this.data[pek][dv] && this.data[pek][dv][v]) Object.keys(this.data[pek][dv][v]).forEach(function(k) { self.c.add(new Option(k, k)); });
                    this.c.disabled = !v;
                }
                this.reset(['v']);
            } else if (lvl === 'c') {
                if (this.v) {
                    this.v.innerHTML = '<option value=""></option>';
                    var pek = toEnglishKey(this.p.value), dv = this.d.value, sv = this.s.value;
                    if (v && this.data[pek][dv][sv] && this.data[pek][dv][sv][v]) this.data[pek][dv][sv][v].forEach(function(k) { self.v.add(new Option(k, k)); });
                    this.v.disabled = !v;
                }
            }
            if (!skipPersist) this.persist();
            else this.showInlineErrors(false);
            this.syncVisible();
        },

        reset: function(lvls) {
            var self = this;
            lvls.forEach(function(l) {
                if (self[l]) { self[l].innerHTML = '<option value=""></option>'; self[l].disabled = true; }
            });
        },

        syncVisible: function() {
            if (this.mode !== 'stepped') return;
            var pairs = [
                [this.p, document.getElementById('wrap_d_' + id)],
                [this.d, document.getElementById('wrap_s_' + id)],
                [this.s, document.getElementById('wrap_c_' + id)],
                [this.c, document.getElementById('wrap_v_' + id)]
            ];
            pairs.forEach(function(pair) {
                var parent = pair[0], wrap = pair[1];
                if (!wrap) return;
                if (parent && parent.value) wrap.classList.remove('rwanda-loc-hidden');
                else wrap.classList.add('rwanda-loc-hidden');
            });
        },

        persist: function() {
            this.h.value = this.p ? this.p.value : "";
            var dh = document.getElementById("_rw_d_" + id);
            var sh = document.getElementById("_rw_s_" + id);
            var ch = document.getElementById("_rw_c_" + id);
            var vh = document.getElementById("_rw_v_" + id);
            if (dh) dh.value = this.d ? this.d.value : "";
            if (sh) sh.value = this.s ? this.s.value : "";
            if (ch) ch.value = this.c ? this.c.value : "";
            if (vh) vh.value = this.v ? this.v.value : "";
            this.showInlineErrors(false);
        },

        // Show inline errors.
        //   allAtOnce=true  — on submit: show ALL required-but-empty fields at once.
        //   allAtOnce=false — while navigating: gate each level on its parent so errors
        //                     reduce one-by-one as the user works down the chain.
        // Nothing shows until this.submitted is true.
        showInlineErrors: function(allAtOnce) {
            if (!this.submitted) return;
            function setErr(key, show, msg) {
                var el = document.getElementById("rw-err-" + key + "_" + id);
                if (!el) return;
                el.textContent = show ? msg : "";
            }
            var pv = this.p ? this.p.value : "";
            var dv = this.d ? this.d.value : "";
            var sv = this.s ? this.s.value : "";
            var cv = this.c ? this.c.value : "";
            var vv = this.v ? this.v.value : "";

            setErr("p", rwReqConfig.p.req && !pv, rwReqConfig.p.msg);
            setErr("d", rwReqConfig.d.req && !dv && (allAtOnce || !!pv), rwReqConfig.d.msg);
            setErr("s", rwReqConfig.s.req && !sv && (allAtOnce || !!dv), rwReqConfig.s.msg);
            setErr("c", rwReqConfig.c.req && !cv && (allAtOnce || !!sv), rwReqConfig.c.msg);
            setErr("v", rwReqConfig.v.req && !vv && (allAtOnce || !!cv), rwReqConfig.v.msg);
        },

        destroy: function() {
            this.p = this.d = this.s = this.c = this.v = this.h = null;
        }
    };

    window[ns].init();
})();
</script>
