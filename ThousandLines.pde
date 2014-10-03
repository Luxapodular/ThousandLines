import java.awt.Robot;
import java.awt.AWTException;
import processing.serial.*;
import java.awt.MouseInfo;
import java.awt.Point;

Robot rob;

ArrayList<ZoomLine> lines;

boolean mouseInWindow;

void setup() {
  size(700,500);
  lines = new ArrayList<ZoomLine>();
  createLines();
  //Set up Bot to move mouse
  try {
  rob = new Robot();
  }
  catch (AWTException e) {
    e.printStackTrace();
  }
}

void draw() {  
  background(255);
  mouseInWindow();
  moveMouse();
  updateLines();
}

void moveMouse() {
  if (mouseInWindow){
      float distance = dist(mouseX,mouseY,width/2,height/2);
      float speed = 3;
      int x = frame.getLocation().x;
      int y = frame.getLocation().y;
      float xChange;
      float yChange;
      if (mouseX < width/2) {
        xChange = -1;
      } else {
        xChange = +1;
      }
      if (mouseY < height/2) {
        yChange = 1;
      } else {
        yChange = -1;
      }
      rob.mouseMove((x + mouseX),(int) (y + mouseY));
  }
}

void createLines() {
  for (int i = 0; i < 100; i++) { // Top Left to center
    lines.add(new ZoomLine(0,0,width*.75,height*.5,false,-50,-50,0,0));
  }
  for (int i = 0; i < 100; i++) { //Top right to center
    lines.add(new ZoomLine(width,0,width*.75,height*.5,false,50,-50,0,0));
  }
  for (int i = 0; i < 100; i++) { //Bottom Right to Center
    lines.add(new ZoomLine(width,height,width*.75,height*.5,false,50,50,0,0));
  }
  for (int i = 0; i < 100; i++) { //Bottom Left to Center
    lines.add(new ZoomLine(0,height,width*.75,height*.5,false,-50,50,0,0));
  }
  for (int i = 0; i < 100; i++) { //Top bar
    lines.add(new ZoomLine(width/2 + 50,height/2 - 50,
                           width/2 - 50,height/2 - 50 ,true,-50,-50,50,-50));
  }
  for (int i = 0; i < 100; i++) { //Right Bar
    lines.add(new ZoomLine(width/2 + 50,height/2 + 50,
                           width/2 + 50,height/2 - 50 ,true,+50,-50,50,50));
  }
  for (int i = 0; i < 100; i++) { // Left Bar
    lines.add(new ZoomLine(width/2 - 50,height/2 - 50,
                           width/2 - 50,height/2 + 50 ,true,-50,+50,-50,-50));
  }
  for (int i = 0; i < 100; i++) { //Bottom Bar
    lines.add(new ZoomLine(width/2 - 50,height/2 + 50,
                           width/2 + 50,height/2 + 50 ,true,+50,+50,-50,+50));
  }
  for (int i = 0; i < 50; i++) { //Top center to center
    lines.add(new ZoomLine(width/2,0,height/2,height/2 - 50,false,0,-50,0,0));
  }
  for (int i = 0; i < 50; i++) { //Left to center
    lines.add(new ZoomLine(0,height/2,width/2 - 50,height/2,false,-50,0,0,0));
  }
  for (int i = 0; i < 50; i++) { //Bottom to center
    lines.add(new ZoomLine(width/2,height,width/2,height/2 + 50,false,0,50,0,0));
  }
  for (int i = 0; i < 50; i++) { //Right to center
    lines.add(new ZoomLine(width,height/2,width/2 + 50,height/2,false,50,0,0,0));
  }
}

void updateLines() {
  for (int i = 0; i < lines.size(); i++) {
    lines.get(i).update();
    lines.get(i).drawMe();

  }
}

class ZoomLine {
  Position start;
  Position lineLoc;
  Position lineEnd;
  Position goal;
  
  Position velocity;
  
  float lineLength;
  float angle;
  
  boolean moving;
  
  float noiseStart = random(100);
  float noiseChange = .007;
  
  float speed;
  
  float offSetX;
  float offSetY;
  
  float mouseOffX;
  float mouseOffY;
  
  float startOffX;
  float startOffY;
  
  ZoomLine(float startX, float startY, float goalX, float goalY, 
           boolean moving, float mouseOffX, float mouseOffY, 
           float startOffX, float startOffY) {
    
    this.start = new Position(startX, startY);
    this.goal = new Position(goalX, goalY);
    
    this.mouseOffX = mouseOffX;
    this.mouseOffY = mouseOffY;
    
    this.startOffX = startOffX;
    this.startOffY = startOffY;
    
    this.moving = moving;
    this.speed = 5;
   
    this.lineLoc = pointBetween(this.start.x, this.start.y,
                                this.goal.x, this.goal.y); 
    updateAngle();
    updateLength();
    updateLineEnd();
    float largest = max(width,height);
    offSetX = random(-largest * .03,largest * .03);
    offSetY = random(-largest * .03,largest * .03);
  }
  
  void updateSpeed() {
    float distance = dist(this.goal.x, this.goal.y,
                          this.start.x, this.start.y);
    this.speed = distance / this.lineLength;
  }
      
  void updateAngle() {
    float dx = this.goal.x - this.lineLoc.x;
    float dy = this.goal.y - this.lineLoc.y;
    
    this.angle = atan2(dy,dx);
  }
  
  void updateLength() {
    float distance = dist(this.goal.x, this.goal.y,
                          this.start.x, this.start.y);
    
    this.noiseStart += this.noiseChange;
    
    this.lineLength = (distance * .3) * noise(this.noiseStart);
  }
  
  Position pointBetween(float x1, float y1, float x2, float y2) { 
    float w = random(0,1);
    
    float xm = x1 * w + (1 - w) * x2;
    float ym = y1 * w + (1 - w) * y2;
   
    return new Position(xm, ym); 
  }
  
  void updateLineEnd() {
    float yChange = sin(this.angle) * this.lineLength;
    float xChange = cos(this.angle) * this.lineLength;
    this.lineEnd = new Position(this.lineLoc.x + xChange, this.lineLoc.y + yChange);
  }
  void drawMe() {
    strokeWeight(4);
    line(this.lineLoc.x + offSetX, this.lineLoc.y + offSetY, 
         this.lineEnd.x + offSetX, this.lineEnd.y + offSetY);
  } 
  
  void updateGoal() {
    if (mouseInWindow) {
      this.goal.x = mouseX + this.mouseOffX;
      this.goal.y = mouseY + this.mouseOffY;
    } else {
      this.goal.x = width/2;
      this.goal.y = height/2;
    }
    if ((this.moving) && (mouseInWindow)){
      this.start.x = mouseX + this.startOffX;
      this.start.y = mouseY + this.startOffY;
    }
  }
  void update() {
    this.updateGoal();
    this.updateAngle();
    this.updateLineEnd();
    this.move();
  }
  
  void move() {
    float distance = dist(this.lineLoc.x,this.lineLoc.y,this.goal.x, this.goal.y);
    this.lineLoc.x += this.speed*((this.goal.x - this.lineLoc.x)/distance);
    this.lineLoc.y += this.speed*((this.goal.y - this.lineLoc.y) / distance);
    
    if (dist(this.lineLoc.x, this.lineLoc.y,this.goal.x, this.goal.y) <= width * .02) {
          this.lineLoc.x = this.start.x;
          this.lineLoc.y = this.start.y;
          this.updateLength();
          this.updateSpeed();
    }
  }
}
  
void mouseInWindow() {
  Point mousePos = (MouseInfo.getPointerInfo().getLocation());
  int mWinX = mousePos.x;
  int mWinY = mousePos.y;
  int fX = frame.getLocation().x;
  int fY = frame.getLocation().y;
  if ((mWinX > fX && mWinX < fX + width) &&
     (mWinY > fY && mWinY < fY + height)) {
   mouseInWindow = true;
  } else {
   mouseInWindow = false;
  } 
}
    
class Position {
    float x;
    float y;
    Position(float x, float y) {
      this.x = x;
      this.y = y;
    }
}
 
class RandomPosition extends Position {
      RandomPosition(float startX, float endX, float startY, float endY) {
      super(random(startX, endX),random(startY, endY));
    }
}
