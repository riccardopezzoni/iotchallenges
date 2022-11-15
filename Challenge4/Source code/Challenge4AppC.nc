
#include "Challenge4.h"

configuration Challenge4AppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, Challenge4C as App;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  components new TimerMilliC();
  components new FakeSensorC();
  components ActiveMessageC;


/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  //Timer interface
  App.MilliTimer -> TimerMilliC;
  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  //Fake Sensor read
  App.Read -> FakeSensorC.Read;
  //Acks
  App.PacketAcknowledgements -> AMSenderC.Acks;

}

