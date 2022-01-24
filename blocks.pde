class Block{
 String name;
 public float[] rgb=new float[3];
 Block(JSONObject file){
   name=file.getString("block");
   rgb[0]=file.getFloat("red");
   rgb[1]=file.getFloat("green");
   rgb[2]=file.getFloat("blue");
 }
 
 String export(int x,int y,int z){
  return "setblock ~"+x+" ~"+y+" ~"+z+" "+name; 
  
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
}
