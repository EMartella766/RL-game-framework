#Basic Game framework with RL module

#OVERVIEW:

This project is a modular real-time game framework I developed using Roblox Studio featuring concepts such as gameplay systems, procedural content generation and RL applied to an enemy while also keeping in mind real-time performance constraints. 
Rather than focusing on making sure the project is complete, I wanted to prioritise a clean and scalable system architecture allowing individual modules to be developed, tested and extended individually.


#Map Generation

Module capable of generating maps of different sizes. In this instance, I made 4 different rooms, with one being the origin where generation begins. 
It expands by iteratively connecting exits to newly generated rooms while preventing overlapping. This process is resursively executed to produce a map of n rooms.

![Demo](media/MapGenerationSmall.png)

The current implementation supports scalable layouts that can be used for different gameplay scenarios. 

Planned improvements include vertical generation which can support multi-floor or cave-like environments.

![Demo](media/MapGenerationBig.png)


#Player Stats and HUD (Visor GUI)

A Visor GUI that can be toggled on and off by the player, providing real-time player info such as:
- Compass directional system;
- Health and Stamina indicators;
- Currently equipped weapon;
- Current ammo count.

The system is designed to be modular allowing individual HUD elements to be added with ease without impacting other gameplay elements.

![Demo](media/VisorGUI.gif)


#Damage and Reload system

A modular weapon framework supporting:
- Firing logic with reload constraints (players are not able to fire while reloading);
- Basic bullet physics and hit detection;
- Weapon firing animations;
- A system that allows players to pick different class-based loadouts.

![Demo](media/Damage.gif)

(Bit of a blender workflow, while experimenting with graphs to simulate physics)

![Demo](media/BlenderAnim.gif)


#Inventory GUI

a grid-based inventory GUI which allows items to be dragged and repositioned within a 2D grid. Items "snap" back into valid slots when the mouse is released.
The system is designed with extensibility in mind, with plans to support multiple backpack types which allow for different storage capacities based on grid size.

![Demo](media/Inventory.gif)


#Reinforcement Learning Module (Experimental)

An experimental RL module exploring the use of Q-learning to drive enemy decision-making during live gameplay. Agents can evaluate actions based on player's behaviour and update state-action values in real time. The demo also displays statistics such as the reward received per episode (one episode terminating when the enemy gets close enough to the player ) and the exploration rate.

Key Characteristics:
- Q-learning implementation;
- State-action values stored in a Q-table; (the agent's estimated reward when taking an action in a specific state);
- Persistent learning via Roblox DataStores;
- Online learning across multiple play sessions.

Technical Challenges Addressed:
- Memory growth as the Q-table grows in size;
- DataStore bandwidth limits when saving frequently;
- Maintaing learning updates without impacting frame rate.

The solutions were to flatten down the Q-table and then using the Roblox's buffer library to store data as raw bytes preventing throttling as well as limiting the amount of saves done in a period by including a save cooldown.

This module is currently experimental with a lot of debugging and parameter tuning to be done as well as testing on more finalised maps with multiple players.


![Demo](media/Agent.gif)


This project really taught and exposed me to:
- Structuring and maintaining large, modular codebases;
- Designing scalable gameplay systems;
- Apply Reinforcment learning under real-time constraints;
- Performance, memory and persistance considerations in live game environments;
- How plugins and external tools can be used to make workflow more efficient and productive.

While the system still remains experimental, The framework provides a scalable base for further development and experimentation.


