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
nosave float		timescale;

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
vector		project;
vector		reject;
vector		reflect;

vector		wind;

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
.float		weapon;			// one of the IT_PISTOL, etc flags
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

//.float		armortype;		// save this fraction of incoming damage
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
.float		weapon_skin;
.float		clip;
.float 		noclip;
.float		info_type; //hardcoded names for now
.float		info_hp;
.float		info_head;
.float		info_hp_max;
.float		info_head_max;

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
const float NOFLAGS					= 0;
const float NULL_OFFSET				= 0.0;

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
const float FL_EXPLOBOX				= 8192;
const float FL_PROJECTILE			= 16384;

// do not modify, hardcoded into engine [clipgroups]
const float CLIP_CLIENT			= 1; 
const float CLIP_MONSTER		= 2; 
const float CLIP_PROJECTILE		= 4; 
const float CLIP_GROUPA			= 8; 
const float CLIP_GROUPB			= 16;
const float CLIP_GROUPC			= 32;
const float CLIP_GROUPD			= 64;
const float CLIP_GROUPE			= 128;

const float NOCLIP_CLIENT		= CLIP_CLIENT;	
const float NOCLIP_MONSTER		= CLIP_MONSTER;
const float NOCLIP_PROJECTILE	= CLIP_PROJECTILE;
const float NOCLIP_GROUPA		= CLIP_GROUPA;
const float NOCLIP_GROUPB		= CLIP_GROUPB;
const float NOCLIP_GROUPC		= CLIP_GROUPC;	
const float NOCLIP_GROUPD		= CLIP_GROUPD;	
const float NOCLIP_GROUPE		= CLIP_GROUPE;	
// do not modify ^^

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
const float	DEAD_SPECTATING			= 3; // copper rename

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
const float	IT_BULLETS				= 128;
const float	IT_SHELLS				= 256;
const float	IT_NAILS				= 512;
const float	IT_ROCKETS				= 1024;
const float	IT_CELLS				= 2048;
const float	IT_ARMOR				= 8192;
//			= 16384;
//			= 32768;
//const float	IT_SUPERHEALTH			= 65536;
const float	IT_KEY1					= 131072;
const float	IT_KEY2					= 262144;
const float	IT_INVISIBILITY			= 524288;
const float	IT_INVULNERABILITY		= 1048576;
const float	IT_SUIT					= 2097152;
const float	IT_QUAD					= 4194304;

const float	IT_KATANA				= IT_AXE;
const float	IT_PISTOL				= IT_SHOTGUN;
const float	IT_SMGS					= IT_NAILGUN;
const float	IT_CHAINGUN				= IT_SUPER_NAILGUN;
const float	IT_GRENADE_LAUNCHER		= IT_GRENADE_LAUNCHER;
const float	IT_GAUSS				= IT_ROCKET_LAUNCHER;
const float	IT_SHOCK				= IT_LIGHTNING;

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
const float	SVC_UPDATESTAT		= 3;
const float	SVC_TEMPENTITY		= 23;
const float	SVC_KILLEDMONSTER	= 27;
const float	SVC_FOUNDSECRET		= 28;
const float	SVC_INTERMISSION	= 30;
const float	SVC_FINALE			= 31;
const float	SVC_CDTRACK			= 32;
const float	SVC_SELLSCREEN		= 33;

#define	TE_SPIKE				0
#define	TE_EXPLOSION			1
#define	TE_LIGHTNING1			2
#define	TE_LIGHTNING2			3
#define	TE_LIGHTNING3			4
#define	TE_LAVASPLASH			5
#define	TE_TELEPORT				6
#define TE_ROBOTHEAD_EXPLOSION	7
#define TE_SYNTHHEAD_EXPLOSION 	8
#define	TE_BEAMBYNAME			9
#define	TE_BULLETTRACE			10
#define	TE_GAUSSTRACE			11
#define	TE_IMPACT				12
#define TE_HEAD					13
#define TE_LASERTRACE			14
#define TE_SHOCKWAVE			15
#define	TE_EXPLOSION_PLASMA		16

enum LASERCOLOR:float {
	LASER_BLUE = 0xd0,
	LASER_RED = 0xfb,
	LASER_YELLOW = 0xf2,
	LASER_WHITE = 0xfe
};

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
const float EF_QEX_QUADLIGHT	= 16;	// 2021 rerelease
const float EF_QEX_PENTALIGHT	= 32;	// 2021 rerelease
const float EF_QEX_CANDLELIGHT	= 64;	// 2021 rerelease
const float	EF_NOLERP 		= 128; // new for the muzzleflash nolerp effect // 1 frame
const float	EF_NOLERP2 		= 256; // old behaviour 2 frames

// messages
const float	MSG_BROADCAST	= 0;		// unreliable to all
const float	MSG_ONE			= 1;		// reliable to one (msg_entity)
const float	MSG_ALL			= 2;		// reliable to all
const float	MSG_INIT		= 3;		// write to the init string

// svc updatestat byte types - from copper by Lunaran
const float	STAT_HEALTH			= 0;
const float	STAT_FRAGS			= 1;
const float	STAT_WEAPON			= 2;
const float	STAT_AMMO			= 3;
const float	STAT_ARMOR			= 4;
const float	STAT_WEAPONFRAME	= 5;
const float	STAT_SHELLS			= 6;
const float	STAT_NAILS			= 7;
const float	STAT_ROCKETS		= 8;
const float	STAT_CELLS			= 9;
const float	STAT_ACTIVEWEAPON	= 10;
const float	STAT_TOTALSECRETS	= 11;	// hmmm ...
const float	STAT_TOTALMONSTERS	= 12;	// must send this if new monsters are spawned after the map starts
const float	STAT_SECRETS		= 13;	// bumped on client side by svc_foundsecret
const float	STAT_MONSTERS		= 14;	// bumped by svc_killedmonster

const float SPAWN_TRIGGERSPAWN2	= 8; //smp?
const float SPAWN_TRIGGERSPAWN	= 16; //copper
const float	SPAWN_NO_TFOG		= 32;
const float	SPAWN_NO_TFRAG		= 64;
const float	SPAWN_INSTAWAKE		= 128;

#define FLICK_TIME	2.45
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

// Slow Motion stuff

const float SLOWMO_VALUE = 0.4;
const float SLOWMO_FADE_TIME = 0.25;
const float SLOWMO_FADE_HELPER = 4; // 1/SLOWMO_FADE_TIME
/*
enumflags SLOWMOSTATE {
	SLOWMO_OFF = 0,
	SLOWMO_ON = 1,
	SLOWMO_PLAYER,
	SLOWMO_EVENT,
	SLOWMO_TRANSITION,
	SLOWMO_DESIRE_ON,
	SLOWMO_DESIRE_OFF,
	SLOWMO_FORCE_OFF,
	SLOWMO_TRANSITION_TO_OFF,
	SLOWMO_TRANSITION_TO_ON,
	SLOWMO_NEEDSCHANGE,
};*/

nosave float	slowmotion;		// flags based?
//float 	slowmotion_flags;
nosave float	slowmotion_time;
//float	slowmotion_event_time;
//float	slowmotion_cooldown;
#define SKIN_DEFAULT 0
#define SKIN_GLOW 1

// Slow Motion stuff end

float	skill;
entity wind_ent;
entity	multi_head;
// fields related to global multi damage 
#define M_BODY 0
#define M_HEAD 1
#define M_COUNT 2
.vector	multi_damage; // x = body, y = head, z = hits count for shotgun
.entity multi_chain;
.float 		alpha;
.string		target2;
.string		target3;
.string		target4;

.float		armortype;		// save this fraction of incoming damage
.float blackhole_timer; // shambler's attack

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
.float		oldstyle; // copper field
.float		gravity;
.float		scale;

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
.void()		th_spawn; // new for triggerspawn

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
#define MAX_BULLETS 96
						//1		2		3		4		5		6		7		8		9		10		11		12		13		14
const float SSGX[14] = {0.3200, 0.0000,-0.3200, 0.4000, 0.2400, 0.0800,-0.0800,-0.2400,-0.4000, 0.3200, 0.1600, 0.0000,-0.1600,-0.3200}; //rearranged for easier fx messages checks
const float SSGY[14] = {0.0000, 0.0000, 0.0000, 0.0500, 0.0500, 0.0500, 0.0500, 0.0500, 0.0500,-0.0500,-0.0500,-0.0500,-0.0500,-0.0500};

const float CIRCLEX[16] = {0.000, 0.382, 0.707, 0.923, 1.000, 0.923, 0.707, 0.382, 0.000,-0.382,-0.707,-0.923,-1.000,-0.923,-0.707,-0.382};
const float CIRCLEY[16] = {1.000, 0.923, 0.707, 0.382, 0.000,-0.382,-0.707,-0.923,-1.000,-0.923,-0.707,-0.382, 0.000, 0.382, 0.707, 0.923};

// ENGINE FLAGS, USED ON THE ENGINE SIDE FOR THINGS, ALWAYS SENT
const float ENF_HITMARKER = 1;
const float ENF_ADRENALINE_OFF = 2;
const float ENF_NOWALLRUN = 4;
const float ENF_HITHEAD = 8;
const float ENF_CHANGESKIN = 16; // never subtract in QC, only add, cause engine uses standart subtract operation to get rid of this flag
const float ENF_HUDINFO = 32;
//-------------------------------------------------------------

#define IMPACT_NORMAL 0
#define IMPACT_GAUSS_FINAL 1 // solid, endpoint
#define IMPACT_GAUSS_ENTRANCE 2 // solid, penetrating, entrance hole
#define IMPACT_GAUSS_EXIT 3 // solid, penetrating, exit hole
#define IMPACT_GAUSS_FLESH 4 // red blood
#define IMPACT_GAUSS_ROBOT 5 // mech/robot sparks
#define IMPACT_FLESH_HEADSHOT 6
#define IMPACT_ROBOT_HEADSHOT 7
#define IMPACT_FLESH 8
#define IMPACT_ROBOT 9
#define IMPACT_WALL 10
#define IMPACT_LASER 11
#define IMPACT_SHIELD 12
#define IMPACT_SHOCK 13

// movement flags
const float MF_CROUCHINAIR = 1;
const float	MF_INSLIDE = 2;
const float MF_LEFTLEG = 4;
const float MF_JUMPDISABLED = 8;
const float MF_NOACCELERATION = 16;
const float MF_NOAIRACCELERATION = 32;
const float MF_FORCEDSLIDE = 64;
const float MF_AFTERDODGE = 128;
const float MF_NOWALLJUMPS = 256;
const float MF_NODODGES = 512;
const float MF_NOSLIDES = 1024;
const float MF_NOSPRINT = 2048;

//muzzleflash
const float	MF_PISTOL = 1;
const float	MF_SHOTGUN = 2;
const float	MF_SMG = 3;
const float	MF_GAUSS = 4;
const float	MF_CHAINGUN = 5;
const float	MF_GRENADE = 6;
const float	MF_LG = 7;

//monsterflags, should be only set on monsters
const float MFL_NOTMONSTER = 1; // obsolete? meant for explobox i think
const float MFL_HASHEAD = 2; // recieve head damage, additional logic when head is gone
const float MFL_HEADKILLS = 4; // set this if you want healh_health < 0 to kill target
const float MFL_PAIN_HEADSHOT = 8; // play special pain animation
const float MFL_LOST_HEAD = 16; // mark that we just lost the head, so launch special event
const float MFL_DROP_HEAD = 32; // we got killed with katana, spawn head model
const float MFL_ROBOT = 64;
const float MFL_SYNTH = 128;
const float MFL_GIB_ME = 256;
const float MFL_BOSS = 512;
const float MFL_CONFUSED = 1024; // monster chase player's trail instead of origin
const float MFL_SHIELD = 2048;
const float MFL_PUSH_RESISTENT = 4096;
const float MFL_FIENDTOUCH = 8192; // fiend only
const float MFL_LOSTWEAPON = 8192; // ogre only
const float MFL_SHAM_EXPLODE = 8192; // shambler only

//const float MFL_HASDRONE = 8192; // vore only

const float TYPE_GENERAL = 0;
const float TYPE_PLAYER = 1;

const float SLIDE_OFFSET = 10;
const float STANDART_OFFSET = 22;
const float SLIDE_STOPSPEED		= 100;
// sprawflags
const float SFL_RESETWEAPONFRAME = 1;
const float SFL_SEMIAUTO = 2;
const float SFL_LEFTHAND = 4;
const float SFL_INQUICKMELEE = 8;
const float SFL_STOPMELEE = 16;
const float SFL_HOLD = 32;
const float SFL_READYTOSPIN = 64;
const float SFL_VMOFFSET = 128;
const float SFL_NEEDTOSETSPEED = 256;
const float SFL_SPRINT = 512;
const float SFL_UNLIMITED_ADRENALINE = 1024;
const float SFL_CHANGESCREENTINT = 2048;

// world brush flags
const float SFL_MOVINGSOLID = 1;
// projectile
const float SFLP_GRENADE_CHARGED = 1;
const float SFLP_GRENADE_NOTOUCH = 2;
const float SFLP_GRENADE_CANTOUCHSOFT = 4;
const float SFLP_OGRE = 8;

// items
const float SFLI_TARGETSFIRED = 1;
const float SFLI_MODELSET = 2; // ammo nails change model only once when < 51
const float SFLI_REGEN = 4;
const float SFLI_MEGA = 8;
const float SFLI_SETAMMO = 16; // value need to be set on respawn 
const float SFLI_SETHEALTH = 32; // value need to be set on respawn 

// movement inputs
const float MOVE_FORWARD = 1;
const float MOVE_BACKWARD = 2;
const float MOVE_RIGHT = 4;
const float MOVE_LEFT = 8;
const float MOVE_NONE = 0;

//damage flags
const float DF_HEADSHOT = 1; // damage to the head's healthpool
const float DF_NEVERGIB = 2;
const float DF_ALWAYSGIB = 4;
const float DF_KATANA = 8; // damage was done by katana
const float DF_EXPLOSION = 16; // damage was done by explosion
const float DF_EPICENTER = 32; // target was close to the epicenter, used by ogres to explode their weapons
const float DF_INSTAGIB = 64; // telefrag
const float DF_SHOCK = 128;

//monstertypes
//"enum [class] [name_e]:type"
enum monstertypes:int {
	TYPE_SOLDIER,
	TYPE_KNIGHT,
	TYPE_ENFORCER,
	TYPE_DOG,
	TYPE_SCRAG,
	TYPE_ZOMBIE,
	TYPE_OGRE,
	TYPE_FIEND,
	TYPE_HELLKNIGHT,
	TYPE_SHAMBLER,
	TYPE_VORE
};

#define KATANA_DAMAGE			40
#define PISTOL_DAMAGE			70
#define PISTOL_PENETRATION		-0.4
#define SMG_DAMAGE				15
#define SMG_PENETRATION			0.5
#define SHOTGUN_DAMAGE			20
#define SHOTGUN_PENETRATION		-0.5
#define CHAINGUN_DAMAGE			120
#define CHAINGUN_PENETRATION	-0.7
#define GRENADE_EXPLOSION		200
#define GRENADE_CUMULATIVE		170
#define GRENADE_PENETRATION 	0.9
#define GAUSS_DAMAGE			190
#define SHOCK_DAMAGE_MIN		15
#define SHOCK_DAMAGE_MAX		40

#define EXTRA_PENETRATION_EASY		0.8
#define EXTRA_PENETRATION_NORMAL	0.4

typedef struct {
	float body_resistance; // percent of damage to decline
	float body_mitigation; // absolute value to subtract from resulted damage
	float head_resistance;
	float head_mitigation;
	float explosives_resistance;
} armor_t;

armor_t armorstats; // global used in T_DAMAGE
// stats for monsters		  br bm			hr hm		er
const armor_t A_NULL 		= {0, 0,		0, 0,		0};
const armor_t A_SOLDIER		= {0.1, 0,		0, 0,		0};
const armor_t A_KNIGHT		= {0.25, 0,		0, 0,		0};
const armor_t A_ENFORCER	= {0.3, 1,		0.15, 3,	0};
const armor_t A_DOG			= {0.3, 1,		0, 0,		0.4};
const armor_t A_SCRAG		= {0.0, 0,		0, 0,		0.0};
const armor_t A_ZOMBIE		= {0.3, 2,		0.2, 1,		0.0};
const armor_t A_OGRE		= {0.5, 4,		0.2, 1,		0.5};
const armor_t A_HELLKNIGHT	= {0.6, 2,		0.3, 2,		0.2}; // the guy is a synth, so he his body can resist a lot of damage
const armor_t A_FIEND		= {0.6, 2,		0.8, 30,	0.5};
const armor_t A_VORE		= {0.4, 5,		0, 0,		0.5};
const armor_t A_SHAMBLER	= {0.8, 5,		0.95, 50,	0.75};

#define SOLDIER_HEALTH 		100
#define SOLDIER_HEAD 		20
#define KNIGHT_HEALTH		100
#define KNIGHT_HEAD			20
#define ENFORCER_HEALTH		150
#define ENFORCER_HEAD		50
#define DOG_HEALTH			100
#define SCRAG_HEALTH		100
#define ZOMBIE_THROWHEADHP	100
#define ZOMBIE_HEALTH		150
#define ZOMBIE_HEADLESS		50
#define ZOMBIE_HEAD			50
#define OGRE_HEALTH			475		
#define OGRE_HEALTH_FAST	350		
#define OGRE_HEAD			150
#define OGRE_HEAD_FAST		100
#define OGRE_HEAD_EXPLOSION_DAMAGE	175
#define OGRE_MINHP			 50
#define HELLKNIGHT_HEALTH	300
#define HELLKNIGHT_HEAD		80
#define FIEND_HEALTH		300
#define FIEND_HEAD			50
#define VORE_HEALTH			400
#define SHAMBLER_HEALTH		800
#define SHAMBLER_HEAD		350

// these are player positions stored for monster aiming calculations
.vector		trail1;
.vector		trail2;
.vector		trail3;
.vector		trail4;
.float		trail; // position to use, changes with events like dodge and jumps
.float		trail_time; // used to space out trail normalization

// hud info_ent
.float 		info_stay_time;
.float 		info_trace_time;

.float		counter;
.float		sprawlflags;
.float		movementflags;
.float		overheal_decay;
.float		katana_finished;
.float		katanasound_finished;
.float		pistol_finished;
.float		shotgun_finished;
.float		gauss_finished;
.float		grenade_finished;
.float		stopmelee_finished;
.float		jumpreset_time;
.float		spin_finished;
.float		spin_sound_loop;
.float		pushback_time; // vore shield
.float		slide_time;
.float		laststep;

.float		chaingun_frame;
.float 		jump_timer;
.float		crouch_timer;
.float		footstep_timer;

.vector		punch_fast;
.vector		punch_normal;
.vector		punch_slow;
.float		punch_time;

.float		deploy_time;

entity		grenade_handler; // global
.entity		list_next;
.entity		list_previous;
.float		isgrenade; // findfloat(isgrenade, 1);

.string		quickmelee_model; // stores the current weapon model;
.float		quickmelee_weapon;
.float		lastweapon;
.float		hitmarker_time;
.float		headmarker_time;
.float		katana_strikes;
.float		shock_charge;
.entity		shock_target;

.float		chaingun_frame;
.float		chaingun_speed;
.float		chaingun_count;

nosave .float		cshift_value;

.float		forcedslide_timer; // no friction until timer ends
.float		noairacceleration_timer; // same for air acceleration
.float		current_airacceleration; // save previous state to restore to it
.float		noacceleration_timer; // same
.float		current_acceleration;
//var .float		nowallrun_timer; // forbids wallrunning
.float		current_speed; //
.float		speedmodifier; // changes speed when katana in hands
.float		adrenaline_regentimer; 
//combo
.float		dodge_time; // time until next dodge can be performed
.float		combo_index; // write data to queu on this index position
.float		combo_index_head; // which index is the start of the queue, cause it can wrap around 
.vector		combo_queue; // last three inputs stored here
.float		combo_timer; // reset combo if timer runs out
.float		saved_inputs; // use this to find out which inputs was changed since last frame

// monsters stuff ----------------------------------------------------------------------------------------------------------
.float		health_head; // move to progs
.float		health_head_max; // move to progs
.entity 	info_ent;
.entity 	info_oldent;

.float		monstertype;
.float		state;
// end
.float		reload_time;
.float		monster_ammo;
.vector		head_offset;
.float		head_size;
.float		monsterflags;
.float		gib_threshold; // amount of damage required to gib the monster
.float 		lasthit_damage; //save amount of damage from last damage taken, used for gibs logic
.vector		lasthit_direction; // direction to launch the gibs
.float 		fadecount;
//.float		failed_distance; // accumulated distance monster failed to move // rather use thinkA with trail to origin distance

//
// extra utility fields, to meet all the needs for complex stuff
.float		fA, fB, fC, fD, fE;//, fF, fG, fH, fI, fJ, fK, fL, fM, fN, fO, fP; // 16 floats 
.vector		vA, vB, vC, vD, vE;//, vF, vG, vH, vI, vJ, vK, vL, vM, vN, vO, vP; // 48 floats
.entity		eA, eB, eC, eD, eE;//, eF, eG, eH, eI, eJ, eK, eL, eM, eN, eO, eP; // 16 ints

.float		walkframe;

.float 		attack_finished;
.float		pain_finished;
.float		painsound_time;

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

//.float		t_length, t_width; // copper


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
.float		skinchange;

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
//.float		state;
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
//float() droptofloor= #34;	// TRUE if landed on floor
float(float yaw, float dist) droptofloor = #34;	// TRUE if landed on floor // copper have different prototype, hm
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
//--------------------------------------------------------------------												
float(float angle) sin = #60; // new
float(float angle) cos = #61; // new
float(float value) sqrt = #62; // new
float(float a, float b, ...) min = #94;
float(float a, float b, ...) max = #95;
float(float minimum, float val, float maximum) clamp = #96; // aka bound
float(float value, float exp) pow = #97; 
float(float a, float n)mod = #245;
void(vector dir)vectorvectors = #432; // makevectors out of direction vector 
entity(.float fld, float match) findfloat = #700; // returns chain of entities
void (float newvalue) change_timescale = #701; // clamped from 0 to 10
float(vector raypoint, vector direction, vector point) distancetoray = #702; //  // A to B
void(vector A, vector onto) project_onto_vector = #703; // { "project_vector",			PF_SSQC(PF_ProjectOnVector),	703 }, // A to B, result project_to_vector
void(vector A, vector onto) project_onto_plane = #704; // { "project_plane",			PF_SSQC(PF_ProjectOnPlane),		704 },
void(vector A, vector onto, float multiplier) reflectVector = #705; //default multiplier for 1 to 1 reflection is 2
float(vector v) vlen2 = #706;  // non sqrt distance / 10000, returns 0 if it's < 16 before division
entity(vector org, float rad) findradius_damage = #707;
float(float bitmask, float shift) bithshift = #708;
entity(entity copyfrom) spawncopy = #709;
void(entity copyfrom, entity copyto) copyedict = #710; 