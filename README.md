# Arkonia
A natural selection simulator

[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v3.0)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

![Awesome gif of Arkonia missing](https://github.com/SaganRitual/Arkonia/blob/exp/MovieforREADME.gif)

A hobbyist's toy, under construction. A world of creatures whose brains and bodies evolve
genetically to make them better at eating each other, and ultimately, to make you all my slaves.
Written in Swift, using SpriteKit, with no UI other than the main window, because I really
suck at UI programming.

# Status 09 April 2020

## How to Build n Stuff

I notice that a few people have cloned the repo. That's cool. I do most development on the `exp`
branch. I merge down to `dev` whenever I get sick of chasing bugs long enough to do the merge
and push. So look for the latest on `exp`. Build the `Karamba` Xcode project, debug or release

## The Latest on The `exp` Branch
### Metal and Accelerate support for neural nets

Now we can use the BNNS functions from the Accelerate library, in addition to the Metal libs for
using the GPU, as well as the BLAS stuff in Accelerate. As it turns out, Accelerate does just as well
as the GPU; I think it's because the nets are too small to be efficient. Some investigation is in order,
but I haven't done it yet. Also, I think I broke the GPU and BLAS stuff while getting the BNNS
stuff to work

### Pollenators

Mysterious disc-shaped creatures that float around in the Arkonian ooze, pollenating the manna
so it will regrow after it has been grazed

### Sensory inputs

Arkons currently have four sets of senses, two sets for tracking external stimuli and two
for tracking internal stimuli:

* Hunger level
* Oxygen level
* Location in the world, as (x, y)
* Variable-range detection of food and other arkons (which can be eaten if the attacker is big
enough), as ((x, y), nutrition value) pairs
* Locations of pollenators, as (x, y)

I don't have a road map, because I lack discipline. Here are some alleyways I will probably explore.

* Restore parasitism, which I broke while working on the GPU stuff, and which has since gone a bit crusty
* Genome
  * Body and behavior genes
  * Sex
  * Gestation period and other birth-related stuff
  * Relatedness detection, so they'll know whether they're about to eat their uncle
