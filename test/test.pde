
import processing.video.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.Core;
import org.opencv.core.Mat;
import org.opencv.core.MatOfPoint;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.CvType;
import org.opencv.core.Point;
import org.opencv.core.Size;
import java.util.List;
import org.opencv.core.Scalar;
import org.opencv.imgproc.Moments;


Capture cam;
OpenCV opencv;
PImage  img, thresh, blur, adaptive;
ArrayList<MatOfPoint> contours;
ArrayList<MatOfPoint2f> approximations;
ArrayList<MatOfPoint2f> shapes;

void setup() {
  size(640, 480);
  /*
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    //cam = new Capture(this, 640, 480);
    //cam.start();     
  }      
*/
  img = loadImage("shapes.jpg");
  img.resize(640, 480);
  opencv = new OpenCV(this,img);  
}

/*
void captureEvent(Capture c) {
  c.read();
}*/

void draw() {  
  opencv.loadImage(img);
 
  Mat src = Mat.zeros(img.width, img.height, Core.LINE_8);
  OpenCV.toCv(img, src);
          
  // hold on to this for later, since adaptiveThreshold is destructive
  Mat gray = OpenCV.imitate(opencv.getGray());
  opencv.getGray().copyTo(gray);
    
  Mat cannyEdges = new Mat();
  Imgproc.Canny(gray, cannyEdges, 10, 100);
  PImage canny = opencv.getSnapshot(cannyEdges);
  
  Mat thresholdMat = Mat.zeros(img.width, img.height, Core.LINE_8);
  Imgproc.threshold(gray, thresholdMat, 127,255,1);
  PImage threshold = opencv.getSnapshot(thresholdMat);
  
  
  List<MatOfPoint> contours = new ArrayList<MatOfPoint>();
  Mat hierarchy = new Mat();
  Imgproc.findContours(thresholdMat, contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);
  //Imgproc.findContours(thresholdMat, contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);
  
  MatOfPoint2f approxCurve = new MatOfPoint2f();
  
    image(threshold, 0, 0);
    
  for (int i = 0; i < contours.size(); i++) {
    
    double contourArea = Imgproc.contourArea(contours.get(i));

    if(contourArea > 2500) {
    
      //Convert contours(i) from MatOfPoint to MatOfPoint2f
      MatOfPoint2f contour2f = new MatOfPoint2f( contours.get(i).toArray() );
      //Processing on mMOP2f1 which is in type MatOfPoint2f
      double approxDistance = Imgproc.arcLength(contour2f, true)*0.01;

      Imgproc.approxPolyDP(contour2f, approxCurve, approxDistance, true);  
      int count = (int) approxCurve.total();
      
      Scalar c = new Scalar(255, 0, 0);
      if(count < 10) {
       Moments p = Imgproc.moments(contours.get(i), false);
       int x = (int) (p.get_m10() / p.get_m00());
       int y = (int) (p.get_m01() / p.get_m00());

        if(count == 4) {      
             c = new Scalar(0, 0, 255);
            Imgproc.drawContours(cannyEdges, contours, -1, c, -1);
            PImage output = opencv.getSnapshot(src);
            image(output,0,0);
            fill(255,0,0);
            textSize(70);
            text("Quadrado", x, y);
        }
        else if(count == 3) {      
             c = new Scalar(0, 255, 0);
            Imgproc.drawContours(cannyEdges, contours, -1, c, -1);
            PImage output = opencv.getSnapshot(src);
            image(output,0,0);
            fill(0,255,0);
            textSize(70);
            text("Triângulo", x, y);
        }
        else if(count > 7 && count < 10) {
          c = new Scalar(255, 255, 0);
         Imgproc.drawContours(cannyEdges, contours, -1, c, -1);
         PImage output = opencv.getSnapshot(src);
         image(output,0,0);
          fill(0,0,255);
          textSize(70);
          text("Círculo", x, y);
        }
      }
    }
  }  
}
