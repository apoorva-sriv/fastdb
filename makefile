# -*- makefile -*-
# Makefile for Generic Unix with GCC compiler

FAULT_TOLERANT?=0
DEBUG?=1

# Default install directory
PREFIX ?= /usr/local

# Place where to copy FastDB header files
INCSPATH=$(PREFIX)/include/fastdb

#Place where to copy Fastdb library
LIBSPATH=$(PREFIX)/lib

#Place where to copy Fastdb subsql utility
BINSPATH=$(PREFIX)/bin

ifdef NO_PTHREADS
OBJS = class.o compiler.o database.o xml.o hashtab.o file.o symtab.o ttree.o rtree.o container.o \
	cursor.o query.o wwwapi.o unisock.o sync.o localcli.o stdtp.o 
else
OBJS = class.o compiler.o database.o xml.o hashtab.o file.o symtab.o ttree.o rtree.o container.o \
	cursor.o query.o wwwapi.o unisock.o sync.o localcli.o stdtp.o server.o
endif

CLI_OBJS = cli.o unisock.o repsock.o stdtp.o 

INCS = inc/fastdb.h inc/stdtp.h inc/config.h inc/class.h inc/database.h inc/cursor.h inc/reference.h inc/wwwapi.h \
	inc/cli.h inc/array.h inc/file.h inc/hashtab.h inc/ttree.h inc/rtree.h inc/container.h inc/sync.h inc/sync_unix.h \
	inc/query.h inc/datetime.h inc/harray.h inc/rectangle.h inc/timeseries.h inc/exception.h

#
# threads settings - please comment this lines for single-threaded libs
#
ifdef NO_PTHREADS
TFLAGS=-DNO_PTHREADS
THRLIBS=
SUFF=
else
TFLAGS=-pthread
THRLIBS=-pthread
SUFF=_r
endif

STDLIBS =  -lm  $(THRLIBS)
SOCKLIBS = 
TFLAGS += -fPIC


VERSION=2
FASTDB_LIB = libfastdb$(SUFF).a 
FASTDB_SHARED = libfastdb$(SUFF).so.${VERSION}
CLI_LIB = libcli$(SUFF).a
JNI_LIB = libjnicli$(SUFF).so.${VERSION}
CLI_SHARED = libcli$(SUFF).so.${VERSION}

EXES = subsql forcerecovery cleanupsem inspectsem
#FASTDB_LIBS=-L. -lfastdb$(SUFF)
#CLI_LIBS=-L. -lcli$(SUFF)
FASTDB_LIBS=$(FASTDB_LIB)
CLI_LIBS=$(CLI_LIB)

EXAMPLES = guess testdb testleak testfrag testjoin testddl testperf testpar testindex testarridx testudt testfuzzy testsync testconc testiref testtrav testidx clitest clitest2 testrect testalter testraw localclitest testharr testspat testtimeseries testwcs testtl

WEB_EXAMPLES = cgistub bugdb clidb

CC = g++

# DEFS macro is deprecatred, edit config.h file instead
DEFS = -Wno-invalid-offsetof -Wno-write-strings

ifeq ($(DEBUG), 1)
CFLAGS = -c -Iinc -Wall -O0 -g -fPIC $(DEFS) $(TFLAGS)
else
CFLAGS = -c -Iinc -Wall -O5 -g -fPIC $(DEFS) $(TFLAGS)
endif

#SHFLAGS=-shared -Wl,-soname,$@
SHFLAGS=-shared


LD = $(CC)
LDFLAGS = -g $(TFLAGS)

AR = ar
ARFLAGS = -cru

ifneq (,$(findstring FreeBSD,$(OSTYPE)))
RANLIB = ranlib
else
RANLIB = true
endif

ifneq (0,$(FAULT_TOLERANT))
STDLIBS +=  $(SOCKLIBS)
DEFS += -DREPLICATION_SUPPORT
endif


all: static shared bins

static: $(FASTDB_LIB) $(CLI_LIB) 

shared: $(FASTDB_SHARED) $(CLI_SHARED) 

bins: $(EXES) $(EXAMPLES) 

www: $(FASTDB_SHARED) $(WEB_EXAMPLES)


class.o: src/class.cpp inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/class.cpp

compiler.o: src/compiler.cpp inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/compiler.cpp

query.o: src/query.cpp inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/query.cpp

database.o: src/database.cpp inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/database.cpp

xml.o: src/xml.cpp inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/xml.cpp

localcli.o: src/localcli.cpp inc/compiler.h inc/compiler.d inc/symtab.h inc/localcli.h $(INCS)
	$(CC) $(CFLAGS) src/localcli.cpp

cursor.o: src/cursor.cpp inc/compiler.h inc/compiler.d $(INCS)
	$(CC) $(CFLAGS) src/cursor.cpp

hashtab.o: src/hashtab.cpp $(INCS)
	$(CC) $(CFLAGS) src/hashtab.cpp

file.o: src/file.cpp $(INCS)
	$(CC) $(CFLAGS) src/file.cpp

stdtp.o: src/stdtp.cpp $(INCS)
	$(CC) $(CFLAGS) src/stdtp.cpp

sync.o: src/sync.cpp $(INCS)
	$(CC) $(CFLAGS) src/sync.cpp

symtab.o: src/symtab.cpp inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/symtab.cpp

ttree.o: src/ttree.cpp $(INCS)
	$(CC) $(CFLAGS) src/ttree.cpp

rtree.o: src/rtree.cpp $(INCS)
	$(CC) $(CFLAGS) src/rtree.cpp

container.o: src/container.cpp $(INCS)
	$(CC) $(CFLAGS) src/container.cpp

wwwapi.o: src/wwwapi.cpp inc/wwwapi.h inc/sockio.h inc/stdtp.h inc/sync.h inc/config.h inc/sync_unix.h 
	$(CC) $(CFLAGS) src/wwwapi.cpp

unisock.o: src/unisock.cpp inc/unisock.h inc/sockio.h inc/stdtp.h
	$(CC) $(CFLAGS) src/unisock.cpp

repsock.o: src/repsock.cpp inc/unisock.h inc/sockio.h inc/stdtp.h inc/sync.h inc/sync_unix.h inc/config.h 
	$(CC) $(CFLAGS) src/repsock.cpp

cli.o: src/cli.cpp inc/cli.h inc/cliproto.h
	$(CC) $(CFLAGS) src/cli.cpp

$(FASTDB_LIB): $(OBJS)
	rm -f $(FASTDB_LIB)
	$(AR) $(ARFLAGS) $(FASTDB_LIB) $(OBJS)
	$(RANLIB) $(FASTDB_LIB)

$(FASTDB_SHARED): $(OBJS)
	rm -f $(FASTDB_SHARED)
	$(CC) $(SHFLAGS) -o $(FASTDB_SHARED) $(OBJS) $(THRLIBS)
	ln -f -s $(FASTDB_SHARED) libfastdb$(SUFF).so

$(CLI_LIB): $(CLI_OBJS)
	rm -f $(CLI_LIB)
	$(AR) $(ARFLAGS) $(CLI_LIB) $(CLI_OBJS)
	$(RANLIB) $(CLI_LIB)

$(CLI_SHARED): $(CLI_OBJS)
	rm -f $(CLI_SHARED)
	$(CC) $(SHFLAGS) -o  $(CLI_SHARED) $(CLI_OBJS) $(THRLIBS)
	ln -f -s $(CLI_SHARED) libcli$(SUFF).so


clitest.o: examples/clitest.c inc/cli.h
	$(CC) $(CFLAGS) examples/clitest.c

clitest: clitest.o $(CLI_LIB)
	$(LD) $(LDFLAGS) -o clitest clitest.o $(CLI_LIBS) $(STDLIBS) $(SOCKLIBS)

clitest2.o: examples/clitest2.c inc/cli.h
	$(CC) $(CFLAGS) examples/clitest2.c

clitest2: clitest2.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o clitest2 clitest2.o $(FASTDB_LIB) $(STDLIBS)

testalter.o: examples/testalter.c inc/cli.h
	$(CC) $(CFLAGS) examples/testalter.c

testalter: testalter.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testalter testalter.o $(FASTDB_LIB) $(STDLIBS)

localclitest: clitest.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o localclitest clitest.o $(FASTDB_LIB) $(STDLIBS)

testrect.o: examples/testrect.c inc/cli.h
	$(CC) $(CFLAGS) examples/testrect.c

testrect: testrect.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testrect testrect.o $(FASTDB_LIB) $(STDLIBS)

subsql.o: src/subsql.cpp inc/subsql.h inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/subsql.cpp

server.o: src/server.cpp inc/server.h inc/cli.h inc/cliproto.h inc/subsql.h inc/compiler.h inc/compiler.d inc/symtab.h $(INCS)
	$(CC) $(CFLAGS) src/server.cpp

subsql: subsql.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o subsql subsql.o $(FASTDB_LIBS) $(STDLIBS) $(SOCKLIBS)

bugdb.o: examples/bugdb.cpp examples/bugdb.h $(INCS)
	$(CC) $(CFLAGS) examples/bugdb.cpp

bugdb: bugdb.o  $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o bugdb bugdb.o $(FASTDB_LIBS) $(STDLIBS) $(SOCKLIBS)

clidb.o: examples/clidb.cpp examples/clidb.h $(INCS)
	$(CC) $(CFLAGS) examples/clidb.cpp

clidb: clidb.o  $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o clidb clidb.o $(FASTDB_LIBS) $(STDLIBS) $(SOCKLIBS)

cgistub.o: src/cgistub.cpp inc/stdtp.h inc/sockio.h
	$(CC) $(CFLAGS) src/cgistub.cpp 

cgistub: cgistub.o
	$(LD) $(LDFLAGS) -o cgistub cgistub.o $(FASTDB_LIBS) $(STDLIBS) $(SOCKLIBS)


forcerecovery.o: src/forcerecovery.cpp inc/database.h
	$(CC) $(CFLAGS) src/forcerecovery.cpp 

forcerecovery: forcerecovery.o
	$(LD) $(LDFLAGS)  -o forcerecovery forcerecovery.o

cleanupsem.o: src/cleanupsem.cpp inc/database.h
	$(CC) $(CFLAGS) src/cleanupsem.cpp 

cleanupsem: cleanupsem.o
	$(LD) $(LDFLAGS)  -o cleanupsem cleanupsem.o

inspectsem.o: src/inspectsem.cpp inc/database.h
	$(CC) $(CFLAGS) src/inspectsem.cpp 

inspectsem: inspectsem.o
	$(LD) $(LDFLAGS)  -o inspectsem inspectsem.o


guess.o: examples/guess.cpp $(INCS)
	$(CC) $(CFLAGS) examples/guess.cpp 

guess: guess.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o guess guess.o $(FASTDB_LIBS) $(STDLIBS)

testharr.o: examples/testharr.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testharr.cpp 

testharr: testharr.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testharr testharr.o $(FASTDB_LIBS) $(STDLIBS)

testdb.o: examples/testdb.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testdb.cpp 

testdb: testdb.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testdb testdb.o $(FASTDB_LIBS) $(STDLIBS)

testraw.o: examples/testraw.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testraw.cpp 

testraw: testraw.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testraw testraw.o $(FASTDB_LIBS) $(STDLIBS)

testleak.o: examples/testleak.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testleak.cpp 

testleak: testleak.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testleak testleak.o $(FASTDB_LIBS) $(STDLIBS)

testfrag.o: examples/testfrag.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testfrag.cpp 

testfrag: testfrag.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testfrag testfrag.o $(FASTDB_LIBS) $(STDLIBS)

testjoin.o: examples/testjoin.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testjoin.cpp 

testjoin: testjoin.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testjoin testjoin.o $(FASTDB_LIBS) $(STDLIBS)

testddl.o: examples/testddl.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testddl.cpp 

testddl: testddl.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testddl testddl.o $(FASTDB_LIBS) $(STDLIBS)

testperf.o: examples/testperf.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testperf.cpp 

testperf: testperf.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testperf testperf.o $(FASTDB_LIBS) $(STDLIBS)

testwcs.o: examples/testwcs.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testwcs.cpp 

testwcs: testwcs.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testwcs testwcs.o $(FASTDB_LIBS) $(STDLIBS)

testpar.o: examples/testpar.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testpar.cpp 

testpar: testpar.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testpar testpar.o $(FASTDB_LIBS) $(STDLIBS)

testindex.o: examples/testindex.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testindex.cpp 

testindex: testindex.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testindex testindex.o $(FASTDB_LIBS) $(STDLIBS)

testarridx.o: examples/testarridx.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testarridx.cpp 

testarridx: testarridx.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testarridx testarridx.o $(FASTDB_LIBS) $(STDLIBS)

testudt.o: examples/testudt.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testudt.cpp 

testudt: testudt.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testudt testudt.o $(FASTDB_LIBS) $(STDLIBS)

testspat.o: examples/testspat.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testspat.cpp

testspat: testspat.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testspat testspat.o $(FASTDB_LIBS) $(STDLIBS)

testtimeseries.o: examples/testtimeseries.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testtimeseries.cpp

testtimeseries: testtimeseries.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testtimeseries testtimeseries.o $(FASTDB_LIBS) $(STDLIBS)

testfuzzy.o: examples/testfuzzy.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testfuzzy.cpp 

testfuzzy: testfuzzy.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testfuzzy testfuzzy.o $(FASTDB_LIBS) $(STDLIBS)

testidx.o: examples/testidx.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testidx.cpp 

testidx: testidx.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testidx testidx.o $(FASTDB_LIBS) $(STDLIBS)

testtl.o: examples/testtl.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testtl.cpp 

testtl: testtl.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testtl testtl.o $(FASTDB_LIBS) $(STDLIBS)

testsync.o: examples/testsync.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testsync.cpp 

testsync: testsync.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testsync testsync.o $(FASTDB_LIBS) $(STDLIBS)

testconc.o: examples/testconc.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testconc.cpp 

testconc: testconc.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testconc testconc.o $(FASTDB_LIBS) $(STDLIBS)

testreplic.o: examples/testreplic.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testreplic.cpp 

testreplic: testreplic.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testreplic testreplic.o $(FASTDB_LIBS) $(STDLIBS)

testiref.o: examples/testiref.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testiref.cpp 

testiref: testiref.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testiref testiref.o $(FASTDB_LIBS) $(STDLIBS)

testtrav.o: examples/testtrav.cpp $(INCS)
	$(CC) $(CFLAGS) examples/testtrav.cpp 

testtrav: testtrav.o $(FASTDB_LIB)
	$(LD) $(LDFLAGS) -o testtrav testtrav.o $(FASTDB_LIBS) $(STDLIBS)


java: javacli.jar jnicli.jar $(JNI_LIB) examples/JniTestIndex.class examples/JniTestRelations.class examples/TestIndex.class examples/CliTest.class

jnicli.o: jnicli/jnicli.cpp
	$(CC) $(CFLAGS) -I$(JAVA_HOME)/include -I$(JAVA_HOME)/include/linux -I. jnicli/jnicli.cpp

$(JNI_LIB): jnicli.o $(GB_LIB)
	$(CC) $(SHFLAGS) -o $(JNI_LIB) jnicli.o $(FASTDB_LIB) 
	ln -f -s $(JNI_LIB) libjnicli.so

javacli.jar: javacli/*.java
	javac -g javacli/*.java
	jar cvf javacli.jar javacli/*.class
	javadoc -d javacli/docs -public javacli/*.java

jnicli.jar: jnicli/*.java
	javac -g jnicli/*.java
	jar cvf jnicli.jar jnicli/*.class
	javadoc -d jnicli/docs -public jnicli/*.java

examples/JniTestIndex.class: examples/JniTestIndex.java jnicli.jar
	javac -classpath jnicli.jar examples/JniTestIndex.java

examples/JniTestRelations.class: examples/JniTestRelations.java jnicli.jar
	javac -classpath jnicli.jar examples/JniTestRelations.java

examples/CliTest.class: examples/CliTest.java javacli.jar
	javac -classpath javacli.jar examples/CliTest.java

examples/TestIndex.class: examples/TestIndex.java javacli.jar
	javac -classpath javacli.jar examples/TestIndex.java

install: subsql cleanupsem inspectsem installlib
	mkdir -p $(BINSPATH)
	cp subsql $(BINSPATH)
	strip $(BINSPATH)/subsql
	cp cleanupsem $(BINSPATH)
	cp inspectsem $(BINSPATH)


installlib: $(FASTDB_LIB) $(CLI_LIB) $(FASTDB_SHARED) $(CLI_SHARED)
	mkdir -p $(INCSPATH)
	cp $(INCS) $(INCSPATH)
	mkdir -p $(LIBSPATH)
	cp $(FASTDB_LIB) $(CLI_LIB) $(FASTDB_SHARED) $(CLI_SHARED) $(LIBSPATH)
	(cd $(LIBSPATH) && ln -f -s $(FASTDB_SHARED) libfastdb$(SUFF).so \
	 && ln -f -s $(CLI_SHARED) libcli$(SUFF).so)
	if [ -f $(JNI_LIB) ]; then cp $(JNI_LIB) $(LIBSPATH); \
	  cd $(LIBSPATH) && ln -f -s $(JNI_LIB) libjnicli.so; fi

uninstall:
	rm -fr $(INCSPATH)
	cd $(LIBSPATH); rm -f $(FASTDB_LIB) $(CLI_LIB) $(FASTDB_SHARED) $(CLI_SHARED) $(JNI_LIB) libfastdb$(SUFF).so libjnicli.so libcli$(SUFF).so
	rm $(BINSPATH)/subsql

cleanobj:
	rm -fr *.o *.tgz examples/*.class javacli/*~ javacli/*.class jnicli/*~ jnicli/*.class jnicli/*.o jnicli/*.so core *~ cxx_repository

cleandbs:
	rm -f *.fdb *.log


clean: cleanobj cleandbs
	rm -f *.a *.so *.so.* $(EXAMPLES) $(WEB_EXAMPLES) $(EXES)

tgz:	clean
	chmod +x configure genauto.sh
	cd ..; tar cvzf fastdb.tgz fastdb

copytgz: tgz
	mcopy -o ../fastdb.tgz a:
