# Arkonia
A hobbyist's toy, under construction. An evolution and natural selection simulator.
Creatures whose brains and bodies evolve genetically to make them better at eating each other.
### Current status: 27 Feb 2019
* Genome
  * Fully functional: asexual replication, mutation, decode to net frame
  * Lots of net genes in place
  * All the genes currently apply only to the net
  * To do: add meta-genes to act on the genome itself or change its expression in some way, for example
    * Hox, like a real hox gene, to cause certain segments of the genome to produce multiple
    phenotypical expressions. That is, to cause the body to have repeated sections, like a
    caterpillar, or insects in general, with head/abdomen/thorax segments.
    * Lock, to cause a certain segment of the genome to be treated as an atomic unit, such that
    any genome snippet takes the locked segment as a whole, never just a portion of it. Not sure
    whether this would give us any interesting results. Some experimentation would be needed.
  * To do: add body genes -- what I'm working on now
  * To do: sexual replication 
* Net
  * Fully functional: construct from net frame, drive sense inputs through to motor outputs
  * To do: the net frame might be an unnecessary holdover from a previous design experiment,
  but I can't remember. It's a staging area for the "live" net, the component that actually
  converts sense inputs to motor outputs. I think a staging area is unnecessary now, but I
  need to look into it.
* Body
  * Right now it's a simple circle with three jets, equally spaced on its circumference.
  * To do: add body parts to correspond to the aforementioned body genes I'm working on now.
  * To do: add "policies", for example, how healthy do I need to be in order to reproduce? or
  how close of a relative am I willing to eat? That sort of thing.
* Display
  * When I was just working on the net part, I had a nice display of the net, with layers and
  neurons and such. But I've broken that in the process of implementing the display for the Arkons.
  So all I have right now is the Arkons display.
  * To do: fix the damned net display
  * To do: show some statistics in one of the display portals, not just for looks, but for debugging too.
