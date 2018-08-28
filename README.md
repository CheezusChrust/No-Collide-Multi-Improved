## What is this?
A better version of the commonly made No-Collide Multi tool.

## Why should I use this one instead of the old Multi No-Collide?
This one takes into account whether props are near intersecting or not, based on a threshhold that you set in the tool itself.

## Why is this important?
Say you have a contraption made of 25 props. Some are close to eachother, some touching, and some far apart. With standard No-Collide Multi tools, generally they will constrain each prop to every other prop. This would be (N^2)/2 constraints, where N is the number of props. For 25 props, that is 312 constraints! Ouch!

Now, you can safely Multi No-Collide things, hopefully, having to worry about massive constraint counts causing your dupes to spawn slowly.

## I found a bug! Something isn't working! REEEEEEEEEEE!
This is my first time making a tool for GMod. Of course there may be some bugs. Please tell me how to reproduce them in the comments if you can, and I'll fix them as soon as possible.

## KNOWN BUGS
* Right clicking with nothing selected will display a hint when it shouldn't occasionally
* No-colliding massive amounts of props can cause the tool to break entirely, requiring a map reload
* Cannot undo nocollide if "dumb" is off and only 2 props are no-collided
* Search boxes are not properly axis-aligned so props at odd angles can sometimes be missed (only an issue when "dumb" is off, raise distance as temporary fix)
