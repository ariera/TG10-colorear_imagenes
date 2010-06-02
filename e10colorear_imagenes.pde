/********************************************************
 *                                                       *
 *  24/05/2010                                           *
 *  TÉCNICAS GRAFICAS - Ejercicio 10: Colorear imagenes  *
 *                                                       *
 *  Alejandro Riera Mainar                               *
 *  NºMat: 010381                                        *
 *  ariera@gmail.com                                     *
 *                                                       *
 ********************************************************/
int NEIGHBOURHOOD_SIZE = 13;
boolean DEBUGGING = false;
PImage source, object, object_ref;
int TITLE_HEIGHT = 30;

void setup() {
  colorMode(RGB);
  source  = loadImage("lena.jpg");
  //object_ref = loadImage("natalie.jpg");  
  object  = loadImage("natalie2.jpg");
  size(2*source.width,2*source.height+TITLE_HEIGHT);
  image(source,0,TITLE_HEIGHT);
  image(object,source.width,TITLE_HEIGHT);
  process(source, object);
  displayTitle();
}


void displayTitle(){
  textFont(createFont("Helvetica", 18));
  fill(color(0));
  text("Ejercicio 10: Coloreado de Imagenes" , 10, 20);
}

void displayImgDesc(int base_width, int base_height){
  textFont(createFont("Helvetica", 18));
  fill(color(0));
  rect(0, TITLE_HEIGHT, 75, 20);
  rect(base_width, TITLE_HEIGHT, 75, 20);
  rect(0, base_height+TITLE_HEIGHT, 160, 20);
  rect(base_width, base_height+TITLE_HEIGHT, 75, 20);
  fill(color(255));
  text("source", 10, 17+TITLE_HEIGHT);  
  text("object", base_width + 10, 17+TITLE_HEIGHT);
  text("equalized source", 10, base_height + 17+TITLE_HEIGHT);  
  text("colored", base_width + 10, base_height + 17+TITLE_HEIGHT);
}

void draw() {

}

void process(PImage src, PImage obj){
  int pix;
  src.loadPixels();
  obj.loadPixels();
  LABImage labsrc = new LABImage(src);
  LABImage labobj = new LABImage(obj);
  labsrc.print_stats(10);

  equalizeLimunosity(labsrc,labobj);
  for(int i=0; i < labobj.imagen.length; i++){
    pix = selectBestPixelRandomly(labsrc, labobj, i);
    copyColors(labsrc, pix, labobj, i);
    if ((i % 10000) == 0)
      println(i);
  }


  labobj.to_rgb(obj);
  labsrc.to_rgb(src);

  obj.updatePixels();
  src.updatePixels();
  image(obj,src.width,src.height+TITLE_HEIGHT);
  image(src,0,src.height+TITLE_HEIGHT);
  displayImgDesc(src.width, src.height);
}

void equalizeLimunosity(LABImage lab_src, LABImage lab_obj){
  //  lab_src.print_stats(20);
  //  lab_obj.print_stats(0);
  for (int x = 0; x < lab_src.imagen.length; x++) 
    lab_src.set_lum(x, lab_obj.mean + (lab_obj.deviation/lab_src.deviation) * (lab_src.lum(x) - lab_src.mean));
  lab_src.calculate_statistics();
  //    lab_src.print_stats(20);
}

float distanceStatistical(LABImage src, int src_pix, LABImage obj, int obj_pix){
  float means_diff = src.pixel_lum_mean(src_pix) - obj.pixel_lum_mean(obj_pix);
  float deviation_diff = src.pixel_lum_deviation(src_pix) - obj.pixel_lum_deviation(obj_pix);
  return (pow(means_diff,2) + pow(deviation_diff,2));
}

int selectBestPixelRandomly(LABImage src, LABImage obj, int obj_pix){
  int best_pixel = (int)random(src.imagen.length);
  float best_distance = distanceStatistical(src, best_pixel, obj, obj_pix);
  int candidate_pixel; 
  float candidate_distance;
  int count=0;
  for(int i = 0; i < src.imagen.length / 1250; i++){
    candidate_pixel = (int)random(src.imagen.length);
    candidate_distance = distanceStatistical(src, candidate_pixel, obj, obj_pix) ;
    if (candidate_distance < best_distance){
      count++;
      best_distance = candidate_distance;
      best_pixel = candidate_pixel;
    }
  }
  //  if ((obj_pix % 2000) == 0 && count > 0)
  //    println("count = " + count);
  return best_pixel;
}

void copyColors(LABImage src, int src_pix, LABImage obj, int obj_pix){
  obj.set_alfa(obj_pix, src.alfa(src_pix));
  obj.set_beta(obj_pix, src.beta(src_pix));
}





public class LABImage {
  float[][] imagen;
  int _width, _height, neighbourhood_size;
  float mean;
  float deviation;

  LABImage(PImage img){
    int loc = 0;
    this._width = img.width;
    this._height = img.height;
    if ((NEIGHBOURHOOD_SIZE % 2) == 0)
      throw new IllegalStateException("Neighbourhood size should be an odd number");
    else
      this.neighbourhood_size = NEIGHBOURHOOD_SIZE;
    this.imagen = new float[img.width*img.height][];
    for (int x = 0; x < img.width; x++) {
      for (int y = 0; y < img.height; y++) {
        loc = x + y*img.width;
        this.imagen[loc] = rgb_to_lab(img.pixels[loc]);
      }
    }
    calculate_statistics();
    println("lab imagen creada");
  }

  public void print_stats(int _size){
    int pix;
    println("- STATS --------------------------------");
    println("mean: " + this.mean + " deviation: " + this.deviation);
    for(int i=0; i < _size; i++){
      pix = (int)random(this.imagen.length);
      println("\t[" + pix + "] " + "mean: " + this.pixel_lum_mean(pix) + ", dev: " + this.pixel_lum_deviation(pix));
    }
  }

  public float lum(int loc){
    return this.imagen[loc][0]; 
  }
  public float alfa(int loc){
    return this.imagen[loc][1]; 
  }
  public float beta(int loc){
    return this.imagen[loc][2]; 
  }
  public float pixel_lum_mean(int loc){
    return this.imagen[loc][3]; 
  }
  public float pixel_lum_deviation(int loc){
    return this.imagen[loc][4]; 
  }
  public void set_lum(int loc, float l){
    this.imagen[loc][0] = l; 
  }
  public void set_alfa(int loc, float a){
    this.imagen[loc][1] = a; 
  }
  public void set_beta(int loc, float b){
    this.imagen[loc][2] = b; 
  }
  private void set_pixel_lum_mean(int loc, float mean){
    this.imagen[loc][3] = mean; 
  }
  private void set_pixel_lum_deviation(int loc, float deviation){
    this.imagen[loc][4] = deviation; 
  }
  public void to_rgb(PImage img){
    for (int x = 0; x < this.imagen.length; x++)
      img.pixels[x] = lab_to_rgb(this.imagen[x]);
    println("to rgb");
  }

  private color lab_to_rgb(float[] lab){
    int r,g,b = 0;
    float L,M,S = 0;
    L= 0.57735*lab[0] + 0.40825*lab[1] + 0.70711*lab[2];
    M= 0.57735*lab[0] + 0.40825*lab[1] - 0.70711*lab[2];
    S= 0.57735*lab[0] - 0.81650*lab[1] + 0.00000*lab[2];

    //    L = invLog10(L);
    //    M = invLog10(M);
    //    S = invLog10(S);

    r = round(L * 4.468670 - M * 3.588676 + S * 0.119604);
    g = round(L * (-1.219717) + M * 2.383088 - S * 0.162630);
    b = round(L * 0.058508 - M * 0.261078 + S * 1.205666);
    return color((int)r, (int)g, (int)b);
  }
  private float[] rgb_to_lab(color c){
    float l,a,b,L,M,S = 0;
    float[] labColor = new float[5];
    L = red(c) * 0.3811 + green(c) * 0.5783 + blue(c) * 0.0402;
    M = red(c) * 0.1967 + green(c) * 0.7244 + blue(c) * 0.0782;
    S = red(c) * 0.0241 + green(c) * 0.1288 + blue(c) * 0.8444;

    l = 0.57735 * L + 0.57735 * M + 0.57735 * S;
    a = 0.40825 * L + 0.40825 * M - 0.81650 * S;  
    b = 0.70711 * L - 0.70711 * M + 0.00000 * S;


    //    l = 0.57735 * log10(L) + 0.57735 * log10(M) + 0.57735 * log10(S);
    //    a = 0.40825 * log10(L) + 0.40825 * log10(M) - 0.81650 * log10(S);  
    //    b = 0.70711 * log10(L) - 0.70711 * log10(M) + 0.00000 * log10(S);

    labColor[0]=l;
    labColor[1]=a;
    labColor[2]=b;
    return labColor;
  }

  public float calculate_neighbour_limunosity_mean(int pix){
    double mean = 0;
    int loc = 0;
    for (int i = -floor(this.neighbourhood_size/2); i <= floor(this.neighbourhood_size/2); i++){
      for (int j = -floor(this.neighbourhood_size/2); j <= floor(this.neighbourhood_size/2); j++){
        loc = pix + i + j*this._width;
        if (loc > 0 && loc < this.imagen.length)
          mean += this.imagen[loc][0];
      }
    }
    return (float)(mean/(this.neighbourhood_size * this.neighbourhood_size));
  }

  public float calculate_neighbour_limunosity_deviation(int pix, float mean){
    double deviation = 0;
    int loc = 0;
    for (int i = -floor(this.neighbourhood_size/2); i <= floor(this.neighbourhood_size/2); i++){
      for (int j = -floor(this.neighbourhood_size/2); j <= floor(this.neighbourhood_size/2); j++){
        loc = pix + i + j*this._width;
        if (loc > 0 && loc < this.imagen.length)
          deviation += pow(this.imagen[loc][0] - mean,2);
      }
    }
    return sqrt((float)deviation / (this.neighbourhood_size * this.neighbourhood_size));
  }

  private float calculate_luminosity_mean(){
    double mean = 0.0;
    for (int x = 0; x < this.imagen.length; x++) {
      //      println("\tm =  " + mean + " + " + this.imagen[x][0]);
      mean += this.imagen[x][0];
      this.set_pixel_lum_mean(x, calculate_neighbour_limunosity_mean(x));
    }

    return  (float)(mean/this.imagen.length);
  }

  private float calculate_luminosity_standard_deviation(float mean){
    double deviation = 0.0;
    for (int x = 0; x < this.imagen.length; x++) {
      deviation += pow(this.imagen[x][0] - mean,2);
      this.set_pixel_lum_deviation(x, calculate_neighbour_limunosity_deviation(x, this.pixel_lum_mean(x)));
    }
    return sqrt((float)deviation / this.imagen.length);
  }

  public void calculate_statistics(){
    this.mean = calculate_luminosity_mean();
    this.deviation = calculate_luminosity_standard_deviation(mean);
  }


  private float log10(float n){
    return (float)Math.log10(n);
  }
  private float invLog10(float n){
    return (float)Math.pow(10,n); 
  }
}

void test_labimage(PImage object){
  println("R" + red(object.pixels[0]) + " G" + green(object.pixels[0]) + " B" + blue(object.pixels[0]));

  LABImage labimg = new LABImage(object);
  /*  println("l: " + labimg.lum(0) + ", a: " + labimg.alfa(0) + ", b: " + labimg.beta(0) + ", mean: " + labimg.pixel_lum_mean(0) + ", dev: " + labimg.pixel_lum_deviation(0));
   labimg.to_rgb(object);
   object.updatePixels();
   println("R" + red(object.pixels[0]) + " G" + green(object.pixels[0]) + " B" + blue(object.pixels[0]));
   labimg.set_alfa(0, 3.1);
   labimg.set_beta(0, 3.2);
   labimg.to_rgb(object);
   object.updatePixels();
   println("R" + red(object.pixels[0]) + " G" + green(object.pixels[0]) + " B" + blue(object.pixels[0]));
   */
  /*  println(labimg.lum(0));
   println(labimg.alfa(0));
   println(labimg.beta(0));
   labimg.set_lum(0, 3.0);
   labimg.set_alfa(0, 3.1);
   labimg.set_beta(0, 3.2);
   println(labimg.lum(0) == 3.0);
   println(labimg.alfa(0) == 3.1);
   println(labimg.beta(0) == 3.2);
   */
  //   labimg.to_rgb(
  //println(red(object.pixels[0]) + " " + green(object.pixels[0]) + " " + blue(object.pixels[0]));

  //println("img mean = " +labimg.mean + "; img deviation = " +labimg.deviation);
  //println("calculate pixel mean: " + labimg.calculate_neighbour_limunosity_mean(0));

}


void test_to_rgb(PImage object){
  print("test to_rgb: ");
  PImage dest = createImage(object.width, object.height, RGB);
  LABImage labimg = new LABImage(object);
  labimg.to_rgb(dest);
  int loc = 0;
  for (int x = 0; x < object.width; x++) {
    for (int y = 0; y < object.height; y++ ) {
      loc = x + y*object.width;
      //      println(x + ", " +y);
      if (object.pixels[loc] != dest.pixels[loc])
        throw new IllegalStateException("FAILURE: to_rgb");
    }
  }

}

void test_neighbour(){
  LABImage test = new LABImage(source);
  DEBUGGING = true;
  test.calculate_neighbour_limunosity_deviation(1000, 10.0);
  DEBUGGING = false;
}
void keyPressed(){
  //  test_labimage(source);
  // test_to_rgb(object);
  //  test_neighbour();
}







