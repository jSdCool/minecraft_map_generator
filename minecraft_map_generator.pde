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
String message="";
int msgtmr=0;

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
 fill(200);
 rect(50,500,200,50);
 fill(0);
 textSize(22);
 text("export as mcfunction",150,525);
 strokeWeight(0);
 if(mapReady){
   for(int i=0;i<map.length;i++){
    for(int j=0;j<map[i].length;j++){
      fill(blocks.get(map[i][j]).getColor());
      rect(i*3+400,j*3+100,3,3);
      
    }
   }
 }
 if(msgtmr>millis()){
  fill(0);
  textSize(50);
  text(message,width/2,600);
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
      message="failed to load image";
 msgtmr=millis()+1000;
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
    if(mouseX>=50&&mouseX<=250&&mouseY>=500&&mouseY<=550){
      export();
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
  return index;
}

void export(){
    
if(mapReady){
  PrintWriter output= createWriter("map.mcfunction");
   for(int x=0;x<map.length;x++){
    for(int z=0;z<map[x].length;z++){
      String cmd=blocks.get(map[x][z]).export(x,0,z);
      output.println(cmd);
    }
   }
   output.flush(); 
  output.close();
 }else{
  message="exported failed";
 msgtmr=millis()+1000;
 return;
 }
 message="exported successfuly";
 msgtmr=millis()+1000;
}
