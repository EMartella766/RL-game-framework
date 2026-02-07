# RL game framework

## Modular real-time game framework with an integrated RL system used to implement smart enemies that can evaluate their decisions based on player's behaviours. 
## These agents learn during live gameplay while also considering real-time constraints and performance.

Map generation module which can generate maps of different sizes. In this instance, I made 4 types of different rooms, with one of them being the starting room or the origin. 
From this starting room, the program goes through each exit (or door), and connects the entrance of the new generate room to it. However if there is an overlap, then the room won't be generated. This process is resursively executed to produce a map of n rooms.

![Demo](media/MapGenerationSmall.png)

As you can see we can generate small and big maps, making it scalable but also applicable to different map scenarios. The next challenge would be to also try and make it generate vertically which could, for instance, allow for a cave system map with different floors.

![Demo](media/MapGenerationBig.png)



![Demo](media/VisorGUI.gif)

![Demo](media/Damage.gif)

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

