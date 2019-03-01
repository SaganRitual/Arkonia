# Arkonia
[![GitHub release](https://img.shields.io/github/release-pre/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/tree/v0.1)
[![License](https://img.shields.io/github/license/SaganRitual/Arkonia.svg?style=plastic)](https://github.com/SaganRitual/Arkonia/blob/dev/LICENSE)
[![Runs on](https://img.shields.io/badge/Platform-macOS%20only-blue.svg?style=plastic)](https://www.apple.com/macos/)
[![Does not run on](https://img.shields.io/badge/Platform-not%20iOS-red.svg?style=plastic)](https://www.urbandictionary.com/define.php?term=SOL)

A hobbyist's toy, under construction. An evolution and natural selection simulator.
Creatures whose brains and bodies evolve genetically to make them better at eating each other.
Written in Swift, using SpriteKit, with no UI other than the main window. Presumably it would
be an enormous effort to port to iOS, even if anyone wanted to.

I don't have any formal training with AI or ML or genetic algorithms, or any of this
stuff. I realized that I hate math after linear algebra and two semesters of calculus,
and I don't remember any of it anyway, having learned it all directly from Messrs Newton and
Leibniz themselves. Don't expect gradients, or loss functions, or anything you may have learned in school
or on the job or in your formal research about genetic algorithms, because I've never
looked into those disciplines. Everything I know about the subject I've learned from
creating this toy over the last three years.

In other words, I'm self-conscious about how ill-conceived it might appear to anyone who's
serious about the disciplines, and I don't want to put anyone off their breakfast. Caveat lector.

### Status 27 Feb 2019
* Genome
  * We're fully functional, from (asexual) replication with mutation, to genome decode to net frame.
  * Lots of net genes in place--everything I could think of.
  * All the genes currently apply only to the net.
  * Currently working on adding genes for constructing the body--the Arkons already have a pretty interesting
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
  * We're fully functional: from constructing the live net, to driving sense inputs through to motor outputs
  * To do: the net frame component might be an unnecessary holdover from a previous design experiment,
  but I can't remember. It's a staging area for the "live" net, the component that actually
  converts sense inputs to motor outputs. I think a staging area is unnecessary now, but I
  need to look into it.
* Body
  * Right now it's a simple circle with three jets, equally spaced on its circumference.
  * To do: add body parts to correspond to the aforementioned body genes I'm working on now.
* Display
  * When I was just working on the net part, I had a nice display portal for the net, with layers and
  neurons and such. But I've broken that in the process of implementing the portal for the Arkons.
  So all I have right now is the Arkons portal
  * To do: fix the damned net display portal
  * To do: show some statistics in one of the portals, not just for looks, but might be useful for debugging.
* Testing -- there really are only two hard parts at the present:
  * Genome manipulation and mutation--these pass a battle-hardened unit test.
  * The live net--well, it passes a lot of unit testing, but it was so hard to get the design right and took
  me so long to implement that I'm not sure whether I trust it yet. More devious unit testing is in order,
  but right now I'm lured away from good practices by the gratification of watching the Arkons evolve, no matter
  how trivial their evolution is at present.
