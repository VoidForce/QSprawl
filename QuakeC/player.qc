/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd /raid/quake/id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run;

void()	player_stand1 =[	$axstnd1,	player_stand1	]
{
	if (self.sprawlflags & SFL_RESETWEAPONFRAME)
	{
		self.weaponframe = 0;
		self.sprawlflags -= self.sprawlflags & SFL_RESETWEAPONFRAME;
	}

	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	if (self.weapon == IT_KATANA)
	{
		if (self.walkframe >= 12)
			self.walkframe = 0;

		self.frame = $axstnd1 + self.walkframe;
	}

	else
	{
		if (self.walkframe >= 5)
			self.walkframe = 0;

		self.frame = $stand1 + self.walkframe;
	}

	self.walkframe = self.walkframe + 1;	
};

void()	player_run =[	$rockrun1,	player_run	]
{
	// todo: keep it like that for now
	if (self.weapon == IT_PISTOL || self.weapon == IT_CHAINGUN)
		self.effects = self.effects | EF_NOLERP;
	
	if (self.sprawlflags & SFL_RESETWEAPONFRAME)
	{
		self.weaponframe = 0;
		self.sprawlflags -= self.sprawlflags & SFL_RESETWEAPONFRAME;
	}

	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_stand1();
		return;
	}

	if (self.weapon == IT_KATANA)
	{
		if (self.walkframe == 6)
			self.walkframe = 0;

		self.frame = $axrun1 + self.walkframe;
	}

	else
	{
		if (self.walkframe == 6)
			self.walkframe = 0;

		self.frame = self.frame + self.walkframe;
	}

	self.walkframe = self.walkframe + 1;
};
//------------------------------------------
// Pistol
void() animatePistolFire = 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.weaponframe = 1;
	weaponThink(loopPistolFire, 0.085);
};

void() loopPistolFire =
{
	self.weaponframe++;

	if (self.weaponframe > 9)
	{
		weaponThink(player_run, 0.085);
		//self.sprawlflags |= SFL_RESETWEAPONFRAME;
	}
	else
		weaponThink(loopPistolFire, 0.085);
	
};
//------------------------------------------
// Shotgun
void() animateShotgunFire = 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.weaponframe = 1;
	weaponThink(loopShotgunFire, 0.05);
};

void() loopShotgunFire =
{
	self.weaponframe++;
	
	if (self.weaponframe == 10)
		addShake(80, -50, 0);
		//makePunch([0,-8,0], [0,-5,0], [0,0,0]);
	if (self.weaponframe == 13)
	{
		launchCasing(self.origin, v_forward * 12 + v_right * 6 + v_up * (self.view_ofs_z-2), 1);
		launchCasing(self.origin, v_forward * 12 + v_right * 8 + v_up * (self.view_ofs_z-2), 1);
	}
	if (self.weaponframe > 29)
	{
		weaponThink(player_run, 0.05);
		self.sprawlflags |= SFL_RESETWEAPONFRAME;
	}
	else
		weaponThink(loopShotgunFire, 0.05);
};
//------------------------------------------
// SMG
void() animateSMGFire = 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	if (self.sprawlflags & SFL_LEFTHAND)
	{
		self.weaponframe = floor(1 + random()*2);
		W_FireSMG(0);
	}
	else 
	{
		W_FireSMG(1);
		self.weaponframe = floor(15 + random()*2);
	}
	self.sprawlflags = SFL_LEFTHAND ^ self.sprawlflags; // switch the bit

	weaponThink(loopSMGFire, 0.05);
};

void() loopSMGFire =
{
	self.weaponframe++;

	if ((self.weaponframe > 13 && !(self.sprawlflags & SFL_LEFTHAND)) || (self.weaponframe > 27 && self.sprawlflags & SFL_LEFTHAND))
	{
		weaponThink(player_run, 0.05);
		self.sprawlflags |= SFL_RESETWEAPONFRAME;
	}
	else
		weaponThink(loopSMGFire, 0.05);
};
//------------------------------------------
// Grenade Launcher
void() animateGrenadeFire = 
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.weaponframe = 1;
	weaponThink(loopGrenadeFire, 0.05);
};

void() loopGrenadeFire =
{
	self.weaponframe++;
	self.nextthink = time + 0.05;

	if (self.weaponframe > 17)
	{
		weaponThink(player_run, 0.05);
		self.sprawlflags |= SFL_RESETWEAPONFRAME;
	}
	else
		weaponThink(loopGrenadeFire, 0.05);
};
//------------------------------------------
// Gauss
const float GAUSS_FIREFRAME = 21;

void() setGaussSkin =
{
	switch (self.weaponframe)
	{
		case 25:
			self.weapon_skin = 5;
			self.engineflags |= ENF_CHANGESKIN;
			break;
		case 21:
			if (self.weapon_skin == 3)
				sound (self, CHAN_AUTO, "weapons/gauss_charge5.wav", 1, ATTN_NORM);
			self.weapon_skin = 4;
			self.engineflags |= ENF_CHANGESKIN;
			break;
		case 17:
			if (self.weapon_skin == 2)
				sound (self, CHAN_AUTO, "weapons/gauss_charge3.wav", 1, ATTN_NORM);
			self.weapon_skin = 3;
			self.engineflags |= ENF_CHANGESKIN;
			break;
		case 13:
			if (self.weapon_skin == 1)
				sound (self, CHAN_AUTO, "weapons/gauss_charge2.wav", 1, ATTN_NORM);
			self.weapon_skin = 2;
			self.engineflags |= ENF_CHANGESKIN;
			break;
		case 9:
			if (self.weapon_skin == 0)
				sound (self, CHAN_AUTO, "weapons/gauss_charge1.wav", 1, ATTN_NORM);
			self.weapon_skin = 1;
			self.engineflags |= ENF_CHANGESKIN;
			break;
		case 5:
		case 40:
			if (self.weapon_skin == 5)
				sound (self, CHAN_AUTO, "weapons/gauss_charge4.wav", 1, ATTN_NORM);
			self.weapon_skin = 0;
			self.engineflags |= ENF_CHANGESKIN;
			break;
	}
};

void() heatupGauss =
{
	// we holding fire when post fire sequence is playing, reset
	if (self.weaponframe > GAUSS_FIREFRAME)
		self.weaponframe = 1;
	else
		self.weaponframe++;
	
	// mark hold
	self.sprawlflags |= SFL_HOLD;
	weaponThink(heatupGaussLoop, 0.03);
};

void() heatupGaussLoop = 
{
	self.weaponframe++;
	addPunchVelocity(crandom()*6,crandom()*6,0);
	setGaussSkin();
	if (self.weaponframe > GAUSS_FIREFRAME)
	{
		W_FireGauss();
		self.effects |= EF_MUZZLEFLASH;
		weaponThink(postGaussFire, 0.03);
		self.sprawlflags -= self.sprawlflags & SFL_HOLD;
		self.gauss_finished = time + 1;
		self.attack_finished = time + 0.2;
		return;
	}
	else if (!self.button0)
		weaponThink(cooldownGaussLoop, 0.03);
	else
		weaponThink(heatupGaussLoop, 0.03);
};

void() cooldownGaussLoop =
{
	self.weaponframe--;
	setGaussSkin();
	if (self.weaponframe < 1)
		weaponThink(player_run, 0.03);
	else
		weaponThink(cooldownGaussLoop, 0.03);
};

void() postGaussFire =
{
	self.weaponframe++;
	setGaussSkin();
	if (self.weaponframe > 47)
	{
		weaponThink(player_run, 0.05);
		self.sprawlflags |= SFL_RESETWEAPONFRAME;
	}
	else
		weaponThink(postGaussFire, 0.05);
};
//------------------------------------------
// Katana
void() katanaSwingStart = 
{
	self.weaponframe = 1;
	self.sprawlflags |= SFL_HOLD | SFL_SPRINT;
	weaponThink(katanaSwingLoop, 0.035);
};

void() katanaSwingLoop = 
{
	if (self.button0 && self.sprawlflags & SFL_HOLD)
	{
		weaponThink(katanaSwingLoop, 0.1);
		return;
	}
	
	if (self.weaponframe == 1)
	{
		self.attack_finished = time + 0.3;
		self.katana_finished = time + 0.4;
		addShake(30,-150,20);
	}
	
	self.weaponframe++;
	
	if (self.weaponframe == 2)
		sound (self, CHAN_WEAPON, "weapons/f_katana.wav", 1, ATTN_NORM);
	if (self.weaponframe == 4)
	{
		W_SwingKatana();
		if (self.speedmodifier > 1.35 || self.dodge_time > time)
		{
			self.touch = playerBump;
			consumeAdrenaline(0, 0.5);
		}
		self.movementflags |= MF_JUMPDISABLED;
		
		StopAcceleration(0.25, self);
		ForceStartSlide(0.25, self);
		StopAirAcceleration(0.25, self);
		
		makevectors(self.v_angle);
		
		if (self.dodge_time > time)
		{
		// 10 degrees, 800 power
			float aimangle;
			aimangle = v_forward_z;

			if (traceDown(self))//(self.flags & FL_ONGROUND)
				aimangle = clamp(0.09, aimangle, 0.175); // 5..10 degrees
			else
				aimangle = clamp(-0.5, aimangle, 0.175); // -30..10 degrees

			self.velocity = [v_forward_x, v_forward_y, aimangle] * 800;
	
			self.katana_strikes = 4;
		}
		else
		{
			self.velocity = [v_forward_x, v_forward_y, 0] * clamp(self.current_speed, ( 100 + ( 700 * (self.speedmodifier - 1.0) ) ), 1000);
			self.katana_strikes = rint((self.speedmodifier - 1.0) * 4);
		}
		self.sprawlflags -= self.sprawlflags & SFL_SPRINT;
		self.sprawlflags -= self.sprawlflags & SFL_HOLD;
	}
	
	if (self.weaponframe > 4 && self.katana_strikes > 0 && self.movementflags & MF_JUMPDISABLED)
	{
		W_SwingKatana();
		self.katana_strikes--;
	}
	
	if (self.weaponframe == 8 )
	{
		self.movementflags -= self.movementflags & MF_JUMPDISABLED;
		self.touch = SUB_Null;
	}

	if (self.weaponframe > 39)
	{
		self.sprawlflags |= SFL_RESETWEAPONFRAME;
		//self.attack_finished = time + 0.2;
		weaponThink(player_run, 0.05);
	}
	else
		weaponThink(katanaSwingLoop, 0.035);
};
//------------------------------------------
// Quick Melee
void() quickMeleeStart = 
{
	self.stopmelee_finished = time + 0.3;
	self.sprawlflags |= SFL_INQUICKMELEE | SFL_STOPMELEE;
	self.sprawlflags -= self.sprawlflags & SFL_HOLD;
	self.engineflags |= ENF_CHANGESKIN;
	self.weapon_skin = 0; // no skin fix
	self.weaponmodel = "progs/v_katana.mdl";
	
	sound (self, CHAN_AUTO, "weapons/f_katana.wav", 1, ATTN_NORM);
	self.weaponframe = 1;
	self.think = quickMeleeLoop;
	self.nextthink = time + 0.01;
};

void() quickMeleeLoop = 
{
	self.weaponframe++;
	self.nextthink = time + 0.05;
	
	if (self.weaponframe == 4)
		W_SwingKatana();
	
	if (self.weaponframe > 7) //7 39
	{
		self.attack_finished = time + 0.2;
		self.effects = self.effects | EF_NOLERP;
		self.sprawlflags -= self.sprawlflags & SFL_INQUICKMELEE;
		deployGun(self.weapon);
	}
	else
		self.think = quickMeleeLoop;
};
//------------------------------------------
// Chaingun

#define CG_STARTFRAME 13
#define CG_LOOPFRAME 24

#define PRE_FIRST 24
#define FIRE_FIRST 1
#define END_FIRST 4
#define AFTER_FIRST 17

#define PRE_SECOND 16
#define FIRE_SECOND 5
#define END_SECOND 8
#define AFTER_SECOND 21

#define PRE_THIRD 20
#define FIRE_THIRD 9
#define END_THIRD 12
#define AFTER_THIRD 13

#define CG_FASTEST_SPIN 0.03 // 0.025
#define CG_SLOWEST_SPIN 0.15 // 0.1
#define CG_FIRE_STEP 0.02
#define CG_SPEEDUP_STEP 0.005
#define CG_SLOWDOWN_STEP 0.01
#define CG_INERTIA 20

void() animateChaingun =
{
	//dprint("start: ");
	//dprint2(ftos(self.weaponframe), " after: ");
	sound (self, 5, "weapons/chaingun_wu.wav", 0.5, ATTN_NORM);
	self.spin_sound_loop = time + 0.5;

	self.attack_finished = time + 0.3;
	self.sprawlflags |= SFL_HOLD;
	
	if (self.chaingun_frame == 0)
		self.weaponframe = CG_STARTFRAME;
	else
	{
		self.weaponframe++;
		if (self.weaponframe > CG_LOOPFRAME)
			self.weaponframe = CG_STARTFRAME;
	}
	
	if (self.chaingun_speed > 0.1)
		self.chaingun_speed = 0.1;
	
	weaponThink(spinChaingunLoop, self.chaingun_speed);
};

// --------------- SPIN -----------
void() spinChaingunLoop =
{
	//dprint("spin: ");
	//dprint(ftos(self.weaponframe));endl();
	if (self.spin_sound_loop < time)
	{
		sound (self, 5, "weapons/chaingun_loop.wav", 0.5, ATTN_NORM);
		self.spin_sound_loop = time + 2.2;
	}
	
	if (!self.button0)
	{
		self.attack_finished = time + 0.1;
		self.sprawlflags -= self.sprawlflags & SFL_HOLD;
		self.weaponframe++;
		if (self.weaponframe > CG_LOOPFRAME)
			self.weaponframe = CG_STARTFRAME;
		weaponThink(spinDownLoop, self.chaingun_speed);
		sound (self, 5, "weapons/chaingun_wd.wav", 0.5, ATTN_NORM);
		return;
	}

	//self.chaingun_speed -= CG_SPEEDUP_STEP;
	self.chaingun_speed *= 0.95;
	self.chaingun_speed = floor(self.chaingun_speed * 1000) * 0.001;
	if (self.chaingun_speed < CG_FASTEST_SPIN)
	{
	// we spin fast enough, so check for fire positions
		self.chaingun_speed = CG_FASTEST_SPIN;
		
		switch (self.weaponframe)
		{
			case PRE_FIRST:
				self.weaponframe = FIRE_FIRST;
				goto fire;
				break;
				
			case PRE_SECOND:
				self.weaponframe = FIRE_SECOND;
				goto fire;
				break;
				
			case PRE_THIRD:
				self.weaponframe = FIRE_THIRD;
				goto fire;
				break;
		}
	}
		
	self.weaponframe++;
	
	if (self.weaponframe > CG_LOOPFRAME)
		self.weaponframe = CG_STARTFRAME;
	
	self.chaingun_frame = self.weaponframe;
	
	weaponThink(spinChaingunLoop, self.chaingun_speed);
	return; // default exit
//----------------------------------
	fire:
		W_FireChaingun();
		self.effects = self.effects | EF_MUZZLEFLASH;
		
		if (self.ammo_bullets < 1)
		{
			self.sprawlflags -= self.sprawlflags & SFL_HOLD;
			weaponThink(player_run, 0.05);
			return;
		}
		weaponThink(fireChaingunLoop, self.chaingun_speed);
};

// --------------- FIRE -----------
void() fireChaingunLoop =
{
	if (self.spin_sound_loop < time)
	{
		sound (self, 5, "weapons/chaingun_loop.wav", 0.5, ATTN_NORM);
		self.spin_sound_loop = time + 2.263;
	}
	//dprint("fire: ");
	//dprint(ftos(self.weaponframe));endl();
	if (!self.button0)
	{
		self.attack_finished = time + 0.1;
		self.sprawlflags -= self.sprawlflags & SFL_HOLD;
		self.weaponframe++;
		self.chaingun_speed = CG_FIRE_STEP;
		self.chaingun_count = CG_INERTIA; // how many frames to spin with the same speed
		weaponThink(spinDownLoop, self.chaingun_speed);
		sound (self, 5, "weapons/chaingun_wd.wav", 0.5, ATTN_NORM);
		return;
	}
	
	self.weaponframe++;
	
	if (self.weaponframe == CG_STARTFRAME)
		self.weaponframe = FIRE_FIRST;
	
	switch (self.weaponframe)
	{
		case FIRE_FIRST:
			goto fire;
			break;
		case FIRE_SECOND:
			goto fire;
			break;
		case FIRE_THIRD:
			goto fire;
			break;
	}
	self.chaingun_frame = self.weaponframe + 12; // 12 frames offset between fire and flat spin
	weaponThink(fireChaingunLoop, CG_FIRE_STEP);	
	return; // default exit
//----------------------------------	
	fire:
		W_FireChaingun();
		self.effects = self.effects | EF_MUZZLEFLASH;
		
		if (self.ammo_bullets < 1)
		{
			self.sprawlflags -= self.sprawlflags & SFL_HOLD;
			weaponThink(player_run, 0.05);
			return;
		}
		weaponThink(fireChaingunLoop, CG_FIRE_STEP);	
}

// --------------- SLOWDOWN -----------
void() spinDownLoop =
{
	//dprint("slow: ");
	//dprint(ftos(self.weaponframe));endl();

// don't let weaponframe redirect us to animateChaingun, use this loop to catch the input instead
// otherwise we will have non-lerped transition to the next frame, caused by thinktime interruption
	self.attack_finished = time + 0.16; 
	
// transition from firing frames to standart spin frames, let it finish rotation and reach "end" frames
	if (self.weaponframe < 13)
	{
		switch (self.weaponframe)
		{
			case END_FIRST:
				self.weaponframe = AFTER_FIRST;
				break;
			case END_SECOND:
				self.weaponframe = AFTER_SECOND;
				break;
			case END_THIRD:
				self.weaponframe = AFTER_THIRD;
				break;
			default:
				self.weaponframe++;
				break;
		}
	}
	else
	{
		if (self.button0)
		{
			self.weaponframe++;
			if (self.weaponframe > CG_LOOPFRAME)
				self.weaponframe = CG_STARTFRAME;
			weaponThink(animateChaingun, self.chaingun_speed);
			return;
		}
		self.weaponframe++;
		if (self.chaingun_count > 0)
			self.chaingun_count--;
		else
		{
			//self.chaingun_speed += CG_SLOWDOWN_STEP;
			self.chaingun_speed *= 1.05;
			self.chaingun_speed = floor(self.chaingun_speed * 1000) * 0.001;
		}
	}

	if (self.weaponframe > CG_LOOPFRAME)
		self.weaponframe = CG_STARTFRAME;
	
	self.chaingun_frame = self.weaponframe;
		
	if (self.chaingun_speed > CG_SLOWEST_SPIN)
	{
		self.chaingun_speed = CG_SLOWEST_SPIN;
		weaponThink(player_run, 0.1);
	}
	else
		weaponThink(spinDownLoop, self.chaingun_speed);
	self.spin_finished = time + self.chaingun_speed;
};

//============================================================================

void() player_light1 = //[$light1, player_light2  ] 
{
	if (!self.button0)
	{
		//self.sprawlflags |= SFL_RESETWEAPONFRAME;
		self.weaponframe = 69;
		self.think = light_cool;
		self.nextthink = time + 0.05;
		//player_run ();
		return;
	}
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	self.weaponframe++;

	if (self.weaponframe == 53)
		self.weaponframe = 11;

	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
	self.think = player_light1;
	self.nextthink = time + 0.05;
};

void() light_cool = 
{
	self.weaponframe++;
	self.nextthink = time + 0.05;

	if (self.weaponframe > 82)
	{
		self.sprawlflags |= SFL_RESETWEAPONFRAME;
		self.think = player_run;
	}
	else
		self.think = light_cool;
};

void() animateShock =
{
	self.weaponframe ++;
	if (self.weaponframe < 70)
	{
		W_FireLightning();
	}
	if (self.weaponframe > 74)
	{
		self.sprawlflags -= self.sprawlflags & SFL_HOLD;
		self.weaponframe = 0;
		self.think = player_run;
		self.nextthink = time + 0.05;
	}
	else
	{
		self.think = animateShock;
		self.nextthink = time + 0.05;
	}
	//self.shock_charge;
};

//============================================================================

void() PainSound =
{
	local float		rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	// water pain sounds
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);

		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);

		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);

		return;
	}

	// slime pain sounds
	if (self.watertype == CONTENT_SLIME)
	{
		// FIX ME	put in some steam here
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
	
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);

		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);

		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);

		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}

	self.pain_finished = time + 0.5;

	// don't make multiple pain sounds right after each other

	// ax pain sound
	if (self.axhitme == 1)
	{
		self.axhitme = 0;
		sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);

		return;
	}
	

	rs = rint((random() * 5) + 1);

	self.noise = string_null;

	switch (rs)
	{

	case 1:
		self.noise = "player/pain1.wav";
		break;
	case 2:
		self.noise = "player/pain2.wav";
		break;
	case 3:
		self.noise = "player/pain3.wav";
		break;
	case 4:
		self.noise = "player/pain4.wav";
		break;
	case 5:
		self.noise = "player/pain5.wav";
		break;
	default:
		self.noise = "player/pain6.wav";
		break;
	}
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

};

void()	player_pain1 =	[	$pain1,	player_pain2	] {PainSound();self.weaponframe=0;};
void()	player_pain2 =	[	$pain2,	player_pain3	] {};
void()	player_pain3 =	[	$pain3,	player_pain4	] {};
void()	player_pain4 =	[	$pain4,	player_pain5	] {};
void()	player_pain5 =	[	$pain5,	player_pain6	] {};
void()	player_pain6 =	[	$pain6,	player_run	] {};

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {PainSound();self.weaponframe=0;};
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {};
void()	player_axpain6 =	[	$axpain6,	player_run	] {};

void(entity attacker, float damage) player_pain =
{
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames

	if (self.weapon == IT_KATANA)
		player_axpain1 ();

	else
		player_pain1 ();
};

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;
void() player_die_ax1;

void() DeathBubblesSpawn =
{
	local entity	bubble;

	if (self.owner.waterlevel != 3)
		return;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;

	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
	local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	
	return;
};


void() DeathSound =
{
	local float		rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);

		return;
	}
	
	rs = rint ((random() * 4) + 1);

	if (rs == 1)
		self.noise = "player/death1.wav";

	if (rs == 2)
		self.noise = "player/death2.wav";

	if (rs == 3)
		self.noise = "player/death3.wav";

	if (rs == 4)
		self.noise = "player/death4.wav";

	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);

	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
	self.deadflag = DEAD_DEAD;	// allow respawn after a certain time
};

void() GibPlayer =
{
	ThrowHead ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);

	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDie =
{
	local	float	i;
	
	self.items = self.items - (self.items & IT_INVISIBILITY);
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.modelindex = modelindex_player;	// don't use eyes
	self.sprawlflags = 0;
	self.engineflags = 0;

	if (deathmatch || coop)
		DropBackpack();
	
	self.weaponmodel=string_null;
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;

	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
	{
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
	
	if (self.weapon == IT_KATANA)
	{
		player_die_ax1 ();
		return;
	}
	
	i = cvar("temp1");

	if (!i)
		i = 1 + floor(random()*6);
	
	if (i == 1)
		player_diea1();

	else if (i == 2)
		player_dieb1();

	else if (i == 3)
		player_diec1();

	else if (i == 4)
		player_died1();

	else
		player_diee1();
};

void() set_suicide_frame =
{	// used by klill command and diconnect command

	if (self.model != "progs/player.mdl")
		return;	// allready gibbed

	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerDead();};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead();};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead();};

void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead();};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead();};

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {};
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerDead();};
