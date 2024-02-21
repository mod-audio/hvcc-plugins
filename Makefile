#!/usr/bin/make -f
# Makefile for hvcc-plugins #
# ------------------------- #
# Created by falkTX
#

include dpf/Makefile.base.mk

# ---------------------------------------------------------------------------------------------------------------------
# helper macros

PLUGINS = $(subst plugins/,,$(wildcard plugins/*))

# CUSTOM_TTL = $(subst custom-ttl/,,$(wildcard custom-ttl/*))
# MODGUIS = $(subst custom-ttl/,,$(subst /modgui,,$(wildcard custom-ttl/*/modgui)))

# ---------------------------------------------------------------------------------------------------------------------
# build rules

all: pregen
# 	$(foreach p,$(CUSTOM_TTL),cp custom-ttl/${p}/*.ttl bin/${p}.lv2/;)
# 	$(foreach p,$(MODGUIS),cp -r custom-ttl/${p}/modgui bin/${p}.lv2/;)

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

build/%/Makefile: hvcc/build/lib/hvcc/__init__.py plugins/%/plugin.json plugins/%/plugin.pd
	env PYTHONPATH=$(CURDIR)/hvcc/build/lib \
	python3 ./hvcc/build/lib/hvcc/__init__.py \
		plugins/$*/plugin.pd \
		-m plugins/$*/plugin.json \
		-n "$(lastword $(subst -, ,$*))" \
		-g dpf \
		-o $(@D)

dpf/utils/lv2_ttl_generator$(APP_EXT):
	$(MAKE) -C dpf/utils/lv2-ttl-generator

hvcc/build/lib/hvcc/__init__.py:
	cd hvcc && \
	python3 -m pip install --isolated --no-cache-dir --no-input -q -r requirements.txt && \
	[ -e build ] || python3 setup.py build

# ---------------------------------------------------------------------------------------------------------------------
# cleanup

clean:
	$(MAKE) clean -C dpf/utils/lv2-ttl-generator
	rm -rf bin build hvcc/build

# ---------------------------------------------------------------------------------------------------------------------

.PHONY: plugins
