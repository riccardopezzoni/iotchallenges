#include "Challenge4.h"
#include "Timer.h"

module Challenge4C {

  uses {
  /****** INTERFACES *****/
	/****** INTERFACES *****/
	interface Boot;

  interface AMSend;
  interface Receive;
  interface Packet;
  interface Timer<TMilli> as MilliTimer;
  interface SplitControl as SplitControl;
  interface PacketAcknowledgements;
  interface Read<uint16_t>;
  }

} implementation {

  uint8_t last_digit = 7;
  uint8_t recCounter;
  uint8_t counter=0;
  uint8_t ack_counter = 0;
  uint8_t rec_ack = 0;
  message_t packet;
  bool locked;

  void sendReq();
  void sendResp();
  
  
  //***************** Send request function ********************//
  void sendReq() {
	/* This function is called when we want to send a request
	 *
	 * STEPS:
	 * 1. Prepare the msg
	 * 2. Set the ACK flag for the message using the PacketAcknowledgements interface
	 *     (read the docs)
	 * 3. Send an UNICAST message to the correct node
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	
	if (locked){
	 	return;
	 	}else{
	 	my_msg_t* rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
      if (rcm == NULL) {
	return;
      }
      rcm->msg_counter = counter;
      rcm->msg_type = 1;
      rcm->value = NULL;
      
      
      call PacketAcknowledgements.requestAck(&packet);

      if (call AMSend.send(2, &packet, sizeof(my_msg_t)) == SUCCESS) {
      	dbg("radio_send","Request sent with c = %d.\n", counter);
      	locked = TRUE;
            }else{
            	dbgerror("radio_send","Error sending request sent with c = %d.\n", counter);
            }

	 }
	 
 }        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raises the event read done.
  	 */
  	 
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted.\n");
	call SplitControl.start();
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
      if (err == SUCCESS) {
      dbg("radio","Radio ON on node %d!\n", TOS_NODE_ID);
      if (TOS_NODE_ID == 1){
        call MilliTimer.startPeriodic(1000);
        dbg("timer", "Timer started!\n");
      }
    }else {
      dbgerror("radio", "Radio failed to start, retrying...\n");
      call SplitControl.start();
    }

  }
  
  event void SplitControl.stopDone(error_t err){
    dbg("boot", "Radio stopped!\n");
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
	 counter ++;
   	 sendReq();
  }
  

  //********************* AMSend interface ****************//
  event void AMSend.sendDone(message_t* buf,error_t err) {
	/* This event is triggered when a message is sent 
	 *
	 * STEPS:
	 * 1. Check if the packet is sent
	 * 2. Check if the ACK is received (read the docs)
	 * 2a. If yes, stop the timer according to your id. The program is done
	 * 2b. Otherwise, send again the request
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	   	 my_msg_t* rcm;
	 	 if (&packet == buf) {
      locked = FALSE;
    }
   	if (err != SUCCESS){
   		dbgerror("radio", "Message not sent correctly!\n");
   		return;
   	}else{

   	 rcm = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));
   	}
   	
   	if (rcm==NULL){return;}else{
   		  if(TOS_NODE_ID == 1) {
   	if(call PacketAcknowledgements.wasAcked(buf)){

   		rec_ack ++;
        dbg("radio_ack", "Ack received for request with c = %d. This is the %dº ack received\n", rcm -> msg_counter , rec_ack);
		if (rec_ack == last_digit + 1){
      dbg("timer", "Stopping the timer!\n");
			call MilliTimer.stop();
		}
    }else{
        dbg("radio_ack", "Ack not received for request with c = %d!\n", rcm -> msg_counter);
    }
   } 
   
      if(TOS_NODE_ID == 2) {
   	if(call PacketAcknowledgements.wasAcked(buf)){

        dbg("radio_ack", "Ack received for response with c = %d.\n" , rcm -> msg_counter);
    }else{
        dbg("radio_ack", "Ack not received for response with c = %d!\n", rcm -> msg_counter);
    }
   }
   	
   	
   	}
  
  
   
	 
  }

  //***************************** Receive interface *****************//
  event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
	/* This event is triggered when a message is received 
	 *
	 * STEPS:
	 * 1. Read the content of the message
	 * 2. Check if the type is request (REQ)
	 * 3. If a request is received, send the response
	 * X. Use debug statements showing what's happening (i.e. message fields)
	 */
	 
	 my_msg_t* rcm = (my_msg_t*)payload;
	 if (rcm->msg_type == 1){

	 	recCounter = rcm->msg_counter;
	 	ack_counter++;
    	dbg("radio_rec", "Request received with c = %d!\n", rcm -> msg_counter);
 		sendResp();
	 	return buf;

	 }
	 
	 if (rcm->msg_type == 2){
    //Nothing needs to be done but a pointer to a message must be returned to compile.
    dbg("radio_rec", "Response received with c = %d!\n", rcm -> msg_counter);
	 	return buf;
	 } 

  }
  
  //************************* Read interface **********************//
  event void Read.readDone(error_t result, uint16_t data) {
	/* This event is triggered when the fake sensor finishes to read (after a Read.read()) 
	 *
	 * STEPS:
	 * 1. Prepare the response (RESP)
	 * 2. Send back (with a unicast message) the response
	 * X. Use debug statement showing what's happening (i.e. message fields)
	 */
	 
	 
	
	 
	 
  	    my_msg_t* resp = (my_msg_t*)call Packet.getPayload(&packet, sizeof(my_msg_t));

    if (resp == NULL) {
    	 dbgerror("radio", "Radio error. Pointer to response not inizialised \n");
	return;
      }
      resp->msg_counter = recCounter;
      resp->msg_type = 2;
      resp->value = data;
      
		
		
		if (locked){
		    	 dbgerror("radio", "Radio error. Channel locked\n");
	 	return;
	 	}else{

	  call PacketAcknowledgements.requestAck(&packet);

      if (call AMSend.send(1, &packet, sizeof(my_msg_t)) == SUCCESS) {
      	dbg("radio","Response sent with c = %d and data %d.\n", resp->msg_counter, resp->value);
      	locked = TRUE;

    }


	 }


	 }


}

