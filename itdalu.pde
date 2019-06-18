/*

itdalu 

Cameron Randall & John Wild | 2019 | cameronrandall.com

*/


import java.util.Date;
ArrayList<File> allFiles;
ArrayList<PImage> images;
boolean pixelSticky = false;
boolean b_Sticky = true;
int b_count = 0;

//Threshold for while black is sticky - Threshold adjustable 
int seedVal = 1722; // Threshold 1080p 
//int seedVal = 3720; // Threshold 4k 

public void settings() {
  fullScreen();
}

void setup() {

  background(0);

  // Using just the path of this sketch to demonstrate,
  // but you can list any directory you like.
  String path = "/Users/cameron/Documents/Processing/itdalu/data/";

  println("Listing all filenames in a directory: ");
  String[] filenames = listFileNames(path);
  printArray(filenames);

  println("\nListing info about all files in a directory: ");
  File[] files = listFiles(path);
  for (int i = 0; i < files.length; i++) {
    File f = files[i];    
    println("Name: " + f.getName());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  println("\nListing info about all files in a directory and all subdirectories: ");
  allFiles = listFilesRecursive(path);

  for (File f : allFiles) {
    println("Name: " + f.getName());
    println("Full path: " + f.getAbsolutePath());
    println("Is directory: " + f.isDirectory());
    println("Size: " + f.length());
    String lastModified = new Date(f.lastModified()).toString();
    println("Last Modified: " + lastModified);
    println("-----------------------");
  }

  images = new ArrayList();
  for ( File file : allFiles )
  {
    String fileName = file.getName();
    //remove corupt files
    boolean kurupt = false;   
    if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")|| fileName.endsWith(".JPG")|| fileName.endsWith(".JPEG")) {
      kurupt = false;
    } else {
        print("No file extention! -> ");
        println(fileName);
      kurupt = true;
    }

    for (int n=0; n< fileName.length(); n++) {
      char c1 = fileName.charAt(n);
      if (c1 == '?') {
        kurupt = true;
      }
    }


    if (!kurupt) {
      //check for null image file
      PImage ImageName = loadImage(fileName );
      if (ImageName != null) {
        images.add(loadImage(fileName ) );
        kurupt = false;
      } else {     
        print("null file - > ");
        println(fileName);
      }
    }
  }
}

void draw() {

  for (PImage image : images) {
    pixelSticky = false;
    float image_x = random(image.width);
    float image_y = random (image.height);
    color image_color = image.get(int(image_x), int(image_y));
    fill (image_color);
    noStroke();

    int loopcount = 0;

    while (!pixelSticky) {
      loopcount++;
      println ("********************  Loop - " + loopcount);
      //Choose random location on screen
      int screen_x = int(random (width));
      int screen_y = int(random (height));
      // LEFT - is pixel sticky on the left
      if ((screen_x-1)>=0) {
        int left_x = screen_x -1;
        if (algo(left_x, screen_y, image_color)) {
          rect (screen_x, screen_y, 1, 1);
          println("LEFT");
        }
      }
      // RIGHT - is pixel sticky on the right
      if (!pixelSticky && ((screen_x +1)< width)) {
        int right_x = screen_x +1;
        if (algo(right_x, screen_y, image_color)) {
          rect (screen_x, screen_y, 1, 1);
          println("RIGHT");
        }
      }
      // Above - is pixel sticky on above
      if (!pixelSticky && ((screen_y -1 )>=0)) {
        int above_y = screen_y -1;
        if (algo(screen_x, above_y, image_color)) {
          rect (screen_x, screen_y, 1, 1);
          println("UP");
        }
      }
      // Below- is pixel sticky above
      if (!pixelSticky && ((screen_y +1 )< height)) {
        int below_y = screen_y +1;
        if (algo(screen_x, below_y, image_color)) {
          rect (screen_x, screen_y, 1, 1);
          println("DOWN");
        }
      }
    }
    if (b_Sticky == true) {
      b_count++;
    }
    if (b_count > seedVal) {
      b_Sticky = false;
      println("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    }
  }//close while
}

// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

// Function to get a list of all files in a directory and all subdirectories
ArrayList<File> listFilesRecursive(String dir) {
  ArrayList<File> fileList = new ArrayList<File>(); 
  recurseDir(fileList, dir);
  return fileList;
}

// Recursive function to traverse subdirectories
void recurseDir(ArrayList<File> a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    println("isdirectory");
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      // Call this function on all files in this directory
      recurseDir(a, subfiles[i].getAbsolutePath());
    }
  } else {
    if ( file.getName().equals(".DS_Store") )
    {
      println("DS");
    } else
    {
      println("working");
      a.add(file);
    }
  }
}

//This function campares the image pixel with the sceeen pixal at location cX,cY
boolean algo( int cX, int cY, color PixelColour)
{
  loadPixels();  

  int r = (PixelColour >> 16) & 0xFF;  // Faster way of getting red(argb)
  int g = (PixelColour >> 8) & 0xFF;   // Faster way of getting green(argb)
  int b = PixelColour & 0xFF;          // Faster way of getting blue(argb)

  int image_highestVal = highestColor(r, g, b);

  //Get screen rgb values 

  //Get compare pixel rgb values
  int screeLoc = (cY*width)+cX;
  color comparePixel = pixels[screeLoc]; 

  //compare the two pixels
  color black = color(0, 0, 0);
  if (comparePixel == black ) {
    if (b_Sticky == true) {
      pixelSticky = true;
    }
  } 

  //Compare r g b
  if (!pixelSticky) { 

    int c_r= (comparePixel >> 16) & 0xFF;  // Faster way of getting red(argb)
    int c_g  = (comparePixel >> 8) & 0xFF;   // Faster way of getting green(argb)
    int c_b  = comparePixel & 0xFF;          // Faster way of getting blue(argb)
    int screen_highestVal = highestColor(c_r, c_g, c_b);  
    print("image colour = ");
    println(image_highestVal);
    print("compare colour = ");
    println(screen_highestVal);
    if (image_highestVal == screen_highestVal) {
      print("STICKY !!!");
      println(screen_highestVal);
      pixelSticky = true;
    }
  }

  //++++++++++++++++++++++++++++++++++++++++++++++++


  //Return results
  if (pixelSticky == true) {
    fill(PixelColour);
    stroke(PixelColour);
    return true;
  } else {
    pixelSticky = false;
    return false;
  }
}


// which is the greatest? returns 0 (w), 1 (r), 2 (g), or 3 (b)
int highestColor(float r, float g, float b) {

  int greatestColor = 0;
  float minVal = -1;          // account for 0s in the color (0 will be greater)

  if (r==255 && g == 255 && b==255) {
    greatestColor = 4;
  } else if (r==0 && g == 0 && b==0) {
    greatestColor = 5;
  } 

  if (greatestColor != 4 && greatestColor != 5) {

    if (r > minVal) {
      greatestColor = 1;
      minVal = r;
    }
    if (g > minVal) {
      greatestColor = 2;
      minVal = g;
    }
    if (b > minVal) {
      greatestColor = 3;
      minVal = b;
    }
  }
  return greatestColor;
}
