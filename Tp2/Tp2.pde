import drop.*;
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

SDrop drop;
OpenCV opencv;

PImage image, thresh, blur, adaptive, output, ipca;
ArrayList<MatOfPoint> contours;
ArrayList<MatOfPoint2f> approximations;
ArrayList<MatOfPoint2f> shapes;
int storyboard = 0;

int triangulosCounter = 0;
int circulosCounter = 0;
int hexagonosCounter = 0;
int pentagonosCounter = 0;
int quadradosCounter = 0;

void setup() {
  size(1280, 720);
  frameRate(30);
  drop = new SDrop(this);
  ipca = loadImage("shapesAbs.jpg");
  frame.setResizable(true);
}

void draw() {
  background(255);

  if (storyboard ==0)
  {
    // Background
    image(ipca, 0, 0);
    ipca.resize(1280, 720);

    // Title
    fill(255);
    textSize(60);
    text("Shape Detector", 50, 80); 
    // Made by
    textSize(48);
    text("Made By:", 75, height - 200);
    textSize(20);
    text("Rui Oliveira 3698", 75, height - 150);
    text("Tiago Silva 6130", 75, height - 110);
    text("Pedro Oliveira 8684", 75, height - 70);
    text("André Monteiro 16202", 75, height - 30);

    // Change page
    if (keyPressed || mousePressed) {
      storyboard =1;
      frame.setSize(1280, 770);
    }
  } else if (storyboard ==1)
  {
    if (image !=null) {
      
      background(36);
      
      image(image, 640, 360);
      image.resize(640, 360);
      opencv = new OpenCV(this, image);  
      opencv.loadImage(image);

      Mat src = Mat.zeros(image.width, image.height, Core.LINE_8);
      OpenCV.toCv(image, src);

      // hold on to this for later, since adaptiveThreshold is destructive
      PImage  grayImage =   opencv.getSnapshot();
      Mat gray = OpenCV.imitate(opencv.getGray());
      opencv.getGray().copyTo(gray);
      opencv.toPImage(gray, grayImage);

      Mat cannyEdges = new Mat();
      Imgproc.Canny(gray, cannyEdges, 10, 100);
      PImage canny = opencv.getSnapshot(cannyEdges);

      Mat thresholdMat = Mat.zeros(image.width, image.height, Core.LINE_8);
      //Mat thresholdMat = new Mat(); 
      Imgproc.threshold(gray, thresholdMat, 210, 255, Imgproc.THRESH_BINARY_INV);
      PImage threshold = opencv.getSnapshot(thresholdMat);

      image(threshold, 640, 0);
      image(canny, 0, 360);
      image(grayImage, 0, 0);

      List<MatOfPoint>contours  = new ArrayList<MatOfPoint>();
      Mat hierarchy = new Mat();
      Imgproc.findContours(thresholdMat, contours, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);

      MatOfPoint2f approxCurve = new MatOfPoint2f();

      //println("Counters size is "+contours.size()); 
      for (int i = 0; i < contours.size(); i++) {

        double contourArea = Imgproc.contourArea(contours.get(i));

        if (contourArea > 100) {

          //Convert contours(i) from MatOfPoint to MatOfPoint2f
          MatOfPoint2f contour2f = new MatOfPoint2f( contours.get(i).toArray() );
          //Processing on mMOP2f1 which is in type MatOfPoint2f
          double approxDistance = Imgproc.arcLength(contour2f, true)*0.01;

          Imgproc.approxPolyDP(contour2f, approxCurve, approxDistance, true);  
          int count = (int) approxCurve.total();
          //println("count= "+count); 
          if (count < 20) {
            Moments p = Imgproc.moments(contours.get(i), false);
            int x = (int) (p.get_m10() / p.get_m00());
            int y = (int) (p.get_m01() / p.get_m00());
            ellipse(x+640, y+360, 10, 10);
            fill(0, 0, 0);
            textSize(20);
            if (count == 4) {   
               fill(242,177,52);
              text("Quadrilátero", x+580, y+340);
              quadradosCounter++;
            } else if (count == 3) { 
              fill(235,85,59);
              text("Triângulo", x+590, y+340);
              triangulosCounter++;
            } else if (count == 5) { 
              fill(71,171,108);
              text("Pentágono", x+590, y+340);
              pentagonosCounter++;
            } else if (count == 6) {   
              fill(242,53,91);
              text("Hexágono", x+590, y+340);
              hexagonosCounter++;
            } else if (count > 7 && count < 20) {
              fill(8,148,161);
              text("Círculo", x+610, y+340);
              circulosCounter++;
            }
          }
        }
      }
      // Count shapes
      fill(235,85,59);
      text("Triângulos: " + triangulosCounter, 200, 750); 
      triangulosCounter = 0;
      fill(8,148,161);
      text("Círculos: " + circulosCounter, 390, 750); 
      circulosCounter = 0;
      fill(71,171,108);
      text("Pentágonos: " + pentagonosCounter, 600, 750); 
      pentagonosCounter = 0;
      fill(242,53,91);
      text("Hexágonos: " + hexagonosCounter, 820, 750); 
      hexagonosCounter = 0;
      fill(242,177,52);
      text("Quadriláteros: " + quadradosCounter, 1020, 750); 
      quadradosCounter = 0;
      
    } else 
    {  
      fill(119,136,153); 
      textSize(60); 
      text("Drop your image here", 340, 440 );
    }
  }
}

void dropEvent(DropEvent theDropEvent) {
  //println("recebeu imagem"); 
  if (theDropEvent.isImage()) {
    image = theDropEvent.loadImage();
  }
}
