#include "Vcontrol_spi_tb.h"
#include "verilated.h"
#include "testbench.h"
#define CATCH_CONFIG_MAIN
#include "catch.hpp"
#include "string.h"
#define SIG(x) tb.core->x
#define CSIG(x) core->x

class Control_tb: public Testbench<Vcontrol_spi_tb>{
public:
  Control_tb(){
    opentrace("dump.vcd");
    CSIG(SSEL) = 1;
    reset();
    tick();
  }
  void spi_begin(){
    CSIG(SSEL) = 0;
    CSIG(SCK) = 0;
    cycles(4);
  }
  uint8_t spi_tx_byte(uint8_t byte){
    uint8_t ret = 0;
    for(int i=0;i<8;i++){
      ret <<=1;
      CSIG(MOSI) = (byte&128) >0;
      cycles(3);
      CSIG(SCK) = 1;
      cycles(3);
      CSIG(SCK) = 0;
      ret |= CSIG(MISO);
      byte <<= 1;
    }
    return ret;
    
  }
  void spi_tx_bytes(uint8_t* in, uint8_t* out, size_t count){
    for(size_t i = 0; i<count; i++){
      if(out)
	out[i] = spi_tx_byte(in[i]);
      else
	spi_tx_byte(in[i]);
    }
  }
  void spi_end(){
    CSIG(SCK) = 0;
    CSIG(SSEL) = 1;
    cycles(4);
  }
};
Control_tb tb;

TEST_CASE("Test_get_space", "[spi]"){
  SIG(fifo_space_free) = 435;
  uint8_t cmd[] = {1,2,0,0};
  uint8_t resp[4];
  tb.spi_begin();
  tb.spi_tx_bytes(cmd,resp,sizeof(cmd));
  tb.spi_end();
  tb.cycles(10);
  CHECK(resp[1] == 0xa5);
  CHECK((resp[2]<<8) + resp[3] == SIG(fifo_space_free));

}

TEST_CASE("Test_set_freq", "[spi]"){
  tb.reset();
  uint8_t cmd[] = {2,2,34,63};
  tb.spi_begin();
  tb.spi_tx_bytes(cmd, NULL, sizeof(cmd));
  tb.spi_end();
  tb.cycles(10);

}
void fifo_tick_handler(std::vector<int>* fifo){
  if(SIG(fifo_wr) == 1 && SIG(clk) == 1)
    fifo->push_back(SIG(fifo_data_in));
}

TEST_CASE("Test_fifo", "[spi]"){
  tb.reset();
  std::vector<int> fifo;
  std::function<void(void)> handler = std::bind(fifo_tick_handler, &fifo);
  tb.register_tick_handler(handler);
  uint8_t cmd[] = {3,4,0x34, 0x13, 0xf3, 0x7a};
  uint8_t resp[6];
  tb.spi_begin();
  tb.spi_tx_bytes(cmd, resp, sizeof(cmd));
  tb.spi_end();
  tb.cycles(10);
  CHECK(fifo.size() == 4);
  for(int i=0;i<4;i++){
    CHECK(fifo[i] == cmd[i+2]);
  }
}

void fifo_write_handler(int* count, int* fifo_entries){
  SIG(fifo_full) = *fifo_entries == 0;
  SIG(fifo_space_free) = *fifo_entries;
  if(SIG(fifo_wr) && SIG(clk)){
    (*count)++;
    (*fifo_entries)--;
  }

}
TEST_CASE("Test_write_on_full", "[spi]"){
  tb.reset();
  int fifo_writes = 0;
  int fifo_entries = 2;
  std::function<void()> handler = std::bind(fifo_write_handler, &fifo_writes, &fifo_entries);
  tb.register_tick_handler(handler);
  uint8_t cmd[] = {3,4,1,2,3,4};
  tb.spi_begin();
  tb.spi_tx_bytes(cmd, NULL, sizeof(cmd));
  tb.spi_end();
  tb.cycles(10);
  CHECK(fifo_writes == 2);

}
