
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
  opencv = new OpenCV(this, img);  
}


void captureEvent(Capture c) {
  c.read();
}

void draw() {  
  opencv.loadImage(img);
  image(img, 0, 0);
  
  // hold on to this for later, since adaptiveThreshold is destructive
  Mat gray = OpenCV.imitate(opencv.getGray());
  opencv.getGray().copyTo(gray);

  Mat thresholdMat = OpenCV.imitate(opencv.getGray());

  opencv.blur(5);
  PImage blur = opencv.getSnapshot();
  image(blur,0,0);
  
  //Imgproc.adaptiveThreshold(opencv.getGray(), thresholdMat, 255, Imgproc.ADAPTIVE_THRESH_GAUSSIAN_C, Imgproc.THRESH_BINARY_INV, 451, -65);
  opencv.threshold();
  PImage threshold = opencv.getSnapshot();
  image(threshold,0,0);

  contours = new ArrayList<MatOfPoint>();
  ArrayList<Contour> cnt = opencv.findContours();
  println(cnt.size());

  //approximations = createPolygonApproximations(contours);
  
  shapes = selectShapes(approximations);
  
  noFill();
  smooth();
  strokeWeight(5);
  stroke(0, 255, 0);
  drawContours2f(shapes); 
}

ArrayList<MatOfPoint2f> selectShapes(ArrayList<MatOfPoint2f> candidates) {
  float minAllowedContourSide = 50;
  minAllowedContourSide = minAllowedContourSide * minAllowedContourSide;

  ArrayList<MatOfPoint2f> result = new ArrayList<MatOfPoint2f>();

  for (MatOfPoint2f candidate : candidates) {

    if (candidate.size().height != 4) {
      continue;
    } 

    if (!Imgproc.isContourConvex(new MatOfPoint(candidate.toArray()))) {
      continue;
    }

    // eliminate markers where consecutive
    // points are too close together
    float minDist = img.width * img.width;
    Point[] points = candidate.toArray();
    for (int i = 0; i < points.length; i++) {
      Point side = new Point(points[i].x - points[(i+1)%4].x, points[i].y - points[(i+1)%4].y);
      float squaredLength = (float)side.dot(side);
      // println("minDist: " + minDist  + " squaredLength: " +squaredLength);
      minDist = min(minDist, squaredLength);
    }

    //  println(minDist);


    if (minDist < minAllowedContourSide) {
      continue;
    }

    result.add(candidate);
  }

  return result;
}

ArrayList<MatOfPoint2f> createPolygonApproximations(ArrayList<MatOfPoint> cntrs) {
  ArrayList<MatOfPoint2f> result = new ArrayList<MatOfPoint2f>();

  if(cntrs.size() > 0) {
    double epsilon = cntrs.get(0).size().height * 0.01;
  
    for (MatOfPoint contour : cntrs) {
      MatOfPoint2f approx = new MatOfPoint2f();
      Imgproc.approxPolyDP(new MatOfPoint2f(contour.toArray()), approx, epsilon, true);
      result.add(approx);
    }
  }
  return result;
}

void drawContours2f(ArrayList<MatOfPoint2f> cntrs) {
  for (MatOfPoint2f contour : cntrs) {
    beginShape();
    Point[] points = contour.toArray();

    for (int i = 0; i < points.length; i++) {
      vertex((float)points[i].x, (float)points[i].y);
    }
    endShape(CLOSE);
  }
}
