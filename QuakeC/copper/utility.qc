
void(string s, string ss) bprint2 = 
	{ bprint(s); bprint(ss); }
void(string s, string ss, string sss) bprint3 = 
	{ bprint(s); bprint(ss); bprint(sss); }
void(string s, string ss, string sss, string ssss) bprint4 = 
	{ bprint(s); bprint(ss); bprint(sss); bprint(ssss); }
void(string s, string ss, string sss, string ssss, string sssss) bprint5 = 
	{ bprint(s); bprint(ss); bprint(sss); bprint(ssss); bprint(sssss); }

void(entity who, string s) centerprintlocal =
{
	entity e;
	vector dir;
	e = nextent(world);
		
	while (e.flags & FL_CLIENT)
	{
		if (e == who)
		{
			centerprint(e, s);
		}
		else
		{
			dir = e.origin - who.origin;
			dir = normalize(dir);
			traceline(who.origin, who.origin + dir * 500, TRUE, who);
			if (trace_ent == e)
				centerprint(e, s);
		}
		e = nextent(e);
	}
}

void(string s) centerprintall =
{
	entity e;
	e = nextent(world);
		
	while (e.flags & FL_CLIENT)
	{
		centerprint(e, s);
		e = nextent(e);
	}
}

void(string s, entity excl) centerprintothers =
{
	entity e;
	e = nextent(world);
		
	while (e.flags & FL_CLIENT)
	{
		if (e != excl)
			centerprint(e, s);
		e = nextent(e);
	}
}


// sprint_to_others
// for mirroring private centerprinted text to other clients
void(string s, entity excl) sprint_to_others =
{
	if (!coop) return;

	entity pl = nextent(world);
	while (pl.flags & FL_CLIENT)
	{
		if (pl != excl)
			sprint(pl, s);
		pl = nextent(pl);
	}
}

void(string s, string ss, entity excl) sprint2_to_others =
{
	if (!coop) return;

	entity pl = nextent(world);
	while (pl.flags & FL_CLIENT)
	{
		if (pl != excl)
		{
			sprint(pl, s);
			sprint(pl, ss);
		}
		pl = nextent(pl);
	}
}

void(string s, string ss, string sss, entity excl) sprint3_to_others =
{
	if (!coop) return;

	entity pl = nextent(world);
	while (pl.flags & FL_CLIENT)
	{
		if (pl != excl)
		{
			sprint(pl, s);
			sprint(pl, ss);
			sprint(pl, sss);
		}
		pl = nextent(pl);
	}
}

void(string s, string ss, string sss, string ssss, entity excl) sprint4_to_others =
{
	if (!coop) return;

	entity pl = nextent(world);
	while (pl.flags & FL_CLIENT)
	{
		if (pl != excl)
		{
			sprint(pl, s);
			sprint(pl, ss);
			sprint(pl, sss);
			sprint(pl, ssss);
		}
		pl = nextent(pl);
	}
}

void(string s, string ss, string sss, string ssss, string sssss, entity excl) sprint5_to_others =
{
	if (!coop) return;

	entity pl = nextent(world);
	while (pl.flags & FL_CLIENT)
	{
		if (pl != excl)
		{
			sprint(pl, s);
			sprint(pl, ss);
			sprint(pl, sss);
			sprint(pl, ssss);
			sprint(pl, sssss);
		}
		pl = nextent(pl);
	}
}


float(float in) bprint_int =
{
	in = floor(in);
	if (in <= 0) return 0;
	
	float digit;
	digit = in - bprint_int(in / 10);
	
	switch(digit) {
	case 9:
		bprint("9"); break;
	case 8:
		bprint("8"); break;
	case 7:
		bprint("7"); break;
	case 6:
		bprint("6"); break;
	case 5:
		bprint("5"); break;
	case 4:
		bprint("4"); break;
	case 3:
		bprint("3"); break;
	case 2:
		bprint("2"); break;
	case 1:
		bprint("1"); break;
	case 0:
		bprint("0"); break;
	}
	
	return in * 10;
}


//============================================================================

float(entity who) has_invis = { return (who.items & IT_INVISIBILITY || who.invisible_finished > time); }
float(entity who) has_quad = { return (who.items & IT_QUAD || who.super_damage_finished > time); }
float(entity who) has_invuln = { return (who.items & IT_INVULNERABILITY || who.invincible_finished > time); }
float(entity who) has_biosuit = { return (who.items & IT_SUIT || who.radsuit_finished > time); }

//============================================================================

// findradius only works on solid entities, because apparently it's only for explosions
entity(vector point, float rad, .string fld, string match) findradiusplus =
{
	entity head, prev;
	prev = world;
	head = find(world, fld, match);
	
	float found = 0;
	
	while(head)
	{
		if ( vlen(point - head.origin) <= rad )
		{
			head.chain = prev;		
			prev = head;
			found += 1;
		}
		head = find(head, fld, match);
	}
	return prev;
}


// just find every damn thing targeted by 'src' and return it as head.chain
// targets will be primarily in order by target/2/3/4, and secondarily by spawn order
// so 'target's always come before 'target2's in the chain, etc
entity(entity src) findalltargets =
{
	// WARNING: do not use this in the context of actually triggering targets.
	// an entity triggering down an active .chain of targets could trigger one
	// which itself calls findalltargets to do the same, which could blow away
	// the existing chain.
	entity head, f, prev;
	head = world;
	f = world;
	prev = world;
	
	if (src.target != string_null)
	{
		f = find(world, targetname, src.target);
		while(f)
		{
			if (!head) head = f;	// mark the start location
			if (prev)
				prev.chain = f;		// connect the end of the chain
			prev = f;
			f = find(f, targetname, src.target);
		}
	}
	if (src.target2 != string_null)
	{
		f = find(world, targetname, src.target2);
		while(f)
		{
			if (!head) head = f;
			if (prev)
				prev.chain = f;
			prev = f;
			f = find(f, targetname, src.target2);
		}
	}
	if (src.target3 != string_null)
	{
		f = find(world, targetname, src.target3);
		while(f)
		{
			if (!head) head = f;
			if (prev)
				prev.chain = f;
			prev = f;
			f = find(f, targetname, src.target3);
		}
	}
	if (src.target4 != string_null)
	{
		f = find(world, targetname, src.target4);
		while(f)
		{
			if (!head) head = f;
			if (prev)
				prev.chain = f;
			prev = f;
			f = find(f, targetname, src.target4);
		}
	}
	
	prev.chain = world;	// don't link to stale chains
	return head;
}

// findalltargets, but in reverse: returns a chain of all entities that target dst
entity(entity dst) findalltargeters =
{
	if (dst.targetname == string_null)
		return world;
	
	entity head, f, prev;
	head = world;
	f = world;
	prev = world;
	
	f = find(world, target, dst.targetname);
	while(f)
	{
		if (!head) head = f;	// mark the start location
		if (prev)
			prev.chain = f;		// connect the end of the chain
		prev = f;
		f = find(f, target, dst.targetname);
	}

	f = find(world, target2, dst.targetname);
	while(f)
	{
		if (!head) head = f;
		if (prev)
			prev.chain = f;
		prev = f;
		f = find(f, target2, dst.targetname);
	}

	f = find(world, target3, dst.targetname);
	while(f)
	{
		if (!head) head = f;
		if (prev)
			prev.chain = f;
		prev = f;
		f = find(f, target3, dst.targetname);
	}

	f = find(world, target4, dst.targetname);
	while(f)
	{
		if (!head) head = f;
		if (prev)
			prev.chain = f;
		prev = f;
		f = find(f, target4, dst.targetname);
	}

	prev.chain = world;	// don't link to stale chains
	return head;
}

entity(entity start, .string fld, string match) findunlocked =
{
	entity head;
	float found = FALSE;
	head = find(start, fld, match);
	while (head)
	{
		if (!(head.copperflags & CFL_LOCKED))
			break;
		head = find(head, fld, match);
	}
	return head;
}

entity(entity e, entity start) findunlockedtarget =
{
	entity head = world;
	if (e.target != string_null)
		head = findunlocked(start, targetname, e.target);
	if (head) return head;
	
	if (e.target2 != string_null)
		head = findunlocked(start, targetname, e.target2);
	if (head) return head;
	
	if (e.target3 != string_null)
		head = findunlocked(start, targetname, e.target3);
	if (head) return head;
	
	if (e.target4 != string_null)
		return findunlocked(start, targetname, e.target4);
	return world;
}

// quake hates precaches that happen late, and
// some maphacks create trigger_first triggers by setting 'use' to 
// 'trigger_multiple', causing this to be called in mid-level
string(string s) precache_sound_safe =
{
	if (framecount || s == string_null) return string_null;
	return precache_sound(s);
}
string(string s) precache_sound2_safe =
{
	if (framecount || s == string_null) return string_null;
	return precache_sound2(s);
}

/*
i've brought over the quoth convention of letting mappers set the 'model' key on func_*
to override an entity's model with something external, which must be precached, but that 
collides with the existing use of the model keyvalue, and also causes precache-out-of-turn
errors on maps with map hacks like mce.bsp

however, if the entity already has a modelindex, it already has a model internal to the
bsp and precache should never be called no matter what time it is. (do not call when self
is world, like in W_Precache)
*/
void(string s) precache_model_safe	=
{
	if (framecount) return;
	if (s != string_null && !self.modelindex)
		precache_model(s);
}
void(string s) precache_model2_safe	=
{
	if (framecount) return;
	if (s != string_null && !self.modelindex)
		precache_model2(s);
}

/*
failed precaches still prevent the map from loading in most engines. put all mod-related 
precaches through these wrappers so they can be easily turned off, in the event you want 
to send small test builds to engine programmers to show them bugs without having to 
build and package your entire mod.
*/
void(string s) precache_model3	= { precache_model2_safe(s); }
void(string s) precache_sound3	= { precache_sound2_safe(s); }
/*
void(string s) precache_model3	= { return; }
void(string s) precache_sound3	= { return; }
*/

float(entity e) localtime =
{
	if (e.solid == SOLID_BSP || e.movetype == MOVETYPE_PUSH)
		return e.ltime;
	return time;
}

// shorthand for turning -1 to 0 for keyvalues for which 0 is a valid non-default selection
float(float in) zeroconvert =
{
	if (in == -1) return 0;
	return in;
}
float(float in, float def) zeroconvertdefault =
{
	if (in == -1) return 0;
	if (in == 0) return def;
	return in;
}

//count -4 = numclients in coop
void(.float fld) playercount_convert =
{
	if (self.fld != -4) return;
	if (!coop)
		self.fld = 1;
	else
	{
		// limit this because we can't assume a max of 8 coop players (... thanks decino)
		if (clients <= 4)
			self.fld = clients;
		else if (clients >= 20)
			self.fld = 10;	// hard cap of 10 @ 20 players
		else if (clients >= 16)
			self.fld = 9;
		else if (clients >= 12)
			self.fld = 8;
		else if (clients >= 10)
			self.fld = 7;
		else if (clients >= 8)
			self.fld = 6;
		else if (clients >= 6)
			self.fld = 5;		
		/*
			self.fld =	// magic formula ...
				min(4, clients)	+							// first four clients count full
				floor(max(0, min(12, clients) - 4) / 2) +	// clients above 4th count half
				floor(max(0, clients - 12) / 4);			// clients above 12th count quarter
		*/
	}
}




// ================================
//	Frustum/Box Tests
// ================================

vector(entity e) BoundsCenter =
{
	return e.origin + 0.5 * ( e.mins + e.maxs );
}

vector(entity e) BoundsBottom =
{
	vector out;
	out = e.origin + 0.5 * ( e.mins + e.maxs );
	out_z = e.origin_z + e.mins_z;
	return out;
}

// for measuring how large an entity is along an arbitrary vector
// FIXME: this is trash and it returns trash
float(vector v, vector s) BoundsAngleSize =
{
	v_x = fabs(v_x);
	v_y = fabs(v_y);
	v_z = fabs(v_z);
	
	// size is always + + + but this is in case I switch the parameters somewhere
	s_x = fabs(s_x);
	s_y = fabs(s_y);
	s_z = fabs(s_z);
	
	return v * s;
}

float (vector e1mins, vector e1maxs, vector e2mins, vector e2maxs, float pad) BoundsTouching =
{
	if (e1mins_x > e2maxs_x + pad) return FALSE;
	if (e1mins_y > e2maxs_y + pad) return FALSE;
	if (e1mins_z > e2maxs_z + pad) return FALSE;
	if (e1maxs_x < e2mins_x - pad) return FALSE;
	if (e1maxs_y < e2mins_y - pad) return FALSE;
	if (e1maxs_z < e2mins_z - pad) return FALSE;
	return TRUE;
}

// moved from doors
float (entity e1, entity e2) EntitiesTouching =
{
	return BoundsTouching(e1.absmin, e1.absmax, e2.absmin, e2.absmax, 0);
}
/*
float(vector org, float hside, vector point) BoundingCubeTest =
{
	if (point_x > org_x + hside) return FALSE;
	if (point_x < org_x - hside) return FALSE;
	if (point_y > org_y + hside) return FALSE;
	if (point_y < org_y - hside) return FALSE;
	if (point_z > org_z + hside) return FALSE;
	if (point_z < org_z - hside) return FALSE;
	return TRUE;
}

float(vector planeN, float planeD, vector point) PlaneTest =
{
	return point * planeN - planeD;
}
*/
/*
float(vector planeN, float planeD, vector mn, vector mx) BoxPlaneTest =
{
	local float outCount;

	outCount = 0;
	
	// you know what's cool?  arrays.
	if (PlaneTest(planeN, planeD, Vector(mn_x, mn_y, mn_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mx_x, mn_y, mn_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mn_x, mx_y, mn_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mx_x, mx_y, mn_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mn_x, mn_y, mx_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mx_x, mn_y, mx_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mn_x, mx_y, mx_z)) <= 0) outCount++;
	if (PlaneTest(planeN, planeD, Vector(mx_x, mx_y, mx_z)) <= 0) outCount++;
	
	dprint(": ");
	dprint(ftos(outCount));
	dprint(" ");
	
	return outCount;
}
*/
/* voidforce: seems like not used anywhere?
float(entity observer, float fov, vector mn, vector mx) FrustumCheck =
{
	local vector vorg;
	vorg = observer.origin + observer.view_ofs;
	makevectors(observer.v_angle);
	
	// assume vertical fov is at most 3/4 hfov, because nobody plays quake in a square window
	local float hfov, vfov;
	hfov = fov * 0.6;
	vfov = fov * 0.45; // was 0.5/0.375
	// added a 20% buffer because engines like mk5 and quakespasm have added "correction" 
	// so now hfov can't be trusted to just be the actual fucking fov anymore
	
	local float bpt, hc, hs, vc, vs;
	local vector temp, side0n, side1n, side2n, side3n, side4n;
	local float side0d, side1d, side2d, side3d, side4d;
	
	temp = SinCos(hfov);
	hs = temp_x;
	hc = temp_y;
	
	temp = SinCos(vfov);
	vs = temp_x;
	vc = temp_y;
	
	// determine frustum planes one at a time, starting with near, then left/right, then top/bottom
	// far plane isn't really necessary
	side0n = v_forward;
	side0d = vorg * side0n;
	dprint("NR");
	bpt = BoxPlaneTest(side0n, side0d, mn, mx);
	if (bpt == 8) return 0;
	
	side1n = v_forward * hs + v_right * hc;
	side1d = vorg * side1n;
	dprint("LF");
	bpt = BoxPlaneTest(side1n, side1d, mn, mx);
	if (bpt == 8) return 0;
	
	side2n = v_forward * hs - v_right * hc;
	side2d = vorg * side2n;
	dprint("RT");
	bpt = BoxPlaneTest(side2n, side2d, mn, mx);
	if (bpt == 8) return 0;
	
	side3n = v_forward * vs + v_up * vc;
	side3d = vorg * side3n;
	dprint("DN");
	bpt = BoxPlaneTest(side3n, side3d, mn, mx);
	if (bpt == 8) return 0;
	
	side4n = v_forward * vs - v_up * vc;
	side4d = vorg * side4n;
	dprint("UP");
	bpt = BoxPlaneTest(side4n, side4d, mn, mx);
	if (bpt == 8) return 0;
	
	return 1;	
}
*/




// the following amazing pollution is by czg

/*
=============
stuffcmd_float

This is a horrible hack that I am ashamed of!
===============
*/
void stuffcmd_digit( entity client, float f) =
{
	float d;
	d = floor(f);
	d = mod(d, 10);

	//CLOSE YOUR EYES, HONEY! DON'T LOOK!
	if(d == 0)
		stuffcmd(client, "0");
	else if(d == 1)
		stuffcmd(client, "1");
	else if(d == 2)
		stuffcmd(client, "2");
	else if(d == 3)
		stuffcmd(client, "3");
	else if(d == 4)
		stuffcmd(client, "4");
	else if(d == 5)
		stuffcmd(client, "5");
	else if(d == 6)
		stuffcmd(client, "6");
	else if(d == 7)
		stuffcmd(client, "7");
	else if(d == 8)
		stuffcmd(client, "8");
	else if(d == 9)
		stuffcmd(client, "9");	
}

void stuffcmd_int( entity client, float f, float numdigits) =
{
	
	float tmp;

	
	if(f == 0)
	{
		stuffcmd( client, "0");
		return;
	}

	if(f < 0)
	{
		// Yeah sure.
		stuffcmd( client, "-");
		f = fabs(f);
	}
	
	if(numdigits <= 0)
	{
		tmp = f;
		numdigits = 1;
		while(tmp >= 1){
			tmp = tmp / 10;
			numdigits = numdigits * 10;
		}
	}
	
	//I don't know what I'm thinking here...
	//I need to do this to get zero-padding to work.

	while( numdigits > 1 )
	{
		numdigits = numdigits / 10;
		tmp = f / numdigits;
		stuffcmd_digit( client, tmp);
	}
}

void stuffcmd_float( entity client, float f) =
{
	float intpart, decpart, isNegative;
	
	isNegative = FALSE;
	
	if(f == 0)
	{
		stuffcmd( client, "0");
		return;
	}
	
	if(f < 0)
	{
		// easier this way
		isNegative = TRUE;
		f = fabs(f);
	}	
	
	// 1: stuff the integer part.
	intpart = floor(f);
	if(isNegative) 
		stuffcmd( client, "-");
	stuffcmd_int( client, intpart, 0);
	
	// 2: stuff the decimal point.
	stuffcmd( client, ".");
	
	// 3: stuff the decimal part.
	decpart = mod( f, 1);
	decpart = decpart * 10000;
	stuffcmd_int( client, decpart, 10000);
}




/*
===============
dprint_float stuff

bc i'm tired of ftos cutting off all the important digits
===============
*/
void dprint_digit( float f) =
{
	float d;
	d = floor(f);
	d = mod(d, 10);

	if(d == 0)		dprint("0");
	else if(d == 1)	dprint("1");
	else if(d == 2)	dprint("2");
	else if(d == 3)	dprint("3");
	else if(d == 4)	dprint("4");
	else if(d == 5)	dprint("5");
	else if(d == 6)	dprint("6");
	else if(d == 7)	dprint("7");
	else if(d == 8)	dprint("8");
	else if(d == 9)	dprint("9");	
}

void dprint_int( float f, float numdigits) =
{
	float tmp;
	
	if(f == 0)
	{
		dprint("0");
		return;
	}

	if(f < 0)
	{
		dprint("-");
		f = fabs(f);
	}
	
	if(numdigits <= 0)
	{
		tmp = f;
		numdigits = 1;
		while(tmp >= 1){
			tmp = tmp / 10;
			numdigits = numdigits * 10;
		}
	}
	
	while( numdigits > 1 )
	{
		numdigits = numdigits / 10;
		tmp = f / numdigits;
		dprint_digit( tmp );
	}
}

void dprint_float( float f) =
{
	float intpart, decpart, isNegative;
	
	isNegative = FALSE;
	
	if(f == 0)
	{
		dprint( "0");
		return;
	}
	
	if(f < 0)
	{
		// easier this way
		isNegative = TRUE;
		f = fabs(f);
	}	
	
	// 1: stuff the integer part.
	intpart = floor(f);
	if(isNegative) 
		dprint( "-");
	dprint_int( intpart, 0);
	
	// 2: stuff the decimal point.
	dprint(".");
	
	// 3: stuff the decimal part.
	decpart = mod( f, 1);
	decpart = decpart * 10000;
	dprint_int(decpart, 10000);
}

void dprint_vector(vector v) =
{
	dprint("( ");
	dprint_float(v_x);
	dprint(" ");
	dprint_float(v_y);
	dprint(" ");
	dprint_float(v_z);
	dprint(" )");
}
