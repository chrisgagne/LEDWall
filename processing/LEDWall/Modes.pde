class Modes {

  static final int TEST   = 0;
  static final int MAIN   = 1;
  static final int KRGB   = 2;
  static final int KDEPTH = 3;
  static final int KSCENE = 4;

  int current;
  int start_time, check_time;
  
  String text = new String();

  PFont testFont = loadFont("Verdana-Bold-52.vlw");
  TextOverlay text_overlay = new TextOverlay(CENTER, CENTER, testFont);

  Modes() {
    set(TEST);
  }

  void set(int c) {
    current = c;
    start_time = millis();
    check_time = 0;
  }

  void doTest() {
    int now = millis();
    check_time = now - start_time;
    if (check_time > 20000) {
      set(MAIN);
    } 
    else if (check_time > 16000) {
      text = "This concludes this test of the Emergency Broadcast System.";
      showText = true;
      showImage(smpte);
    } 
    else if (check_time > 14000) {
      showText = false;
      showTestColor(color(255, 255, 255));
    } 
    else if (check_time > 12000) {
      showText = false;
      showTestColor(color(0, 0, 255));
    } 
    else if (check_time > 10000) {
      showText = false;
      showTestColor(color(0, 255, 0));
    } 
    else if (check_time > 8000) {
      showText = false;
      showTestColor(color(255, 0, 0));
    } 
    else {
      text = "This is a test. For the next few seconds, this station will conduct a test of the Emergency Broadcast System. This is only a test.";
      showText = true;
      showImage(smpte);
    }
  }

  void showImage(PImage img) {
    buffer.beginDraw();
    buffer.RAW.background(0);
    buffer.RAW.image(img, 0, 0, FRAME_BUFFER_WIDTH, FRAME_BUFFER_HEIGHT);
    if (showText) {
      text_overlay.on();
    } else {
      text_overlay.off();
    }
    text_overlay.setColor(color(255, 255, 128));
    text_overlay.set(text);
    text_overlay.display();
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void showTestColor(color c) {
    buffer.beginDraw();
    buffer.RAW.background(c);
    if (showText) {
      text_overlay.on();
    } else {
      text_overlay.off();
    }
    text_overlay.setColor(color(0, 0, 0));
    text_overlay.set(text);
    text_overlay.display();
    buffer.endDraw();
    buffer.update();
    buffer.send();
  }

  void doMain() {
    set(KRGB);
  }

  void doKRGB() {
    kinect.update();
    PImage img = kinect.rgbImage();
    showImage(img);
  }

  void doKDEPTH() {
    kinect.update();
    PImage img = kinect.depthImage();
    showImage(img);
  }

  void doKSCENE() {
    kinect.update();
    PImage img = kinect.sceneImage();
    showImage(img);
  }

  void run() {
    switch(current) {
    case TEST:
      doTest();
      break;
    case MAIN:
      doMain();
      break;
    case KRGB:
      doKRGB();
      break;
    case KDEPTH:
      doKDEPTH();
      break;
    case KSCENE:
      doKSCENE();
      break;
    }
  }
}

