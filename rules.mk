#
#	rules.mk			(C) 2007-2008, Aurélien Croc (AP²C)
#
#  Compilation rules file for SpliX
#

$(rastertoqpdl_TARGET): $(rastertoqpdl_OBJ)
	$(call printCmd, $(cmd_link))
	$(Q)g++ -o $@ $^ $(rastertoqpdl_CXXFLAGS) $(rastertoqpdl_LDFLAGS) \
		$(rastertoqpdl_LIBS)

$(pstoqpdl_TARGET): $(pstoqpdl_OBJ)
	$(call printCmd, $(cmd_link))
	$(Q)g++ -o $@ $^ $(pstoqpdl_CXXFLAGS) $(pstoqpdl_LDFLAGS) \
		$(pstoqpdl_LIBS)

.PHONY: install installcms installosx
cmd_install_raster	= INSTALL           $(rastertoqpdl_TARGET)
cmd_install_ps		= INSTALL           $(pstoqpdl_TARGET)
cmd_install_cms		= INSTALL           color profile files
install: $(rastertoqpdl_TARGET) $(pstoqpdl_TARGET)
	$(Q)mkdir -p $(DESTDIR)${CUPSFILTER}
	$(call printCmd, $(cmd_install_raster))
	$(Q)install -m 755 $(rastertoqpdl_TARGET) $(DESTDIR)${CUPSFILTER}
	$(call printCmd, $(cmd_install_ps))
	$(Q)install -m 755 $(pstoqpdl_TARGET) $(DESTDIR)${CUPSFILTER}
	$(Q)$(MAKE) --no-print-directory -C ppd install Q=$(Q) \
		DESTDIR=$(abspath $(DESTDIR)) DISABLE_JBIG=$(DISABLE_JBIG)
	@echo ""
	@echo "PLEASE INSTALL MANUALLY COLOR PROFILE FILES (CHECK INSTALL)"
	@echo "             --- Everything is done! Have fun ---"
	@echo ""

installcms:
	@if [ "$$CMSDIR" -a -d "$$CMSDIR" ]; then \
		CMSBASE=$(CUPSPROFILE)/$$MANUFACTURER; \
		mkdir -p $(DESTDIR)$$CMSBASE; \
		install -m 644 "$(CMSDIR)"/* $(DESTDIR)$$CMSBASE; \
		if [ $$? = 0 ]; then \
			echo "Color profile files has been copied."; \
		fi; \
	else \
		echo "Usage: make installcms CMSDIR=/path/to/cms" \
			"MANUFACTURER={samsung,xerox,dell}"; \
	fi

installosx: $(rastertoqpdl_TARGET) $(pstoqpdl_TARGET)
	install -m 755 $(rastertoqpdl_TARGET) $(DESTDIR)${CUPSFILTER}
	install -m 755 $(pstoqpdl_TARGET) $(DESTDIR)${CUPSFILTER}
	$(Q)$(MAKE) --no-print-directory -C ppd install Q=$(Q) \
		DESTDIR=/tmp DISABLE_JBIG=$(DISABLE_JBIG)
# Specific rules used for development and information

.PHONY: tags optionList drv ppd cleanppd
tags:
	ctags --recurse --language-force=c++ --extra=+q --fields=+i \
	      --exclude=doc --exclude=.svn * 

drv:
	@$(MAKE) --no-print-directory -C ppd/ drv DISABLE_JBIG=$(DISABLE_JBIG)
ppd:
	@$(MAKE) --no-print-directory -C ppd/ ppd DISABLE_JBIG=$(DISABLE_JBIG)
cleanppd:
	@$(MAKE) --no-print-directory -C ppd/ distclean DISABLE_JBIG=$(DISABLE_JBIG)


ifneq ($(DISABLE_JBIG),0)
JBIGSTATE := disabled
else
JBIGSTATE := enabled
endif
ifneq ($(DISABLE_THREADS),0)
THREADSSTATE := disabled
else
THREADSSTATE := enabled
endif
ifneq ($(DISABLE_BLACKOPTIM),0)
BLACKOPTIMSTATE := disabled
else
BLACKOPTIMSTATE := enabled
endif
ifeq ($(DRV_ONLY),0)
DRVSTATE := disabled
else
DRVSTATE := enabled
endif


MSG	:=    +---------------------------------------------+\n
MSG	+=    |      COMPILATION PARAMETERS SUMMARY         |\n
MSG	+=    +---------------------------------------------+\n
MSG	+=    |      THREADS     = %8s                 |\n
MSG	+=    |      THREADS Nr  = %8i                 |\n
MSG	+=    |      CACHESIZE   = %8i                 |\n
MSG	+=    |      JBIG        = %8s                 |\n
MSG	+=    |      BLACK OPTIM = %8s                 |\n
MSG	+=    |      DRV ONLY    = %8s                 |\n
MSG	+=    +---------------------------------------------+\n
MSG	+=   (Do a \"make clean\" before updating these values)\n\n
optionList:
	@printf " $(MSG)" $(THREADSSTATE) $(THREADS) $(CACHESIZE) $(JBIGSTATE) \
		$(BLACKOPTIMSTATE) $(DRVSTATE)
