ifeq ($(GNUSTEP_MAKEFILES),)
  GNUSTEP_MAKEFILES := $(shell gnustep-config --variable=GNUSTEP_MAKEFILES 2>/dev/null)
  ifeq ($(GNUSTEP_MAKEFILES),)
  $(warning )
  $(warning Unable to obtain GNUSTEP_MAKEFILES setting from gnustep-config!)
  $(warning Perhaps gnustep-make is not properly installed,)
  $(warning so gnustep-config is not in your PATH.)
  $(warning )
  $(warning Your PATH is currently $(PATH))
  $(warning )
  endif
endif

ifeq ($(GNUSTEP_MAKEFILES),)
    $(error You need to set GNUSTEP_MAKEFILES before compiling!)
  endif
include $(GNUSTEP_MAKEFILES)/common.make

TOOL_NAME=WebServerExample

WebServerExample_OBJC_FILES=\
  Handler.m \
  main.m

ADDITIONAL_OBJCFLAGS+=-fobjc-arc

WebServerExample_TOOL_LIBS+=-lWebServer -ldispatch

-include GNUmakefile.preamble
include $(GNUSTEP_MAKEFILES)/tool.make
-include GNUmakefile.postamble
