void setup() {
  size(1280, 720);
  JSONArray file=loadJSONArray("data/blockMapColors.json");
  for (int i=0; i<file.size(); i++) {
    blocks.add(new Block(file.getJSONObject(i), 0));
  }
  for (int v=-1; v<2; v+=2) {
    for (int i=0; i<file.size(); i++) {
      moreBlocks.add(new Block(file.getJSONObject(i), v));
    }
  }
  println(blocks.size());
  println(moreBlocks.size());
}
ArrayList<Block> blocks=new ArrayList<Block>(), moreBlocks=new ArrayList<Block>();
int[][] map=new int[128][128];
PImage source;
boolean validImage=false, mapReady=false, extendedColorRange=true;
String message="",mapS="1X1";
int msgtmr=0, curheight=0, avgheight=0,aproximationMode=1,mapSize=128,layout=1;

void draw() {
  background(230);
  fill(0);
  rect(100, 100, mapSize, mapSize);
  if (validImage) {
    image(source, 100, 100);
  }
  fill(200);
  stroke(0);
  strokeWeight(1);
  rect(50, 400, 200, 50);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(25);
  text("load image", 150, 425);
  fill(200);
  rect(50, 500, 200, 50);
  fill(0);
  textSize(22);
  text("export as mcfunction", 150, 525);
  fill(200);
  rect(800+120,100,300,50);
  fill(0);
  text("extended color mode: "+extendedColorRange,950+120,125);
  fill(200);
  rect(800+120,200,300,50);
  fill(0);
  text("map size: "+mapS,950+120,225);
  strokeWeight(0);
  if (mapReady) {
    int pw=3;
    if(layout==1){
       pw=3; 
      }
      if(layout==2){
       pw=2; 
      }
    for (int i=0; i<map.length; i++) {
      for (int j=0; j<map[i].length; j++) {
        int indx=map[i][j];
        color col;
        if (indx>60) {
          col=moreBlocks.get(indx-62).getColor();
        } else {
          col=blocks.get(indx).getColor();
        }
        fill(col);
        rect(i*pw+400, j*pw+100, pw, pw);
      }
    }
  }
  if (msgtmr>millis()) {
    fill(0);
    textSize(50);
    text(message, width/2, 600);
  }
}


void fileSelected(File selection) {
  validImage=false;
  mapReady=false;
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    return;
  } else {
    println("User selected " + selection.getAbsolutePath());
    try {
      source=loadImage(selection.getAbsolutePath());
      source.resize(mapSize, mapSize);
    }
    catch(Exception e) {
      message="failed to load image";
      msgtmr=millis()+1000;
      return ;
    }
    validImage=true;
    source.loadPixels();
    determinemap();
  }
}

void mouseClicked() {
  if (mouseButton==LEFT) {
    if (mouseX>=50&&mouseX<=250&&mouseY>=400&&mouseY<=450) {
      selectInput("select image:", "fileSelected");
    }
    if (mouseX>=50&&mouseX<=250&&mouseY>=500&&mouseY<=550) {
      export();
    }
    if (mouseX>=800+120&&mouseX<=1200+120&&mouseY>=100&&mouseY<=150) {
      if(extendedColorRange){
        extendedColorRange=false;
      }else{
        extendedColorRange=true;
      }
      mapReady=false;
      determinemap();
    }
    if(mouseX>=800+120&&mouseX<=1200+120&&mouseY>=200&&mouseY<=250){
      layout++;
      if(layout==3){
       layout=1; 
      }
      if(layout==1){
       mapSize=128; 
       mapS="1X1";
      }
      if(layout==2){
       mapSize=256;
       mapS="2X2";
      }
      map=new int[mapSize][mapSize];
      if(source!=null){
      source.resize(mapSize,mapSize);
      
      mapReady=false;
      determinemap();
      }
    }
  }
}

void determinemap() {
  for (int i=0; i<source.pixels.length; i++) {
    int x=i%mapSize, y=i/mapSize;
    map[x][y]=bestBlock(source.pixels[i]);
  }
  mapReady=true;
}

int bestBlock(int pixle) {
  float red=red(pixle), green=green(pixle), blue=blue(pixle);
  float lowestDelta=100000;
  int index=-1;

  for (int i=0; i<blocks.size(); i++) {
    float[] delts = blocks.get(i).deltaValues(red, green, blue);
    float delta = (delts[0]+delts[1]+delts[2])/3;
    if (delta<lowestDelta) {
      lowestDelta=delta;
      index=i;
    }
  }
  if (extendedColorRange) {
    for (int i=0; i<moreBlocks.size(); i++) {
      float[] delts = moreBlocks.get(i).deltaValues(red, green, blue);
      float delta = aproxamateColor(delts,(int)moreBlocks.get(i).rgb[0],(int)red);
      if (delta<lowestDelta) {
        lowestDelta=delta;
        index=i+62;
      }
    }
  }
  return index;
}

void export() {

  if (mapReady) {
    PrintWriter output= createWriter("map.mcfunction");
    for (int x=0; x<map.length; x++) {
      if (extendedColorRange) {
        int max=0, min=0;
        avgheight=0;
        curheight=0;
        for (int z=0; z<map[x].length; z++) {
          int indx=map[x][z];
          if (indx>60) {
            moreBlocks.get(indx-62).calcHeight();
          } else {
            blocks.get(indx).calcHeight();
          }
          min=Math.min(min, avgheight);
          max=Math.max(max, avgheight);
        }
        avgheight=abs(min);
        curheight=avgheight;
      }
      output.println("setblock ~"+x+" ~"+curheight+" ~-1 minecraft:stone");
      for (int z=0; z<map[x].length; z++) {
        int indx=map[x][z];
        String cmd;
        if (indx>60) {
          cmd=moreBlocks.get(indx-62).export(x, z);
        } else {
          cmd=blocks.get(indx).export(x, z);
        }
        output.println(cmd);
      }
    }
    output.flush();
    output.close();
  } else {
    message="exported failed";
    msgtmr=millis()+1000;
    return;
  }
  message="exported successfuly";
  msgtmr=millis()+1000;
}

float aproxamateColor(float[] deltas,int rb,int rp){
  switch(aproximationMode){
    case 1:
    return(deltas[0]+deltas[1]+deltas[2])/3;
    case 2:
    return (float)Math.sqrt(deltas[0]*deltas[0]+deltas[1]*deltas[1]+deltas[2]*deltas[2]);
    case 3:
    return (float)Math.pow(Math.pow(deltas[0],3)+Math.pow(deltas[1],3)+Math.pow(deltas[2],3),1/3.0);
    case 4:
    return (float)Math.pow(Math.pow(deltas[0],6)+Math.pow(deltas[1],6)+Math.pow(deltas[2],6),1/6.0);
    case 5: 
    return (float) sqrt((2+(0.5*(rb+rp)))*pow(deltas[0],2)+4*pow(deltas[1],2)+(2+(255-(0.5*(rb+rp))/256))*pow(deltas[2],2));

    
  }
  return 1000000000;
}
