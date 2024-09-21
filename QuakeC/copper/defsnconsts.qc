// copper stuff

const string version_s = "Copper Quake 1.30 - 31 October 2023";
const float version_f = 1.30;
.float version = worldtype;

entity s;
string	keyType;

.vector	extra_mins;
.vector extra_maxs;
.float		alpha2;
.float copperflags;
.float		lifetime_finished;
.vector rmovedir = finaldest;
.string	include = wad;		// for monsterjump filters
.string exclude = map;
.string	model2 = wad;		// for debris emitter
.string model3 = map;
.vector fadecolor = fog_color;	// for func_void fadeout
.float svflags = jump_flag;	// for target_give and item_sigil
.float		nextmovesound;	// replaces swim_flag and fly_sound, both of which were timers

float	coop_time;
nosave float	clients;
nosave float	gamestarted;
nosave float	cleanUpClientShit;
//nosave float	clientsAlive;
//nosave float	clientsAliveMask;
.entity buddy;

.float		length, width, height;
.float t_length = length;	// preserve old func_door_secret maphacks
.float t_width = width;

.float		notrace;		// entity will be invisible to traceline2()
.vector		oldvelocity;	// necessary for getting projectiles to pass through .notrace entities
.entity		trueowner;		// now this is getting dumb
.void(float unlock) lock;	// so entities can define their own target_lock cleanup
.float()	th_checkattack;
.string type;
.float speed2;
float intermission;
//float intermission_time;
string	inter_text;		// used by changelevel code in t_level.qc
//.float armortype;
.float		switchshadstyle;	// was "shadowstyle" too clear and easy to type or something

// fog
.vector		fog_color, fog_color2;
.float		fog_density, fog_density2;
.float		fog_sky, fog_sky2;

float	trace_debug;

const vector	VEC_ONE			= '1 1 1';
const vector	VEC_UP			= '0 0 1';
const vector	VEC_DOWN 		= '0 0 -1';

const float	ITEM_SUSPENDED = 4;

const float	A_SHITLOAD		= 9999999; // no shit, Lun

// .copperflags:
const float	CFL_LEFTY			= 1;	// used by slidemovers (scrags) to alternate strafe direction
const float	CFL_RETURNED		= 1;	// zombie has already respawned in nightmare
const float	CFL_INVLIGHT			= 1;	// for backwards bmover light fade behavior
const float	CFL_ZAPPED			= 2;
const float	CFL_AXEHITME		= 4;
const float	CFL_LOCKED			= 16;	// special state-independent deactivation
const float	CFL_INPAIN			= 16;	// zombie should knockdown soon
const float	CFL_KNOCKEDDOWN		= 32;	// zombie is down
const float	CFL_PLUNGE			= 64;	// has fallen in a death pit
const float	CFL_SPAWNER			= 128;	// is a generator of monsters
const float	CFL_UNDYING			= 256;	// god mode minus one point (player)
const float	CFL_LIQUID_IMMUNE	= 512;	// monster spawned touching slime or lava, so assume designer wants it immune to damage
const float	CFL_MELEEONLY		= 1024;	// has no ranged attack (monster)
const float	CFL_LIMBO			= 2048;	// waiting in teleport limbo (coop, player)
const float	CFL_OMNIVISION		= 4096;	// eyes in back of head

// serverflags
const float	SVFL_EPISODE1		= 1;
const float	SVFL_EPISODE2		= 2;
const float	SVFL_EPISODE3		= 4;
const float	SVFL_EPISODE4		= 8;
const float	SVFL_ALLEPISODES	= 15;
const float	SVFL_RESPAWNING		= 2097152;	// to notify target_autosave that we just restarted after dying

const float	DEAD_SPECTATING			= 3;

const float	SPAWN_NOTEASY		= 256;
const float	SPAWN_NOTNORMAL		= 512;
const float	SPAWN_NOTHARD		= 1024;
const float	SPAWN_NOTDM			= 2048;
const float	SPAWN_COOPONLY		= 4096;
const float	SPAWN_NOTCOOP		= 8192;

const float	SPAWN_ALT_TARG		= 16384;	// fire the four target keys at different times

const float	STATE_TOP			= 0;
const float	STATE_BOTTOM		= 1;
const float	STATE_UP			= 2;
const float	STATE_DOWN			= 3;

const float	STATE_OFF			= 0;
const float	STATE_ON			= 1;

const float	START_OFF			= 1;

const float	IT_POWERUPS				= IT_INVISIBILITY + IT_INVULNERABILITY + IT_SUIT + IT_QUAD;
const float	IT_WEAPONS				= 127 + 4096;

// monsters
const float	SPAWN_AMBUSH		= 1;
//const float	SPAWN_CRUCIFIEDX	= 1;
const float	SPAWN_TRIGGERED		= 16;
const float	SPAWN_NO_TFOG		= 32;
const float	SPAWN_NO_TFRAG		= 64;
const float	SPAWN_INSTAWAKE		= 128;
//const float	SPAWN_CRUCIFIED		= 32768;	// was 128, but random zombies in stock quake have spawnflags&128 left over from something :P

const float	TRACE_NOMONSTERS		= 1;
const float	TRACE_WATER				= 2;