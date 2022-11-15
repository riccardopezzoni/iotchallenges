#define NEW_PRINTF_SEMANTICS
#include "printf.h"

configuration ChallengeApp{
}
implementation {
  components MainC, Challenge, LedsC;
  components new TimerMilliC();
  components SerialPrintfC;
  components SerialStartC;

  Challenge.Boot -> MainC;
  Challenge.Timer -> TimerMilliC;
  Challenge.Leds -> LedsC;
}
