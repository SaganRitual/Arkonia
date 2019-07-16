# Arkonia
A natural selection simulator

[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v1.0)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

![Awesome gif of Arkonia missing](https://github.com/SaganRitual/Arkonia/blob/exp/MovieforREADME.gif)

A hobbyist's toy, under construction. A world of creatures whose brains and bodies evolve
genetically to make them better at eating each other, and ultimately, to make you all my slaves.
Written in Swift, using SpriteKit, with no UI other than the main window, because I really
suck at UI programming.

### Status 16 July 2019

I took a step back from my high ambitions from before, and just focused on the neural nets, leaving
out all the genes for body and behavior. It's all in place now, and the overall structure of the code
has begun to stabilize enough that I can start building on it. My next step will be
to implement some genes to control the body--at present, all the genes are devoted to building the
brain. The arkons all have the same propulsion style:

* Go forward
* Stop
* Rotate
* Stop
* Repeat

The power and duration of the forward motion and rotation are under genetic control, as well as the duration of
the stops.

Arkons currently have eight senses. Three of the senses are 2D vectors requiring two inputs, and
the other five ar scalars. The senses are:

* Velocity
* Angular velocity
* Oxygen level
* Location in the world, as (r, Θ) to the origin
* Very short-range detection of food, as (r, Θ) to the closest morsel, and a count of how many are sensed
* Very short-range detection of other arkons, as (r, Θ) to the closest arkon, and a count of how many are sensed

I don't have a road map, because I lack discipline. Here are some alleyways I will probably explore.

* Genome
  * Body and behavior genes
  * Sex
  * Predation
  * Other propulsion strategies
