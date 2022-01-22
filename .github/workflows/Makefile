PROJECT_ROOT = ../..
BUILDDIR = $(PROJECT_ROOT)/build/medlog
FLUTTER_BUILD = $(PROJECT_ROOT)/build/app/outputs/

APK_NAME = medlog
BUILDCMD = flutter build apk $(FLAGS)
#FLAGS = --verbose
HASH = $(shell sh -c "git rev-parse --short HEAD")

# git rev-parse --short=6 HEAD  # get the hash of the current commit

all: prerequesite setup release debug
setup: cleanversioned mkoutdir

prerequesite:
	@echo "Building medlog for hash" $(HASH)

debug:
	@echo "Building debug apk"
	@$(BUILDCMD) --debug
	@mv $(FLUTTER_BUILD)/apk/debug/app-debug.apk $(BUILDDIR)/$(APK_NAME)-$(HASH)-debug.apk

release:
	@echo "Building release apk"
	@$(BUILDCMD)
	@mv $(FLUTTER_BUILD)/apk/release/app-release.apk $(BUILDDIR)/$(APK_NAME)-$(HASH)-release.apk

cleanversioned:
	@rm -rf $(BUILDDIR)

mkoutdir:
	@mkdir -p $(BUILDDIR)

clean:
	@echo "cleaning all buildfiles"
# using -f bcs rm will not cry if the dir dosnt exist
	@rm -rf $(PROJECT_ROOT)/build
	@rm -rf $(PROJECT_ROOT)/.dart_tool
