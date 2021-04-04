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
	@echo $(JSON_NAMES)
	@echo $(TXT_NAMES)
	@echo $(YAML_NAMES)
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
# Result of running 'make' after changing e.g. source/3.yaml:
# $ make
# yq e -j source/1.yaml > json/1.json
# cat json/1.json | jq . > txt/1.txt
# yq e -j source/2.yaml > json/2.json
# cat json/2.json | jq . > txt/2.txt
# yq e -j source/3.yaml > json/3.json
# cat json/3.json | jq . > txt/3.txt


# Alternative final rule (more readable, but causes all intermediate targets to be remade?)
# $(FINAL_OUTFILES): $(JSON_OUTFILES) $(YAML_OUTFILES) $(TXT_OUTFILES) | $(FINALDIR)

# Result of running 'make' after changing e.g. source/3.yaml
# $ make
# yq e -j source/1.yaml > json/1.json
# yq e -j source/2.yaml > json/2.json
# yq e -j source/3.yaml > json/3.json
# cat json/4.json | jq . > txt/4.txt
# cat json/5.json | jq . > txt/5.txt
# cat json/wooga.json | jq . > txt/wooga.txt
# cat json/1.json | jq . > txt/1.txt
# cat json/2.json | jq . > txt/2.txt
# cat json/3.json | jq . > txt/3.txt
