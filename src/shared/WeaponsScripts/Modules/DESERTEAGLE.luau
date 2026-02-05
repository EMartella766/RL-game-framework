local Settings = {
	
	canAim = true;
	aimSmooth = 0.05;
	sprintCF = CFrame.new() * CFrame.Angles(math.rad(-90/10), math.rad(0), math.rad(0));
	zoomAim = 40;
	zoomTime = 1;
	hasScope = false;
	
	semi = true;
	mode = "semi";
	fireRate = .25;
	maxAmmo = 7;
	ammo = 7;
	debounce = .5;
	damage = 8;
	headshot = 40;
	
	fireSound = game.ReplicatedStorage.Weapons.SFX["deagle "];
	firingAnim = "rbxassetid://75008433966736";
	equipAnim =  "rbxassetid://127498262442643";
	reloadAnim = "rbxassetid://74976156456131";
	
	icon ="rbxassetid://5379422414"
	
}

return Settings
