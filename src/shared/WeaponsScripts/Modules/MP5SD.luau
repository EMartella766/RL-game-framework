local Settings = {
	
	canAim = true;
	aimSmooth = 0.05;
	sprintCF = CFrame.new() * CFrame.Angles(math.rad(-90/10), math.rad(45/5), math.rad(75/5));
	zoomAim = 40;
	zoomTime = 1;
	hasScope = false;
	
	semi = true;
	mode = "fullAuto";
	fireRate = .11;
	maxAmmo = 30;
	ammo = 30;
	debounce = .05;
	damage = 10;
	headshot = 40;
	
	fireSound = game.ReplicatedStorage.Weapons.SFX["MP5K shoot"];
	firingAnim = "rbxassetid://75008433966736";
	equipAnim =  "rbxassetid://127498262442643";
	reloadAnim = "rbxassetid://87481940172802";
	
	icon = "rbxassetid://14000213979"
	
}

return Settings