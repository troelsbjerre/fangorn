# Fangorn

## Looking for the better tree to throw Darts at

This is a collection of data structures that are all meant as drop-in
replacements for SplayTreeMap from the dart:collection library.

## But why? Why would you do that?

It started because I was curious if the idea behind the Sorted Container module
(http://www.grantjenks.com/docs/sortedcontainers/) would translate to
performant Dart. If so, this would lead to a much more memory efficient
alternative to SplayTreeMap. Early trials revealed that it was indeed possible
to beat SplayTreeMap on most metrics. However, the two-layer idea from the
Python project was not the fastest option. Thus, the search continues.

## But why tho?!

Because it's fun to write data structures, and always a good idea to see how
the theoretical ideas stack up in practice.

## So, make with the results!

Easy now. So far, only a couple of data structures have been implemented.
Currently, the best contender is BPlusTreeMap. On most of the benchmark
(depending on input size), it is between 50% and 100% faster than
SplayTreeMap and currently uses the same amount of memory. This is due to
change, when I swap out the growable lists for fixed lists.
