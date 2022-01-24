class Block{
 String name;
 int vertadjust;
 public float[] rgb=new float[3];
 Block(JSONObject file,int verticlaOffset){
   vertadjust=verticlaOffset;
   name=file.getString("block");
   rgb[0]=file.getFloat("red");
   rgb[1]=file.getFloat("green");
   rgb[2]=file.getFloat("blue");
   switch(verticlaOffset){
    case 1:
    rgb[0]*=1;
   rgb[1]*=1;
   rgb[2]*=1;
    break;
    case 0:
    rgb[0]*=0.86;
   rgb[1]*=0.86;
   rgb[2]*=0.86;
    break;
    case -1:
    rgb[0]*=0.71;
   rgb[1]*=0.71;
   rgb[2]*=0.71;
    break;
   }
 }
 
 String export(int x,int z){
  curheight+=vertadjust;
  return "setblock ~"+x+" ~"+curheight+" ~"+z+" "+name; 
  
 }
 
 
 float[] deltaValues(float r,float g, float b){
  float out[]=new float[3];
  out[0]=abs(rgb[0]-r);
  out[1]=abs(rgb[1]-g);
  out[2]=abs(rgb[2]-b);
  
  return out;
 }
 
 color getColor(){
   return color(rgb[0],rgb[1],rgb[2]);
 }
 
 String toString(){
  return name; 
 }
 void calcHeight(){
   avgheight+=vertadjust;
 }
}
