#!/usr/bin/make -f
# Makefile for hvcc-plugins #
# ------------------------- #
# Created by falkTX
#

include dpf/Makefile.base.mk

# ---------------------------------------------------------------------------------------------------------------------
# helper macros

PLUGINS = $(subst plugins/,,$(wildcard plugins/*))

CUSTOM_TTL = $(subst custom-ttl/,,$(wildcard custom-ttl/*))
MODGUIS = $(subst custom-ttl/,,$(subst /modgui,,$(wildcard custom-ttl/*/modgui)))

# ---------------------------------------------------------------------------------------------------------------------
# build rules

all: pregen
	$(foreach p,$(CUSTOM_TTL),cp custom-ttl/${p}/*.ttl bin/$(lastword $(subst -, ,${p})).lv2/;)
	$(foreach p,$(MODGUIS),cp -r custom-ttl/${p}/modgui bin/$(lastword $(subst -, ,${p})).lv2/;)

pregen: plugins dpf/utils/lv2_ttl_generator$(APP_EXT)
	@$(CURDIR)/dpf/utils/generate-ttl.sh

plugins: $(PLUGINS:%=build/%/dpf) $(PLUGINS:%=build/%/dpf-widgets) $(PLUGINS:%=build/%/Makefile)
	$(foreach p,$(PLUGINS),$(MAKE) DPF_PATH=$(CURDIR)/dpf DPF_TARGET_DIR=$(CURDIR)/bin -C build/${p} plugin;)

build/%/dpf: dpf
	-@mkdir -p build/$*
	ln -s $(abspath $<) $@

build/%/dpf-widgets: dpf-widgets
	-@mkdir -p build/$*
	ln -s $(abspath $<) $@

build/%/Makefile: plugins/%/plugin.json plugins/%/plugin.pd
	hvcc \
		plugins/$*/plugin.pd \
		-m plugins/$*/plugin.json \
		-n "$(lastword $(subst -, ,$*))" \
		-g dpf \
		-o $(@D)

dpf/utils/lv2_ttl_generator$(APP_EXT):
	$(MAKE) -C dpf/utils/lv2-ttl-generator

# ---------------------------------------------------------------------------------------------------------------------
# cleanup

clean:
	$(MAKE) clean -C dpf/utils/lv2-ttl-generator
	rm -rf bin build hvcc/build

# ---------------------------------------------------------------------------------------------------------------------

.PHONY: plugins
