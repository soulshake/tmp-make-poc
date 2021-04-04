.DEFAULT_GOAL := final

SRCDIR = source
OUTDIR = json
FINALDIR = txt

SOURCE_FILES = $(wildcard $(SRCDIR)/*.*)

IN_JSON = $(wildcard $(SRCDIR)/*.json)
IN_YAML = $(wildcard $(SRCDIR)/*.yaml)
IN_TXT = $(wildcard $(SRCDIR)/*.txt)

YAML_OUTFILES = $(subst $(SRCDIR)/,$(OUTDIR)/,$(subst .yaml,.json,$(IN_YAML)))
JSON_OUTFILES = $(subst $(SRCDIR)/,$(OUTDIR)/,$(subst .json,.json,$(IN_JSON)))
TXT_OUTFILES = $(subst $(SRCDIR)/,$(OUTDIR)/,$(subst .txt,.json,$(IN_TXT)))

FINAL_OUTFILES = $(subst $(OUTDIR)/,$(FINALDIR)/,$(subst .json,.txt,$(YAML_OUTFILES) $(JSON_OUTFILES) $(TXT_OUTFILES)))

wat:
	@echo "-- IN_(JSON|TXT|YAML) --"
	@echo $(IN_JSON)
	@echo $(IN_TXT)
	@echo $(IN_YAML)
	@echo "--- JSON_OUTFILES ---"
	@echo $(JSON_OUTFILES)
	@echo "--- TXT_OUTFILES ---"
	@echo $(TXT_OUTFILES)
	@echo "--- YAML_OUTFILES ---"
	@echo $(YAML_OUTFILES)
	@echo "--- FINAL_OUTFILES ---"
	@echo $(FINAL_OUTFILES)


$(OUTDIR) $(FINALDIR):
	@mkdir -pv $@

$(JSON_OUTFILES): $(IN_JSON) | $(OUTDIR)
	cat source/$(@F) | jq . > $@

$(TXT_OUTFILES): $(IN_TXT) | $(OUTDIR)
	jq -R < source/$(@F:json=txt) > $@

$(YAML_OUTFILES): $(IN_YAML) | $(OUTDIR)
	yq e -j source/$(@F:json=yaml) > $@


.PHONY: intermediate
intermediate: $(JSON_OUTFILES) $(YAML_OUTFILES) $(TXT_OUTFILES)


.PHONY: final
final: $(FINAL_OUTFILES)
$(FINAL_OUTFILES): $(JSON_OUTFILES) $(YAML_OUTFILES) $(TXT_OUTFILES) | $(FINALDIR)
	cat json/$(@F:txt=json) | jq . > $@
