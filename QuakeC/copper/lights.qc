//
// ================================================================
//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
	// you know what's cool?  arrays.
// 0 normal
string light0 = "m";
// 1 FLICKER (first variety)
string light1 = "mmnmmommommnonmmonqnmmo";
// 2 SLOW STRONG PULSE
string light2 = "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba";
// 3 CANDLE (first variety)
string light3 = "mmmmmaaaaammmmmaaaaaabcdefgabcdefg";
// 4 FAST STROBE
string light4 = "mamamamamama";
// 5 GENTLE PULSE 1
string light5 = "jklmnopqrstuvwxyzyxwvutsrqponmlkj";
// 6 FLICKER (second variety)
string light6 = "nmonqnmomnmomomno";
// 7 CANDLE (second variety)
string light7 = "mmmaaaabcdefgmmmmaaaammmaamm";
// 8 CANDLE (third variety)
string light8 = "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa";
// 9 SLOW STROBE (fourth variety)
string light9 = "aaaaaaaazzzzzzzz";
// 10 FLUORESCENT FLICKER
string light10 = "mmamammmmammamamaaamammma";
// 11 SLOW PULSE TO BLACK
string light11 = "abcdefghijklmnopqrrqponmlkjihgfedcba";
// styles 32-62 are assigned by the light program for switchable lights

string light_off = "a";


/*FGD
@baseclass base() color(255 255 80) size(-8 -8 -8, 8 8 8) = Light [
	light(integer) : "Brightness" : 300
	_color(string) : "Color" : "1 1 1"
	wait(string) : "Fade distance multiplier" : "1"
	mangle(string) : "Spotlight aim (yaw pitch roll, neg. pitch is down)"
	angle(integer) : "Spotlight cone angle"
	_softangle(integer) : "Spotlight inner cone angle"
	_dirt(integer) : "Override dirt"
	message(string) : "override the style string directly for the assigned style (clashes will overwrite each other)"
	target(string) : "Entity to aim at"
	delay(choices) : "Attenuation" =
	[
		0 : "Linear falloff (Default)"
		1 : "Inverse distance falloff"
		2 : "Inverse distance squared"
		3 : "No falloff"
		4 : "Local minlight"
		5 : "Inverse distance squared B"
	]
	style(Choices) : "Appearance" : 0 =
	[
		0 : "Normal"
		10: "Fluorescent flicker"
		2 : "Slow, strong pulse"
		11: "Slow pulse, black"
		5 : "Gentle pulse, no black"
		1 : "Flicker A"
		6 : "Flicker B"
		3 : "Candle A"
		7 : "Candle B"
		8 : "Candle C"
		4 : "Fast strobe"
		9 : "Slow strobe"
	]
]
@baseclass base(Light, Targetname) = LightTriggerable [
	spawnflags(flags) = [
		1 : "Start off" : 0
	]
]
@baseclass base() = Flame [
	volume(string) : "Crackle Volume" : "1"
	distance(choices) : "Crackle Range" : 0 =
	[
		0 : "Ambient"
		1 : "Monster Idle"
		2 : "Monster Bark"
		3 : "Global (plz no)"
	]
	spawnflags(flags) = [
		2 : "Silent" : 0
	]
]
*/

//
// ================================================================
//

string( float st ) GetLightStyle =
{
	if (st == 1) return light1;
	if (st == 2) return light2;
	if (st == 3) return light3;
	if (st == 4) return light4;
	if (st == 5) return light5;
	if (st == 6) return light6;
	if (st == 7) return light7;
	if (st == 8) return light8;
	if (st == 9) return light9;
	if (st == 10) return light10;
	if (st == 11) return light11;
/*	if (st == 12) return light12;
	if (st == 13) return light13;
	if (st == 14) return light14;
	if (st == 15) return light15;
	if (st == 16) return light16;
	if (st == 17) return light17;
	if (st == 18) return light18;*/
	
	/*
	if (icantsee)
		return "z";
	*/
	return light0;
}

void() InitLightStyles =
{
	lightstyle(0, light0);
	lightstyle(1, light1);
	lightstyle(2, light2);
	lightstyle(3, light3);
	lightstyle(4, light4);
	lightstyle(5, light5);
	lightstyle(6, light6);
	lightstyle(7, light7);
	lightstyle(8, light8);
	lightstyle(9, light9);
	lightstyle(10, light10);
	lightstyle(11, light11);
/*	lightstyle(12, light12);
	lightstyle(13, light13);
	lightstyle(14, light14);
	lightstyle(15, light15);
	lightstyle(16, light16);
	lightstyle(17, light17);
	lightstyle(18, light18);*/
	
	// 63 testing
	//lightstyle(63, "a");
}

void() light_use =
{
	//dprint("light_use\n");
	if (self.spawnflags & START_OFF)
	{
		if (self.message != string_null)
			lightstyle(self.style, self.message);
		else
			lightstyle(self.style, GetLightStyle(self.oldstyle));
		self.spawnflags = self.spawnflags - START_OFF;
		//dprint("turning light on\n");
	}
	else
	{
		lightstyle(self.style, light_off);
		self.spawnflags = self.spawnflags | START_OFF;
		//dprint("turning light off\n");
	}
}

void(entity b, float opacity) bmodel_lightstyle =
{
	float a = zeroconvertdefault(b.alpha, 1);
	float f;

	// 'alpha' could be set by mapper or target_fade, 0 is invisible
	//		1 blocks all light, 0 admits all
	// 'opacity' is like positional alpha: is the bmodel visible or hidden? how far open is the door? etc
	//		1 blocks all light, 0 admits all
	
	// stash for future changes in alpha
	if (opacity == 0) b.alpha2 = -1;
	else b.alpha2 = opacity;
	
	if (b.copperflags & CFL_INVLIGHT)
		opacity = 1 - opacity;
	
	// 0 for either will override the other and admit light, so we multiply
	// finally, invert so 0 (brightest) becomes a high value
	f = 1 - opacity * a;

	string l = light_str(f);

	if (b.style)
		lightstyle(b.style, l);
	if (b.switchshadstyle)
		lightstyle(b.switchshadstyle, l);
}

string(float f) light_str =
{
	float bright = floor(f * 12 + 0.5);
	
	if (bright <= 0 ) return "a";
	if (bright >= 12) return "m";

	if (bright == 1 ) return "b";
	if (bright == 2 ) return "c";
	if (bright == 3 ) return "d";
	if (bright == 4 ) return "e";
	if (bright == 5 ) return "f";
	if (bright == 6 ) return "g";
	if (bright == 7 ) return "h";
	if (bright == 8 ) return "i";
	if (bright == 9 ) return "j";
	if (bright == 10) return "k";
	if (bright == 11) return "l";
	return "a";
}

// Lights with "count" will gradually change brightness each time they're triggered, reaching normal brightness or complete darkness after 'count' triggers.
void() light_inc_use =
{
	if (self.spawnflags & START_OFF)
	{
		if (self.cnt == self.count) return;
		self.cnt = self.cnt + 1;
	}
	else
	{
		if (self.cnt == 0) return;
		self.cnt = self.cnt - 1;
	}
	
	lightstyle(self.style, light_str(self.cnt / self.count));
}

void() light_message =
{
	if (self.message != string_null)
	{
		if (self.oldstyle > 11)
			lightstyle(self.oldstyle, self.message);
		else if (self.style > 11)
			lightstyle(self.style, self.message);
		else
			dprint5("\bwarning:\b light at ", vtos(self.origin), " with message ", self.message, " but no style # set\n");
	}
}

void() light_oldstyle =
{
	if (self.style >= 32)
	{
		if (self.count > 0)
		{
			self.use = light_inc_use;
			if (self.spawnflags & START_OFF)
			{
				lightstyle(self.style, light_off);
				self.cnt = 0;
			}
			else
			{
				lightstyle(self.style, GetLightStyle(self.oldstyle));
				self.cnt = self.count;
			}
			return;
		}
		
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, light_off);
		else
			lightstyle(self.style, GetLightStyle(self.oldstyle));
	}
}

/*QUAKED light (0 .75 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light. If targeted, it will toggle between on or off. 

"start_off"	starts off until triggered

Keys:
"light"		sets brightness (default: 300)
"targetname"	entity name
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
*/
/*FGD
@PointClass base(LightTriggerable) = light : "Invisible light source" []
*/
void() light =
{
	light_message();
	
	if (self.targetname == string_null && !self.impulse)
	{	// inert light
		remove(self);
		return;
	}
	
	light_oldstyle();
}

//============================================================================

/*QUAKED light_fluoro (1 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light. Makes steady fluorescent humming sound.

Flags:
"start_off"	starts off until triggered

Keys:
"light"		sets brightness (default: 300)
"targetname"	entity name
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
*/
/*FGD
@PointClass base(LightTriggerable) = light_fluoro : "Humming fluorescent light source" []
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
}

/*QUAKED light_fluorospark (1 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light. Default style is 10. Makes sparking, broken fluorescent sound.

Keys:
"light"		sets brightness (default: 300)
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
*/
/*FGD
@PointClass base(Light) = light_fluorospark : "Sparking flickering light source" []
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
}

/*QUAKED light_globe (1 1 0) (-12 -12 -12) (12 12 12)
Sphere globe light.  Can't be triggered.

Keys:
"light"		sets brightness (default: 300)
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
*/
/*FGD
@PointClass base(Light) size(24 24 24) = light_globe : "Globe light" []
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
}

void() FireAmbient =
{
	if (self.spawnflags & 2) return;	// silent spawnflag
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
}

/*QUAKED light_torch_small_walltorch (1 1 0) (-4 -4 -12) (4 4 20)
Short wall torch. Makes crackly torch sound.

Flags:
"silent"	no ambient noise

Keys:
"light"		sets brightness (default: 300)
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
"distance" sound attenuation range (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Light, Flame) size(-4 -4 -12, 4 4 20) model({ "path": ":progs/flame.mdl" }) = 
	light_torch_small_walltorch : "Small walltorch" []
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
}

/*QUAKED light_flame_large_yellow (1 1 0) (-8 -8 -12) (8 8 20)
Large yellow flame ball.  Makes crackly torch sound.

Flags:
"silent"	no ambient noise

Keys:
"light"		sets brightness (default: 300)
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
"distance" sound attenuation range (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Light, Flame) size(-8 -8 -12, 8 8 20) model({ "path": ":progs/flame2.mdl" }) = 
	light_flame_large_yellow : "Large yellow flame" []
*/
void() light_flame_large_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
}

/*QUAKED light_flame_small_yellow (1 1 0) (-4 -4 -12) (4 4 20)
Small yellow flame ball.  Makes crackly torch sound.

Flags:
"silent"	no ambient noise

Keys:
"light"		sets brightness (default: 300)
"mangle"	spotlight direction - the first # is yaw, 0 to 360 around Z. second # is pitch, 90 up to -90 down.
"angle"		spotlight cone size
"_softangle" spotlight inner cone size
"wait"		scale the falloff distance.  N>1 will shorten range, n<1 will extend it
"delay"		attenuation formula
	0 = Linear, original id (default)
	1 = 1/x attenuation formula
	2 = 1/(x^2) attenuation formula
	3 = No attenuation (light stays same brightness at any distance)
"_color" "# # #" 0-255
"style"
    0 = normal
    1 = flicker: "mmnmmommommnonmmonqnmmo"
    2 = slow strong pulse: "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba"
    3 = candle: "mmmmmaaaaammmmmaaaaaabcdefgabcdefg"
    4 = fast strobe: "mamamamamama"
    5 = slow pulse, no black: "jklmnopqrstuvwxyzyxwvutsrqponmlkj"
    6 = flicker: "nmonqnmomnmomomno"
    7 = candle: "mmmaaaabcdefgmmmmaaaammmaamm"
    8 = candle2: "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa"
    9 = slow strobe: "aaaaaaaazzzzzzzz"
    10 = flourescent flicker: mmamammmmammamamaaamammma"
    11 = slow pulse, fading to black: "abcdefghijklmnopqrrqponmlkjihgfedcba"

    styles 32-62 are assigned by the light program for switchable lights 
    (default: 0)
"message"	override the style string directly for the assigned style (clashes will overwrite each other)
"distance" sound attenuation range (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Light, Flame) size(-4 -4 -12, 4 4 20) model({ "path": ":progs/flame2.mdl" }) = 
	light_flame_small_yellow : "Small yellow flame"  []
*/
void() light_flame_small_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
}

/*QUAKED light_flame_small_white (1 1 0) (-4 -4 -12) (4 4 20)
Same as light_flame_small_yellow. Use that one.
*/
/*FGD
@PointClass base(Light, Flame) size(-4 -4 -12, 4 4 20) model({ "path": ":progs/flame2.mdl" }) = 
	light_flame_small_white : "Small white flame (same as light_flame_small_yellow)" []
*/
void() light_flame_small_white =
{
	light_flame_small_yellow();
}

// ================================================================
/*
void() light_candle_group_off =
{
	entity c;
	c = self;
	do {
		c.frame = not(c.frame, 1);
		c = c.buddy;
	} while (c != self && c != world);
}

void() light_candle_group_on =
{
	entity c;
	c = self;
	do {
		c.frame |= 1;
		c = c.buddy;
	} while (c != self && c != world);
}

void() light_candle_use =
{
	light_use();
	if (self.spawnflags & START_OFF)
		light_candle_group_off();
	else
		light_candle_group_on();
}

// cache all candles with the same targetname as a linked list, with the first
// one as master, so they can all be turned on and off in one target activation
// without searching the whole map each time
void() light_candle_group =
{
	if (self.buddy)
		return;
	
	entity c, clast;
	string oh = self.targetname;
	clast = c = self;	
	do {
		c = find(c, targetname, oh);
		if (c.classname == "light_candle")
		{
			clast.buddy = c;
			c.targetname = string_null;
			c.nextthink = 0;
			clast = c;
		}
	} while (c != world);
	
	self.targetname = oh;
	self.use = light_candle_use;
}
*/
/*QUAKED light_candle (1 1 0) (-4 -4 0) (4 4 16) START_OFF
Candle. If triggered to turn on and off, all candles with a matching targetname will ignite or go out as well.
Keys:
"width" - choose width 1-3, default (0) is random
"height" - choose height 1-3, default (0) is random
"angle" - choose orientation, blank is random yaw
See 'light' keyvalues/spawnflags for more.
*/
/*FGD
@PointClass base(LightTriggerable) size(-4 -4 0, 4 4 16) model({ "path": ":progs/candle2.mdl" }) = 
	light_candle : "Animated candle. Trigger to turn on or off.
If triggered to turn on and off, all candles with a matching targetname will ignite or go out as well.
Choose size with 'width' and 'height' (leave either at 0 for random selection)."
[
	width(choices) : "Width" : 0 =
	[
		0: "Random"
		1: "Narrow"
		2: "Medium"
		3: "Thick"
	]
	height(choices) : "Height" : 0 =
	[
		0: "Random"
		1: "Short"
		2: "Medium"
		3: "Tall"
	]
]
*/
/*
void() light_candle =
{
	if (!self.width)
		//self.width = 1 + floor(random()*2.99);
		self.width = 1 + floor(fabs((self.origin_x % 5) + (self.origin_y % 13) - self.origin_z) % 3);
	if (!self.height)
		//self.height = 1 + floor(random()*2.99);
		self.height = 1 + floor(fabs((self.origin_x % 11) + (self.origin_y % 7) - self.origin_z) % 3);
	if (self.angles == VEC_ORIGIN)
		self.angles_y = floor(fabs((self.origin_x % 17) + (self.origin_y % 23) - self.origin_z) % 10) * 36;
	
	if (self.height == 1)
		self.model = "progs/candle1.mdl";
	else if (self.height == 2)
		self.model = "progs/candle2.mdl";
	else if (self.height == 3)
		self.model = "progs/candle3.mdl";

	precache_model2(self.model);
	setmodel(self,self.model);
		
	if (self.width == 1)
		self.frame = 4;
	else if (self.width == 2)
		self.frame = 0;
	else if (self.width == 3)
		self.frame = 2;
	if (!(self.spawnflags & START_OFF))
		self.frame += 1;
	
	light_message();
	
	if (self.targetname == string_null && self.style < 32)
	{
		makestatic(self);
		return;
	}
	
	light_oldstyle();
	self.think = light_candle_group;
	self.nextthink = time + 0.1;
}
*/
// ================================================================

string() target_lightstyle_next =
{
	entity tls;
	if (self.owner) tls = self.owner;
	else tls = self;
	
	if (tls.state == 0)
	{
		if (tls.noise == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.message;
	}
	else if (tls.state == 1)
	{
		if (tls.noise1 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise;
	}
	else if (tls.state == 2)
	{
		if (tls.noise2 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise1;
	}
	else if (tls.state == 3)
	{
		if (tls.noise3 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise2;
	}
	else if (tls.state == 4)
	{
		if (tls.noise4 == string_null)
			tls.state = 0;
		else
			tls.state += 1;
		return tls.noise3;
	}
	else if (tls.state == 5)
	{
		tls.state = 0;
		return tls.noise4;
	}
	return tls.message;
}

void(entity l, string st) lightstyle_switch =
{
	if (l.style)
		lightstyle(l.style, st);
	if (l.switchshadstyle)
		lightstyle(l.switchshadstyle, st);
}

void() target_lightstyle_go =
{
	float st;
	string newstyle = target_lightstyle_next();
	if (self.style)
	{
		st = zeroconvert(self.style);		
		lightstyle(st, newstyle);
		return;
	}
	
	entity l;
	if (self.target != string_null)
	{
		l = world;
		while (l.style == 0 && l.switchshadstyle == 0)
		{
			l = find(l, targetname, self.target);		
			if (l == world)
			{
				dprint3("target_lightstyle couldn't find target ", self.target, "\n");
				break;
			}
		}
	}
	if (l) lightstyle_switch(l, newstyle);
	
	if (self.target2 != string_null)
	{
		l = world;
		while (l.style == 0 && l.switchshadstyle == 0)
		{
			l = find(l, targetname, self.target2);	
			if (l == world)
			{
				dprint3("target_lightstyle couldn't find target2 ", self.target, "\n");
				break;
			}
		}
	}
	if (l) lightstyle_switch(l, newstyle);

	if (self.target3 != string_null)
	{
		l = world;
		while (l.style == 0 && l.switchshadstyle == 0)
		{
			l = find(l, targetname, self.target3);
			if (l == world)
			{
				dprint3("target_lightstyle couldn't find target3 ", self.target, "\n");
				break;
			}
		}
	}
	if (l) lightstyle_switch(l, newstyle);

	if (self.target4 != string_null)
	{
		l = world;
		while (l.style == 0 && l.switchshadstyle == 0)
		{
			l = find(l, targetname, self.target4);		
			if (l == world)
			{
				dprint3("target_lightstyle couldn't find target4 ", self.target, "\n");
				break;
			}
		}
	}	
	if (l) lightstyle_switch(l, newstyle);
}

void() target_lightstyle_use =
{
	entity tls;
	if (self.delay)
	{
		tls = spawn();
		tls.think = target_lightstyle_go;
		tls.nextthink = time + self.delay;
		SUB_CopyTargets(tls);
		tls.style = self.style;
		tls.owner = self;
	}
	else
	{
		target_lightstyle_go();
	}

	playercount_convert(count);
	if (self.count > 0)
	{
		self.count -= 1;
		if (self.count == 0)
			remove(self);
	}
}

/*QUAKED target_lightstyle (.5 .8 .5) (-8 -8 -8) (8 8 8)
This entity changes a global lightstyle when triggered. Set "style" to the lightstyle you want to override, and set "message" to the brightness pattern you want to set it to. If style is not set, and this entity targets any triggerable lights, it sets the brightness pattern of those lights when triggered instead. Note that targeting anything at a light makes it a triggerable light with its own style automatically.

Setting style to -1 will override lightstyle 0, which is all static lights in the entire level.

"count" limit number of uses, 0 = infinite
"delay" pause between trigger and activation
*/
/*FGD
@PointClass base(Appearflags, Targetname) color(128 210 128) = target_lightstyle : 
"Target : Lightstyle
Changes a global lightstyle when triggered."
[
	message(string) : "Brightness pattern"
	style(integer) : "Lightstyle to change (0-63)" : 0
	count(integer) : "Limit uses" : 0
	delay(string) : "Delay before activation" : "0"
	target(target_destination) : "Target: acts on all with matching targetname" 
	target2(target_destination) : "Target 2: acts on all with matching targetname" 
	target3(target_destination) : "Target 3: acts on all with matching targetname" 
	target4(target_destination) : "Target 4: acts on all with matching targetname" 
]
*/
void() target_lightstyle =
{
	if (!SUB_ShouldSpawn()) 
		return;
		
	if (self.message == string_null)
		self.message = "azam";	// suitably garish accidental default
	self.use = target_lightstyle_use;
}