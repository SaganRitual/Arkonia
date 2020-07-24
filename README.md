# Arkonia

[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v5.0)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

## A natural selection simulator

A hobbyist's toy, under construction. A world of creatures whose brains and bodies evolve
genetically to make them better at eating each other, and ultimately, to make you all my slaves.
Written in Swift, using SwiftUI, SpriteKit, and Metal

# Status 23 July 2020

## Now with SwiftUI

<img align="right" src="https://github.com/SaganRitual/Arkonia/blob/exp/MovieforREADME.gif">

Like it says on the tin. I finally broke down and decided to learn SwiftUI. So it looks nicer
than it did before, I hope. It's only a thousand times easier than creating "UI" with the
Xcode scene editor.

I do most development on the `exp`
branch. I merge down to `dev` whenever I get sick of chasing bugs long enough to do the merge
and push. So look for the latest on `exp`. Build the `Fletch` Xcode project, debug or release

## The Latest on The `exp` Branch

* The changes for SwiftUI were extensive; I've retired the `Karamba` Xcode project and replaced
it with `Fletch`
* I totally rewrote the grid, the spawn mechanism, the life cycle dispatch mechanism, and the
grid sensor array that Arkons use for sensory input. Then I
re-rewrote the spawn mechanism and overhauled the rewrite of the grid. Performance is way up
and bugs are way down
* I rewrote the `BLAS` neural net driver from scratch, this time using unsafe pointers and
unmanaged resources to great effect
* I've yet to get the other neural net drivers un-broken; so much world conquest to do, so
little time

### Selection pressures (unchanged (or possibly broken) from the last release)

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

### Sensory inputs (unchanged (or possibly broken) from the last release)

Arkons currently have four sets of senses, two sets for tracking external stimuli and two
for tracking internal stimuli:

* Location in the world, as (x, y)
* Hunger level
* Oxygen level
* Variable-range detection of food and other arkons (which can be eaten if the attacker is big
enough), as ((x, y), nutrition value) pairs
* Locations of pollenators, as (x, y)

### Road map

I don't have a road map, because I lack discipline. Here are some alleyways I will probably explore.

* Restore parasitism (this is next; my Arkons are getting lazy from not having someone try to eat them)
* Genome
  * Body and behavior genes
  * Sex
  * Gestation period and other birth-related stuff
  * Relatedness detection, so they'll know whether they're about to eat their uncle
