Cuis-Unicode
============

### Aim

Design Sketch showing mechanics for Unicode support. Uses Ropes.
cf https://github.com/KenDickey/Cuis-Ropes


### Status

Incomplete; Pre-Alpha; Not ready yet to see the light of day...


### Introduction

Unicode is a complex system and strategy for computer manipulation of character and string information for human language. 

The code presented here has very limited ambitions:

- Properly read and write Unicode data to/from disk.
- Allow programattic (code) manipulation of Unicode code points.
- Implement reasonable sorting, searching, and other manipulation of code points.
	
The support of Unicode text display is minimal.  Fonts are not yet supported.

Bitmap glyphs are from http://www.unifoundry.com/unifont.html 

The basic strategy is as follows:
- The main useful classes are UniChar and UniString.  Others are helper subclasses.
- Unicode text is represented by arrayed blocks of storage where all characters are of the same size.
- Ropes are used to keep the illustion of mixed storage sizes while allowing indexing into text by character location.
  [See https://en.wikipedia.org/wiki/Rope_%28computer_science%29 ]

More on Unicode see http://Unicode.org  
Note also Wikipedia Unicode pages and http://site.icu-project.org/docs

This package is separate from Core Cuis.  
This means that the class UniChar does not inherit from Character and UniString does not inherit from String. 


### The grand plan

- UniCodes	- Basic codepoint support (CodePoints: Characters, Ropes ["strings"]) The grand planidirectional, location based sorting; advanced algorithms
- UniDisplay	- Character composition ; ligatures
- UniInput	- Multilingual text input

Unit tests are in separate packages due to large size:

- UniCodesTests
- UniUtilsTests
- UniDisplayTests
- UniInputTests
