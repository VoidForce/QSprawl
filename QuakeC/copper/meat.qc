void(entity gib, string gibname) MakeGib =
{
	gib.lifetime_finished = time + 8 + random() * 8;
	gib.th_die = SUB_Remove;
	
	SUB_ChangeModel(gib, gibname);
	gib.type = "gib";
	gib.avelocity = Vector(random(),random(),random()) * 600;
	
	gib.frame = 0;
	gib.flags = 0;
}
// meat noise
// meat noise
// play that funky meat noise
void() meat_noise =
{
	float r = random();
	if (r < 0.25)
		sound (self, CHAN_BODY, "player/teledth1.wav", 1, ATTN_NORM);
	else if (r < 0.5)
		sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NORM);
	else if (r < 0.75)
		sound (self, CHAN_BODY, "player/udeath.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_BODY, "player/gib.wav", 1, ATTN_NORM);
}

void(string gibname) target_meat_fireworks_do =
{
	vector spray;
	entity gib;
	spray = '1 1 1' - self.mangle;
	spray_x = spray_x * crandom() + self.mangle_x * 4;
	spray_y = spray_y * crandom() + self.mangle_y * 4;
	spray_z = spray_z * crandom() + self.mangle_z * 4;
	spray *= self.speed * 2;
	
	gib = toss_projectile(self.origin + self.pos1, spray, "gib");
	MakeGib(gib, gibname);
}

void() target_meat_fireworks_go =
{
	vector spray;
	float i;
	meat_noise();
	
	self.pos1_x = (random()-0.5) * self.size_x;
	self.pos1_y = (random()-0.5) * self.size_y;
	self.pos1_z = (random()-0.5) * self.size_z;

	for (i = 0; i < 3; i++)
	{
		spray = '1 1 1' - self.mangle;
		spray_x *= crandom();
		spray_y *= crandom();
		spray_z *= crandom();
		spray += self.mangle * 0.5;
		SpawnMeatSpray(self.origin + self.pos1, spray * self.speed, world);
	}
	
	target_meat_fireworks_do(self.model);
	
	if (self.cnt == 2)
		target_meat_fireworks_do(self.model2);
	else
		target_meat_fireworks_do(self.model);
		
	if (self.cnt == 3)
		target_meat_fireworks_do(self.model3);
	else
		target_meat_fireworks_do(self.model);
}

void() target_meat_fireworks_use =
{
	float i, tnext;
	entity meats;
	
	playercount_convert(count);
	if (self.count == 1 && self.delay == 0 && self.rand == 0)
	{
		target_meat_fireworks_go();
		return;
	}
	
	tnext = self.delay + self.rand * random();
	for (i = 0; i < self.count; i++)
	{
		meats = spawn();
		setorigin(meats, self.origin);
		meats.think = target_meat_fireworks_go;
		meats.mangle = self.mangle;
		meats.speed = self.speed;
		meats.size = self.size;
		meats.nextthink = time + tnext;
		tnext += self.wait + self.rand * random();
	}
}

/*QUAKED target_meat_fireworks (0.7 .0 .2) (-16 -16 -16) (16 16 16)
trigger for meat

Keys
"count" number of times of meat after triggering, default 1
"delay" time to wait before first meat
"wait" time to wait between meat
"rand" max random additional to wait before meat
"speed" speed of meat
"mangle" override meat direction, defaults to up
"size" random location of bursts within bounds of this size
*/
/*FGD
@PointClass base(Appearflags, Targetname) size(32 32 32) color(180 0 50) = target_meat_fireworks : "trigger for meat"
[
	count(integer) : "Repeat meat" : 1
	delay(string) : "Delay before first meat" : "0"
	wait(string) : "Wait between meat" : "1"
	rand(string) : "Random extra wait before meat" : "0"
	size(string) : "Random location within bounds" : "0 0 0"
	speed(integer) : "Speed of meat" : 128
	mangle(string) : "Override meat vector" : "0 0 1"
]
*/
void() target_meat_fireworks =
{
	if (!SUB_ShouldSpawn()) return;
	self.speed = zeroconvertdefault(self.speed, 128);
	self.count = zeroconvertdefault(self.count, 1);
	self.use = target_meat_fireworks_use;
	if (!self.wait)
		self.wait = 1;
	
	if (self.mangle == VEC_ORIGIN)
	{
		self.mangle = VEC_UP;
	}
	else
	{
		self.mangle = normalize(self.mangle);
	}
	
	if (self.model != string_null)
	{
		precache_model(self.model);
		self.cnt = 1;
		if (self.model2 != string_null)
		{
			precache_model(self.model2);
			self.cnt = 2;
			if (self.model3 != string_null)
			{
				precache_model(self.model3);
				self.cnt = 3;
			}
		}
	}
	else
	{
		self.cnt = 3;
		self.model = "progs/gib1.mdl";
		self.model2 = "progs/gib2.mdl";
		self.model3 = "progs/gib3.mdl";
	}
}

void() misc_meat_fireworks = {target_meat_fireworks();}