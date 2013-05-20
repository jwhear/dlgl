
SOURCES=$(shell find . -name '*.d')

all:
	dmd $(SOURCES) -lib -oflib/libdlgl.a -version=debugGL
