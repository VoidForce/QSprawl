//* --------------------------------------------------------------------
/*
Following code is taken from Arcane Dimensions mod, adapted to fit Copper mod systems

	MOD     : AD v1.80 - (Arcane Dimensions)
	Updated : October 2020
	Author  : Simon "Sock" OCallaghan
	Website : www.simonoc.com
	
	Please do not use any of these assets in ANY COMMERCIAL PROJECT.
	and remember to give credit if you use any of these assets.
					  
	The QC files in this MOD are based on 1.06 source files by ID Software.
	These files are released under the terms of GNU General Public License v2 or
	later. You may use the source files as a base to build your own MODs as long
	as you release them under the same license and make the source available.
	Please also give proper credit. Check http://www.gnu.org for details.
*/

//======================================================================
/*QUAKED trigger_cdtrack (0.8 0.5 0) (-8 -8 -16) (8 8 16) x
Change CD track for all clients
-------- KEYS --------
targetname : trigger entity
count      : CD track number (eg. 0-x)
-------- SPAWNFLAGS --------
-------- NOTES --------
Change CD track for all clients

======================================================================*/
void() trigger_cdtrack_change =
{
	// Write CD track to all clients
	msg_entity = self;
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, trig_cdtrack);
	WriteByte (MSG_ALL, trig_cdtrack);
};

//----------------------------------------------------------------------
void() trigger_cdtrack_use =
{
	// Check for entity state system block
	//if (self.estate & ESTATE_BLOCK) return;
	
	// Make sure CD track change in savefile
	trig_cdtrack = self.count;

	// Write message to all clients
	trigger_cdtrack_change();
};

//----------------------------------------------------------------------
void() trigger_cdtrack =
{
	//self.classtype = CT_TRIGCDTRACK;
	//self.classgroup = CG_TARGETS;

	// Check for firing conditions (nightmare, coop)
	//if (check_nightmare() == TRUE) return;
	//if (check_coop() == TRUE) return;

	if (self.targetname == string_null) 
	{
		dprint("\b[TRIG_CD]\b targetname missing!\n");
		//spawn_marker(self.origin, SPNMARK_YELLOW);
		remove(self);
		return;
	}

	// Make sure specified cd track is integer number
	self.count = fabs(rint(self.count));
	self.use = trigger_cdtrack_use;
	/*
	// Setup Entity State functionality
	if (self.targetname != string_null)
		self.use = entity_state_use;
	self.estate_use = trigger_cdtrack_use;
	self.estate = ESTATE_ON;
	*/
};