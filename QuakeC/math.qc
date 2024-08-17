//https://thatfrenchgamedev.com/1026/game-programmers-handy-maths-formulas/
float signedDistanceCircles(vector c1Center, float c1Radius, vector c2Center, float c2Radius) 
{
  return vlen(c1Center - c2Center) - (c1Radius + c2Radius);
}

/*
float clamp(float flr, float v, float cl) 
{
  return min(max(v, flr), cl);
}
*/

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

vector(vector a, vector b, vector c, float mix) lerp3PointCurve =
{
	if (mix <= 0)
		return a;
	if (mix >= 1)
		return c;
	
	vector d,e;
	
	d = (b * mix + a * ( 1 - mix ));
	e = (c * mix + b * ( 1 - mix ));
	return (e * mix + d * ( 1 - mix ));
}

//float(float a, float b) min = { if (a <= b) return a; return b; }
//float(float a, float b) max = { if (a >= b) return a; return b; }

vector(vector a, vector b) CrossProduct =
{
	vector c;
	
	c_x = a_y * b_z - a_z * b_y;
	c_y = a_z * b_x - a_x * b_z;
	c_z = a_x * b_y - a_y * b_x;
	
	return c;
}

float() crandom =
{
	return 2*(random() - 0.5);
};

float() randomsign =
{
	if (crandom() > 0)
		return 1;
	else 
		return -1;
};
/*
float(float x, float y) pow =
{
	if (y < 0)
		return 0;
	float c;
	c = 1;
	while (y)
	{
		c *= x;
		y--;
	}
	return c;
};
*/

// zi = (xi – min(x)) / (max(x) – min(x)) normalize to 0..1