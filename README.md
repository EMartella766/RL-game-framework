#Basic Game framework with RL module

## Modular real-time game framework with an integrated RL system used to implement smart enemies that can evaluate their decisions based on player's behaviours. 
## These agents learn during live gameplay while also considering real-time constraints and performance.

#OVERVIEW:

#Map Generation
Module which can generate maps of different sizes. In this instance, I made 4 types of different rooms, with one of them being the starting room or the origin. 
From this starting room, the program goes through each exit (or door), and connects the entrance of the new generate room to it. However if there is an overlap, then the room won't be generated. This process is resursively executed to produce a map of n rooms.

![Demo](media/MapGenerationSmall.png)

As you can see we can generate small and big maps, making it scalable but also applicable to different map scenarios. The next challenge would be to also try and make it generate vertically which could, for instance, allow for a cave system map with different floors.

![Demo](media/MapGenerationBig.png)

#Stats GUI

This demo instead showcases a Visor like GUI that can be toggled on and off. it features a compass system, a health and stamina counter, the current weapon equipped and the current ammo held.

![Demo](media/VisorGUI.gif)

#Damage and Reload system

The Weapons framework module includes a working firing system with weapon reload (player not allowed to shoot while reloading), basic bullet physics as well as some firing animations. It additionally features a loadout system where the player can pick between two classes and select different loadouts.

![Demo](media/Damage.gif)

#Inventory GUI

This GUI 
![Demo](media/Inventory.gif)

![Demo](media/BlenderAnim.gif)

![Demo](media/Agent.gif)



-- things to showcase
Map Generation Module
Weapon Animations done
Damage system done
Camera sway motion done
Sprint system done
Loadout system done
Visor GUI done
Inventory item dragging system done

