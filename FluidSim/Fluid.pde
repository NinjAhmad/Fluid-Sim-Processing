int IX(int x, int y) {
  x = constrain(x, 0, grid-1);
  y = constrain(y, 0, grid-1);
  return x + y * grid;
}

class Fluid {
  // size of the fluid
  int size;
  // the length of the timestep
  float timeStep;
  // how fast stuff spreads out in the fluid
  float diffusion;
  // how thick a fluid is
  float viscosity;

  float[] previousDensity;
  // Density of the dye NOT the fluid
  float[] density;

  // Current velocity X & Y
  float[] velX;
  float[] velY;

  // Previous velocity X & Y
  float[] previousVelX;
  float[] previousVelY;

  Fluid(float dt, float diffusion, float viscosity) {

    this.size = grid;
    this.timeStep = dt;
    this.diffusion = diffusion;
    this.viscosity = viscosity;

    this.previousDensity = new float[grid*grid];
    this.density = new float[grid*grid];

    this.velX = new float[grid*grid];
    this.velY = new float[grid*grid];

    this.previousVelX = new float[grid*grid];
    this.previousVelY = new float[grid*grid];
  }

  void Step()
  {
    float visc = this.viscosity;
    float diff = this.diffusion;
    float dt = this.timeStep;
    float[] Vx = this.velX;
    float[] Vy = this.velY;
    float[] Vx0 = this.previousVelX;
    float[] Vy0 = this.previousVelY;
    float[] s = this.previousDensity;
    float[] density = this.density;

    Diffuse(1, Vx0, Vx, visc, dt);
    Diffuse(2, Vy0, Vy, visc, dt);

    Project(Vx0, Vy0, Vx, Vy);

    Advect(1, Vx, Vx0, Vx0, Vy0, dt);
    Advect(2, Vy, Vy0, Vx0, Vy0, dt);

    Project(Vx, Vy, Vx0, Vy0);

    Diffuse(0, s, density, diff, dt);
    Advect(0, density, s, Vx, Vy, dt);
  }

  void AddDensity(int x, int y, float amount)
  {
    int index = IX(x, y);
    this.density[index] += amount;
  }

  void AddVelocity(int x, int y, float amountX, float amountY)
  {
    int index = IX(x, y);
    this.velX[index] += amountX;
    this.velY[index] += amountY;
  }

  void RenderD() {
    colorMode(RGB, 255);

    for (int i = 0; i< grid; i++) {
      for (int j = 0; j< grid; j++) {
        float x = i * SCALE;
        float y = j * SCALE;
        float d = this.density[IX(i, j)];
        fill(myColor1, myColor2, myColor3, d);
        noStroke();
        square(x, y, SCALE);
      }
    }
  }

  void RenderV() {
    for (int i = 0; i< grid; i++) {
      for (int j = 0; j< grid; j++) {
        float x = i * SCALE;
        float y = j * SCALE;
        float vx = this.velX[IX(i, j)];
        float vy = this.velY[IX(i, j)];
        stroke(145);

        if (!(abs(vx) < -0.1 && abs(vy) <= 0.1))
          line(x, y, x+vx*SCALE, y+vy*SCALE);
      }
    }
  }

  // Make the dye fade based on dye density
  void FadeDye() {
    for (int i = 0; i < this.density.length; i++) {
      float d = density[i];
      density[i] = constrain(d-0.1, 0, 255);
    }
  }
  
  // We use diffusion both in the obvious case of making the dye spread out, and also in the less obvious case of making the velocities of the fluid spread out. 
  void Diffuse (int b, float[] x, float[] x0, float diff, float dt)
  {
    float a = dt * diff * (grid - 2) * (grid - 2);
    LinearEqSolve(b, x, x0, a, 1 + 6 * a);
  }

  // I have no clue on what this exactly does, this solves a linear differential equation of some sort.
  void LinearEqSolve(int b, float[] x, float[] x0, float a, float c)
  {
    float cRecip = 1.0 / c;
    for (int k = 0; k < iter; k++) {
      for (int j = 1; j < grid - 1; j++) {
        for (int i = 1; i < grid - 1; i++) {
          x[IX(i, j)] =
            (x0[IX(i, j)]
            + a*(    x[IX(i+1, j)]
            +x[IX(i-1, j)]
            +x[IX(i, j+1)]
            +x[IX(i, j-1)]
            )) * cRecip;
        }
      }
      SetBoundaries(b, x);
    }
  }

  // Iterates through grid to balance the fluids making it constant
  void Project(float[] velocX, float[] velocY, float[] p, float[] div)
  {
    for (int j = 1; j < grid - 1; j++) {
      for (int i = 1; i < grid - 1; i++) {
        div[IX(i, j)] = -0.5f*(
          velocX[IX(i+1, j)]
          -velocX[IX(i-1, j)]
          +velocY[IX(i, j+1 )]
          -velocY[IX(i, j-1)]
          )/grid;
          
        p[IX(i, j)] = 0;
      }
    }
    SetBoundaries(0, div); 
    SetBoundaries(0, p);
    LinearEqSolve(0, p, div, 1, 6);

    for (int j = 1; j < grid - 1; j++) {
      for (int i = 1; i < grid - 1; i++) {
        velocX[IX(i, j)] -= 0.5f * (  p[IX(i+1, j)]
          -p[IX(i-1, j)]) * grid;
        velocY[IX(i, j)] -= 0.5f * (  p[IX(i, j+1)]
          -p[IX(i, j-1)]) * grid;
      }
    }
    SetBoundaries(1, velocX);
    SetBoundaries(2, velocY);
  }

  // Every cell has a set of velocities, and these velocities make things move.
  void Advect(int b, float[] d, float[] d0, float[] velocX, float[] velocY, float dt)
  {
    float i0, i1, j0, j1;

    float dtx = dt * (grid - 2);
    float dty = dt * (grid - 2);

    float s0, s1, t0, t1;
    float tmp1, tmp2, x, y;

    float Nfloat = grid;
    float ifloat, jfloat;
    int i, j;

    for (j = 1, jfloat = 1; j < grid - 1; j++, jfloat++) { 
      for (i = 1, ifloat = 1; i < grid - 1; i++, ifloat++) {
        tmp1 = dtx * velocX[IX(i, j)];
        tmp2 = dty * velocY[IX(i, j)];
        x = ifloat - tmp1; 
        y = jfloat - tmp2;

        if (x < 0.5f) x = 0.5f; 
        if (x > Nfloat + 0.5f) x = Nfloat + 0.5f; 
        i0 = floor(x); 
        i1 = i0 + 1.0f;
        if (y < 0.5f) y = 0.5f; 
        if (y > Nfloat + 0.5f) y = Nfloat + 0.5f; 
        j0 = floor(y);
        j1 = j0 + 1.0f; 

        s1 = x - i0; 
        s0 = 1.0f - s1; 
        t1 = y - j0; 
        t0 = 1.0f - t1;

        int i0i = int(i0);
        int i1i = int(i1);
        int j0i = int(j0);
        int j1i = int(j1);

        d[IX(i, j)] = 
          s0 * (t0 * d0[IX(i0i, j0i)] + t1 * d0[IX(i0i, j1i)]) +
          s1 * (t0 * d0[IX(i1i, j0i)] + t1 * d0[IX(i1i, j1i)]);
      }
    }
    SetBoundaries(b, d);
  }

  // Set boundaries for the fluids to make it stay on screen.
  void SetBoundaries(int b, float[] x)
  {
    for (int i = 1; i < grid - 1; i++) {
      x[IX(i, 0 )] = b == 2 ? -x[IX(i, 1)] : x[IX(i, 1)];
      x[IX(i, grid-1)] = b == 2 ? -x[IX(i, grid-2)] : x[IX(i, grid-2)];
    }
    for (int j = 1; j < grid - 1; j++) {
      x[IX(0, j )] = b == 1 ? -x[IX(1, j)] : x[IX(1, j)];
      x[IX(grid-1, j)] = b == 1 ? -x[IX(grid-2, j)] : x[IX(grid-2, j)];
    }

    x[IX(0, 0)] = 0.5f * (x[IX(1, 0)] + x[IX(0, 1)]);
    x[IX(0, grid-1)] = 0.5f * (x[IX(1, grid-1)] + x[IX(0, grid-2)]);
    x[IX(grid-1, 0)] = 0.5f * (x[IX(grid-2, 0)] + x[IX(grid-1, 1)]);
    x[IX(grid-1, grid-1)] = 0.5f * (x[IX(grid-2, grid-1)] + x[IX(grid-1, grid-2)]);
  }
}
