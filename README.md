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

(Bit of a blender workflow, while I was learning how to manipulate graphs to simulate physics)

![Demo](media/BlenderAnim.gif)


#Inventory GUI

An inventory system that allows for items to be dragged around inside a 2D grid where the icons "snap" back when the mouse is released. While still unfinished, the idea is to make different backpacks that vary in storage space, depending on how many blocks are inside the grid.

![Demo](media/Inventory.gif)


#RL Module

While this is yet to be tested (there are definitely a lot of bugs), this demo shows some stats like, The reward received per episode (one episode being the enemy catching the player or getting close enough) as well as what action it thinks it should take (not sure why it doesn't actually chase the player). 
I have simulated the agent's brain by using Q-learning to update state action values (what it thinks the expected reward is when taking an action in a specific state). 
These state action value are stored inside a Q-table which is saved periodically during gameply and loaded back in when a player enters the game again, allowing for online learning. Some challenges also came through such as keeping the agent learning under real-time constraints. For instance, as the Q-table grows in size it will require a lot more space in memory so one solution would be to use Roblox's buffer library to store entries in the Q tables as raw bytes rather than strings or integers. Another example would be the frequency at which the Q-table is saved, too many saves in a short amount of time will lead to throttling (Roblox Data Stores only allow a certain bandwidth of data saves). Thus the solution would be to just add a saving cooldown.

![Demo](media/Agent.gif)


This was a really fun project to work and really taught me how big projects should be actually managed and structured but also really making me experience how using a 3D Game Engine feels like and the tools and plugins it has to offer, making tedious work a lot more manageable while also making the overall workflow a lot more enjoyable and efficient.
While most of the features work the overall codebase is still very experimental and a lot of the features are still to be finished and fixed. Especially the RL module, it is still unfinished and a lot of debugging is yet to be done alongside parameter tuning and testing it on more finalised maps with multiple players. Nonetheless it taught me some core RL fundamentals while also considering performance and some basic memory management.

