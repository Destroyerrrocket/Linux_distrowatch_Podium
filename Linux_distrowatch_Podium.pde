import java.io.*;
import java.net.HttpURLConnection;    // required for HTML download
import java.net.*;

PrintWriter out, saveweb;
PImage[] LinuxImage = new PImage[3];
String[] parsedTableLines = new String[301];
String[] parsedTableImages = new String[301];
color BackgroundColorGradient;
Fill f = new Fill();

void setup() {
  background(255);
  LinuxDistrowatch();
  for (int i = 0; i < 3; i++) {
    GoogleImageDownloader(parsedTableLines[i], i);
    println(parsedTableImages[i]);
  }
  size(1600, 800);
  noLoop();
}
void draw () {
  f.fil(#D6E9FF);
  f.strok(0);
  textAlign(CENTER);
  imageMode(CENTER);
  for (int i = 0; i < LinuxImage.length; i++) {
    LinuxImage[i] = loadImage(parsedTableImages[i], "jpg");
    LinuxImage[i].resize(80, 80);
  }
  BackgroundColorGradient = extractColorFromImage(LinuxImage[0]);
  setGradient(0, 0, width, height/2, BackgroundColorGradient, color(255), 1);
  rect(width / 2 - 100, height / 3*2, 200, height / 3+1, 12, 12, 0, 0);
  f.fil(#F9FFD6);
  rect(width / 4 - 100, height / 4*3, 200, height / 4-1, 12, 12, 0, 0);
  f.fil(#FFDED6);
  rect(width / 4*3 - 100, height / 5*4, 200, height / 5-1, 12, 12, 0, 0);
  f.fil(255);
  textSize(32);
  strokeText("1",width / 2, height - 20);
  strokeText("2",width / 4, height - 20);
  strokeText("3",width / 4*3, height - 20);
  strokeText(parsedTableLines[0],width / 2, height / 3*2 + 40);
  strokeText(parsedTableLines[1],width / 4, height / 4*3 + 40);
  strokeText(parsedTableLines[2],width / 4*3, height / 5*4 + 40);
  image(LinuxImage[0], width / 2, height / 3*2 - 40);
  image(LinuxImage[1], width / 4, height / 4*3 - 40);
  image(LinuxImage[2], width / 4*3, height / 5*4 - 40);
  save("Linux_podium.jpg");
}



















color extractColorFromImage(PImage img) {
    img.loadPixels();
    int r = 0, g = 0, b = 0;
    for (int i=0; i<img.pixels.length; i++) {
        color c = img.pixels[i];
        r += c>>16&0xFF;
        g += c>>8&0xFF;
        b += c&0xFF;
    }
    r /= img.pixels.length;
    g /= img.pixels.length;
    b /= img.pixels.length;
 
    return color(r, g, b);
}

void strokeText(String message, int x, int y) 
{ 
  color ColorFillBackup = f.CurrentFillColor;
  f.fil(0); 
  text(message, x-1, y); 
  text(message, x, y-1); 
  text(message, x+1, y); 
  text(message, x, y+1); 
  f.fil(255); 
  text(message, x, y); 
  f.fil(ColorFillBackup);
} 

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  f.noFil();
  color ColorStrokeBackup = f.CurrentStrokeColor;
  if (axis == 1) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      f.strok(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == 2) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      f.strok(c);
      line(i, y, i, y+h);
    }
  }
  f.strok(ColorStrokeBackup);
  f.yesFil();
}

public class Fill {
  color CurrentStrokeColor;
  color CurrentFillColor;
  void fil (color Color) {
    CurrentFillColor = Color;
    fill(CurrentFillColor);
  }
  void noFil () {
    noFill();
  }
  void yesFil () {
    fill(CurrentFillColor);
  }
  void strok (color Color) {
    CurrentStrokeColor = Color;
    stroke(CurrentStrokeColor);
  }
  void noStrok () {
    noStroke();
  }
  void yesStrok () {
    stroke(CurrentStrokeColor);
  }
}

void LinuxDistrowatch () {
  String[] lines;
  String alllines = "";
  println("initializing...");
  try {
    File f = dataFile("Debug.txt");    
    out = new PrintWriter(new BufferedWriter(new FileWriter(f, true)));
    println("Getting the web...");
    File w = new File(dataPath("web.txt"));
    if (!w.exists()) {
      lines = loadStrings("http://distrowatch.com/dwres.php?resource=popularity");
      saveweb = new PrintWriter(new BufferedWriter(new FileWriter(w, true)));
      
      for (int aba = 0 ; aba < lines.length; aba++) {
         saveweb.println(lines[aba]);
      }
      saveweb.flush();
      saveweb.close();
    } else {
      lines = loadStrings(w);
    }
    println("Starting to parse the web:");
    println("Make a huge string");
    for (int abai = 0 ; abai < lines.length; abai++) {
      alllines += lines[abai];
    }
    
    int positionofdata = alllines.indexOf("Last 1 month</th></tr>"); //(.*?)
    out.println("the first line is in: " + Integer.toString(positionofdata));
    println("the first line of the desired table is in: " + Integer.toString(positionofdata));
    String notparsedtable = alllines.substring(positionofdata);
    println("make the not parsed table (saved on web.txt)");
    //out.println(notparsedtable);
    String[][] ParsedtableNames = matchAll(notparsedtable, "<td class=\"phr2\">(.*?)</a></td>");
    println("trying to parse the names");
    out.println("there are " + ParsedtableNames.length + " Names");
    for (int i = 0; i < 300; i++) {
      int indexOf = ParsedtableNames[i][1].indexOf(">") + 1;
      String parsingTableLines = ParsedtableNames[i][1].substring(indexOf);
      if (!parsingTableLines.equals("Mint")) {
      parsedTableLines[i] = parsingTableLines;
      } else {
      parsedTableLines[i] = "Linux " + parsingTableLines;
      }
      out.println("Num: " + Integer.toString(i + 1) + ") " + parsedTableLines[i]);
    }
  }
  catch (IOException e) {
    println(e);
  }
  out.flush();
  out.close();
  println("done");
}

void GoogleImageDownloader (String SearchTermInput, int indexOfparsedTableImages) {
String searchTerm = SearchTermInput;   // term to search for (use spaces to separate terms)
int offset = 0;                      // we can only 20 results at a time - use this to offset and get more!
String source = null;                 // string to save raw HTML source code
String[][] m;                         // store the images
// format spaces in URL to avoid problems
searchTerm = searchTerm.replace(" ", "%20");
// get Google image search HTML source code; mostly built from PhyloWidget example:
// http://code.google.com/p/phylowidget/source/browse/trunk/PhyloWidget/src/org/phylowidget/render/images/ImageSearcher.java
try {
  //URL query = new URL("http://images.google.com/images?gbv=1&start=" + offset + "&q=" + searchTerm + "&tbs=isz:i");
  URL query = new URL("http://www.google.com/search?q=" + searchTerm + "&tbs=isz:i&tbm=isch&gbv=2&gws_rd=cr&dcr=0&ei=PU_eWb_NNeTdgAaAipfgBA");
  HttpURLConnection urlc = (HttpURLConnection) query.openConnection();                                // start connection...
  urlc.setInstanceFollowRedirects(true);
  urlc.setRequestProperty("User-Agent", "");
  urlc.connect();
  BufferedReader in = new BufferedReader(new InputStreamReader(urlc.getInputStream()));               // stream in HTTP source to file
  StringBuffer response = new StringBuffer();
  char[] buffer = new char[1024];
  while (true) {
    int charsRead = in.read(buffer);
    if (charsRead == -1) {
      break;
    }
    response.append(buffer, 0, charsRead);
  }
  in.close();                                                                                          // close input stream (also closes network connection)
  source = response.toString();
}
// any problems connecting? let us know
catch (Exception e) {
  e.printStackTrace();
}

// print full source code (for debugging)
// println(source);

// extract image URLs only, starting with 'imgurl'
if (source != null) {
  m = matchAll(source, "img height=\"\\d+\" src=\"([^\"]+)\"");
  // String[][] m = matchAll(source, "imgurl=(.*?\\.(?i)(jpg|jpeg|png|gif|bmp|tif|tiff))");    // (?i) means case-insensitive
  
  parsedTableImages[indexOfparsedTableImages] = m[0][1];
}
}