# Arkonia
A natural selection simulator

[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v2.0)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

![Awesome gif of Arkonia missing](https://github.com/SaganRitual/Arkonia/blob/exp/MovieforREADME.gif)

A hobbyist's toy, under construction. A world of creatures whose brains and bodies evolve
genetically to make them better at eating each other, and ultimately, to make you all my slaves.
Written in Swift, using SpriteKit, with no UI other than the main window, because I really
suck at UI programming.

### Status 05 Jan 2020

Another big redesign. Using the physics engine to move them around turned out to be a big headache,
so now I move them around on a fixed grid using SKActions. Now, with any luck, I'll get some cool
genetic stuff going, like some genes to control the body--at present, all the genes are devoted to building the
brain.

Arkons currently have four sets of senses, two sets for tracking external stimuli and two
for tracking internal stimuli:

* Hunger level
* Oxygen level
* Location in the world, as (r, Θ) to the origin
* Very short-range detection of food and other arkons (which can be eaten if the attacker is big
enough), as (relative position, nutrition value) pairs

I don't have a road map, because I lack discipline. Here are some alleyways I will probably explore.

* Genome
  * Body and behavior genes
  * Sex
  * Gestation period and other birth-related stuff
  * Relatedness detection, so they'll know whether they're about to eat their uncle
