// ADD COMMENTS

import processing.video.*;

MovieClips movies;
Slider movieSlider;
Slider movieSpeed;

void setupClips() {
  println("VIDEO CLIPS - starting setup...");
  movies = new MovieClips(this, "videos");

  int x = TAB_START + 10;
  int y = WINDOW_YSIZE - 80;
  int m = movies.clips.length - 1;

  // controler name, min, max, value, x, y, width, height, label, handle size, text size, type, move to tab
  movieSlider = 
    createSlider("doMovieSlider", 0, m, movies.current, x, y, TAB_MAX_WIDTH + 20, 40, "Brightness", 20, lFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  movieSpeed = 
    createSlider("doMovieSpeed", movies.minSpeed, movies.maxSpeed, movies.speed, TAB_MAX_WIDTH-220, DEBUG_WINDOW_START+50, 220, 50, "Speed", 14, mFont, Slider.FLEXIBLE, DISPLAY_STR[DISPLAY_MODE_CLIPS]);

  // controll name, text name, x, y, width, height, text size, value, move 2 tab
  createToggle("allowMovieSwitch", "Random", TAB_START + 20, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, movies.switchOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createToggle("allowMovieJumps", "Jump", TAB_START + 80, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, movies.jumpsOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createToggle("allowMovieBPM", "BPM", TAB_START + 140, DEBUG_WINDOW_START + 50, 50, 50, mFont, ControlP5.DEFAULT, movies.bpmOn, DISPLAY_STR[DISPLAY_MODE_CLIPS]);

  createTextfield("setMinSpeed", "min speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+55, 50, 20, nf(movies.minSpeed, 1, 0), sFont, ControlP5.FLOAT, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  cp5.getController("setMinSpeed").captionLabel().align(ControlP5.CENTER, ControlP5.TOP_OUTSIDE);
  createTextfield("setMaxSpeed", "max speed", TAB_MAX_WIDTH + 10, DEBUG_WINDOW_START+80, 50, 20, nf(movies.maxSpeed, 1, 0), sFont, ControlP5.FLOAT, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  createTextfield("setMaxBPM", "max bpm", TAB_MAX_WIDTH + 70, DEBUG_WINDOW_START+65, 50, 30, nf(movies.maxBPM, 1), sFont, ControlP5.INTEGER, DISPLAY_STR[DISPLAY_MODE_CLIPS]);
  cp5.getController("setMaxBPM").captionLabel().align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER).setPaddingX(5);

  println("VIDEO CLIPS - setup finished!");
}

void doMovieSlider(int v) {
  movies.setClip(v);
}

void doMovieSpeed(float v) {
  if (!movies.bpmOn) movies.setSpeed(v);
}

void setMinSpeed(String valueString) {
  float minSpeed  = float(valueString);
  movies.minSpeed = minSpeed;
  movieSpeed.setMin(minSpeed);
  movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void setMaxSpeed(String valueString) {
  float maxSpeed  = float(valueString);
  movies.maxSpeed = maxSpeed;
  movieSpeed.setMax(maxSpeed);
  movieSpeed.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER).setPaddingX(5);
  movieSpeed.getCaptionLabel().align(ControlP5.CENTER, ControlP5.BOTTOM_OUTSIDE).setPaddingY(5);
}

void setMaxBPM(String valueString) {
  int maxBPM  = int(valueString);
  movies.maxBPM = maxBPM;
}

void allowMovieSwitch(boolean b) {
  movies.switchOn = b;
}

void allowMovieJumps(boolean b) {
  movies.jumpsOn = b;
}

void allowMovieBPM(boolean b) {
  movies.bpmOn = b;
}

void doClips() {
  //buffer.blendMode(ADD);
  buffer.background(0);
  movies.draw();
  buffer.blendMode(BLEND);
}

class MovieClips {
  float speed = 1.0;
  float minSpeed = 0.5;
  float maxSpeed = 1.0;
  int maxBPM = 130;

  int current = 0;
  Movie[] clips;
  int switch_count = 0;
  int jump_count = 0;
  String[] names;

  boolean switchOn = true;
  boolean jumpsOn  = true;
  boolean bpmOn    = true;

  MovieClips(PApplet app, String dir) {
    String[] movie_files = getFileNames(dir, "mov");
    clips = new Movie [movie_files.length];
    names = new String [movie_files.length];

    for (int i = 0; i < clips.length; i++) {
      //String[] parts = movie_files[i].split(java.io.File.pathSeparatorChar);
      names[i] = movie_files[i].substring(movie_files[i].lastIndexOf("\\")+1);
      println("CLIPS - loading clip - " + i + ": " + names[i]);
      clips[i] = new Movie(app, movie_files[i]);
      clips[i].loop();
    }
  }

  void setClip(int v) {
    if (switch_count > 7) {
      switch_count = 0;
      int seed = round(random(frameCount));
      randomSeed(seed);
    }
    
    current = v;
    cp5.getController("doMovieSlider").getCaptionLabel().setText(names[current]);
    switch_count++;
  }

  void setRandomClip() {
    int next = round( random(clips.length - 1) );
    setClip(next);
    movieSlider.setValue(current);
    //cp5.getController("doMovieSlider").setValue(current);
  }

  void setSpeed(float v) {
    clips[current].speed(v);
    speed = v;
  }
  
  void doJump() {
    if (jump_count > 7) {
      jump_count = 0;
      int seed = round(random(frameCount));
      noiseSeed(seed);
    }
    float spot = noise(xoff) * clips[current].duration();
    clips[current].jump( spot );
    jump_count++;
  }

  void update() {
    // switch clips?
    if ( audio.isOnBeat() ) {
      float test = random(0, 1);
      if (test > 0.75 && switchOn) {
        setRandomClip();
      } 
      else {
        if (jumpsOn) doJump();
      }
    }

    // read the new frame
    if (clips[current].available() == true) {
      clips[current].read();
    }

    // set the speed of the next frame according to the current BPM
    if (bpmOn) {
      speed = map(audio.BPM, 0, maxBPM, minSpeed, maxSpeed);
      clips[current].speed(speed);
      movieSpeed.setValue(speed);
    }
  }

  void draw() {
    update();
    buffer.image(clips[current], 0, 0); //, buffer.width, buffer.height);
  }
}
