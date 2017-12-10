CFLAGS=-std=c++14 -Wall -Werror -Wno-empty-body -g
VFILES:= control_spi_tb.v
TESTS:= $(patsubst %.v, obj_dir/V%, $(VFILES))
SBYS:= $(wildcard *.sby)
FORMAL:= $(patsubst %.sby, %/PASS, $(SBYS))
all: $(TESTS) 

obj_dir/V%.h: %.v
	verilator -Wall -trace --public -CFLAGS "$(CFLAGS)" --cc test_$*.cpp --exe $<

obj_dir/V%: test_%.cpp obj_dir/V%.h
	$(MAKE) -C obj_dir -f V$*.mk V$*
	./$@


formal: $(FORMAL)

%/PASS: %.sby %.v
	sby -f $<

.PHONY: formal

clean:
	rm -f *.smt2
	rm -f *.vcd
	rm -rf altera_tx/
	rm -rf controller/
	rm -rf fifo/
	rm -rf phase_accum/
	rm -rf sampler/
	rm -rf spi/

distclean:
	rm *~
