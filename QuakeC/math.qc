//https://thatfrenchgamedev.com/1026/game-programmers-handy-maths-formulas/
float signedDistanceCircles(vector c1Center, float c1Radius, vector c2Center, float c2Radius) 
{
  return vlen(c1Center - c2Center) - (c1Radius + c2Radius);
}

float clamp(float flr, float v, float cl) 
{
  return min(max(v, flr), cl);
}

float clamp01(float v) 
{
  return min(max(v, 0), 1);
}

float inverseLerpClamped(float a, float b, float v) 
{
  return clamp01((v - a) / (b - a)); // Clamp01 makes sure the result is between [0, 1]
}

float inverseLerp(float a, float b, float v) 
{
  return ((v - a) / (b - a)); // Clamp01 makes sure the result is between [0, 1]
}

float(float a, float b, float mix) lerp =
{
	if (mix <= 0) return a;
	if (mix >= 1) return b;
	return (b * mix + a * ( 1 - mix ) );
}

vector(vector a, vector b, float mix) lerpVector =
{
	if (mix <= 0) return a;
	if (mix >= 1) return b;
	return (b * mix + a * ( 1 - mix ) );
}

vector(vector a, vector b, float mix) lerpv =
{
	if (mix <= 0) return a;
	if (mix >= 1) return b;
	return (b * mix + a * ( 1 - mix ) );
}

float(float a, float b) min = { if (a <= b) return a; return b; }
float(float a, float b) max = { if (a >= b) return a; return b; }