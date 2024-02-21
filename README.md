hvcc-plugins
============

Collection of hvcc based audio plugins used in MOD Audio.  
Stored in a single source code repository to make it easy for contributors and MOD staff to add and maintain these plugins.

This source code repository has the following contents:

- **custom-ttl** - LV2 ttl files modified by hand, based on the generated DPF output, that adds a bit more information and meta-data to a plugin
- **dpf** - the plugin framework used to get CLAP, LV2, VST2, VST3 formats from a single implementation;  
for MOD we only care about the LV2 format for now
- **dpf-widgets** - optional, UI widgets for DPF that allow these generated plugins to include a desktop UI
- **hvcc** - the tools that convert puredata patches into C and C++ and integrates with DPF
- **plugins** - the actual plugins, 1 folder by plugin, in which we have the puredata patch(es) and the hvcc specific configuration
- **presets** - optional, LV2 presets to be included on the MOD plugin store builds of each plugin

### ADDING NEW PLUGINS

#### PLUGIN

This repository builds plugins as present in the `plugins` folder.
Each folder should follow the naming convention of "brandname-pluginame", with a single dash as separator and no spaces or special characters.

Inside each plugin folder there are at least 3 files:

- plugin.json
- plugin.pd
- README.md

The first file is meant for hvcc, it sets up branding, plugin categories and audio port count.
It is safe to copy this file to another plugin for a starting point, but then make sure to edit the fields as necessary.
The URI of the plugin **must** match the folder name in the style of "urn:hvcc:brandname:pluginname" (so keep the "urn:hvcc:" and change the rest)

Then we have the puredata entry point file as `plugin.pd`.
It can reference and include other files on this same directory, but the entry point **must have this filename**.

And finally a readme just to give some details on the plugin and any relevant information.

### BUILDING

For building you will need a POSIX-compliant compiler (GCC or Clang) plus GNU Make.  
Building is a simple as running `make` after cloning this repository, assuming you have the needed tools installed.

Note that this repository uses git submodules, so cloning with `git clone --recursive` is required.

After building you will find CLAP, LV2, VST2 and VST3 plugin builds in a newly created `./bin` directory.  
Alternatively you can download nightly builds from the [generated GitHub actions](https://github.com/moddevices/hvcc-plugins/actions/workflows/build.yml).

#### BUILDING FOR MOD

If you already have "bootstrapped" [mod-plugin-builder](https://github.com/moddevices/mod-plugin-builder) before, building for e.g. MOD Dwarf is as simple as:

```
make moddwarf
```

Change `moddwarf` to `modduo` or `modduox` if applicable.

After building, you can directly push the bundle into a MOD unit over USB by running:

```sh
make modpush
```
