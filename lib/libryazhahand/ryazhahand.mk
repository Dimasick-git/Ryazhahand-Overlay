#--------------------------------------------------------------------------------- 
# Ryzhand Library Configuration
# Auto-detects libryazhahand directory location
#--------------------------------------------------------------------------------- 

# Assume TOPDIR is the root project directory where you run make
TOPDIR ?= $(CURDIR)

# Get the absolute path of this .mk file directory
RYZ_ABS := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))

# Convert absolute path to relative path from TOPDIR
RYZ_DIR := $(subst $(TOPDIR)/,,$(RYZ_ABS))

# If RYZ_DIR equals RYZ_ABS, then RYZ_ABS is outside TOPDIR,
# fallback to just RYZ_ABS (rare case)
ifeq ($(RYZ_DIR),$(RYZ_ABS))
  RYZ_DIR := $(RYZ_ABS)
endif


# Now add folder paths relative to TOPDIR (or absolute if fallback)
SOURCES += \
  $(RYZ_DIR)/common \
  $(RYZ_DIR)/libryz/source

INCLUDES += \
  $(RYZ_DIR)/common \
  $(RYZ_DIR)/libryz/include \
  $(RYZ_DIR)/libtesla/include
