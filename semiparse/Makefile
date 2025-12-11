# Makefile for semiparse project
# This project uses no dub, just direct DMD compilation

DC = dmd
DFLAGS = -g -w -d

# Project directories
SEMIPARSE_DIR = semiparse
MKYSTD_DIR = mkystd

# Source files
SEMIPARSE_SOURCES = $(wildcard semiparse/source/*.d)
MKYSTD_SOURCES = $(wildcard mkystd/source/*.d)

# Object files
SEMIPARSE_OBJECTS = $(SEMIPARSE_SOURCES:.d=.o)
MKYSTD_OBJECTS = $(MKYSTD_SOURCES:.d=.o)

# Targets
SEMIPARSE_LIB = libsemiparse.a
MKYSTD_LIB = libmkystd.a

all: $(SEMIPARSE_LIB) $(MKYSTD_LIB)

# Build semiparse library
$(SEMIPARSE_LIB): $(SEMIPARSE_SOURCES)
	@echo "Building semiparse library..."
	@mkdir -p build
	$(DC) $(DFLAGS) -lib -of$@ $(SEMIPARSE_SOURCES)

# Build mkystd library  
$(MKYSTD_LIB): $(MKYSTD_SOURCES)
	@echo "Building mkystd library..."
	@mkdir -p build
	$(DC) $(DFLAGS) -lib -of$@ $(MKYSTD_SOURCES)

# Build executables
build/test_semiparse: $(SEMIPARSE_LIB) $(SEMIPARSE_SOURCES) semiparse/test_semiparse.d
	@echo "Building test_semiparse..."
	@mkdir -p build
	$(DC) $(DFLAGS) -of$@ semiparse/test_semiparse.d $(SEMIPARSE_SOURCES)

build/semiparse_tests: $(SEMIPARSE_LIB) $(SEMIPARSE_SOURCES) semiparse/semiparse_tests.d
	@echo "Building semiparse_tests..."
	@mkdir -p build
	$(DC) $(DFLAGS) -of$@ semiparse/semiparse_tests.d $(SEMIPARSE_SOURCES)

build: build/test_semiparse build/semiparse_tests

# Run tests
test: build/semiparse_tests
	@echo "Running semiparse tests..."
	./build/semiparse_tests

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f $(SEMIPARSE_LIB) $(MKYSTD_LIB)
	rm -rf build

.PHONY: all build test clean