
//============================================================================

/*FGD
@baseclass base(Appearflags) = Ambient [
	distance(choices) : "Attenuation" : 0 = [
		0 : "Ambient"
		1 : "Monster Idle"
		2 : "Monster Bark"
		3 : "Global"
	]
]
*/
void(float vol) sound_setup =
{
	if (!self.volume)
		self.volume = vol;
	if (!self.distance)
		self.distance = ATTN_STATIC;
	else if (self.distance == 1) self.distance = ATTN_IDLE;
	else if (self.distance == 2) self.distance = ATTN_NORM;
	else if (self.distance == 3) self.distance = ATTN_NONE;
	
	self.width = 0;
	precache_sound_safe(self.noise);
	
	if (self.noise1 == string_null) return;
	precache_sound_safe(self.noise1);
	self.width++;

	if (self.noise2 == string_null) return;
	precache_sound_safe(self.noise2);
	self.width++;

	if (self.noise3 == string_null) return;
	precache_sound_safe(self.noise3);
	self.width++;

	if (self.noise4 == string_null) return;
	precache_sound_safe(self.noise4);
	self.width++;
}

void(float vol) ambient_setup =
{
	sound_setup(vol);
	ambientsound (self.origin, self.noise, self.volume, self.distance);
}

/*QUAKED ambient_sound (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
specify any ambient sound you want. any at all!

"distance" attenuation range (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance

"noise"  wav to play - don't leave off the ".wav"!
ambience/
  buzz1.wav	clicking sparks (ambient_flouro_buzz)
  comp1.wav	bloops and bleeps (ambient_comp_hum)
  drip1.wav	those drips (ambient_drip)
  drone6.wav	deep slipgate throb (ambient_drone)
  fire1.wav	torch crackle (ambient_)
  fl_hum1.wav	flourescent light buzz (ambient_light_buzz)
  hum1.wav	wispy teleporter wind (trigger_teleport sound)
  suck1.wav	deep hollow wind (ambient_suck_wind)
  swamp1.wav	frogs and crickets (ambient_swamp1 or 2)
  water1.wav	eerie swooshing water (waterbrush sound)
  wind2.wav	higher pitched hollow wind (skybrush sound)
  windfly.wav	the wind tunnel air sound
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_sound : "Custom ambient sound"
[
	noise(string) : "path to .wav"
	volume(string) : "Volume" : "1"
]
*/
void() ambient_sound =
{
	if (!SUB_ShouldSpawn()) return;
	if (self.noise == string_null)
		return;
	
	ambient_setup(1);
}

//============================================================================


/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
good old suck wind

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_suck_wind : "Wind sound" [
	volume(string) : "Volume" : "1"
]
*/
void() ambient_suck_wind =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/suck1.wav";
	ambient_setup(1);
}

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
more of a throb, really

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_drone : "Engine/machinery sound" [
	volume(string) : "Volume" : "0.55"
]
*/
void() ambient_drone =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/drone6.wav";
	ambient_setup(0.55);
}

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
zaps and sparks

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_flouro_buzz : "Fluorescent buzzing sound" [
	volume(string) : "Volume" : "1"
]
*/
void() ambient_flouro_buzz =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/buzz1.wav";
	ambient_setup(1);
}
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
drip drip

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_drip : "Dripping sound" [
	volume(string) : "Volume" : "0.75"
]
*/
void() ambient_drip =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/drip1.wav";
	ambient_setup(0.75);
}
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
bleeps and bloops

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_comp_hum : "Computer background sounds" [
	volume(string) : "Volume" : "1"
]
*/
void() ambient_comp_hum =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/comp1.wav";
	ambient_setup(1);
}
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
what

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_thunder : "Thunder sound" [
	volume(string) : "Volume" : "0.5"
]
*/
void() ambient_thunder =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/thunder1.wav";
	ambient_setup(0.5);
}
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
gentle lamp hum

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_light_buzz : "Buzzing sound from light" [
	volume(string) : "Volume" : "0.85"
]
*/
void() ambient_light_buzz =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/fl_hum1.wav";
	ambient_setup(0.85);
}
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
swamp

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_swamp1 : "Frogs croaking" [
	volume(string) : "Volume" : "0.75"
]
*/
void() ambient_swamp1 =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/swamp1.wav";
	ambient_setup(0.75);
}
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
same as swamp1

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" loudness (0-1), distinct from distance
*/
/*FGD
@PointClass base(Ambient) color(150 0 150) = ambient_swamp2 : "Frogs croaking B" [
	volume(string) : "Volume" : "0.5"
]
*/
void() ambient_swamp2 =
{
	if (!SUB_ShouldSpawn()) return;
	self.noise = "ambience/swamp2.wav";
	ambient_setup(0.5);
}

//============================================================================

void(entity on, float _chan, string _noise, float _volume, float _distance, float _delay) sound_delayed =
{
	if (!_delay)
	{
		sound(on, _chan, _noise, _volume, _distance);
		return;
	}
	entity snd = spawn();
	setorigin(snd, BoundsCenter(on));
	snd.noise = _noise;
	snd.volume = _volume;
	snd.distance = _distance;
	snd.style = _chan;
	snd.think = target_sound_use;
	snd.nextthink = time + _delay;
}

string() target_sound_next =
{
	float r;
	if (self.width == 0) return self.noise;
	
	if (self.spawnflags & 1)
	{
		r = self.lip;
		while (r == self.lip)	// don't play the same sound twice
		{
			self.lip = floor(random() * (self.width + 0.98));
		}
	}
	else
	{
		self.lip = (self.lip + 1) % (self.width + 1);
	}
	
	switch(self.lip)
	{
		case 0:
			return self.noise;
		case 1:
			return self.noise1;
		case 2:
			return self.noise2;
		case 3:
			return self.noise3;
		case 4:
			return self.noise4;
	}
	return self.noise;
}

void() target_sound_find =
{
	if (self.buddy != world) return;
	
	if ((self.spawnflags & 2) && activator.classname == "player")
	{
		self.buddy = activator;
		return;
	}
	if (self.target != string_null)
	{
		self.buddy = find(world, targetname, self.target);
		if (!self.buddy) self.buddy = self;
		return;
	}
	self.buddy = self;
}

void() target_sound_go =
{
	string snd = target_sound_next();
	
	if (self.delay > 0)
	{
		sound_delayed(self.buddy, self.style, snd, self.volume, self.distance, self.delay);
		return;
	}
	sound(self.buddy, self.style, snd, self.volume, self.distance);
}

.float rand;
void() target_sound_think =
{
	target_sound_go();
	if (self.count > 0)
	{
		self.cnt += 1;
		if (self.cnt == self.count)
		{
			self.cnt = 0;
			self.state = 0;
			return;
		}
	}
	self.nextthink = time + self.wait + random() * self.rand;
}

void() target_sound_use =
{
	playercount_convert(count);
	if (self.spawnflags & 4)	// toggle
	{
		self.state = !self.state;
		if (self.state)
		{
			target_sound_find();
			self.think = target_sound_think;
			self.nextthink = time;
		}
		else
		{
			self.nextthink = 0;
			self.buddy = world;
		}
		return;
	}
	
	if (self.count > 0)
	{
		self.cnt += 1;
		if (self.cnt == self.count)
			SUB_RemoveSoon();
	}
	target_sound_find();
	target_sound_go();
	self.buddy = world;
}

/*QUAKED target_sound (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) SHUFFLE ON_PLAYER TOGGLE
play a sound when triggered.

"distance" attenuation (integer) - defaults to 0, which is the same as other ambient sounds.
  1 = 'idle' - monster idle sound range
  2 = 'normal' - monster bark sound range
  3 = 'none' - loops everywhere forever (don't use this)
"volume" volume, defaults to 1.0 (full volume)
"noise"  wav to play - don't leave off the ".wav"!
"noise1-4"  add additional wavs to cycle through
"delay"	delay sound after trigger
"count" limit number of uses before self destruction
"wait" time between plays, if TOGGLE
"rand" random extra time between plays, if TOGGLE
"style" force single sound channel (0 = any)

Spawnflags:
"SHUFFLE"	select next sound randomly if more than one noise is specified
"ON_PLAYER"	use activating player as source of sound
"TOGGLE"	trigger to turn on/off instead of firing once ('count' will limit use per activation if set)
*/
/*FGD
@PointClass base(Ambient, Targetname) color(150 0 150) = target_sound : "Custom triggered sound. Will play one sound every time it is triggered.
You can set up to five sounds on this entity to cycle through in order (or shuffle, with the 'random' spawnflag). They will not cut each other off, so triggering this entity more frequently than the length of the sounds will overlap them."
[
	noise(string) : "path to .wav"
	noise1(string) : "optional additional .wav to cycle"
	noise2(string) : "optional additional .wav to cycle"
	noise3(string) : "optional additional .wav to cycle"
	noise4(string) : "optional additional .wav to cycle"
	volume(string) : "Volume" : "1"
	delay(string) : "Delay" : "1"
	count(integer) : "Limit Uses" : 0
	wait(string) : "Time between sounds, if toggle" : 0
	rand(string) : "Random extra time between sounds, if toggle" : 0
	style(integer) : "Force sound channel" : 0
	spawnflags(flags) = 
	[
		1 : "Random next sound" : 0
		2 : "Play on player" : 0
		4 : "Toggle" : 0
	]
	target(target_source) : "Optional target to play sound on"
]
*/
void() target_sound =
{
	sound_setup(1);
	self.use = target_sound_use;
	if ((self.style < 0) || (self.style > 7)) self.style = 0;
}

//============================================================================
/*
void() noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
}

void() misc_noisemaker =
{
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");

	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
}
*/