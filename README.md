# Arkonia

[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v4.0)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

## A natural selection simulator

A hobbyist's toy, under construction. A world of creatures whose brains and bodies evolve
genetically to make them better at eating each other, and ultimately, to make you all my slaves.
Written in Swift, using SpriteKit, with no UI other than the main window, because I really
suck at UI programming.

# Status 10 April 2020

## Now We're Somewhere

<img align="right" src="https://github.com/SaganRitual/Arkonia/blob/exp/MovieforREADME.gif">

At long last, it's fast enough and stable enough to be (potentially) interesting.
I notice that a few people have cloned the repo. That's seriously cool. I do most development on the `exp`
branch. I merge down to `dev` whenever I get sick of chasing bugs long enough to do the merge
and push. So look for the latest on `exp`. Build the `Karamba` Xcode project, debug or release

## The Latest on The `exp` Branch

### Metal and Accelerate support for neural nets

I've created neural net drivers for both the `BLAS` and `BNNS` models in the Accelerate library,
as well as drivers for the GPU using both the matrix operations and the convolution kernel tools
in the the Metal Performance Shaders library. As it turns out, Accelerate does just as well
as the GPU; I think it's because my neural nets are (currently) too small to be efficient.
Some investigation is in order, but I haven't done it yet. Also, I think I broke the GPU and BLAS
stuff while getting the BNNS stuff to work, but now that I know so much more than I did then, I'll
probably rewrite those rather than trying to fix them

### Selection pressures

* The obvious one, finding the manna (food): Arkons don't know how to do that when the app launches
* Pollenation: the manna can't re-bloom after being grazed until it's pollenated. The pollenators
are mysterious, expertly-drawn, disc-shaped creatures that float around randomly in the Arkonian ooze
* Manna fatigue: manna takes longer to re-bloom to full nutritional value when it's overgrazed; it
needs time to recover
* Oxygen: there's a trace amount of oxygen in the muck, which arkons can absorb only when they move;
most of what they need is in the manna, so they kind of have to eat constantly
* Per-neuron energy cost
* Per-mass energy cost
* Gestation and birth costs
* Entropy
* Carbon-dioxide reducer or whatever-something: some random experiments with other selection pressure,
I'll clean it all up some day

### Sensory inputs

Arkons currently have four sets of senses, two sets for tracking external stimuli and two
for tracking internal stimuli:

* Location in the world, as (x, y)
* Hunger level
* Oxygen level
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
