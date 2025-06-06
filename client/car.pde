class Car {
  private static final float ACCEL = 6.0;
  private static final float DEACCEL = 0.04;
  private static final float FRICTION = 0.978;

  private int nitro, nitroDelay;

  private float scale, recipScale;

  private PVector pos, vel, tract, offset;
  private PImage sprite;

  private boolean flip, stopX, stopY;

  public Car(PVector pos, float scale) {
    this.pos = pos;

    this.scale = scale;
    this.recipScale = 1 / scale;
 
    this.tract = new PVector(0, 0);
    this.vel = new PVector(0, 0);
    
    this.offset = new PVector(0, 0);
    
    this.nitro = 100;

    this.sprite = loadImage("../assets/sprites/player.png");
  }

  public void update(boolean[] keys) {
    vel.limit(200);
    listen(keys);
    pos.add(tract);
    pos.add(vel);

    vel.mult(FRICTION);
    display();
  }

  private void display() {
    pushMatrix();

    imageMode(CENTER);
    scale(scale);

    if (stopX && stopY) translate(width / 2 * recipScale, height / 2 * recipScale);
    else if (stopX) translate(width / 2 * recipScale, pos.y + offset.y);
    else if (stopY) translate(pos.x + offset.x, height / 2 * recipScale);
    else translate(pos.x + offset.x, pos.y + offset.y);

    rotate(vel.heading());

    if (flip) rotate(PI);
    image(sprite, 0, 0);

    popMatrix();
  }

  private void listen(boolean[] keys) {
    boolean w = keys[0];
    boolean a = keys[1];
    boolean s = keys[2];
    boolean d = keys[3];
    boolean space = keys[4];
    boolean v = keys[5];

    PVector targetTraction = new PVector(0, 0);

    // ACCELERATION/FORWARD
    if (w) {
      PVector forward = PVector.fromAngle(vel.heading());

      if (reversing) {
        forward.rotate(PI);

        if (vel.mag() < 5) {
          reversing = false;
          flip = false;
        }
      }

      tract.add(vel.copy().normalize().mult(0.2));
      forward.mult(ACCEL);
      vel.add(forward);
      toggledBack = false;

      if (!accelerationSound.isPlaying()) accelerationSound.play();
    } else {
      if (accelerationSound.isPlaying()) accelerationSound.stop();
    }

    // BRAKING/BACKWARDS
    if (s) {
      if (vel.mag() > 5 && !reversing) {
        vel.add(vel.copy().mult(-DEACCEL));
      }

      else {
        reversing = true;
        vel.limit(50);

        PVector backward = PVector.fromAngle(vel.heading());

        if (!toggledBack) {
          toggledBack = true;
          vel.rotate(PI);
          flip = true;
        }

        else backward.mult(DEACCEL * 40);

        vel.add(backward);
        tract.add(vel.copy().normalize().mult(-0.1));
      }
    }

    // TURNING
    if (a) {
      if (space) vel.rotate(constrain(-DEACCEL * (vel.mag() / 2), -DEACCEL, 0));
      else vel.rotate(constrain(-DEACCEL * (vel.mag() / 60), -DEACCEL, 0));
    }

    if (d) {
      if (space)
        vel.rotate(constrain(DEACCEL * (vel.mag() / 2), 0, DEACCEL));
      else vel.rotate(constrain(DEACCEL * (vel.mag() / 60), 0, DEACCEL));
    }
                          
    // DRIFTING
    if (space) {
      if (d) {
       if (!driftSound.isPlaying()) driftSound.play();

       targetTraction = vel.copy().mult(0.5).rotate(-PI / 2);
      }

      else if (a) {
        if (!driftSound.isPlaying()) driftSound.play();

        targetTraction = vel.copy().mult(0.5).rotate(PI / 2);
      }

      else driftSound.stop();

      vel.mult(0.985);
    } else {
      tract.mult(0.9);

      if (driftSound.isPlaying()) driftSound.stop();
    }
    
    // NITRO
    if (v) {
      if (nitro > 0) {
        vel.mult(1.3);
        nitro -= 1;
        nitroDelay = 500;
      } else {
        if (nitroDelay > 0) nitro += 1;
        nitroDelay -= 1;
      }
    }

    tract.lerp(targetTraction, 0.075);
  }

  public float getScale() {
    return scale;
  }

  public float getRecipScale() {
    return recipScale;
  }

  public PVector getVel() {
    return vel.copy();
  }
  
  public PVector getPos() {
    return pos.copy();
  }

  public PVector getOffset() {
    return offset.copy();
  }

  public void setOffset(PVector offset) {
    this.offset = offset;
  }

  public void setStopX(boolean stopX) {
    this.stopX = stopX;
  }

  public void setStopY(boolean stopY) {
    this.stopY = stopY;
  }
}
