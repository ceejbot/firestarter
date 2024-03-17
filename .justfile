set windows-shell := ["pwsh.exe", "-Command"]
set shell := ["bash", "-uc"]

# The location of a target development mod.
TESTMOD := "/mnt/g/MO2Skyrim/firestarter-dev"
PLUGIN_FILE := "firestarter.esp"
SPRIGGIT := "~/bin/spriggit/Spriggit.CLI"

# List recipes
_help:
	@just -l

# Serialize the plugin to yaml.
serialize:
	{{SPRIGGIT}} serialize --InputPath data/firestarter.esp --OutputPath ./firestarter-esp/ --GameRelease SkyrimSE --PackageName Spriggit.Yaml

# Re-hydrate the plugin from yaml.
hydrate:
	cp data/firestarter.esp firestarter_bak.esp
	{{SPRIGGIT}} deserialize --InputPath ./firestarter-esp --OutputPath ./data/firestarter.esp

# check that all $ strings in config have matching translation strings
[unix]
check-translations:
	mcm-meta-helper --moddir data check all

# Copy the built mod files to the test mod. Can use rsync to copy many files.
[unix]
@install:
	echo "copying to live mod for testing..."
	rsync -a data/ "{{TESTMOD}}"

[unix]
@backup:
	echo "Copying edits back from live mod..."
	rsync -a "{{TESTMOD}}/" data

[windows]
@sources:
	echo "Run this where you have bash."

[windows]
@install:
	echo "Run this where you have bash."

[windows]
@backup:
	echo "Run this where you have bash."
