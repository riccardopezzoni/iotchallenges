# IOT Course Challenges
Challenges of the Internet of Things course at Polimi

### Challenge 1: Sniffing 
The aim was to answer the question in the provided [rules](Challenge1/Challenge1Rules.pdf) analysing the [traffic file](Challenge1/homework1.pcapng) producing a [delivery file](Challenge1/Challenge1.pdf) with motivated responses and code/filter used.

### Challenge 2: MQTT 
The aim was to crearte a NodeRed chart that reads values from a csv, sends some of those to ThingSpeak using MQTT and create a local chart with some values. ([Precise Rules](Challenge2/Challenge1Rules.pdf)).\
The delivery consisted in a short [report](Challenge2/report.pdf) and the [NodeRed flow](Challenge2/flow.json)

### Challenge 3: TinyOS and Cooja 
The aim was to create a mote on Cooja that toggles some led on and off based on a binary conversion, start the serial socket connecting Cooja with NodeRed and send there the stdout. In NodeRed I had to send to Thingspeak via MQTT the updated LEDs status at each iteration. ([Precise Rules](Challenge3/Challenge1Rules.pdf)).\
The delivery consisted in a short [report](Challenge3/report.pdf), the [NodeRed flow](Challenge3/flow.json) and the [Source Code of the mote](Challenge3/SourceCode)

### Challeneg 4: TinyOS and TOSSIM 
The aim was to Simulate 2 motes talking between each others, having one send REQ messages, booting the second after some seconds and from them having the second sending ACK and RESP (based on a sensor) to the messageds and the first sending ACK (to the resoponses), afetr finally turning off. ([Precise Rules](Challenge4/Challenge1Rules.pdf)).\
The delivery consisted in a short [report](Challenge4/report.pdf), the [log](Challenge4/log) of the TOSSIM simulation and the [Source Code of the motes](Challenge4/SourceCode)
