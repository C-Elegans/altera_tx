#include "verilated.h"
#include "verilated_vcd_c.h"
#include <functional>
template <class Module> class Testbench {
public:
  unsigned long tickcount;
  Module* core;
  VerilatedVcdC* trace;
  bool print;
  std::function<void(void)> tickhandler;


 Testbench() : tickcount(0), trace(NULL) {
    core = new Module;
    Verilated::traceEverOn(true);
    print = 1;
  }
  virtual ~Testbench(void){
    if(trace) trace->close();
    delete core;
    core = NULL;
  }

  virtual void reset(void){
    #ifndef NO_RESET
    core->rst = 1;
    this->tick();
    core->rst = 0;
    #endif
  }
  virtual void tick(void){
    tickcount++;

    core->clk = 0;
    core->eval();
    if(trace) trace->dump(10*tickcount-2);
    
    core->clk = 1;
    if(tickhandler)tickhandler();
    core->eval();
    if(trace) trace->dump(10*tickcount);

    core->clk = 0;
    if(tickhandler)tickhandler();
    core->eval();
    if(trace){
      trace->dump(10*tickcount+5);
      trace->flush();
    }
  }
  void register_tick_handler(std::function<void(void)> handler){
    tickhandler = handler;
  }
  virtual void cycles(int cycles){
    for(int i=0;i<cycles;i++){
      this->tick();
    }
  }
  virtual void opentrace(const char* vcdname){
    if(!trace){
      trace = new VerilatedVcdC();
      core->trace(trace, 99);
      trace->open(vcdname);
    }
  }
  virtual void closetrace(void){
    if(trace){
      trace->close();
      trace = NULL;
    }
  }
  virtual bool done(void) { return (Verilated::gotFinish());}
};
