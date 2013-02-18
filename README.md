Cuis-Unicode
============

Design Sketch showing dispatch mechanics for Unicode support.

Not ready yet to see the light of day...

See http://Unicode.org

Unicode is a complex system and strategy for computer manipulation of character and string information for human language. 

The code presented here has very limited ambitions:

	Properly read and write Unicode data to/from disk.
	Allow programattic (code) manipulation of Unicode code points.
	Implement reasonable sorting, searching, and other manipulation of code points.
	
There is nothing here at this time to support actual display of Unicode text.

The basic strategy is as follows:
	Unicode characters are supported by the smallest size of their representation (8, 16, or 32 bits in Char8, Char16 or Char32 objects).
	Unicode text is represented by arrayed blocks of storage where all characters are of the same size.
	Ropes are used to keep the illustion of mixed storage sizes while allowing indexing into text by character location.
	[See https://en.wikipedia.org/wiki/Rope_%28computer_science%29 ]

THE GRAND PLAN

	UniCodes	- Basic codepoint support (CodePoints: Characters, Ropes ["strings"])
	UniUtils	- Bidirectional, location based sorting; advanced algorithms
	UniDisplay	- Character composition ; ligatures
	UniInput	- Multilingual text input

Unit tests are in separate packages due to large size:

	UniCodesTests
	UniUtilsTests
	UniDisplayTests
	UniInputTests

