CFLAGS=-Wall -O2 -MMD -MP -pg
TXTFILES=text/HamletActISceneII.txt text/HamletActIISceneI.txt text/HamletActIIISceneI.txt text/HamletActIIISceneII.txt text/HamletActIVSceneV.txt

default:
	mkdir -p build
	$(MAKE) trace2Multithread1CPU
	$(MAKE) trace2Multithread2CPU
	$(MAKE) trace2Multithread3CPU
	$(MAKE) trace2Multithread4CPU
	$(MAKE) trace2Multithread5CPU
	$(MAKE) trace2Multithread6CPU

trace2Multithread: cleanMultithreadMain buildMultithread
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_no_owner_results.csv > /dev/null

trace2Multithread1CPU: cleanMultithreadMain buildMultithread
	taskset -c 0 \
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_1_CPU_results.csv > /dev/null

trace2Multithread2CPU: cleanMultithreadMain buildMultithread
	taskset -c 0-1 \
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_2_CPU_results.csv > /dev/null

trace2Multithread3CPU: cleanMultithreadMain buildMultithread
	taskset -c 0-2 \
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_3_CPU_results.csv > /dev/null

trace2Multithread4CPU: cleanMultithreadMain buildMultithread
	taskset -c 0-3 \
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_4_CPU_results.csv > /dev/null

trace2Multithread5CPU: cleanMultithreadMain buildMultithread
	taskset -c 0-4 \
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_5_CPU_results.csv > /dev/null

trace2Multithread6CPU: cleanMultithreadMain buildMultithread
	taskset -c 0-5 \
	sudo bpftrace -q ./tracing/trace_no_owner.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_6_CPU_results.csv > /dev/null

traceMultithread: cleanMultithreadMain buildMultithread
	sudo bpftrace -q ./tracing/trace.bt \
	-c './build/multithreadMain $(TXTFILES)' \
	| tee tracing/trace_results.csv > /dev/null

runAatMain: cleanAatMain buildAat
	./build/aatMain

runCounterMain: cleanCounterMain buildCounter
	./build/counterMain text/HamletActISceneII.txt

runMultiprocMain: cleanMultiprocMain buildMultiproc buildSender
	./build/multiprocMain $(TXTFILES)

runMultithreadMain: cleanMultithreadMain buildMultithread
	./build/multithreadMain $(TXTFILES)

buildAat: build/main-aat.o build/aat.o build/stack.o build/strbuffer.o
	gcc build/main-aat.o build/aat.o build/stack.o build/strbuffer.o -o build/aatMain

buildCounter: build/main-counter.o build/counter.o build/aat.o build/stack.o build/strbuffer.o
	gcc build/main-counter.o build/counter.o build/aat.o build/stack.o build/strbuffer.o -o build/counterMain

buildMultiproc: build/main-multiproc.o buildSender
	gcc build/main-multiproc.o build/counter.o build/strbuffer.o build/aat.o build/stack.o -o build/multiprocMain

buildSender: build/main-sender.o
	gcc build/main-sender.o build/counter.o build/strbuffer.o build/aat.o build/stack.o -o build/senderMain

buildMultithread: build/main-multithread.o
	gcc build/main-multithread.o build/counter.o build/aat.o build/strbuffer.o build/stack.o -o build/multithreadMain

cleanAatMain:
	rm -f build/*.o build/*.d build/aatMain

cleanCounterMain:
	rm -f build/*.o build/*.d build/counterMain

cleanMultiprocMain:
	rm -f build/*{.o,.d,multiprocMain,senderMain}

cleanMultithreadMain:
	rm -f build/*{.o,.d,multithreadMain}

build/main-multithread.o: src/main-multithread.c build/counter.o build/aat.o
	gcc -c src/main-multithread.c -o build/main-multithread.o $(CFLAGS)

build/main-sender.o: src/main-sender.c build/counter.o
	gcc -c src/main-sender.c -o build/main-sender.o $(CFLAGS)

build/main-multiproc.o: src/main-multiproc.c build/counter.o build/strbuffer.o
	gcc -c src/main-multiproc.c -o build/main-multiproc.o $(CFLAGS)

build/main-counter.o: src/main-counter.c build/counter.o
	gcc -c src/main-counter.c -o build/main-counter.o $(CFLAGS)

build/counter.o: src/counter.c build/aat.o
	gcc -c src/counter.c -o build/counter.o $(CFLAGS)

build/main-aat.o: src/main-aat.c build/aat.o
	gcc -c src/main-aat.c -o build/main-aat.o $(CFLAGS)

build/aat.o: src/aat.c build/stack.o build/strbuffer.o
	gcc -c src/aat.c -Iinclude -o build/aat.o $(CFLAGS)

build/stack.o: src/stack.c
	gcc -c src/stack.c -Iinclude -o build/stack.o $(CFLAGS)

build/strbuffer.o: src/strbuffer.c
	gcc -c src/strbuffer.c -Iinclude -o build/strbuffer.o $(CFLAGS)

-include build/*.d