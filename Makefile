
INSTALL_ROOT ?= $(HOME)

CC := g++
CFLAGS := -std=c++11 -Wall
ifdef DEBUG
	CFLAGS += -O0 -g3
else
	CFLAGS += -O3 -g0
endif

ifdef LOFAR
	CFLAGS += -DHAVE_HDF5
	HDF5_INCLUDE ?= -I/usr/include
endif
ifdef PSRDADA
	CFLAGS += -DHAVE_PSRDADA
	INCLUDES += -I"$(PSRDADA)/src"
endif

all: bin/Observation.o bin/Platform.o bin/ReadData.o
	-@mkdir -p lib
	$(CC) -o lib/libAstroData.so -shared -Wl,-soname,libAstroData.so bin/ReadData.o bin/Observation.o bin/Platform.o $(CFLAGS)

bin/ReadData.o: include/ReadData.hpp src/ReadData.cpp
	-@mkdir -p bin
	$(CC) -o bin/ReadData.o -c -fpic src/ReadData.cpp -I"include" -I"$(INSTALL_ROOT)/include" $(HDF5_INCLUDE) $(INCLUDES) $(CFLAGS)

bin/Observation.o: $(INSTALL_ROOT)/include/utils.hpp include/Observation.hpp src/Observation.cpp
	-@mkdir -p bin
	$(CC) -o bin/Observation.o -c -fpic src/Observation.cpp -I"include" -I"$(INSTALL_ROOT)/include" $(CFLAGS)

bin/Platform.o: $(INSTALL_ROOT)/include/utils.hpp include/Platform.hpp src/Platform.cpp
	-@mkdir -p bin
	$(CC) -o bin/Platform.o -c -fpic src/Platform.cpp -I"include" -I"$(INSTALL_ROOT)/include" $(CFLAGS)

clean:
	-@rm bin/*.o
	-@rm lib/*

install: all
	-@cp include/* $(INSTALL_ROOT)/include
	-@cp lib/* $(INSTALL_ROOT)/lib
