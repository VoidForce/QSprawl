/*
===============================================================================

BACKPACKS

===============================================================================
*/

/*
================================
print_quant
pretty-print a quantity to a client's buffer
================================
*/
void(float amt, string noun, entity to) print_quant =
{
	string s;
	
	if (amt == 1)
	{
		sprint (to, "1 ");
		sprint (to, noun);
		return;
	}
	
	s = ftos(amt);
	sprint (to, s);
	sprint (to, " ");
	sprint (to, noun);
	sprint (to, "s");
}

/*
================================
BackpackTouch
================================
*/
void() BackpackTouch =
{
	if (!CheckValidTouch()) return;

	// coop 1: players can only pick up their own backpacks
	//if (coop == 1 && self.buddy && self.buddy != other) return;
	// reverted:
	// with no good way to indicate whose backpack is whose (because .colormap
	// only works on players outside the original software renderer) this led to 
	// a lot of ignored mystery backpacks players kept obsessively touching.
	// going out of your way for your own ammo is also a waste of time unless
	// the level is extremely linear, which good quake levels never are

	float acount;
	
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;
	other.ammo_bullets = other.ammo_bullets + self.ammo_bullets;
	bound_other_ammo ();

	//armor_give(other, self.armorvalue, 0, FALSE);	
	other.armorvalue += self.armorvalue;
	other.armorvalue = min(250, other.armorvalue);
	
	sprint (other, "You got ");

	if (self.items && (other.items & self.items) == 0)
	{
		acount = TRUE;
		other.items |= self.items;
		sprint (other, "the ");
		sprint (other, self.netname);
	}

	if (self.armorvalue)
	{
		if (acount) sprint(other, ", ");
		acount = 1;
		sprint(other, ftos(self.armorvalue));
		sprint(other, " armor");
	}
	if (self.ammo_shells)
	{
		if (acount) sprint(other, ", ");
		acount = 2;
		print_quant(self.ammo_shells, "shell", other);
	}
	if (self.ammo_nails)
	{
		if (acount) sprint(other, ", ");
		acount = 2;
		print_quant(self.ammo_nails, "nail", other);
	}
	if (self.ammo_rockets)
	{
		if (acount) sprint(other, ", ");
		acount = 2;
		print_quant(self.ammo_rockets, "rocket", other);
	}
	if (self.ammo_cells)
	{
		if (acount) sprint(other, ", ");
		acount = 2;
		print_quant(self.ammo_cells, "cell", other);
	}
	
	sprint (other, "\n");
	
	// do this after because t_heal prints its own message
	if (self.healamount)
		T_Heal(other, self.healamount, 0);

	// regular monster backpacks don't make the AWESOME NEW backpack sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
		
	stuffcmd (other, "bf\n");

	setAmmo(other);
	ItemTouched();
}

/*
================================
BackpackAutoTouch

backpacks can always be picked up, so mapper-placed ammo backpacks should 
give the player something else if they're maxxed out on any ammo types,
since they're little exploration rewards for hiding behind crates and etc
================================
*/
void() BackpackAutoTouch =
{
	if (!CheckValidTouch()) return;

	if (self.spawnflags & 1)
		sprint (other, "You found a big backpack!\n");
	else
		sprint (other, "You found a backpack\n");
		
	if (other.ammo_shells + self.ammo_shells > MAX_SHELLS)
	{
		self.armorvalue += other.ammo_shells + self.ammo_shells - MAX_SHELLS;
		self.ammo_shells = MAX_SHELLS - other.ammo_shells;
	}
	if (other.ammo_nails + self.ammo_nails > MAX_NAILS)
	{
		self.armorvalue += ceil((other.ammo_nails + self.ammo_nails - MAX_NAILS) / 2);
		self.ammo_nails = MAX_NAILS - other.ammo_nails;
	}
	if (other.ammo_rockets + self.ammo_rockets > MAX_ROCKETS)
	{
		self.armorvalue += (other.ammo_rockets + self.ammo_rockets - MAX_ROCKETS) * 3;
		self.ammo_rockets = MAX_ROCKETS - other.ammo_rockets;
	}
	if (other.ammo_cells + self.ammo_cells > MAX_CELLS)
	{
		self.armorvalue += (other.ammo_cells + self.ammo_cells - MAX_CELLS) * 3;
		self.ammo_cells = MAX_CELLS - other.ammo_cells;
	}
	if (other.ammo_bullets + self.ammo_bullets > MAX_BULLETS)
	{
		self.armorvalue += (other.ammo_bullets + self.ammo_bullets - MAX_BULLETS) * 3;
		self.ammo_bullets = MAX_BULLETS - other.ammo_bullets;
	}
	
	self.armorvalue = floor(self.armorvalue / 2);
	BackpackTouch();
	
	if (self.wait > 0)
	{
		// reset all the values we may have just vandalized
		self.ammo_shells = floor(3 * random() + 6);
		self.ammo_nails = floor(5 * random() + 12);
		if (self.spawnflags & 1)
		{
			self.ammo_shells *= 2;
			self.ammo_nails *= 2;
			
			self.ammo_rockets = 2;
			self.ammo_cells = 3;
			//self.skin = 2;
		}
		self.armorvalue = 0;
	}
}

/*QUAKED item_backpack (0 .5 .5) (-16 -16 0) (16 16 40) BIG ? SUSPENDED -
A forgotten explorer's backpack. Grants a paltry sum of shells and nails (about half a small pack of each). Grants armor instead of any ammo the player already has maxed.

Flags:
"big" doubles shells and nails, adds 2 rockets and 4 cells, appears red
    
Keys:
"target/2/3/4/k" - entity to trigger when picked up
"targetname" - will not spawn until triggered
"wait" - will respawn after 'wait' seconds. fires targets every time.
"count" - limit number of times to respawn
*/
/*FGD
@PointClass base(Item) size(-16 -16 0, 16 16 40) color(0 128 128) 
	model({ "path": ":progs/backpack.mdl" }) 
	= item_backpack : 
"A forgotten explorer's backpack. Grants a paltry sum of shells and nails (about half a small pack of each). Grants armor instead of any ammo the player already has maxed."
[
	spawnflags(flags) =	[
		1 : "Big (2x, red, +2 rockets/4 cells)" : 0
	]
]
*/
void() item_backpack =
{
	if (!SUB_ShouldSpawn()) return;
	self.skin = 0; // we don't use new model for it, so this shuts up the error message
	precache_model_safe("progs/backpack.mdl");

	setmodel (self, "progs/backpack.mdl");
	setsize (self, '-16 -16 0', '16 16 56');
	//self.skin = 1;
	
	self.ammo_shells = floor(3 * random() + 6);
	self.ammo_nails = floor(5 * random() + 12);
	if (self.spawnflags & 1)
	{
		self.ammo_shells *= 2;
		self.ammo_nails *= 2;
		
		self.ammo_rockets = 2;
		self.ammo_cells = 3;
		//self.skin = 2;
	}
	
	self.touch = BackpackAutoTouch;
	StartItem ();
}




/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	entity item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
	
	if (coop != 1)
	{
		item.items = self.weapon;
		if (item.items == IT_AXE)
			item.netname = string_null;
		else if (item.items == IT_SHOTGUN)
			item.netname = "Shotgun";
		else if (item.items == IT_SUPER_SHOTGUN)
			item.netname = "Double-Barrelled Shotgun";
		else if (item.items == IT_NAILGUN)
			item.netname = "Nailgun";
		else if (item.items == IT_SUPER_NAILGUN)
			item.netname = "Perforator";
		else if (item.items == IT_GRENADE_LAUNCHER)
			item.netname = "Grenade Launcher";
		else if (item.items == IT_ROCKET_LAUNCHER)
			item.netname = "Rocket Launcher";
		else if (item.items == IT_LIGHTNING)
			item.netname = "Thunderbolt";
		else
			item.netname = string_null;
		
	}
	
	if (coop == 1)
	{
		// keep half your shells and nails on respawn to make getting your backpack possible
		self.ammo_shells = floor(self.ammo_shells / 2);
		self.ammo_nails = floor(self.ammo_nails / 2);
	}
	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	
	if (self.flags & FL_CLIENT)
	{	// apply player's colormap to his backpack, although currently this only works in software
		item.colormap = self.colormap;
		//item.skin = 3;
		
		if (coop == 1)
		{	// players can only pick up their own backpacks, which never despawn (body run rules)
			item.buddy = self;
			return;
		}
	}
	
	item.nextthink = time + 116;	// remove after 2 minutes
	item.think = ItemDespawnBlink;	// blink 4 times
}