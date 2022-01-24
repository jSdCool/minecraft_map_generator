void setup() {
  size(1280,720);
  JSONArray file=loadJSONArray("data/blockMapColors.json");
  for(int i=0;i<file.size();i++){
   blocks.add(new Block(file.getJSONObject(i))); 
  }
  println(blocks.size());
}
ArrayList<Block> blocks=new ArrayList<Block>();
int[][] map=new int[128][128];
PImage source;
boolean validImage=false,mapReady=false;

void draw(){
 background(230);
 fill(0);
 rect(100,100,128,128);
 if(validImage){
  image(source,100,100); 
 }
 fill(200);
 stroke(0);
 strokeWeight(1);
 rect(50,400,200,50);
 fill(0);
 textAlign(CENTER,CENTER);
 textSize(25);
 text("load image",150,425);
 strokeWeight(0);
 if(mapReady){
   for(int i=0;i<map.length;i++){
    for(int j=0;j<map[i].length;j++){
      fill(blocks.get(map[i][j]).getColor());
      rect(i*3+400,j*3+100,3,3);
      
    }
   }
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
    try{
    source=loadImage(selection.getAbsolutePath());
    source.resize(128,128);
    }catch(Exception e){
     return ;
    }
    validImage=true;
    source.loadPixels();
    determinemap();
  }
}

void mouseClicked(){
  if(mouseButton==LEFT){
    if(mouseX>=50&&mouseX<=250&&mouseY>=400&&mouseY<=450){
      selectInput("select image:", "fileSelected");
    }
  }
}

void determinemap(){
  for(int i=0;i<source.pixels.length;i++){
    int x=i%128,y=i/128;
    map[x][y]=bestBlock(source.pixels[i]);
  }
  mapReady=true;
}

int bestBlock(int pixle){
 // print(pixle+" ");
 //pixle-=16777215;
 //int red=pixle/(256*256);
 //pixle-=red*256*256;
 //int green =pixle/256;
 //int blue=pixle-green*256;
 float red=red(pixle),green=green(pixle),blue=blue(pixle);
 float lowestDelta=100000;
 int index=-1;
 for(int i=0;i<blocks.size();i++){
   float[] delts = blocks.get(i).deltaValues(red,green,blue);
   float delta = (delts[0]+delts[1]+delts[2])/3;
   if(delta<lowestDelta){
     lowestDelta=delta;
     index=i;
   }
 }
 println(" "+lowestDelta);
  return index;
}
