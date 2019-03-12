import numpy as np
import cv2

cap = cv2.VideoCapture(cv2.CAP_DSHOW)

while(True):
    # Capture frame-by-frame
    ret, img = cap.read()

    if img is not None:
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        #img = cv2.imread("shapes.jpg", cv2.IMREAD_GRAYSCALE)
        _, threshold = cv2.threshold(gray, 240, 255, cv2.THRESH_BINARY)
        contours, _ = cv2.findContours(threshold, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)

        font = cv2.FONT_HERSHEY_COMPLEX

        for cnt in contours:
            approx = cv2.approxPolyDP(cnt, 0.01*cv2.arcLength(cnt, True), True)
            cv2.drawContours(img, [approx], 0, (0), 5)
            x = approx.ravel()[0]
            y = approx.ravel()[1]

            if len(approx) == 3:
                cv2.putText(img, "Triangle", (x, y), font, 1, (0))
            elif len(approx) == 4:
                cv2.putText(img, "Rectangle", (x, y), font, 1, (0))
            elif len(approx) == 5:
                cv2.putText(img, "Pentagon", (x, y), font, 1, (0))
            elif 6 < len(approx) < 15:
                cv2.putText(img, "Ellipse", (x, y), font, 1, (0))
            else:
                cv2.putText(img, "Circle", (x, y), font, 1, (0))


    # Display the resulting frame
    cv2.imshow('frame',img)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# When everything done, release the capture
cap.release()
cv2.destroyAllWindows()