ArrayList<Dot> dots;
float actTimer;
int currentAct;
float pulseInterval;
float lastPulseTime;
float spiralAngle;
float spiralSpeed;
float globalIntensity;
color bgColor;
float[] actStartTimes;
float fadeOutAlpha;
boolean ended;

void setup() {
  size(800, 600);
  frameRate(60);
  smooth();
  
  dots = new ArrayList<Dot>();
  dots.add(new Dot(width/2, height/2));
  
  actStartTimes = new float[8];
  actStartTimes[0] = 0;
  actStartTimes[1]  = 5;
  actStartTimes[2]  = 10;
  actStartTimes[3]  = 15;
  actStartTimes[4]  = 20;
  actStartTimes[5]  = 25;
  actStartTimes[6]  = 30;
  actStartTimes[7]  = 35;
  
  currentAct = 0;
  pulseInterval = 1.5;
  lastPulseTime = 0;
  spiralAngle = 0;
  spiralSpeed = 0.03;
  globalIntensity = 0.0;
  fadeOutAlpha = 0;
  ended = false;
}

void draw() {
  actTimer = millis() / 1000.0;
  
  updateAct();
  
  fill(bgColor);
  noStroke();
  rect(0, 0, width, height);
  
  if (!ended) {
    for (int i = dots.size() - 1; i >= 0; i--) {
      Dot d = dots.get(i);
      d.update();
      d.display();
    }
    
    performActBehavior();
  }
  
  if (currentAct == 6 && actTimer >= actStartTimes[6] && !ended) {
    fadeOutAlpha += 3;
    fill(0, 0, 0, fadeOutAlpha);
    rect(0, 0, width, height);
    
    if (fadeOutAlpha >= 255) {
      ended = true;
      dots.clear();
    }
  }
}

void updateAct() {
  for (int i = 0; i < actStartTimes.length - 1; i++) {
    if (actTimer >= actStartTimes[i] && actTimer < actStartTimes[i + 1]) {
      if (currentAct != i) {
        currentAct = i;
        onActEnter(currentAct);
      }
      break;
    }
  }
}

void onActEnter(int act) {
  switch(act) {
    case 0:
      globalIntensity = 0.2;
      addDot();
      break;
      
    case 1:
      globalIntensity = 0.35;
      addDot();
      lastPulseTime = actTimer;
      break;
      
    case 2:
      globalIntensity = 0.5;
      addDot();
      break;
      
    case 3:
      globalIntensity = 0.65;
      addDot();
      break;
      
    case 4:
      globalIntensity = 0.8;
      addDot();
      break;
      
    case 5:
      globalIntensity = 1.0;
      addDot();
      break;
      
    case 6:
      globalIntensity = 0.0;
      break;
  }
}

void addDot() {
  dots.add(new Dot(width/2 + random(-50, 50), height/2 + random(-50, 50)));
}

void deleteDot() {
  if (dots.size() > 1) {
    dots.remove(0);
  }
}

void performActBehavior() {
  switch(currentAct) {
    case 0:
      break;
      
    case 1:
      if (actTimer - lastPulseTime > pulseInterval) {
        pulse();
        lastPulseTime = actTimer;
        pulseInterval = max(0.4, pulseInterval * 0.85);
      }
      break;
      
    case 2:
      if (actTimer - lastPulseTime > pulseInterval) {
        pulse();
        lastPulseTime = actTimer;
        pulseInterval = max(0.3, pulseInterval * 0.85);
      }
      break;
      
    case 3:
      spiralAngle += spiralSpeed;
      for (int i = 0; i < dots.size(); i++) {
        Dot d = dots.get(i);
        float spiralForce = 1.0 * globalIntensity;
        d.vx += cos(spiralAngle + i * 0.5) * spiralForce;
        d.vy += sin(spiralAngle + i * 0.3) * spiralForce;
      }
      if (actTimer - lastPulseTime > pulseInterval) {
        pulse();
        lastPulseTime = actTimer;
        pulseInterval = max(0.3, pulseInterval * 0.85);
      }
      break;
      
    case 4:
      spiralAngle += spiralSpeed;
      for (int i = 0; i < dots.size(); i++) {
        Dot d = dots.get(i);
        float spiralForce = 1.5 * globalIntensity;
        d.vx += cos(spiralAngle + i * 0.6) * spiralForce;
        d.vy += sin(spiralAngle + i * 0.4) * spiralForce;
      }
      if (actTimer - lastPulseTime > pulseInterval) {
        pulse();
        lastPulseTime = actTimer;
        pulseInterval = max(0.25, pulseInterval * 0.85);
      }
      break;
      
    case 5:
      spiralAngle += spiralSpeed * 1.5;
      for (int i = 0; i < dots.size(); i++) {
        Dot d = dots.get(i);
        float spiralForce = 2.0 * globalIntensity;
        d.vx += cos(spiralAngle + i * 0.8) * spiralForce;
        d.vy += sin(spiralAngle + i * 0.7) * spiralForce;
        
        if (random(1) < 0.03) {
          d.panicFlare = 5;
        }
      }
      if (actTimer - lastPulseTime > pulseInterval) {
        pulse();
        lastPulseTime = actTimer;
        pulseInterval = max(0.2, pulseInterval * 0.85);
      }
      break;
      
    case 6:
      if (dots.size() > 1 && frameCount % 3 == 0) {
        deleteDot();
      }
      break;
  }
  
  float bgBrightness = map(globalIntensity, 0, 1, 0, 180);
  if (currentAct == 6) {
    bgColor = color(0, 0, 0);
  } else {
    bgColor = color(bgBrightness, bgBrightness, 0, 50);
  }
}

void pulse() {
  for (int i = 0; i < dots.size(); i++) {
    Dot d = dots.get(i);
    d.pulse(globalIntensity);
  }
}

class Dot {
  PVector pos;
  PVector prevPos;
  PVector vel;
  float vx, vy;
  float baseSize;
  float size;
  float redVal;
  float greenVal;
  float blueVal;
  float tremorStrength;
  float pulseTimer;
  int panicFlare;
  
  Dot(float x, float y) {
    pos = new PVector(x, y);
    prevPos = new PVector(x, y);
    vel = new PVector(0, 0);
    vx = 0;
    vy = 0;
    baseSize = random(12, 22);
    size = baseSize;
    redVal = 200;
    greenVal = 50;
    blueVal = 50;
    tremorStrength = random(1.5, 3.5);
    pulseTimer = 0;
    panicFlare = 0;
  }
  
  void update() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
    
    float tremorX = random(-tremorStrength, tremorStrength) * globalIntensity * 2.0;
    float tremorY = random(-tremorStrength, tremorStrength) * globalIntensity * 2.0;
    
    pos.x += vel.x + tremorX;
    pos.y += vel.y + tremorY;
    
    vel.x *= 0.92;
    vel.y *= 0.92;
    vx *= 0.92;
    vy *= 0.92;
    
    if (pos.x < 10) { pos.x = 10; vel.x *= -0.5; }
    if (pos.x > width - 10) { pos.x = width - 10; vel.x *= -0.5; }
    if (pos.y < 10) { pos.y = 10; vel.y *= -0.5; }
    if (pos.y > height - 10) { pos.y = height - 10; vel.y *= -0.5; }
    
    updateColor();
    
    if (pulseTimer > 0) {
      pulseTimer -= 0.15;
      size = baseSize * (1 + pulseTimer * 0.8);
    } else {
      size = baseSize;
    }
    
    if (panicFlare > 0) {
      panicFlare--;
      redVal = 255;
      greenVal = 0;
      blueVal = 0;
    }
  }
  
  void updateColor() {
    redVal = lerp(redVal, 220, 0.05);
    greenVal = lerp(greenVal, 30, 0.05);
    blueVal = lerp(blueVal, 30, 0.05);
  }
  
  void display() {
    noStroke();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(frameCount * 0.02);
    
    float heartSize = size;
    
    beginShape();
    fill(redVal, greenVal, blueVal, 200);
    vertex(0, -heartSize * 0.8);
    vertex(-heartSize * 0.6, -heartSize * 0.4);
    vertex(-heartSize * 0.8, 0);
    vertex(-heartSize * 0.4, heartSize * 0.4);
    vertex(0, heartSize * 0.8);
    vertex(heartSize * 0.4, heartSize * 0.4);
    vertex(heartSize * 0.8, 0);
    vertex(heartSize * 0.6, -heartSize * 0.4);
    endShape(CLOSE);
    
    popMatrix();
    
    if (globalIntensity > 0.4) {
      pushMatrix();
      translate(prevPos.x, prevPos.y);
      rotate(frameCount * 0.02);
      
      beginShape();
      fill(redVal, greenVal, blueVal, 80);
      vertex(0, -heartSize * 0.8);
      vertex(-heartSize * 0.6, -heartSize * 0.4);
      vertex(-heartSize * 0.8, 0);
      vertex(-heartSize * 0.4, heartSize * 0.4);
      vertex(0, heartSize * 0.8);
      vertex(heartSize * 0.4, heartSize * 0.4);
      vertex(heartSize * 0.8, 0);
      vertex(heartSize * 0.6, -heartSize * 0.4);
      endShape(CLOSE);
      
      popMatrix();
      
      if (globalIntensity > 0.7) {
        pushMatrix();
        translate(prevPos.x - (pos.x - prevPos.x) * 0.5, 
                  prevPos.y - (pos.y - prevPos.y) * 0.5);
        rotate(frameCount * 0.02);
        
        beginShape();
        fill(redVal, greenVal, blueVal, 40);
        vertex(0, -heartSize * 0.6);
        vertex(-heartSize * 0.45, -heartSize * 0.3);
        vertex(-heartSize * 0.6, 0);
        vertex(-heartSize * 0.3, heartSize * 0.3);
        vertex(0, heartSize * 0.6);
        vertex(heartSize * 0.3, heartSize * 0.3);
        vertex(heartSize * 0.6, 0);
        vertex(heartSize * 0.45, -heartSize * 0.3);
        endShape(CLOSE);
        
        popMatrix();
      }
    }
    
    if (panicFlare > 0) {
      fill(255, 50, 50, 100);
      ellipse(pos.x, pos.y, size * 5, size * 5);
    }
  }
  
  void pulse(float intensity) {
    pulseTimer = intensity * 4;
    baseSize = random(12, 25) * (1 + intensity * 0.5);
  }
}
