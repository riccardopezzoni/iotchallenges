#include "printf.h"
module Challenge{
  uses {
    interface Boot;
    interface Timer<TMilli>;
    interface Leds;
  }
}
implementation {

  uint32_t personcode = 10575577;
  uint8_t i = 0;
  bool l0 = 0;
  bool l1 = 0;
  bool l2 = 0;


  event void Boot.booted() {
    call Timer.startPeriodic(60000);
  }
    event void Timer.fired() {
       i = personcode%3;
        if (i == 0){
        	call Leds.led0Toggle();
            l0 = !l0;
        } else if ( i == 1){
        	call Leds.led1Toggle();
            l1 = !l1;
        }else if (i ==2){
        	call Leds.led2Toggle();
            l2 = !l2;
        }
       printf("%d,%d,%d\n", l0,l1,l2);
  	   printfflush();
       personcode = personcode/3;
    if (personcode == 0){return call Timer.stop();}

  }
}
