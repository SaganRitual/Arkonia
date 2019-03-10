# Arkonia
[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v0.1)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

![Awesome gif of Arkonia missing](https://j.gifs.com/mOQ9p0.gif "Awesome gif of Arkonia missing")

A hobbyist's toy, under construction. An evolution and natural selection simulator.
Creatures whose brains and bodies evolve genetically to make them better at eating each other.
Written in Swift, using SpriteKit, with no UI other than the main window, because I really suck at
UI programming.

### Status 10 Mar 2019

The gif says a lot already. Everything is in place now, and the overall structure of the code
has begun to stabilize. It's still a mess in a few places where I haven't really figured out
what I'm doing yet, but it's stable enough that I can start building on it. My next step will be
to implement some genes to control the body--at present, all the genes are devoted to building the
brain. The arkons all have the same body: a circle with three jets spaced equally around the
circumference. The jets are completely under the control of the brain, which in turn is completely
under the control of the genes. The brain receives sensory input, munges the input signal around
a bit, and sends independent force vectors to the jets.

Arkons currently have four senses. Three of the senses are 2D vectors requiring two inputs, and
the last sense is a scalar. The senses are:

* Velocity
* Location in the world, as (r, Θ) to the origin
* Very short-range detection of food, as (r, Θ) to the food
* Angular velocity

I don't have a road map, because I lack discipline. Here are some alleyways I will probably explore.

* Genome
  * Currently preparing to add genes for constructing the body--the Arkons already have a pretty interesting
  body (see below)--but I'd like to see what effect movable appendages will have.
  * To do: add meta-genes to act on the genome itself or change its expression in some way, for example:
    * Hox, like a real hox gene, to cause certain segments of the genome to repeat themselves.
    That is, to cause the body to have repeated sections, like a caterpillar, or insects in
    general, with head/abdomen/thorax segments.
    * Lock, to cause a certain segment of the genome to be treated as an atomic unit, such that
    any genome snippet takes the locked segment as a whole, never just a portion of it. Not sure
    whether this would give us any interesting results. Some experimentation would be needed.
  * To do: implement a "Policy" gene, or a set of policy genes, to answer questions like:
      * How healthy do I need to be in order to reproduce? What level of reserves do I need?
      * How many offspring should I produce at each spawning?
      * How close of a relative am I willing to eat?
  * To do: sexual replication.
  * To consider?: replication involving more than two Arkons.
* Net
  * To do: the net frame component might be an unnecessary holdover from a previous design experiment,
  but I can't remember. It's a staging area for the "live" net, the component that actually
  converts sense inputs to motor outputs. I think a staging area is unnecessary now, but I
  need to look into it.
* Body: right now it's a simple circle with three jets, equally spaced on its circumference.
* Display: the stats portal sucks, because I suck at UI.
* Testing -- there really are only two hard parts at the present:
  * Genome manipulation and mutation--these pass a battle-hardened unit test.
  * The live net passes a lot of unit testing, but it was so hard to get the design right and took
  me so long to implement that I'm not sure whether I trust it yet. More devious unit testing is in order,
  but right now I'm lured away from good practices by the gratification of watching the Arkons evolve, no matter
  how trivial their evolution is at present.
