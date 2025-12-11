goal: make a custom std on site for me to my style. dlang, monkyyy resreach me, pro ranges, find my previous attempts on github there were 3

std's main job is data structures and algorithms; you will likely also need io, traits and some primitive apis to glue these together

D's ranges api of 3 functions is very good as a starting point, 1 function apis are dumb, c++ I dont even know how many function you have to make; 3.
front, pop, empty

phobos optional functions were based on c++ stl and are very much NOT good tho

my optional functions:

`.index` returns something numbery that can be passed to a data structure to access the current front in const time
`.length` same as elsewhere
`.reverse` mutates the range and returns itself, `.reverse.reverse` is a no op
`.remove` marks the element for removal *if resolve is defined front and length doesnt change on call* (Note: originally specified as `.delete` but changed to `.remove` to avoid conflict with D's reserved keyword)
`.append` add element at this site *if resolve is defined front and length doesnt change on call*
`.resolve` finalizes remove and append, may "invalidate" all existing ranges spawned from the parent data structure

for now make me 7 data structures and copy the 30 most used algorithms
