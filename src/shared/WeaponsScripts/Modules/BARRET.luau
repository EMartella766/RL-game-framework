local Settings = {

	canAim = true;
	aimSmooth = 0.05;
	sprintCF = CFrame.new() * CFrame.Angles(math.rad(-90/10), math.rad(45/5), math.rad(75/5));
	zoomAim = 40;
	zoomTime = 1.5;
	scopeZoom = 10;
	zoomSpeed = 5;
	hasScope = true;

	semi = true;
	mode = "semi";
	fireRate = 1;
	maxAmmo = 10;
	ammo = 10;
	debounce = 1;
	damage = 100;
	headshot = 200;

	fireSound = game.ReplicatedStorage.Weapons.SFX["barrett-50-cal2"];
	firingAnim = "rbxassetid://73504326729381";
	equipAnim =  "rbxassetid://127498262442643";
	reloadAnim = "rbxassetid://87481940172802";
	
	icon = "rbxassetid://81490171965739"

}

return Settings