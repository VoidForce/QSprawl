// dwell items
void() item_artifact_berserk =
{
	self.classname = "item_artifact_invulnerability";
	item_artifact_invulnerability();
};

void() item_artifact_haste =
{
	self.classname = "item_artifact_super_damage";
	item_artifact_super_damage();
};

void() item_artifact_wetsuit =
{
	self.classname = "item_artifact_envirosuit";
	item_artifact_envirosuit();
};

void() weapon_quad_shotgun =
{
	self.classname = "weapon_supershotgun";
	weapon_supershotgun();
};

void() weapon_railgun =
{
	self.classname = "weapon_rocketlauncher";
	weapon_rocketlauncher();
};