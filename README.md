## What is this?
A better version of the commonly made No-Collide Multi tool.

## Why should I use this one instead of the old Multi No-Collide?
This one takes into account whether props are near intersecting or not, based on a threshhold that you set in the tool itself.

## Why is this important?
Say you have a contraption made of 25 props. Some are close to eachother, some touching, and some far apart. With standard No-Collide Multi tools, generally they will constrain each prop to every other prop. This would be (N^2)/2 constraints, where N is the number of props. For 25 props, that is 312 constraints! Ouch!

Now, you can safely Multi No-Collide things, hopefully, having to worry about massive constraint counts causing your dupes to spawn slowly.
