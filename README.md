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

### Status 10 March 2020

Neural net calculations can now be configured to run on the GPU -- either as MPSMatrix operations or MPSCNNConvolution stuff -- or on the CPU using the BLAS functions in the Accelerate library. As it turns out, Accelerate does just as well as the GPU; I think it's because the nets are too small to be efficient. Some investigation is in order, but I haven't done it yet.

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
