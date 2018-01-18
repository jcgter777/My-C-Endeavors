#----------------------------
# Makefile
#----------------------------

RELEASE_NAME := CEdev

# common/os specific things
ifeq ($(OS),Windows_NT)
SHELL      = cmd.exe
NATIVEPATH = $(subst /,\,$(1))
WINPATH    = $(NATIVEPATH)
WINCHKPATH = $(NATIVEPATH)
WINCHKDIR := if exist
WINNCHKDIR:= if not exist
RM         = del /f 2>nul
RMDIR      = rmdir /s /q
MKDIR      = mkdir
PREFIX    ?= C:
INSTALLLOC := $(call NATIVEPATH,$(DESTDIR)$(PREFIX))
CP         = copy /y
EXMPL_DIR  = $(call NATIVEPATH,$(INSTALLLOC)/CEdev/examples)
CP_EXMPLS  = (if not exist "$(EXMPL_DIR)" mkdir $(EXMPL_DIR)) && xcopy /y /s /e $(call NATIVEPATH,$(CURDIR)/examples) $(EXMPL_DIR)
CPDIR      = xcopy /y /s /e
ARCH       = makensis.exe /DDIST_PATH=$(call NATIVEPATH,$(DESTDIR)$(PREFIX)/CEdev) $(call NATIVEPATH,$(CURDIR)\tools\installer\installer.nsi) && \
             $(WINNCHKDIR) "release" $(MKDIR) "release" && move /y tools\installer\CEdev.exe release\\
else
NATIVEPATH = $(subst \,/,$(1))
WINPATH    = $(shell winepath --windows $(1))
RM         = rm -f
MKDIR      = mkdir -p
RMDIR      = rm -rf
PREFIX    ?= $(HOME)
INSTALLLOC := $(call NATIVEPATH,$(DESTDIR)$(PREFIX))
CP         = cp
CPDIR      = cp -r
CP_EXMPLS  = $(CPDIR) $(call NATIVEPATH,$(CURDIR)/examples) $(call NATIVEPATH,$(INSTALLLOC)/CEdev)
ARCH       = cd $(INSTALLLOC) && tar -czf $(RELEASE_NAME).tar.gz $(RELEASE_NAME) ; \
             cd $(CURDIR) && $(MKDIR) release && mv -f $(INSTALLLOC)/$(RELEASE_NAME).tar.gz release
CHMOD      = find $(BIN) -name "*.exe" -exec chmod +x {} \;
endif

TOOLSDIR   := $(call NATIVEPATH,$(CURDIR)/tools)
SRCDIR     := $(call NATIVEPATH,$(CURDIR)/src)
FASMGDIR   := $(call NATIVEPATH,$(TOOLSDIR)/fasmg)
CONVHEXDIR := $(call NATIVEPATH,$(TOOLSDIR)/convhex)
CONVPNGDIR := $(call NATIVEPATH,$(TOOLSDIR)/convpng)
CONVTILDIR := $(call NATIVEPATH,$(TOOLSDIR)/convtile)
CEDIR      := $(call NATIVEPATH,$(SRCDIR)/ce)
STDDIR     := $(call NATIVEPATH,$(SRCDIR)/std)
STARTDIR   := $(call NATIVEPATH,$(SRCDIR)/startup)

FASMG      := $(call NATIVEPATH,$(FASMGDIR)/fasmg)
CONVHEX    := $(call NATIVEPATH,$(CONVHEXDIR)/convhex)
CONVPNG    := $(call NATIVEPATH,$(CONVPNGDIR)/convpng)
CONVTILE   := $(call NATIVEPATH,$(CONVTILDIR)/convtile)

ifeq ($(OS),Windows_NT)
FASMG      := $(call NATIVEPATH,$(FASMGDIR)/fasmg.exe)
CONVHEX    := $(call NATIVEPATH,$(CONVHEXDIR)/convhex.exe)
CONVPNG    := $(call NATIVEPATH,$(CONVPNGDIR)/convpng.exe)
CONVTILE   := $(call NATIVEPATH,$(CONVTILDIR)/convtile.exe)
endif

BIN        := $(call NATIVEPATH,$(TOOLSDIR)/zds)

GRAPHXDIR  := $(call NATIVEPATH,$(SRCDIR)/graphx)
KEYPADCDIR := $(call NATIVEPATH,$(SRCDIR)/keypadc)
FILEIOCDIR := $(call NATIVEPATH,$(SRCDIR)/fileioc)
TEMPLATEDIR:= $(call NATIVEPATH,$(SRCDIR)/lib-template)

CEDEVDIR   := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME))
INSTALLBIN := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/bin)
INSTALLINC := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/include)
INSTALLLIB := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib)
INSTALLLS  := $(call NATIVEPATH,$(INSTALLLOC)/$(RELEASE_NAME)/lib/shared)
DIRS       := $(INSTALLINC) $(INSTALLINC)/compat $(INSTALLBIN) $(INSTALLLIB)
DIRS       := $(call NATIVEPATH,$(DIRS))

all: fasmg $(CONVHEX) $(CONVPNG) $(CONVTILE) graphx fileioc keypadc libload ce std startup
	@echo "Toolchain built."

clean: clean-graphx clean-fileioc clean-keypadc clean-ce clean-std clean-libload clean-startup
	$(MAKE) -C $(FASMGDIR) clean
	$(MAKE) -C $(CONVHEXDIR) clean
	$(MAKE) -C $(CONVPNGDIR) clean
	$(MAKE) -C $(CONVTILDIR) clean
	$(WINCHKDIR) $(call WINCHKPATH,release) $(RMDIR) release
	$(WINCHKDIR) $(call WINCHKPATH,doxygen) $(RMDIR) doxygen

#----------------------------
# tool rules
#----------------------------
fasmg:
	$(MAKE) -C $(FASMGDIR)
$(CONVHEX):
	$(MAKE) -C $(CONVHEXDIR)
$(CONVPNG):
	$(MAKE) -C $(CONVPNGDIR)
$(CONVTILE):
	$(MAKE) -C $(CONVTILDIR)
#----------------------------

#----------------------------
# ce rules
#----------------------------
ce:
	$(MAKE) -C $(CEDIR) BIN=$(BIN)
clean-ce:
	$(MAKE) -C $(CEDIR) clean
#----------------------------

#----------------------------
# std rules
#----------------------------
std:
	$(MAKE) -C $(STDDIR) BIN=$(BIN)
clean-std:
	$(MAKE) -C $(STDDIR) clean
#----------------------------

#----------------------------
# template rules
#----------------------------
template: $(FASMG)
	$(MAKE) -C $(TEMPLATEDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-template:
	$(MAKE) -C $(TEMPLATEDIR) clean
#----------------------------

#----------------------------
# graphx rules
#----------------------------
graphx: $(FASMG)
	$(MAKE) -C $(GRAPHXDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-graphx:
	$(MAKE) -C $(GRAPHXDIR) clean
#----------------------------

#----------------------------
# fileioc rules
#----------------------------
fileioc: $(FASMG)
	$(MAKE) -C $(FILEIOCDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-fileioc:
	$(MAKE) -C $(FILEIOCDIR) clean
#----------------------------

#----------------------------
# keypadc rules
#----------------------------
keypadc: $(FASMG)
	$(MAKE) -C $(KEYPADCDIR) FASMG=$(FASMG) BIN=$(BIN)
clean-keypadc:
	$(MAKE) -C $(KEYPADCDIR) clean
#----------------------------

#----------------------------
# libload rules
#----------------------------
libload: $(FASMG)
	cd $(call NATIVEPATH,src/sub/libload) && $(FASMG) libload.asm LibLoad.8xv
clean-libload:
	$(RM) $(call NATIVEPATH,src/sub/libload/LibLoad.8xv)
#----------------------------

#----------------------------
# startup rules
#----------------------------
startup:
	$(MAKE) -C $(STARTDIR) BIN=$(BIN)
clean-startup:
	$(MAKE) -C $(STARTDIR) clean
#----------------------------

#----------------------------
# uninstall rule
#----------------------------
uninstall:
	$(WINCHKDIR) $(call WINCHKPATH,$(INSTALLLOC)/CEdev) $(RMDIR) $(call NATIVEPATH,$(INSTALLLOC)/CEdev)
#----------------------------

#----------------------------
# install rule
#----------------------------
install: $(DIRS) chmod
	$(CP_EXMPLS)
	$(CP) $(call NATIVEPATH,$(SRCDIR)/startup/*.src) $(call NATIVEPATH,$(INSTALLLIB))
	$(CP) $(call NATIVEPATH,$(SRCDIR)/core_makefile) $(call NATIVEPATH,$(INSTALLINC)/.makefile)
	$(CP) $(FASMG) $(INSTALLBIN)
	$(CP) $(CONVHEX) $(INSTALLBIN)
	$(CP) $(CONVPNG) $(INSTALLBIN)
	$(CP) $(CONVTILE) $(INSTALLBIN)
	$(CP) $(call NATIVEPATH,$(BIN)/*) $(INSTALLBIN)
	$(MAKE) -C $(GRAPHXDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(KEYPADCDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(FILEIOCDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(CEDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(MAKE) -C $(STDDIR) install PREFIX=$(PREFIX) DESTDIR=$(DESTDIR)
	$(CPDIR) $(call NATIVEPATH,$(SRCDIR)/sub/compat) $(call NATIVEPATH,$(INSTALLINC))

$(DIRS):
	$(WINNCHKDIR) $(call WINCHKPATH,$(INSTALLBIN)) $(MKDIR) $(INSTALLBIN)
	$(WINNCHKDIR) $(call WINCHKPATH,$(INSTALLLIB)) $(MKDIR) $(INSTALLLIB)
	$(WINNCHKDIR) $(call WINCHKPATH,$(INSTALLINC)) $(MKDIR) $(INSTALLINC)
	$(WINNCHKDIR) $(call WINCHKPATH,$(INSTALLLS)) $(MKDIR) $(INSTALLLS)

chmod:
	$(CHMOD)
#----------------------------

#----------------------------
# release rule
#----------------------------
dist: release
release: install
	$(ARCH)
#----------------------------

#----------------------------
# libraries release rules
#----------------------------
dist-libs: release-libs
release-libs: clibraries
	$(CP) $(call NATIVEPATH,src/graphx/GRAPHX.8xv) $(call NATIVEPATH,clibraries/graphx.8xv)
	$(CP) $(call NATIVEPATH,src/fileioc/FILEIOC.8xv) $(call NATIVEPATH,clibraries/fileioc.8xv)
	$(CP) $(call NATIVEPATH,src/keypadc/KEYPADC.8xv) $(call NATIVEPATH,clibraries/keypadc.8xv)
	$(CP) $(call NATIVEPATH,src/sub/libload/LibLoad.8xv) $(call NATIVEPATH,clibraries/libload.8xv)
clibraries:
	$(WINNCHKDIR) $(call WINCHKPATH,clibraries) $(MKDIR) clibraries
#----------------------------

#----------------------------
# doxygen rule
#----------------------------
doxygen:
	cd $(call NATIVEPATH,tools/doxygen) && doxygen config
#----------------------------

#----------------------------
# makefile help rule
#----------------------------
help:
	@echo Available targets:
	@echo all
	@echo ce
	@echo asm
	@echo std
	@ez80 fasmg
	@echo graphx
	@echo fileioc
	@echo keypadc
	@echo clean
	@echo clean-ce
	@echo clean-asm
	@echo clean-std
	@echo clean-graphx
	@echo clean-fileioc
	@echo clean-keypadc
	@echo install
	@echo uninstall
	@echo release
	@echo doxygen
	@echo release-libs
	@echo help
#----------------------------

.PHONY: clean-libload libload release-libs clibraries doxygen chmod all clean graphx clean-graphx fileioc clean-fileioc keypadc clean-keypadc install uninstall help release fasmg
