##############################################################################
# Product: Makefile for EMF32-SLSTK3401A, QUTEST, GNU-ARM
# Last Updated for Version: 6.2.0
# Date of the Last Update:  2018-04-13
#
#                    Q u a n t u m     L e a P s
#                    ---------------------------
#                    innovating embedded systems
#
# Copyright (C) 2005-2018 Quantum Leaps, LLC. All rights reserved.
#
# This program is open source software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Alternatively, this program may be distributed and modified under the
# terms of Quantum Leaps commercial licenses, which expressly supersede
# the GNU General Public License and are specifically designed for
# licensees interested in retaining the proprietary status of their code.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# Contact information:
# https://www.state-machine.com
# mailto:info@state-machine.com
##############################################################################
#
# examples of invoking this Makefile:
# make -fefm32-slstk3401a.mak  # make and run the tests in the current directory
# make -fefm32-slstk3401a.mak TESTS=philo*.tcl  # make and run the selected tests
# make -fefm32-slstk3401a.mak HOST=localhost:7705 # connect to host:port
# make -fefm32-slstk3401a.mak norun  # only make but not run the tests
# make -fefm32-slstk3401a.mak clean  # cleanup the build
#
# NOTE:
# To use this Makefile on Windows, you will need the GNU make utility, which
# is included in the Qtools collection for Windows, see:
#    http://sourceforge.net/projects/qpc/files/Qtools/
#

#-----------------------------------------------------------------------------
# project name, binary output directory
#
PROJECT := test_qmsm
TARGET  := efm32-slstk3401a

#-----------------------------------------------------------------------------
# project directories
#

# location of the QP/C framework (if not provided in an environemnt var.)
ifeq ($(QPC),)
QPC := ../../..
endif

# location of the QTOOLS directory (if not provided in an environemnt var.)
ifeq ($(QTOOLS),)
QTOOLS := c:/qp/qtools
endif


# QP port used in this project
QP_PORT_DIR := $(QPC)/ports/arm-cm/qutest

# list of all source directories used by this project
VPATH = \
	../$(TARGET) \
	$(QPC)/src/qf \
	$(QPC)/src/qs \
	$(QP_PORT_DIR) \
	$(QPC)/3rd_party/efm32pg1b \
	$(QPC)/3rd_party/efm32pg1b/gnu

# list of all include directories needed by this project
INCLUDES  = \
	-I. \
	-I../$(TARGET) \
	-I$(QPC)/include \
	-I$(QPC)/src \
	-I$(QP_PORT_DIR) \
	-I$(QPC)/3rd_party/CMSIS/Include \
	-I$(QPC)/3rd_party/efm32pg1b

#-----------------------------------------------------------------------------
# files
#

# assembler source files
ASM_SRCS :=

# C source files
C_SRCS := \
	qmsmtst.c \
	test_qmsm.c \
	startup_efm32pg1b.c \
	system_efm32pg1b.c \
	em_cmu.c \
	em_emu.c \
	em_gpio.c \
	em_usart.c

# C++ source files
CPP_SRCS :=

OUTPUT    := $(PROJECT)
LD_SCRIPT := ../$(TARGET)/test.ld

QP_SRCS := \
	qep_hsm.c \
	qep_msm.c \
	qf_act.c \
	qf_actq.c \
	qf_defer.c \
	qf_dyn.c \
	qf_mem.c \
	qf_ps.c \
	qf_qact.c \
	qf_qeq.c \
	qf_qmact.c \
	qs.c \
	qs_64bit.c \
	qs_rx.c \
	qs_fp.c \
	qutest.c \
	qutest_port.c

QP_ASMS :=

LIB_DIRS  :=
LIBS      :=

# defines
DEFINES   := -DEFM32PG1B200F256GM48=1

# ARM CPU, ARCH, FPU, and Float-ABI types...
# ARM_CPU:   [cortex-m0 | cortex-m0plus | cortex-m1 | cortex-m3 | cortex-m4]
# ARM_ARCH:  [6 | 7] (NOTE: must match ARM_CPU!)
# ARM_FPU:   [ | vfp]
# FLOAT_ABI: [ | soft | softfp | hard]
#
ARM_CPU   := -mcpu=cortex-m4
ARM_ARCH  := 7   # NOTE: must match the ARM_CPU!
ARM_FPU   := -mfpu=vfp
FLOAT_ABI := -mfloat-abi=softfp

#-----------------------------------------------------------------------------
# GNU-ARM toolset (NOTE: You need to adjust to your machine)
# see http://gnutoolchains.com/arm-eabi/
#
ifeq ($(GNU_ARM),)
GNU_ARM := $(QTOOLS)/gnu_arm-eabi
endif

# make sure that the GNU-ARM toolset exists...
ifeq ("$(wildcard $(GNU_ARM))","")
$(error GNU_ARM toolset not found. Please adjust the Makefile)
endif

CC    := $(GNU_ARM)/bin/arm-eabi-gcc
CPP   := $(GNU_ARM)/bin/arm-eabi-g++
AS    := $(GNU_ARM)/bin/arm-eabi-as
LINK  := $(GNU_ARM)/bin/arm-eabi-gcc
BIN   := $(GNU_ARM)/bin/arm-eabi-objcopy

#-----------------------------------------------------------------------------
# JLINK tool (NOTE: You need to adjust to your machine)
# see https://www.segger.com/downloads/jlink
#
ifeq ($(JLINK),)
JLINK := $(QTOOLS)/../JLink/JLink.exe
endif

# make sure that the JLINK tool exists...
ifeq ("$(wildcard $(JLINK))","")
$(error JLINK tool not found. Please adjust the Makefile)
endif


##############################################################################
# Typically you should not need to change anything below this line

# basic utilities (included in Qtools for Windows), see:
#    http://sourceforge.net/projects/qpc/files/Qtools

MKDIR  := mkdir
RM     := rm
TCLSH  := tclsh
QUTEST := $(QTOOLS)/qspy/tcl/qutest.tcl

#-----------------------------------------------------------------------------
# build options
#

# combine all the soruces...
C_SRCS += $(QP_SRCS)
ASM_SRCS += $(QP_ASMS)

BIN_DIR := $(TARGET)

ASFLAGS = -g $(ARM_CPU) $(ARM_FPU) $(ASM_CPU) $(ASM_FPU)

CFLAGS = -g $(ARM_CPU) $(ARM_FPU) $(FLOAT_ABI) -mthumb -Wall \
	-ffunction-sections -fdata-sections \
	-O $(INCLUDES) $(DEFINES) -DQ_SPY -DQ_UTEST

CPPFLAGS = -g $(ARM_CPU) $(ARM_FPU) $(FLOAT_ABI) -mthumb -Wall \
	-ffunction-sections -fdata-sections -fno-rtti -fno-exceptions \
	-O $(INCLUDES) $(DEFINES) -DQ_SPY -DQ_UTEST


LINKFLAGS = -T$(LD_SCRIPT) $(ARM_CPU) $(ARM_FPU) $(FLOAT_ABI) \
	-mthumb -nostdlib \
	-Wl,-Map,$(BIN_DIR)/$(OUTPUT).map,--cref,--gc-sections $(LIB_DIRS)

ASM_OBJS     := $(patsubst %.s,%.o,  $(notdir $(ASM_SRCS)))
C_OBJS       := $(patsubst %.c,%.o,  $(notdir $(C_SRCS)))
CPP_OBJS     := $(patsubst %.cpp,%.o,$(notdir $(CPP_SRCS)))

TARGET_BIN   := $(BIN_DIR)/$(OUTPUT).bin
TARGET_ELF   := $(BIN_DIR)/$(OUTPUT).elf
ASM_OBJS_EXT := $(addprefix $(BIN_DIR)/, $(ASM_OBJS))
C_OBJS_EXT   := $(addprefix $(BIN_DIR)/, $(C_OBJS))
C_DEPS_EXT   := $(patsubst %.o, %.d, $(C_OBJS_EXT))
CPP_OBJS_EXT := $(addprefix $(BIN_DIR)/, $(CPP_OBJS))
CPP_DEPS_EXT := $(patsubst %.o, %.d, $(CPP_OBJS_EXT))

# create $(BIN_DIR) if it does not exist
ifeq ("$(wildcard $(BIN_DIR))","")
$(shell $(MKDIR) $(BIN_DIR))
endif

#-----------------------------------------------------------------------------
# rules
#

.PHONY : run norun flash

ifeq ($(MAKECMDGOALS),norun)
all : $(TARGET_BIN)
norun : all
else
all : $(TARGET_BIN) run
endif

ifeq (, $(TESTS))
TESTS := *.tcl
endif

$(TARGET_BIN): $(TARGET_ELF)
	$(BIN) -O binary $< $@
	$(JLINK) -device EFM32PG1B200F256GM48 $(TARGET).jlink

$(TARGET_ELF) : $(ASM_OBJS_EXT) $(C_OBJS_EXT) $(CPP_OBJS_EXT)
	$(CC) $(CFLAGS) -c $(QPC)/include/qstamp.c -o $(BIN_DIR)/qstamp.o
	$(LINK) $(LINKFLAGS) -o $@ $^ $(BIN_DIR)/qstamp.o $(LIBS)

flash :
	$(JLINK) -device EFM32PG1B200F256GM48 $(TARGET).jlink

run : $(TARGET_BIN)
	$(TCLSH) $(QUTEST) $(TESTS) "" $(HOST)

$(BIN_DIR)/%.d : %.c
	$(CC) -MM -MT $(@:.d=.o) $(CFLAGS) $< > $@

$(BIN_DIR)/%.d : %.cpp
	$(CPP) -MM -MT $(@:.d=.o) $(CPPFLAGS) $< > $@

$(BIN_DIR)/%.o : %.s
	$(AS) $(ASFLAGS) $< -o $@

$(BIN_DIR)/%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(BIN_DIR)/%.o : %.cpp
	$(CPP) $(CPPFLAGS) -c $< -o $@

.PHONY : clean show

# include dependency files only if our goal depends on their existence
ifneq ($(MAKECMDGOALS),clean)
  ifneq ($(MAKECMDGOALS),show)
-include $(C_DEPS_EXT) $(CPP_DEPS_EXT)
  endif
endif

clean :
	-$(RM) $(BIN_DIR)/*.o \
	$(BIN_DIR)/*.d \
	$(BIN_DIR)/*.bin \
	$(BIN_DIR)/*.elf \
	$(BIN_DIR)/*.map

show :
	@echo PROJECT      = $(PROJECT)
	@echo TESTS        = $(TESTS)
	@echo TARGET_ELF   = $(TARGET_ELF)
	@echo CONF         = $(CONF)
	@echo VPATH        = $(VPATH)
	@echo C_SRCS       = $(C_SRCS)
	@echo CPP_SRCS     = $(CPP_SRCS)
	@echo ASM_SRCS     = $(ASM_SRCS)
	@echo C_DEPS_EXT   = $(C_DEPS_EXT)
	@echo C_OBJS_EXT   = $(C_OBJS_EXT)

	@echo CPP_DEPS_EXT = $(CPP_DEPS_EXT)
	@echo CPP_OBJS_EXT = $(CPP_OBJS_EXT)

	@echo ASM_OBJS_EXT = $(ASM_OBJS_EXT)
	@echo LIB_DIRS     = $(LIB_DIRS)
	@echo LIBS         = $(LIBS)
	@echo DEFINES      = $(DEFINES)
	@echo QUTEST       = $(QUTEST)
	@echo HOST         = $(HOST)

