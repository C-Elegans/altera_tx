CFLAGS=-std=c++14 -Wall -Werror -Wno-empty-body -g
VFILES:= control_spi_tb.v
TESTS:= $(patsubst %.v, obj_dir/V%, $(VFILES))
all: $(TESTS) 

obj_dir/V%.h: %.v
	verilator -Wall -trace --public -CFLAGS "$(CFLAGS)" --cc test_$*.cpp --exe $<

obj_dir/V%: test_%.cpp obj_dir/V%.h
	$(MAKE) -C obj_dir -f V$*.mk V$*
	./$@
