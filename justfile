set windows-shell := ["pwsh.exe", "-Command"]
set shell := ["bash", "-uc"]

# The location of a target development mod.
TESTMOD := "/mnt/g/MO2Skyrim/firestarter-dev"
PLUGIN_FILE := "firestarter.esp"
SPRIGGIT := "~/bin/spriggit"

# List recipes
_help:
	@just -l

# Serialize the plugin to yaml.
serialize:
	{{SPRIGGIT}} serialize --InputPath installer/core/firestarter.esp --OutputPath ./firestarter-esp/ --GameRelease SkyrimSE --PackageName Spriggit.Yaml

# Re-hydrate the plugin from yaml.
hydrate:
	cp installer/core/firestarter.esp firestarter_bak.esp
	{{SPRIGGIT}} deserialize --InputPath ./firestarter-esp --OutputPath ./installer/core/firestarter.esp

# check that all $ strings in config have matching translation strings
[unix]
check-translations:
	mcm-meta-helper --moddir installer/core check all

# Copy the built mod files to the test mod. Can use rsync to copy many files.
[unix]
install:
	echo "copying to live mod for testing..."
	rsync -a installer/core/ "{{TESTMOD}}"

[windows]
@sources:
	echo "Run this where you have bash."

[windows]
@install:
	echo "Run this where you have bash."
