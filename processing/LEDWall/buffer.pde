// move to LEDWall

PGraphics buffer;

void setupBuffer() {
  buffer = createGraphics(COLUMNS, ROWS, P3D);  
  buffer.smooth(8);
  //buffer.hint(DISABLE_DEPTH_TEST);
  //buffer.hint(DISABLE_DEPTH_MASK);
  buffer.beginDraw();
  buffer.background(0);
  buffer.endDraw();
  buffer.loadPixels();
  println("BUFFER SETUP ...");
}


