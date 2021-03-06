import processing.serial.*;

float WALL_WATTS = 0;
float MAX_WATTS = 0;

int[][] gammaTable;


final int TEENSY_TOTAL  = 10;
final int TEENSY_WIDTH  = 80;
final int TEENSY_HEIGHT = 16;
final int BAUD_RATE = 921600; //115200;

final float RED_GAMMA = 2.1;
final float GREEN_GAMMA = 2.1;
final float BLUE_GAMMA = 2.1;

Teensy[] teensys = new Teensy [TEENSY_TOTAL];

void setupTeensys() {
  println("starting teensy setup...");
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println(list);

  teensys[0] = new Teensy(this, 0, "COM12", true);
  teensys[1] = new Teensy(this, 1, "COM8",  true);
  teensys[2] = new Teensy(this, 2, "COM11", true);
  teensys[3] = new Teensy(this, 3, "COM9",  true);
  teensys[4] = new Teensy(this, 4, "COM10", true);
  teensys[5] = new Teensy(this, 5, "COM5",  true);
  teensys[7] = new Teensy(this, 6, "COM6",  true);
  teensys[6] = new Teensy(this, 7, "COM4",  true);
  teensys[8] = new Teensy(this, 8, "COM3",  true);  
  teensys[9] = new Teensy(this, 9, "COM7",  true);


  //println(gammaTable);

  println("TEENSYS SETUP!!");
  println();
}

void setupGamma() {
  gammaTable = new int [256][3];
  float d;
  for (int i = 0; i < 256; i++) {
    d =  i / 255.0;
    gammaTable[i][0] = floor(255 * pow(d, RED_GAMMA) + 0.5); // RED
    gammaTable[i][1] = floor(255 * pow(d, GREEN_GAMMA) + 0.5); // GREEN
    gammaTable[i][2] = floor(255 * pow(d, BLUE_GAMMA) + 0.5); // BLUE
  }
}



class Teensy {
  boolean threadData; // teensy is master
  int     id;       // id of the image that will be sent to teensy
  float   watts;
  byte[]  data;     // converted image data that gets sent
  Serial  port;     // serial port of the teensy
  int comNumber;
  tThread t;
  String  portName; // serial port name
  int sendTime = 0;
  int maxSend = 0;

  Teensy(PApplet parent, int ID, String name, boolean threadData) {
    println("Setting up teensy: " + name + " ...");
    data     = new byte[(TEENSY_WIDTH * TEENSY_HEIGHT * 3) + 3]; // setup the data array
    this.threadData = threadData;  // should we thread the data?
    portName = name;    // set the port name
    comNumber = int(name.substring(3));
    id       = ID;      // set the id 

    // setup serial port
    try {
      port = new Serial(parent, portName, BAUD_RATE);           // create the port
      if (port == null) throw new NullPointerException();    // was the port created?
      port.write('?');                                       // send ident char to teensy
    } 
    catch (Throwable e) {  // got errors?
      println("Serial port " + portName + " does not exist or is non-functional");
      exit();
    }

    delay(100);
    String line;
    
    byte temp[] = port.readBytesUntil(10);
    if (temp == null) line = null;
    else line = new String(temp);

    //String line = port.readStringUntil(10);  // give me everything up to the linefeed

    if (line == null) {  //  no data back from the teensy? 
      println("Serial port " + portName + " is not responding.");
      println("Is it really a Teensy 3.0 running VideoDisplay?");
      exit();
    }


    String[] param = line.split(",");
 
    if (param.length != 12) { // didn't get 12 back?  bad news...
      println("Error: port " + portName + " did not respond to LED config query");
      exit();
    }

    println(portName + " SETUP!!");
    if (threadData) {
      t = new tThread(port);
      t.start();
    } 
    else {
      println(data.length);
    }
  }

  void clear() {
    port.write('!');
    if (threadData) {
      t.done();
      t.interrupt();
    }
  }

  color updateColor(color c) {
    int r = (c >> 16) & 0xFF;  // get the red
    int g = (c >> 8) & 0xFF;   // get the green
    int b = c & 0xFF;          // get the blue 

    r = int( map( r, 0, 255, 0, MAX_BRIGHTNESS ) );  // map red to max LED brightness
    g = int( map( g, 0, 255, 0, MAX_BRIGHTNESS ) );  // map green to max LED brightness
    b = int( map( b, 0, 255, 0, MAX_BRIGHTNESS ) );  // map blue to max LED brightness

    r = gammaTable[r][0];  // map red to gamma correction table
    g = gammaTable[g][1];  // map green to gamma correction table
    b = gammaTable[b][2];  // map blue to gamma correction table

    float pixel_watts = map(r + g + b, 0, 768, 0, 0.24);  // get the wattage of the pixel
    watts += pixel_watts; // add pixel wattage to total wattage count (watts is added to WALL_WATTS in wall tab)

    return color(g, r, b, 255); // translate the 24 bit color from RGB to the actual order used by the LED wiring.  GRB is the most common.
  }

  // converts an image to OctoWS2811's raw data format.
  // The number of vertical pixels in the image must be a multiple
  // of 8.  The data array must be the proper size for the image.
  void update() { 
    watts = 0;

    int offset = 3;
    int x, y, xbegin, xend, xinc, mask;
    int linesPerPin = wall.teensyImages[id].height / 8;
    int pixel[] = new int[8];

    boolean layout = true;

    for (y = 0; y < linesPerPin; y++) {
      if ((y & 1) == (layout ? 0 : 1)) {
        // even numbered rows are left to right
        xbegin = 0;
        xend = wall.teensyImages[id].width;
        xinc = 1;
      } 
      else {
        // odd numbered rows are right to left
        xbegin = wall.teensyImages[id].width - 1;
        xend = -1;
        xinc = -1;
      }
      for (x = xbegin; x != xend; x += xinc) {
        for (int i=0; i < 8; i++) {
          // fetch 8 pixels from the image, 1 for each pin
          pixel[i] = wall.teensyImages[id].pixels[x + (y + linesPerPin * i) * wall.teensyImages[id].width];
          pixel[i] = updateColor(pixel[i]);
        }
        // convert 8 pixels to 24 bytes
        for (mask = 0x800000; mask != 0; mask >>= 1) {
          byte b = 0;
          for (int i=0; i < 8; i++) {
            if ((pixel[i] & mask) != 0) b |= (1 << i);
          }
          data[offset++] = b;
        }
      }
    }
  }

  void sendData() {
    port.write(data);  // send data over serial to teensy
  }

  void send() {
    sendTime = 0;
    int stime = millis();
    update();

    data[0] = '*'; 
    data[1] = 0; 
    data[2] = 0;

    if (threadData) {
      t.send(data);
      sendTime = t.getTime();
    }
    else {
      sendData();
    }
    sendTime = millis() - stime;
    maxSend = max(sendTime, maxSend);
  }
}

class tThread extends Thread {
  Serial  port;
  int send_time;
  boolean running;
  boolean sendData;
  byte[] data;

  tThread(Serial port) {
    this.port = port;
    //setDaemon(true);
    //setPriority(3);
    //println(getPriority());
    running = false;
    sendData = false;
    send_time = 0;
  }

  void start() {
    running = true;
    super.start();
  }

  synchronized void send(byte[] data) {
    this.data = data;
    sendData = true;
  }

  int getTime() {
    return send_time;
  }

  void done() {
    running = false;
  }

  void run() {
    while (running) {
      if (sendData) {
        int stime = millis();
        sendData = false;
        port.write(data);  // send data over serial to teensy
        send_time = millis() - stime;
      } else {
        yield();
      }
    }
  }
}

