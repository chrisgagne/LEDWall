// STILL A TON TO ADD

import controlP5.*;

ControlP5 cp5;
final int TAB_START  = 250;
final int TAB_HEIGHT = 25;
int TAB_MAX_WIDTH;
int TAB_WIDTH;

PFont xsFont;  // (10)
PFont sFont;   // (11)
PFont tabFont; // (12)
PFont mFont;   // (14)
PFont lFont;   // (20)
PFont xFont;   // (40)

void setupControl() {
  // load fonts
  xsFont  = loadFont("ArialMT-11.vlw");
  sFont   = loadFont("Arial-BoldMT-11.vlw");
  tabFont = loadFont("Arial-BoldMT-12.vlw");
  mFont   = loadFont("Arial-BoldMT-14.vlw");
  lFont   = loadFont("Arial-BoldMT-20.vlw");
  xFont   = loadFont("Arial-BoldMT-40.vlw");
  
  
  cp5 = new ControlP5(this);                              // start ControlP5
  cp5.setAutoDraw(false);                                 // turn off auto draw
  cp5.window().setPositionOfTabs(0, DEBUG_WINDOW_START);  // set tab postion
  cp5.setColor(ControlP5.RED);                            // set color
  
  TAB_MAX_WIDTH = WINDOW_XSIZE - TAB_START - 40;  // max tab width (from the end of default tab to the end of the screen)
  TAB_WIDTH = TAB_MAX_WIDTH / TOTAL_MODES;        // the width of the tabs (not including the default tab)

  // create and setup the tabs
  setTab("default", DISPLAY_STR[0], 0, TAB_START - 5, TAB_HEIGHT, mFont, false, true); // default tab
  
  // setup mode tabs
  for (int i = 1; i <= TOTAL_MODES; i++) {
    String name = DISPLAY_STR[i];
    cp5.addTab(name);
    setTab(name, name, i, TAB_WIDTH, TAB_HEIGHT, mFont, true, false);
  }
  
  // brightness slider
  createHSlider("doSliderBrightness",         // function name
                0,                            // min value
                255,                          // max value
                MAX_BRIGHTNESS,               // starting value
                TAB_START - 95,               // x postion
                DEBUG_WINDOW_START + 35,      // y postion
                80,                           // width
                DEBUG_WINDOW_YSIZE,      // height
                "Brightness",                 // caption name
                20,                           // handle size
                lFont,                        // font
                Slider.FIX,              // slider type  (FIX or FLEXIBLE)
                "default");                   // tab
  cp5.getController("doSliderBrightness")
    .valueLabel()
      .align(ControlP5.CENTER, ControlP5.TOP);
        //.setPaddingX(0)
         //.setPaddingY(0);
         
  println(cp5.getController("doSliderBrightness").getValueLabel().getAlign());
  
  // auto mode toggle
  createToggle("doToggleAutoOn",              // function name
               "Auto Switch",                        // button name
               10,                            // x postion
               WINDOW_YSIZE - 255,            // y postion
               60,                            // width
               40,                            // height
               lFont,                         // font
               ControlP5.DEFAULT,             // toggle type (DEFAULT or SWITCH)
               autoOn,                        // starting value
               "default");                    // tab
  cp5.getController("doToggleAutoOn")
    .captionLabel()
      .align(ControlP5.RIGHT_OUTSIDE, ControlP5.BOTTOM_OUTSIDE)
        .setPaddingX(-50)
         .setPaddingY(5);
  
  // sets the auto mode switch point
  createTextfield("setAutoSwitch",            // function name
                  "@",                // caption name
                  80,                         // x postion
                  WINDOW_YSIZE - 255,         // y postion
                  60,                         // width
                  40,                         // height
                  nf(autoSwitch, 1, 2),       // starting value
                  lFont,                      // font
                  ControlP5.FLOAT,            // input filter (BITFONT, DEFAULT, FLOAT, or INTEGER)
                  "default");                 // tab
  cp5.getController("setAutoSwitch")
    .captionLabel()
      .align(ControlP5.LEFT_OUTSIDE, ControlP5.CENTER)
        .setPaddingX(-3);
  
  if (USE_MINIM) {
    createToggle("doToggleAudioOn",           // function name
                 "Audio",                     // button name
                 10,                          // x postion
                 WINDOW_YSIZE - 150,          // y postion
                 60,                          // width
                 30,                          // height
                 tabFont,                     // font
                 ControlP5.DEFAULT,           // toggle type
                 audioOn,                     // starting value
                 "default");                  // tab
    
    createToggle("doToggleAudioBackOn",       // function name
                 "Back",                      // button name
                 80,                          // x postion
                 WINDOW_YSIZE - 150,          // y postion
                 60,                          // width
                 30,                          // height
                 tabFont,                     // font
                 ControlP5.DEFAULT,           // toggle type
                 aBackOn,                     // starting value
                 "default");                  // tab
  }
  
  if (USE_SOPENNI) {
    createToggle("doToggleKinectOn",          // function name
                 "Kinect",                    // button name
                 10,                          // x postion
                 WINDOW_YSIZE - 100,          // y postion
                 60,                          // width
                 30,                          // height
                 tabFont,                     // font
                 ControlP5.DEFAULT,           // toggle type
                 kinectOn,                    // starting value
                 "default");                  // tab
    
    createToggle("doToggleUserMap",           // function name
                 "User",                      // button name
                 80,                          // x postion
                 WINDOW_YSIZE - 100,          // y postion
                 60,                          // width
                 30,                          // height
                 tabFont,                     // font
                 ControlP5.DEFAULT,           // toggle type
                 kinect.mapUser,              // starting value
                 "default");                  // tab
  }
  
  createToggle("doToggleScreenDebug",         // function name
               "Debug",                       // button name
               80,                            // x postion
               WINDOW_YSIZE - 50,             // y postion
               60,                            // width
               30,                            // height
               tabFont,                       // font
               ControlP5.DEFAULT,             // toggle type
               debugOn,                       // starting value
               "default");                    // tab
  
  createToggle("doToggleSimulate",            // function name
               "Simulate",                    // button name
               10,                            // x postion
               WINDOW_YSIZE - 50,             // y postion
               60,                            // width
               30,                            // height
               tabFont,                       // font
               ControlP5.DEFAULT,             // toggle type
               simulateOn,                    // starting value
               "default");                    // tab
}

// name, default text, x, y, color, font, tab
Textlabel createTextlabel(String name, String tx, int x, int y, color c, PFont f, String m2t) {
  Textlabel tl = cp5.addTextlabel(name, tx, x, y);
  //tl.setText(tx);
  tl.setColorValue(c);
  tl.setFont(f);
  tl.moveTo(m2t);
  return tl;
}

// function name, caption name, x, y, width, height, starting value, font, input filter, tab
Textfield createTextfield(String cN, String lN, int x, int y, int w, int h, String value, PFont f, int ty, String m2t) {
  Textfield tf = cp5.addTextfield(cN, x, y, w, h);
  
  tf.setPosition(x, y);
  tf.setText(value);
  tf.setSize(w, h);                                                  // set size to 50x50
  tf.setInputFilter(ty);
  tf.moveTo(m2t);
  tf.setAutoClear(false);
  tf.captionLabel().setFont(f);
  tf.valueLabel().setFont(f);
  tf.captionLabel().setText(lN);    
  tf.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tf.valueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  tf.setColorBackground(color(20,0,0));
  return tf;
}

// create a Slider controller
// controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
Slider createSlider(String cN, float s, float e, float v, int x, int y, int w, int h, String lN, int hs, PFont tf, int ty, String m2t) {
  Slider sc = cp5.addSlider(cN, s, e, v, x, y, w, h);
  
  sc.getValueLabel().setFont(tf);
  sc.getCaptionLabel().setFont(tf);
  sc.setLabel(lN);
  sc.setHandleSize(hs);
  sc.setSliderMode(ty);
  sc.moveTo(m2t);
  sc.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  sc.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
  
  sc.captionLabel().toUpperCase(false);
  return sc;
}

Slider createHSlider(String cN, float s, float e, float v, int x, int y, int w, int h, String lN, int hs, PFont tf, int ty, String m2t) {
  Slider sc = cp5.addSlider(cN, s, e, v, x, y, w, h);
  
  sc.getValueLabel().setFont(tf);
  sc.getCaptionLabel().setFont(tf);
  sc.setLabel(lN);
  sc.setHandleSize(hs);
  sc.setSliderMode(ty);
  sc.moveTo(m2t);
  //sc.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
  sc.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
  
  sc.captionLabel().toUpperCase(false);
  return sc;
}

Toggle createToggle(String controllerName, String textName, int x, int y, int w, int h, PFont tf, int tm, boolean value, String m2t) {
  Toggle tc = cp5.addToggle(controllerName);
  tc.setPosition(x, y);
  tc.setSize(w, h);                                                  // set size to 50x50
  tc.captionLabel().setFont(tf);
  tc.setMode(tm);
  tc.setValue(value);
  tc.captionLabel().toUpperCase(false);
  tc.captionLabel().setText(textName);                                 // set name
  tc.captionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE); // set alignment
  tc.moveTo(m2t);
  return tc;
}

void setTab(String cName, String tabName, int ID, int w, int h, PFont tf, boolean activate, boolean alwaysActive) {
  Tab tab = cp5.getTab(cName);            // get tab
  tab.captionLabel().setFont(tf);         // set tab font
  tab.setWidth(w);                        // set tab width
  tab.setHeight(h);                       // set tab height
  tab.setId(ID);                          // set tabs id
  tab.setAlwaysActive(alwaysActive);      // set tab as always active
  tab.activateEvent(activate);            // set tab as active
  tab.captionLabel().toUpperCase(false);  // allow lowercase text
  tab.setLabel(tabName);                  // set tab text
}

void doSliderBrightness(int v) {
  MAX_BRIGHTNESS = v;
}

void controlEvent(ControlEvent theEvent) {
  // tab?
  if ( theEvent.isTab() ) {
    int ID = theEvent.getTab().getId();
    if (ID > 0) DISPLAY_MODE = ID;
  }
}

// turn on auto mode
void doToggleAutoOn(boolean b) {
  autoOn = b;
}

void setAutoSwitch(String valueString) {
  autoSwitch = float(valueString);
}

// turn on debug
void doToggleScreenDebug(boolean b) {
  debugOn = b;
}

// turn on audio
void doToggleAudioOn(boolean b) {
  audioOn = b;
}

// turn on audio background
void doToggleAudioBackOn(boolean b) {
  aBackOn = b;
}

// turn on kinect
void doToggleKinectOn(boolean b) {
  kinectOn = b;
}

// turn on user depth mapping
void doToggleUserMap(boolean b) {
  kinect.mapUser = b;
}

// simulate wall
void doToggleSimulate(boolean b) {
  simulateOn = b;
}
