.DEFAULT_GOAL := final

SRCDIR = source
OUTDIR = json
FINALDIR = txt

IN_JSON = $(wildcard $(SRCDIR)/*.json)
IN_YAML = $(wildcard $(SRCDIR)/*.yaml)
IN_TXT = $(wildcard $(SRCDIR)/*.txt)

# turns e.g. "source/1.yaml" -> "1"
JSON_NAMES = $(basename $(subst $(SRCDIR)/,,$(IN_JSON)))
TXT_NAMES = $(basename $(subst $(SRCDIR)/,,$(IN_TXT)))
YAML_NAMES = $(basename $(subst $(SRCDIR)/,,$(IN_YAML)))

JSON_OUTFILES = $(subst $(SRCDIR)/,$(OUTDIR)/,$(subst .json,.json,$(IN_JSON)))
TXT_OUTFILES = $(subst $(SRCDIR)/,$(OUTDIR)/,$(subst .txt,.json,$(IN_TXT)))
YAML_OUTFILES = $(subst $(SRCDIR)/,$(OUTDIR)/,$(subst .yaml,.json,$(IN_YAML)))

FINAL_OUTFILES = $(addsuffix .txt, $(addprefix txt/, $(JSON_NAMES) $(TXT_NAMES) $(YAML_NAMES)))

wat:
	@echo "-- IN_(JSON|TXT|YAML) --"
	@echo $(IN_JSON)
	@echo $(IN_TXT)
	@echo $(IN_YAML)
	@echo "JSON_NAMES: $(JSON_NAMES)"
	@echo "TXT_NAMES: $(TXT_NAMES)"
	@echo "YAML_NAMES: $(YAML_NAMES)"
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

$(JSON_OUTFILES): json/%.json : source/%.json | $(OUTDIR)
	cat source/$(@F) | jq . > $@

$(TXT_OUTFILES): json/%.json : source/%.txt | $(OUTDIR)
	jq -R < source/$(@F:json=txt) > $@

$(YAML_OUTFILES): json/%.json : source/%.yaml | $(OUTDIR)
	yq e -j source/$(@F:json=yaml) > $@


.PHONY: final
final: $(FINAL_OUTFILES)
$(FINAL_OUTFILES): txt/%.txt : json/%.json | $(FINALDIR)
	cat json/$(@F:txt=json) | jq . > $@
