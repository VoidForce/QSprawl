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

/*==============================================================================

			SOURCE FOR GLOBALVARS_T C STRUCTURE

==============================================================================*/

//
// system globals
//
entity		self;
entity		other;
entity		world;
float		time;
float		frametime;
float		timescale;

float		force_retouch;		// force all entities to touch triggers
								// next frame.  this is needed because
								// non-moving things don't normally scan
								// for triggers, and when a trigger is
								// created (like a teleport trigger), it
								// needs to catch everything.
								// decremented each frame, so set to 2
								// to guarantee everything is touched
string		mapname;

float		deathmatch;
float		coop;
float		teamplay;

float		serverflags;		// propagated from level to level, used to
								// keep track of completed episodes

float		total_secrets;
float		total_monsters;

float		found_secrets;		// number of secrets found
float		killed_monsters;	// number of monsters killed


// spawnparms are used to encode information about clients across server
// level changes
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8, parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;

//
// global variables set by built in functions
//	
vector		v_forward, v_up, v_right;	// set by makevectors()
	
// set by traceline / tracebox
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;

entity		msg_entity;				// destination of single entity writes

//
// required prog functions
//
void() 		main;						// only for testing

void()		StartFrame;

void() 		PlayerPreThink;
void() 		PlayerPostThink;

void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;		// call after setting the parm1... parms
void()		ClientDisconnect;

void()		SetNewParms;			// called when a client first connects to
									// a server. sets parms so they can be
									// saved off for restarts

void()		SetChangeParms;			// call to set parms for self so they can
									// be saved for a level transition


//================================================
void		end_sys_globals;		// flag for structure dumping
//================================================

/*
==============================================================================

			SOURCE FOR ENTVARS_T C STRUCTURE

==============================================================================
*/

//
// system fields (*** = do not set in prog code, maintained by C code)
//
.float		modelindex;		// *** model index in the precached list
.vector		absmin, absmax;	// *** origin + mins / maxs

.float		ltime;			// local time for entity
.float		movetype;
.float		solid;

.vector		origin;			// ***
.vector		oldorigin;		// ***
.vector		velocity;
.vector		angles;
.vector		avelocity;

.vector		punchangle;		// temp angle adjust from damage or recoil
.vector		punchvelocity;
.vector		shakeangle;
.vector		shakevelocity;

.string		classname;		// spawn function
.string		model;
.float		frame;
.float		skin;
.float		effects;

.vector		mins, maxs;		// bounding box extents reletive to origin
.vector		size;			// maxs - mins

.void()		touch;
.void()		use;
.void()		think;
.void()		thinkA;
.void()		thinkB;
.float		nextthinkA;
.float		nextthinkB;
.void()		blocked;		// for doors or plats, called when can't push other

.float		nextthink;
.entity		groundentity;

// stats
.float		health;
.float		frags;
.float		weapon;			// one of the IT_SHOTGUN, etc flags
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float		ammo_bullets; //new

.float		items;			// bit flags

.float		takedamage;
.entity		chain;
.float		deadflag;

.vector		view_ofs;			// add to origin to get eye point


.float		button0;		// fire
.float		button1;		// use
.float		button2;		// jump
.float		b_attack2;
.float		b_slide;
.float		b_reload;
.float		b_melee;
.float		b_kick;
.float		b_adrenaline;

.float		impulse;		// weapon changes

.float		fixangle;
.vector		v_angle;		// view / targeting angle for players
.float		idealpitch;		// calculated pitch angle for lookup up slopes


.string		netname;

.entity 	enemy;

.float		flags;

.float		colormap;
.float		team;

.float		max_health;		// players maximum health is stored here

.float		teleport_time;	// don't back up

.float		armortype;		// save this fraction of incoming damage
.float		armorvalue;

.float		waterlevel;		// 0 = not in, 1 = feet, 2 = waist, 3 = eyes
.float		watertype;		// a contents value

.float		ideal_yaw;
.float		yaw_speed;

.entity		aiment;

.entity 	goalentity;		// a movetarget or an enemy

.float		spawnflags;

.string		target;
.string		targetname;

// damage is accumulated through a frame. and sent as one single
// message, so the super shotgun doesn't generate huge messages
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;

.entity		owner;		// who launched a missile
.vector		movedir;	// mostly for doors, but also used for waterjump

.string		message;		// trigger messages

.float		sounds;		// either a cd track number or sound number

.string		noise, noise1, noise2, noise3;	// contains names of wavs to play

.float		phys_speed;
.float		phys_friction;
.float		phys_gravity;
.float		phys_acceleration;
.float		phys_airacceleration;
.float		phys_airfriction;
.float		player_inputs;
.float		entity_type;
.float		wallrun;
.vector		wall_normal;
.float 		wall_jumps;
.vector     viewmodeloffset_angles;
.float		adrenaline; // [0 .. 1]
.float		engineflags;

//================================================
void		end_sys_fields;			// flag for structure dumping
//================================================

/*
==============================================================================

				VARS NOT REFERENCED BY C CODE

==============================================================================
*/


//
// constants
//

const float	FALSE					= 0;
const float TRUE					= 1;

// edict.flags
const float	FL_FLY					= 1;
const float	FL_SWIM					= 2;
const float	FL_CLIENT				= 8;	// set for all client edicts
const float	FL_INWATER				= 16;	// for enter / leave water splash
const float	FL_MONSTER				= 32;
const float	FL_GODMODE				= 64;	// player cheat
const float	FL_NOTARGET				= 128;	// player cheat
const float	FL_ITEM					= 256;	// extra wide size for bonus items
const float	FL_ONGROUND				= 512;	// standing on something
const float	FL_PARTIALGROUND		= 1024;	// not all corners are valid
const float	FL_WATERJUMP			= 2048;	// player jumping out of water
const float	FL_JUMPRELEASED			= 4096;	// for jump debouncing

// edict.movetype values
const float	MOVETYPE_NONE			= 0;	// never moves
//const float	MOVETYPE_ANGLENOCLIP	= 1;
//const float	MOVETYPE_ANGLECLIP		= 2;
const float	MOVETYPE_WALK			= 3;	// players only
const float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
const float	MOVETYPE_FLY			= 5;
const float	MOVETYPE_TOSS			= 6;	// gravity
const float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
const float	MOVETYPE_NOCLIP			= 8;
const float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
const float	MOVETYPE_BOUNCE			= 10;
const float	MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size
const float	MOVETYPE_GIB			= 11;	// 2021 rerelease gibs
// edict.solid values
const float	SOLID_NOT				= 0;	// no interaction with other objects
const float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
const float	SOLID_BBOX				= 2;	// touch on edge, block
const float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
const float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

// range values
const float	RANGE_MELEE				= 0;
const float	RANGE_NEAR				= 1;
const float	RANGE_MID				= 2;
const float	RANGE_FAR				= 3;

// deadflag values

const float	DEAD_NO					= 0;
const float	DEAD_DYING				= 1;
const float	DEAD_DEAD				= 2;
const float	DEAD_RESPAWNABLE		= 3;

// takedamage values

const float	DAMAGE_NO				= 0;
const float	DAMAGE_YES				= 1;
const float	DAMAGE_AIM				= 2;

// items
const float	IT_AXE					= 4096;
const float	IT_SHOTGUN				= 1;
const float	IT_SUPER_SHOTGUN		= 2;
const float	IT_NAILGUN				= 4;
const float	IT_SUPER_NAILGUN		= 8;
const float	IT_GRENADE_LAUNCHER		= 16;
const float	IT_ROCKET_LAUNCHER		= 32;
const float	IT_LIGHTNING			= 64;
const float	IT_EXTRA_WEAPON			= 128;
const float	IT_SHELLS				= 256;
const float	IT_NAILS				= 512;
const float	IT_ROCKETS				= 1024;
const float	IT_CELLS				= 2048;
const float	IT_ARMOR1				= 8192;
const float	IT_ARMOR2				= 16384;
const float	IT_ARMOR3				= 32768;
const float	IT_SUPERHEALTH			= 65536;
const float	IT_KEY1					= 131072;
const float	IT_KEY2					= 262144;
const float	IT_INVISIBILITY			= 524288;
const float	IT_INVULNERABILITY		= 1048576;
const float	IT_SUIT					= 2097152;
const float	IT_QUAD					= 4194304;

// point content values

const float	CONTENT_EMPTY			= -1;
const float	CONTENT_SOLID			= -2;
const float	CONTENT_WATER			= -3;
const float	CONTENT_SLIME			= -4;
const float	CONTENT_LAVA			= -5;
const float	CONTENT_SKY				= -6;

const float	STATE_TOP		= 0;
const float	STATE_BOTTOM	= 1;
const float	STATE_UP		= 2;
const float	STATE_DOWN		= 3;

const vector	VEC_ORIGIN = '0 0 0';
const vector	VEC_HULL_MIN = '-16 -16 -24';
const vector	VEC_HULL_MAX = '16 16 32';

const vector	VEC_HULL2_MIN = '-32 -32 -24';
const vector	VEC_HULL2_MAX = '32 32 64';

// protocol bytes
const float	SVC_TEMPENTITY		= 23;
const float	SVC_KILLEDMONSTER	= 27;
const float	SVC_FOUNDSECRET		= 28;
const float	SVC_INTERMISSION	= 30;
const float	SVC_FINALE			= 31;
const float	SVC_CDTRACK			= 32;
const float	SVC_SELLSCREEN		= 33;


const float	TE_SPIKE		= 0;
const float	TE_SUPERSPIKE	= 1;
const float	TE_GUNSHOT		= 2;
const float	TE_EXPLOSION	= 3;
const float	TE_TAREXPLOSION	= 4;
const float	TE_LIGHTNING1	= 5;
const float	TE_LIGHTNING2	= 6;
const float	TE_WIZSPIKE		= 7;
const float	TE_KNIGHTSPIKE	= 8;
const float	TE_LIGHTNING3	= 9;
const float	TE_LAVASPLASH	= 10;
const float	TE_TELEPORT		= 11;
const float	TE_BEAMBYNAME	= 14; //qsprawl
const float	TE_BULLETTRACE	= 15;
const float	TE_GAUSSTRACE	= 16;
const float	TE_IMPACT		= 17;
const float	TE_MUZZLE		= 18;

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
const float	CHAN_AUTO		= 0;
const float	CHAN_WEAPON		= 1;
const float	CHAN_VOICE		= 2;
const float	CHAN_ITEM		= 3;
const float	CHAN_BODY		= 4;

const float	ATTN_NONE		= 0;
const float	ATTN_NORM		= 1;
const float	ATTN_IDLE		= 2;
const float	ATTN_STATIC		= 3;

// update types

const float	UPDATE_GENERAL	= 0;
const float	UPDATE_STATIC	= 1;
const float	UPDATE_BINARY	= 2;
const float	UPDATE_TEMP		= 3;

// entity effects

const float	EF_BRIGHTFIELD	= 1;
const float	EF_MUZZLEFLASH 	= 2;
const float	EF_BRIGHTLIGHT 	= 4;
const float	EF_DIMLIGHT 	= 8;
const float	EF_NOLERP 		= 128; // new for the muzzleflash nolerp effect // 1 frame
const float	EF_NOLERP2 		= 256; // old behaviour 2 frames


// messages
const float	MSG_BROADCAST	= 0;		// unreliable to all
const float	MSG_ONE			= 1;		// reliable to one (msg_entity)
const float	MSG_ALL			= 2;		// reliable to all
const float	MSG_INIT		= 3;		// write to the init string


//================================================

//
// globals
//
float	movedist;
float	gameover;		// set when a rule exits

string	string_null;	// null string, nothing should be held here

entity	newmis;			// launch_spike sets this after spawning it

entity	activator;		// the entity that activated a trigger or brush

entity	damage_attacker;	// set by T_Damage
float	framecount;
float	slowmotion;
float	slowmotion_time;

float	skill;
entity	multi_head;
// fields related to global multi damage 
.float	multi_damage;
.float	multi_damagehead;
.entity multi_chain;


//================================================

//
// world fields (FIXME: make globals)
//
.string		wad;
.string 	map;
.float		worldtype;	// 0=medieval 1=metal 2=base

//================================================

.string		killtarget;

//
// quakeed fields
//
.float		light_lev;		// not used by game, but parsed by light util
.float		style;
.float		gravity;

.vector	saved_forward;
.vector	saved_right;
.vector saved_up;

//
// monster ai
//
.void()		th_stand;
.void()		th_walk;
.void()		th_run;
.void()		th_missile;
.void()		th_melee;
.void(entity attacker, float damage)		th_pain;
.void()		th_die;

.entity		oldenemy;		// mad at this player before taking damage

.float		speed;

.float	lefty;

.float	search_time;
.float	attack_state;

const float	AS_STRAIGHT		= 1;
const float	AS_SLIDING		= 2;
const float	AS_MELEE		= 3;
const float	AS_MISSILE		= 4;

//
// player only fields
//
// qsprawl
// new player related constants/flags
//
#define IGNOREMONSTERS 1
#define ALLOWMONSTERS 0
#define COMBO_RESET_TIME 0.25
#define FOREVER -1

#define MAX_SHELLS 40
#define MAX_NAILS 250
#define MAX_ROCKETS 6
#define MAX_CELLS 16
const float SSGX[14] = {0.4000, 0.3200, 0.3200, 0.2400, 0.1600, 0.0800, 0.0000, 0.0000,-0.0800,-0.1600,-0.2400,-0.3200,-0.3200,-0.4000};	
const float SSGY[14] = {0.0500,-0.0500, 0.0000, 0.0500,-0.0500, 0.0500, 0.0000,-0.0500, 0.0500,-0.0500, 0.0500, 0.0000,-0.0500, 0.0500};
const float CIRCLEX[16] = {0.000, 0.382, 0.707, 0.923, 1.000, 0.923, 0.707, 0.382, 0.000,-0.382,-0.707,-0.923,-1.000,-0.923,-0.707,-0.382};
const float CIRCLEY[16] = {1.000, 0.923, 0.707, 0.382, 0.000,-0.382,-0.707,-0.923,-1.000,-0.923,-0.707,-0.382, 0.000, 0.382, 0.707, 0.923};
// ENGINE FLAGS, USED ON THE ENGINE SIDE FOR THINGS, ALWAYS SENT
const float ENF_HITMARKER = 1;
const float ENF_ADRENALINE_OFF = 2;
const float ENF_NOWALLRUN = 4;

const float IMPACT_NORMAL = 0;
const float IMPACT_GAUSS_FINAL = 1; // solid, endpoint
const float IMPACT_GAUSS_ENTRANCE = 2; // solid, penetrating, entrance hole
const float IMPACT_GAUSS_EXIT = 3; // solid, penetrating, exit hole
const float IMPACT_GAUSS_FLESH_HEADSHOT = 4;
const float IMPACT_GAUSS_FLESH = 5; // red blood
const float IMPACT_GAUSS_ROBOT_HEADSHOT = 6; 
const float IMPACT_GAUSS_ROBOT = 7; // mech/robot sparks

const float BT_FLESH_RED = 0; // human
const float BT_FLESH_BLUE = 1; // cyborg
const float BT_ROBOT = 2; // mech/robot
// movement flags
const float MF_CROUCHINAIR = 1;
const float	MF_INSLIDE = 2;
const float MF_LEFTLEG = 4;
const float MF_JUMPDISABLED = 8;
const float MF_NOACCELERATION = 16;
const float MF_NOAIRACCELERATION = 32;
const float MF_FORCEDSLIDE = 64;

//muzzleflash
const float	MF_PISTOL = 1;
const float	MF_SHOTGUN = 2;
const float	MF_SMG = 3;
const float	MF_GAUSS = 4;
const float	MF_CHAINGUN = 5;
const float	MF_GRENADE = 6;
const float	MF_LG = 7;
//slowmo states
const float SLOWMO_VALUE = 0.4;
const float SLOWMO_FADE_TIME = 0.25;
const float SLOWMO_FADE_HELPER = 4; // 1/SLOWMO_FADE_TIME

const float TYPE_GENERAL = 0;
const float TYPE_PLAYER = 1;

const float SLIDE_OFFSET = 10;
const float STANDART_OFFSET = 22;
const float SLIDE_STOPSPEED		= 100;

const float SFL_RESETWEAPONFRAME = 1;
const float SFL_SEMIAUTO = 2;
const float SFL_LEFTHAND = 4;
const float SFL_INQUICKMELEE = 8;
const float SFL_STOPMELEE = 16;
const float SFL_HOLD = 32;
const float SFL_INERTIA = 64;
const float SFL_VMOFFSET = 128; // TODO: i need to make something about viewmodel
const float SFL_NEEDTOSETSPEED = 256;
const float SFL_SPRINT = 512;
const float SFLP_GRENADE_CHARGED = 1;
const float SFLP_GRENADE_NOTOUCH = 2;

//monsterflags, should be only set on monsters
const float MFL_ISMONSTER = 1; // should be always set by default to every monster
const float MFL_HASHEAD = 2;
const float MFL_HEADKILLS = 4;
const float MFL_PAIN_HEADSHOT = 8;
const float MFL_LOST_HEAD = 16;

// movement inputs
const float MOVE_FORWARD = 1;
const float MOVE_BACKWARD = 2;
const float MOVE_RIGHT = 4;
const float MOVE_LEFT = 8;
const float MOVE_NONE = 0;

//damage flags
const float DF_HEADSHOT = 1;

//monstertype
const float TYPE_SOLDIER = 1;
const float TYPE_ENFORCER = 2;
const float TYPE_KNIGHT = 4;
const float TYPE_HELLKNIGHT = 8;
const float TYPE_DOG = 16;
const float TYPE_FIEND = 32;
const float TYPE_SCRAG = 64;
const float TYPE_OGRE = 128;
const float TYPE_SHAMBLER = 256;
const float TYPE_ZOMBIE = 512;

//

.float		sprawlflags;
.float		movementflags;
.float		katana_finished;
.float		katanasound_finished;
.float		pistol_finished;
.float		shotgun_finished;
.float		gauss_finished;
.float		grenade_finished;

.float		chaingun_speed;
.float		chaingun_frame;
//.float		chaingun_barrel;
.float		slide_active;
.float 		jump_timer;
.float		crouch_timer;
.float		footstep_timer;

.vector		punch_fast;
.vector		punch_normal;
.vector		punch_slow;
.float		punch_time;

.entity		weapon_director; // special entity that handles complex stuff for the player. One extra entity per client.
.float		deploy_time;

entity		grenade_handler; // global
.entity		list_next;
.entity		list_previous;
.float		isgrenade; // findfloat(isgrenade, 1);

.string		quickmelee_model; // stores the current weapon model;
.float		quickmelee_weapon;
.float		hitmarker_time;
.float		katana_charges;
.float		slash_list;

.float		forcedslide_timer; // no friction until timer ends
.float		noairacceleration_timer; // same for air acceleration
.float		current_airacceleration; // save previous state to restore to it
.float		noacceleration_timer; // same
.float		current_acceleration;
.float		nowallrun_timer; // forbids wallrunning
.float		current_speed; //
.float		speedmodifier; // changes speed when katana in hands
.float		adrenaline_regentimer; 
.float		dodge_time; // time until next dodge can be performed
.float		combo_index; // 
.float		combo_index_head;
.vector		combo_queue;
.float		combo_timer;
.float		saved_inputs;
.float		saved_inputs_old;

// monsters stuff ----------------------------------------------------------------------------------------------------------
.float		monstertype;

// head sphere debug
.vector		origin_old;
.vector 	offset_old; 
.float		lasttick_time; // used for head sphere, last frame change
.entity 	headmodel; // head sphere entity
.float 		alpha;
// end
.vector		head_offset;
.float		head_size;
.float		monsterflags;
.float		bodytype; //flesh or robot used BT_ flag ? should use monsterflag instead ?
.float		gib_threshold; // amount of damage required to gib the monster
.float 		lasthit_damage; //save amount of damage from last damage taken, used for gibs logic
.vector		lasthit_direction; // direction to launch the gibs
//.float		health_body;
.float		health_head; // head has separate healthpool, it still can kill the monster or made him headless
.float		armorclass_body;
.float		armorclass_head;

//
// extra utility fields, to meet all the needs for complex stuff
//.float		fA, fB, fC, fD, fE, fF, fG, fH, fI, fJ, fK, fL, fM, fN, fO, fP; // 16 floats 
//.vector		vA, vB, vC, vD, vE, vF, vG, vH, vI, vJ, vK, vL, vM, vN, vO, vP; // 48 floats
//.entity		eA, eB, eC, eD, eE, eF, eG, eH, eI, eJ, eK, eL, eM, eN, eO, eP; // 16 ints

.float		walkframe;

.float 		attack_finished;
.float		pain_finished;

.float		invincible_finished;
.float		invisible_finished;
.float		super_damage_finished;
.float		radsuit_finished;

.float		invincible_time, invincible_sound;
.float		invisible_time, invisible_sound;
.float		super_time, super_sound;
.float		rad_time;
.float		fly_sound;

.float		axhitme;

.float		show_hostile;	// set to time+0.2 whenever a client fires a
							// weapon or takes damage.  Used to alert
							// monsters that otherwise would let the player go
.float		jump_flag;		// player jump flag
.float		swim_flag;		// player swimming sound flag
.float		air_finished;	// when time > air_finished, start drowning
.float		bubble_count;	// keeps track of the number of bubbles
.string		deathtype;		// keeps track of how the player died

//
// object stuff
//
.string		mdl;
.vector		mangle;			// angle at start

.vector		oldorigin;		// only used by secret door

.float		t_length, t_width;


//
// doors, etc
//
.vector		dest, dest1, dest2;
.float		wait;			// time from firing to restarting
.float		delay;			// time from activation to firing
.entity		trigger_field;	// door's trigger entity
.string		noise4;

//
// monsters
//
.float 		pausetime;
.entity 	movetarget;


//
// doors
//
.float		aflag;
.float		dmg;			// damage done by door when hit
	
//
// misc
//
.float		cnt; 			// misc flag
	
//
// subs
//
.void()		think1;
.vector		finaldest, finalangle;

//
// triggers
//
.float		count;			// for counting triggers


//
// plats / doors / buttons
//
.float		lip;
.float		state;
.vector		pos1, pos2;		// top and bottom positions
.float		height;

//
// sounds
//
.float		waitmin, waitmax;
.float		distance;
.float		volume;


//additions. --gnounc
.string		killstring;		//the message a monster or item leaves when it kills you "was mauled by a rottweiler" etc. //gnounc

//pitch (angles_x) is inverted in quake due to a bug
	//use makevectors2 for monsters with nonzero pitch
//anyone encountering this comment with a better understanding should update the comment to be more informative and useful to modders --gnounc
void makevectors2(vector ang);		

//===========================================================================
	

//
// builtin functions
//

void(vector ang)	makevectors		= #1;		// sets v_forward, etc globals
void(entity e, vector o) setorigin	= #2;
void(entity e, string m) setmodel	= #3;		// set movetype and solid first
void(entity e, vector min, vector max) setsize = #4;
// #5 was removed
void() break						= #6;
float() random						= #7;		// returns 0 - 1
void(entity e, float chan, string samp, float vol, float atten) sound = #8;
vector(vector v) normalize			= #9;
void(string e) error				= #10;
void(string e) objerror				= #11;
float(vector v) vlen				= #12;
float(vector v) vectoyaw			= #13;
entity() spawn						= #14;
void(entity e) remove				= #15;

// sets trace_* globals
// nomonsters can be:
// An entity will also be ignored for testing if forent == test,
// forent->owner == test, or test->owner == forent
// a forent of world is ignored
void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;	

entity() checkclient				= #17;	// returns a client to look for
entity(entity start, .string fld, string match) find = #18;
string(string s) precache_sound		= #19;
string(string s) precache_model		= #20;
void(entity client, string s)stuffcmd = #21;
entity(vector org, float rad) findradius = #22;
void(string s) bprint				= #23;
void(entity client, string s) sprint = #24;
void(string s) dprint				= #25;
string(float f) ftos				= #26;
string(vector v) vtos				= #27;
void() coredump						= #28;		// prints all edicts
void() traceon						= #29;		// turns statment trace on
void() traceoff						= #30;
void(entity e) eprint				= #31;		// prints an entire edict
float(float yaw, float dist) walkmove	= #32;	// returns TRUE or FALSE
// #33 was removed
float() droptofloor= #34;	// TRUE if landed on floor
void(float style, string value) lightstyle = #35;
float(float v) rint					= #36;		// round to nearest int
float(float v) floor				= #37;		// largest integer <= v
float(float v) ceil					= #38;		// smallest integer >= v
// #39 was removed
float(entity e) checkbottom			= #40;		// true if self is on ground
float(vector v) pointcontents		= #41;		// returns a CONTENT_*
// #42 was removed
float(float f) fabs = #43;
vector(entity e, float speed) aim = #44;		// returns the shooting vector
float(string s) cvar = #45;						// return cvar.value
void(string s) localcmd = #46;					// put string into local que
entity(entity e) nextent = #47;					// for looping through all ents
void(vector o, vector d, float color, float count) particle = #48;// start a particle effect
void() ChangeYaw = #49;						// turn towards self.ideal_yaw
											// at self.yaw_speed
// #50 was removed
vector(vector v) vectoangles			= #51;

//
// direct client message generation
//
void(float to, float f) WriteByte		= #52;
void(float to, float f) WriteChar		= #53;
void(float to, float f) WriteShort		= #54;
void(float to, float f) WriteLong		= #55;
void(float to, float f) WriteCoord		= #56;
void(float to, float f) WriteAngle		= #57;
void(float to, string s) WriteString	= #58;
void(float to, entity s) WriteEntity	= #59;

//
// broadcast client message generation
//

// void(float f) bWriteByte		= #59;
// void(float f) bWriteChar		= #60;
// void(float f) bWriteShort		= #61;
// void(float f) bWriteLong		= #62;
// void(float f) bWriteCoord		= #63;
// void(float f) bWriteAngle		= #64;
// void(string s) bWriteString	= #65;
// void(entity e) bWriteEntity = #66;

void(float step) movetogoal				= #67;

string(string s) precache_file		= #68;	// no effect except for -copy
void(entity e) makestatic		= #69;
void(string s) changelevel = #70;

//#71 was removed

void(string var, string val) cvar_set = #72;	// sets cvar.value

void(entity client, string s) centerprint = #73;	// sprint, but in middle

void(vector pos, string samp, float vol, float atten) ambientsound = #74;

string(string s) precache_model2	= #75;		// registered version only
string(string s) precache_sound2	= #76;		// registered version only
string(string s) precache_file2		= #77;		// registered version only

void(entity e) setspawnparms		= #78;		// set parm1... to the
												// values at level start
												// for coop respawn
entity(.float fld, float match) findfloat = #700 // returns chain of entities
void (float newvalue) change_timescale = #701; // clamped from 0 to 10
float(vector raypoint, vector direction, vector point) distancetoray = #702; // 