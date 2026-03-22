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

void setup() {
  size(800, 600);
  frameRate(60);
  smooth();
  
  dots = new ArrayList<Dot>();
  dots.add(new Dot(width/2, height/2));
  
  actStartTimes = new float[7];
  actStartTimes[0] = 0;
  actStartTimes[1] = 3;
  actStartTimes[2] = 6;
  actStartTimes[3] = 9;
  actStartTimes[4] = 12;
  actStartTimes[5] = 18;
  actStartTimes[6] = 24;
  
  currentAct = 0;
  pulseInterval = 1.5;
  lastPulseTime = 0;
  spiralAngle = 0;
  spiralSpeed = 0.03;
  globalIntensity = 0.0;
  bgColor = color(0, 0, 0, 100);
}

void draw() {
  actTimer = millis() / 1000.0;
  
  updateAct();
  
  fill(bgColor);
  noStroke();
  rect(0, 0, width, height);
  
  for (int i = dots.size() - 1; i >= 0; i--) {
    Dot d = dots.get(i);
    d.update();
    d.display();
  }
  
  performActBehavior();
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
      bgColor = color(0, 0, 0, 100);
      globalIntensity = 0.2;
      break;
      
    case 1:
      bgColor = color(0, 0, 5, 100);
      globalIntensity = 0.4;
      lastPulseTime = actTimer;
      break;
      
    case 2:
      bgColor = color(40, 20, 10, 100);
      globalIntensity = 0.6;
      break;
      
    case 3:
      bgColor = color(20, 40, 15, 100);
      globalIntensity = 0.8;
      break;
      
    case 4:
      bgColor = color(0, 60, 20, 95);
      globalIntensity = 1.0;
      break;
      
    case 5:
      bgColor = color(0, 0, 5, 90);
      globalIntensity = 0.3;
      break;
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
        pulseInterval = max(0.4, pulseInterval * 0.8);
      }
      break;
      
    case 2:
      if (actTimer - lastPulseTime > pulseInterval) {
        pulse();
        lastPulseTime = actTimer;
        pulseInterval = max(0.3, pulseInterval * 0.9);
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
      break;
      
    case 4:
      spiralAngle += spiralSpeed;
      for (int i = 0; i < dots.size(); i++) {
        Dot d = dots.get(i);
        float spiralForce = 2.0 * globalIntensity;
        d.vx += cos(spiralAngle + i * 0.8) * spiralForce;
        d.vy += sin(spiralAngle + i * 0.7) * spiralForce;
        
        if (random(1) < 0.02) {
          d.panicFlare = 5;
        }
      }
      break;
      
    case 5:
      break;
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
  float red;
  float green;
  float blue;
  float tremorStrength;
  float pulseTimer;
  int panicFlare;
  
  Dot(float x, float y) {
    pos = new PVector(x, y);
    prevPos = new PVector(x, y);
    vel = new PVector(0, 0);
    vx = 0;
    vy = 0;
    baseSize = random(8, 15);
    size = baseSize;
    red = 100;
    green = 100;
    blue = 150;
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
    
    if (pos.x < 5) { pos.x = 5; vel.x *= -0.5; }
    if (pos.x > width - 5) { pos.x = width - 5; vel.x *= -0.5; }
    if (pos.y < 5) { pos.y = 5; vel.y *= -0.5; }
    if (pos.y > height - 5) { pos.y = height - 5; vel.y *= -0.5; }
    
    updateColor();
    
    if (pulseTimer > 0) {
      pulseTimer -= 0.15;
      size = baseSize * (1 + pulseTimer * 0.8);
    } else {
      size = baseSize;
    }
    
    if (panicFlare > 0) {
      panicFlare--;
      red = 255;
      green = 50;
      blue = 50;
    }
  }
  
  void updateColor() {
    float targetRed = map(globalIntensity, 0, 1, 100, 240);
    float targetGreen = map(globalIntensity, 0, 1, 100, 40);
    float targetBlue = map(globalIntensity, 0, 1, 150, 30);
    
    red = lerp(red, targetRed, 0.08);
    green = lerp(green, targetGreen, 0.08);
    blue = lerp(blue, targetBlue, 0.08);
    
    float distToLeft = pos.x;
    float distToRight = width - pos.x;
    float distToTop = pos.y;
    float distToBottom = height - pos.y;
    
    float minDist = distToLeft;
    if (distToRight < minDist) minDist = distToRight;
    if (distToTop < minDist) minDist = distToTop;
    if (distToBottom < minDist) minDist = distToBottom;
    
    float edgeDarkness = map(minDist, 0, 150, 0.4, 1.0);
    edgeDarkness = constrain(edgeDarkness, 0.4, 1.0);
    
    red = red * edgeDarkness;
    green = green * edgeDarkness;
    blue = blue * edgeDarkness;
  }
  
  void display() {
    noStroke();
    
    fill(red, green, blue, 200);
    ellipse(pos.x, pos.y, size, size);
    
    if (globalIntensity > 0.4) {
      fill(red, green, blue, 100);
      ellipse(prevPos.x, prevPos.y, size * 0.8, size * 0.8);
      
      if (globalIntensity > 0.7) {
        fill(red, green, blue, 50);
        ellipse(prevPos.x - (pos.x - prevPos.x) * 0.5, 
                prevPos.y - (pos.y - prevPos.y) * 0.5, 
                size * 0.6, size * 0.6);
      }
    }
    
    if (panicFlare > 0) {
      fill(255, 100, 100, 120);
      ellipse(pos.x, pos.y, size * 5, size * 5);
    }
  }
  
  void pulse(float intensity) {
    pulseTimer = intensity * 4;
    baseSize = random(8, 18) * (1 + intensity * 0.6);
  }
}
