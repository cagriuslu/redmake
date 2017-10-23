# redmake Makefile
# Version 0.1

# Build Options
#LIBRARY_NAME          =
#COMMON_COMPILER_FLAGS =
#C_COMPILER_FLAGS      =
#CPP_COMPILER_FLAGS    =
#INCLUDE_DIRECTORIES   =
#LINKER_FLAGS          =
#REDMAKE_DEPENDENCIES  =
#LINK_TYPE             = static or dynamic

# Project Configuration
# Source File Extensions
C_EXT = c
CX_EXT = cc
AR_EXT = o
SO_EXT = dylib
# Executables
CC = gcc
CX = g++
AR = ar
LD = g++
RM = rm
MKDIR = mkdir
MAKE = make

#################
## Directories ##
#################
# Do not change these in order not to break
# compatibility with other redmake projects

# Source Directories
SRC_DIR = src
INC_DIR = inc
TST_DIR = tst
# Output Directories
OBJ_DIR = obj
LIB_DIR = lib
BIN_DIR = bin

####################
## Implementation ##
####################

# import source files
C_SRCS = $(wildcard $(SRC_DIR)/*.$(C_EXT))
CX_SRCS = $(wildcard $(SRC_DIR)/*.$(CX_EXT))
# prepare source output files
OUT_C_OBJS = $(patsubst $(SRC_DIR)/%.$(C_EXT), $(OBJ_DIR)/%_$(C_EXT).o, $(C_SRCS))
OUT_CX_OBJS = $(patsubst $(SRC_DIR)/%.$(CX_EXT), $(OBJ_DIR)/%_$(CX_EXT).o, $(CX_SRCS))

# check if the library is header only
ifeq ($(C_SRCS), )
ifeq ($(CX_SRCS), )
IS_HEADER_ONLY = Y
endif
endif
# prepare library output file
ifneq ($(IS_HEADER_ONLY), Y)
ifeq ($(LINK_TYPE), static)
OUT_LIB = $(LIB_DIR)/lib$(LIBRARY_NAME).$(AR_EXT)
endif
ifeq ($(LINK_TYPE), dynamic)
OUT_LIB = $(LIB_DIR)/lib$(LIBRARY_NAME).$(SO_EXT)
endif
endif

# import test files
C_TSTS = $(wildcard $(TST_DIR)/*.$(C_EXT))
CX_TSTS = $(wildcard $(TST_DIR)/*.$(CX_EXT))
# prepare test output files
OUT_C_BINS = $(patsubst $(TST_DIR)/%.$(C_EXT), $(BIN_DIR)/%, $(C_TSTS))
OUT_CX_BINS = $(patsubst $(TST_DIR)/%.$(CX_EXT), $(BIN_DIR)/%, $(CX_TSTS))

# Configurations
all: redmake_dependencies $(OBJ_DIR) $(LIB_DIR) $(OUT_LIB) $(BIN_DIR) $(OUT_C_BINS) $(OUT_CX_BINS)

clean:
	$(RM) -rf $(BIN_DIR)
	$(RM) -rf $(OBJ_DIR)
	$(RM) -rf $(LIB_DIR)

REDMAKE_INCLUDE_DIRECTORIES = $(foreach redmakelib, $(REDMAKE_DEPENDENCIES), -I../$(redmakelib)/inc)
REDMAKE_LIBRARIES = $(foreach redmakelib, $(REDMAKE_DEPENDENCIES), $(if $(wildcard ../$(redmakelib)/src/*.c*), -L../$(redmakelib)/lib -l$(redmakelib)))
redmake_dependencies:
	$(foreach redmakelib, $(REDMAKE_DEPENDENCIES), $(MAKE) -C ../$(redmakelib);)

# create library file
ifeq ($(LINK_TYPE), static)
$(OUT_LIB): $(OUT_C_OBJS) $(OUT_CX_OBJS)
	$(AR) rcsv $@ $(OUT_C_OBJS) $(OUT_CX_OBJS)
endif
ifeq ($(LINK_TYPE), dynamic)
$(OUT_LIB): $(OUT_C_OBJS) $(OUT_CX_OBJS)
	$(LD) -shared -fPIC $(OUT_C_OBJS) $(OUT_CX_OBJS) -o $@
endif

# compile source files
ifeq ($(LINK_TYPE), dynamic)
ADDITIONAL_COMPILER_FLAGS = -fPIC
endif
$(OBJ_DIR)/%_$(C_EXT).o: $(SRC_DIR)/%.$(C_EXT)
	$(CC) $(COMMON_COMPILER_FLAGS) $(C_COMPILER_FLAGS) $(ADDITIONAL_COMPILER_FLAGS) -I$(INC_DIR) $(REDMAKE_INCLUDE_DIRECTORIES) $(INCLUDE_DIRECTORIES) -c $< -o $@
$(OBJ_DIR)/%_$(CX_EXT).o: $(SRC_DIR)/%.$(CX_EXT)
	$(CX) $(COMMON_COMPILER_FLAGS) $(CPP_COMPILER_FLAGS) $(ADDITIONAL_COMPILER_FLAGS) -I$(INC_DIR) $(REDMAKE_INCLUDE_DIRECTORIES) $(INCLUDE_DIRECTORIES) -c $< -o $@

# build test files
ifneq ($(IS_HEADER_ONLY), Y)
ifeq ($(LINK_TYPE), static)
ADDITIONAL_LINKER_FLAGS = -L$(LIB_DIR) -Wl,-Bstatic -l$(LIBRARY_NAME) -Wl,-Bdynamic
endif
ifeq ($(LINK_TYPE), dynamic)
ADDITIONAL_LINKER_FLAGS = -L$(LIB_DIR) -l$(LIBRARY_NAME)
endif
endif
$(BIN_DIR)/%: $(TST_DIR)/%.$(C_EXT)
	$(CC) $(COMMON_COMPILER_FLAGS) $(C_COMPILER_FLAGS) -I$(INC_DIR) $(REDMAKE_INCLUDE_DIRECTORIES) $(INCLUDE_DIRECTORIES) $< $(ADDITIONAL_LINKER_FLAGS) $(REDMAKE_LIBRARIES) $(LINKER_FLAGS) -o $@
$(BIN_DIR)/%: $(TST_DIR)/%.$(CX_EXT)
	$(CX) $(COMMON_COMPILER_FLAGS) $(CPP_COMPILER_FLAGS) -I$(INC_DIR) $(REDMAKE_INCLUDE_DIRECTORIES) $(INCLUDE_DIRECTORIES) $< $(ADDITIONAL_LINKER_FLAGS) $(REDMAKE_LIBRARIES) $(LINKER_FLAGS) -o $@

# mkdir
$(OBJ_DIR):
	$(MKDIR) -p $(OBJ_DIR)
$(LIB_DIR):
	$(MKDIR) -p $(LIB_DIR)
$(BIN_DIR):
	$(MKDIR) -p $(BIN_DIR)
