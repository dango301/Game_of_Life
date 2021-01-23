

void nextGeneration() {
  nextGrid = new Cell[cols][rows];


  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {

      // clone to transfer properties of original Cell-Object to a new one as not to modify any Cells in the original grid while its values are still needed
      Cell clone = grid[i][j].clone();
      nextGrid[i][j] = clone;
      clone.transition();
      clone.display(); // note: for some reason all cells are only drawn at once, after the loop is done
    }
  }


  grid = nextGrid;
  gen++;
}



void fileImported(File selection) {

  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    JSONArray values = loadJSONArray(selection.getAbsolutePath());

    if (values.size() != cols * rows) {

      cols = 0;
      rows = 0;

      for (int i = 0; i < values.size(); i++) {
        JSONObject obj = values.getJSONObject(i); 
        int x = obj.getInt("x");
        int y = obj.getInt("y");

        if (++x > cols) cols = x;
        if (++y > rows) rows = y;
        // the above if statements require the last cell (that of highest row and column) to be last in JSON object
      }
      res = min((width - 2 * margin) / cols, (height - 40 - 2 * margin) / rows);


      grid = new Cell[cols][rows];
      nextGrid = new Cell[cols][rows];
      println("Resolution was changed to " + res + "px to accomodate imported Grid-Ratio: " + cols + " x " + rows);
    }


    for (int i = 0; i < values.size(); i++) {
      JSONObject obj = values.getJSONObject(i); 

      int x = obj.getInt("x");
      int y = obj.getInt("y");
      boolean a = obj.getBoolean("alive");

      Cell c = new Cell(a, x, y);
      grid[x][y] = c;
    }
    forceDraw = true;
  }
}



void fileExported(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    String path = selection.getAbsolutePath();
    path = split(path, ".")[0] + ".json";

    JSONArray values = new JSONArray();
    int index = 0;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {

        Cell cell = grid[i][j];
        JSONObject obj = new JSONObject();

        obj.setInt("id", index);
        obj.setInt("x", cell.x);
        obj.setInt("y", cell.y);
        obj.setBoolean("alive", cell.alive);

        values.setJSONObject(index++, obj);
      }
    }
    saveJSONArray(values, path);
    println("File saved as " + path);
  }
}



void slider(boolean allowOverflow) {

  if (isPainting) return;
  if (!allowOverflow) isSliding = true;

  float x = mouseX;
  if (!allowOverflow && !(x >= 600 && x <= width - 120)) return;
  if (x < 480) return;

  x = constrain(x, 600, width - 120);
  float p = map(x, 600, width - 120, 0, 1);
  float hz = pow(10, p * log(maxHz) / log(10)); // power with base 10 with maximal exponent such as to reach maxHz for p=1 
  T = 1000 / hz;
  //println(hz, T);

  noStroke();
  fill(0);
  rect(480, 0, width, 40);
  fill(255);
  text("Speed:", 480, 0, 120, 40);
  rect(600, 18, width - 720, 4, 4);
  text(nf(hz, 0, 2) + "Hz", width - 120, 0, 120, 40);
  ellipse(600 + p * (width - 720), 20, 10, 10);
}



void drawInitialGrid(boolean dragged) {

  if (isSliding) return;
  if (!dragged) isPainting = true;
  if (!(mouseX >= offsetX && mouseX <= width - offsetX && mouseY >= offsetY + 40 && mouseY <= height - offsetY)) return;

  if (isLooping) {
    toggleLoop(false);
    return;
  }

  int i = floor((mouseX - offsetX) / res);
  int j = floor((mouseY - offsetY - 40) / res);
  if (i >= cols || j >= rows) return;

  Cell c = grid[i][j];
  c.alive = mouseButton == LEFT;
  c.display();
}



void toggleLoop(boolean ...forcedState) {
  isLooping = forcedState.length > 0 ? forcedState[0] : !isLooping;
  //println(isLooping);
  fill(0);
  rect(240, 0, 120, 40);
  fill(255);
  text(isLooping ? "Pause" : "Play", 240, 0, 120, 40);
}
