'From Cuis 4.1 of 12 December 2012 [latest update: #1600] on 17 February 2013 at 10:08:38 pm'!
'Description UniCodes -- basic support for Unicode code points
                -- see http://unicode.org/'!
!classDefinition: #UniChar category: #UniCodes!
Object subclass: #UniChar
	instanceVariableNames: 'codePoint'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UniChar class' category: #UniCodes!
UniChar class
	instanceVariableNames: ''!

!classDefinition: #UChar16 category: #UniCodes!
UniChar subclass: #UChar16
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UChar16 class' category: #UniCodes!
UChar16 class
	instanceVariableNames: ''!

!classDefinition: #UChar32 category: #UniCodes!
UniChar subclass: #UChar32
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UChar32 class' category: #UniCodes!
UChar32 class
	instanceVariableNames: ''!

!classDefinition: #UChar8 category: #UniCodes!
UniChar subclass: #UChar8
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UChar8 class' category: #UniCodes!
UChar8 class
	instanceVariableNames: ''!

!classDefinition: #UniString category: #UniCodes!
ArrayedCollection subclass: #UniString
	instanceVariableNames: ''
	classVariableNames: 'Fibonacci MaxRopeDepth'
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UniString class' category: #UniCodes!
UniString class
	instanceVariableNames: ''!

!classDefinition: #UniFlat category: #UniCodes!
UniString subclass: #UniFlat
	instanceVariableNames: 'charBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UniFlat class' category: #UniCodes!
UniFlat class
	instanceVariableNames: ''!

!classDefinition: #UniFlatSlice category: #UniCodes!
UniString subclass: #UniFlatSlice
	instanceVariableNames: 'charBlock startIndex length'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UniFlatSlice class' category: #UniCodes!
UniFlatSlice class
	instanceVariableNames: ''!

!classDefinition: #UniSplice category: #UniCodes!
UniString subclass: #UniSplice
	instanceVariableNames: 'depth totalLength leftRope rightRope'
	classVariableNames: 'MeldThreshold'
	poolDictionaries: ''
	category: 'UniCodes'!
!classDefinition: 'UniSplice class' category: #UniCodes!
UniSplice class
	instanceVariableNames: ''!


!UChar16 commentStamp: '<historical>' prior: 0!
I am a Unicode character which is represented in 16 bits.
!

!UChar32 commentStamp: '<historical>' prior: 0!
I am a Unicode character which is represented in 32 bits.!

!UChar8 commentStamp: '<historical>' prior: 0!
I am a Unicode character which is represented in 8 bits.!

!UniChar commentStamp: '<historical>' prior: 0!
This is the abstract parent class of Unicode Characters with various representation sizes.
See http://Unicode.org for information.

UniChars are immutable.  

UniChars with the same codePoint are frequently NOT unique.!

!UniFlat commentStamp: '<historical>' prior: 0!
A flat rope is basically a string.  My instances are "leaves" in a Rope "tree".

Internal storage is all the same size, either 8, 16, or 32 bit chunks holding Unicode codePoints.

This is to say, a CharBlock is one of ByteArray, ShortIntegerArray, or WordArray as required.

Do not use me directly, use UniString.!

!UniFlatSlice commentStamp: '<historical>' prior: 0!
I refer to an immutable charBlock slice shared with another UniString.!

!UniSplice commentStamp: '<historical>' prior: 0!
I am the splice/concatenation of two other UniStrings.!

!UniString commentStamp: '<historical>' prior: 0!
I am the abstract class of immutable strings known as Ropes.

Functional string operations return new Ropes. See #at:put: in subclasses.

Multithreaded sharing of ropes needs no locking.

See:
	https://en.wikipedia.org/wiki/Rope_%28computer_science%29

Ropes offers better performance than strings for common operations, and generally reduce memory allocations and copies, while only entailing a small degradation of less common operations.

Where a string is represented in memory by an array of character values, a rope is a tree structure whose leaves are slices of immutable strings. Therefore, concatenation, appending, prepending, substrings, etc. are operations that require only trivial tree manipulation, generally without having to copy memory. In addition, the tree structure of ropes makes them suitable as a form of index to speed-up access to Unicode characters by index in long chunks of text.

The following operations are algorithmically faster in ropes:
    - extracting a subrope is logarithmic (linear in strings);
    - appending/prepending is near-constant time (linear in strings);
    - concatenation is near-constant time (linear in strings);
    - char length is constant-time (linear in strings);
    - access to a character by index is logarithmic (linear in strings);


NB: Unicode strings are treated as strings and called UniStrings, even though represented internally as ropes.
Q:  If you call a tail a leg, how many legs does a dog have?
A:  Five
Correct Answer:  Four.  Calling a tail a leg does not make it one.  ;)
!

!Character methodsFor: '*unicodes' stamp: 'KenD 2/17/2013 14:08'!
asUniChar
	"Answer a Unicode character based on my value interpreted as a code point."

	^UniChar fromCodePoint: (self unicodeCodePoint)! !

!Character methodsFor: '*unicodes' stamp: 'KenD 2/17/2013 20:43'!
asUniString
	"Answer a Unicode string based on my value interpreted as a code point."

	^UniString fromString: (self asString )! !

!Number methodsFor: '*unicodes' stamp: 'KenD 2/17/2013 09:02'!
asUniChar
	"Answer a Unicode character [UniChar] with me as a code point"

	^UniChar fromCodePoint: self! !

!Number methodsFor: '*unicodes' stamp: 'KenD 2/17/2013 08:49'!
classForCodePoint
	"Answer a class which will hold this 8, 16, or 32 bit code point or signal a domain error"

	(self < 0)
	ifTrue: [ DomainError signal: 'Unicode code points must be non-negative' ].
	
	(self <= 16rFF)
	ifTrue: [ ^UChar8 ].
	
	(self <= 16rFFFF)
	ifTrue: [ ^UChar16 ].
	
	(self <= 16rFFFFFFFF)
	ifTrue: [ ^UChar32 ].
	
	DomainError signal: 'Unicode code points must fit within a 32 bit range'! !

!String methodsFor: '*unicodes' stamp: 'KenD 2/17/2013 20:45'!
asUniString

	^UniString fromString: self! !

!UniChar methodsFor: 'converting' stamp: 'KenD 2/17/2013 19:56'!
asCharacter

	"@@Fixme: BOGUS@@"
	^self codePoint asCharacter ! !

!UniChar methodsFor: 'converting' stamp: 'KenD 2/17/2013 14:42'!
asUniChar

	^self! !

!UniChar methodsFor: 'converting' stamp: 'KenD 2/17/2013 22:00'!
asUniString

	^self codePoint asCharacter asUniString ! !

!UniChar methodsFor: 'accessing' stamp: 'KenD 2/17/2013 08:58'!
codePoint

	^codePoint! !

!UniChar methodsFor: 'printing' stamp: 'KenD 2/17/2013 17:25'!
printOn: aStream

	aStream nextPut: $$.
	aStream nextPut: (self codePoint asCharacter) "@@@FIXME@@@"! !

!UniChar methodsFor: 'private' stamp: 'KenD 2/17/2013 09:00'!
privateSetCodePoint: aCodePoint

	codePoint := aCodePoint ! !

!UniChar methodsFor: 'printing' stamp: 'KenD 2/17/2013 17:26'!
storeOn: aStream
	"Character literals are preceded by '$'."

	aStream nextPut: $$; nextPut: (self codePoint asCharacter) "@@@FIXME: Moby Bogus!!@@"! !

!UniChar methodsFor: 'accessing' stamp: 'KenD 2/17/2013 17:18'!
unicodeCodePoint

	^self codePoint! !

!UniChar class methodsFor: 'instance creation' stamp: 'KenD 2/17/2013 09:22'!
fromCodePoint: aCodePoint
	"Answer a new Unicode character to represent aCodePoint"
"
	self assert: (16r34 asUniChar  class == UChar8).
	self assert: (16r1234 asUniChar class == UChar16).
	self assert: (16r1234567 asUniChar class == UChar32).
"	
	| newUChar |
	newUChar := aCodePoint classForCodePoint new initialize.
	newUChar privateSetCodePoint: aCodePoint.
	^newUChar! !

!UniFlat methodsFor: 'accessing' stamp: 'KenD 2/17/2013 16:11'!
at: anIndex
	
	^(self codePointAt: anIndex) asUniChar! !

!UniFlat methodsFor: 'accessing' stamp: 'KenD 2/17/2013 20:58'!
at: index put: aCharacter 

	"Answer a new UniString"
	(self size = 1)
	ifTrue: [
		(index = 1)
		ifTrue: [^ aCharacter asUniString]
		ifFalse: [self errorSubscriptBounds: index]
	].
	
	(index = 1)
	ifTrue: [ ^ (aCharacter asUniString , (self copyFrom: 2 to: self size))].
	
	(index = self size)
	ifTrue: [ ^ (self copyFrom: 1 to: (self size - 1)) , aCharacter asUniString ].
	
	^ (self copyFrom: 1 to: (index - 1)) ,
	   aCharacter asUniString ,
	   (self copyFrom: (index + 1) to: (self size))! !

!UniFlat methodsFor: 'private' stamp: 'KenD 2/17/2013 16:09'!
charBlock

	^charBlock! !

!UniFlat methodsFor: 'accessing' stamp: 'KenD 2/17/2013 16:10'!
codePointAt: anIndex
	
	^self charBlock at: anIndex! !

!UniFlat methodsFor: 'enumerating' stamp: 'KenD 2/17/2013 21:41'!
codePointDo: aBlock
	"aBlock takes each codePoint in me as an argument"

	self charBlock do: aBlock ! !

!UniFlat methodsFor: 'copying' stamp: 'KenD 2/17/2013 20:11'!
copyFrom: start to: stop 
	"Answer a UniString."

	"Handle odd case the same way as OrderedCollection"
	(stop < start) ifTrue: [^ UniFlat fromString: ''].

	((start = 1) and: (stop = self size))
	ifTrue: [^self].
	
	((1 <= start) and: [stop <= self size])
	ifTrue: [
		^(UniFlatSlice new initialize;
			charBlock: (self charBlock) startIndex: start length: (stop - start + 1))
	]
	ifFalse: [
		(stop > self size) 
		ifTrue: [self errorSubscriptBounds: stop]
		ifFalse: [self errorSubscriptBounds: start]
	]! !

!UniFlat methodsFor: 'private' stamp: 'KenD 2/17/2013 16:11'!
depth
	"I am a leaf"
	
	^0! !

!UniFlat methodsFor: 'enumerating' stamp: 'KenD 2/17/2013 19:48'!
do: aBlock
	"aBlock takes each Unicode character in me as an argument"

	self charBlock do: [ :codePoint | aBlock value: (codePoint asUniChar) ]! !

!UniFlat methodsFor: 'accessing' stamp: 'KenD 2/17/2013 16:19'!
size
	
	^ ( self charBlock size )! !

!UniFlat methodsFor: 'copying' stamp: 'KenD 2/17/2013 20:13'!
substringFrom: startIndex length: numChars

	((0 <= startIndex) and: [startIndex + numChars <= self size])
	ifTrue: [
		^(UniFlatSlice new initialize;  charBlock: (self charBlock) startIndex: startIndex length: numChars)
	]
	ifFalse: [self errorSubscriptBounds: startIndex]! !

!UniFlat methodsFor: 'initialize-release' stamp: 'KenD 2/17/2013 16:28'!
with: aCharBlock

	| blockClass |
	blockClass := aCharBlock class.
	((blockClass == ByteArray) or: [(blockClass == ShortIntegerArray) or: [ blockClass == WordArray]])
	ifTrue: [	 charBlock := aCharBlock. "Nota Bene: immutable"
			^self]
	ifFalse: [ DomainError signal: 'UniString storage must be a ByteArray, ShortIntegerArray, or WordArray']! !

!UniFlatSlice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 21:52'!
at: anIndex

	^(self codePointAt: anIndex) asUniChar "Nota Bene: #codePointAt: does the index offset"! !

!UniFlatSlice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 20:59'!
at: index put: aCharacter 

	"Answer a new rope"
	| offsetIndex startIndex endIndex |
	
	startIndex := self startIndex.
	endIndex := startIndex + self size - 1.
	offsetIndex := index +  startIndex - 1.
	
	(self size = 1)
	ifTrue:  [
		(offsetIndex = 1)
		ifTrue: [^ aCharacter asUniString ]
		ifFalse: [self errorSubscriptBounds: index]
	].
	
	(index = 1)
	ifTrue: [ ^ aCharacter asUniString , (self copyFrom: 2 to: self size)].
	
	(offsetIndex = endIndex)
	ifTrue: [ ^ (self copyFrom: 1 to: (index - 1)) , aCharacter asUniString ].
	
	^ (self copyFrom: 1 to: (index - 1)) ,
	   aCharacter asUniString ,
	   (self copyFrom: (index + 1) to: self size )! !

!UniFlatSlice methodsFor: 'private' stamp: 'KenD 2/17/2013 16:32'!
charBlock

	^charBlock ! !

!UniFlatSlice methodsFor: 'initialize-release' stamp: 'KenD 2/17/2013 16:36'!
charBlock: aCharBlock startIndex: anIndex length: numberOfChars
	
	startIndex := anIndex.
	length := numberOfChars.
	charBlock := aCharBlock.
	
	"Idiot checks"
	(aCharBlock size < (numberOfChars - anIndex + 1))
	ifTrue: [self error: 'Length exceeds max' , (numberOfChars - anIndex + 1) printString ].
	
	(numberOfChars < 0)
	ifTrue: [self error: 'Can''t have negative length' , numberOfChars].
	
	((anIndex < 1) or: (anIndex > aCharBlock size))
	ifTrue: [self errorSubscriptBounds: anIndex].
	
	^self! !

!UniFlatSlice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 16:32'!
codePointAt: anIndex

	^self charBlock at: (anIndex + startIndex - 1)! !

!UniFlatSlice methodsFor: 'enumerating' stamp: 'KenD 2/17/2013 21:41'!
codePointDo: aBlock
	"aBlock takes each codePoint in me as an argument"

	| start end charBlock |
	start := self startIndex.
	end := start + self size - 1.
	charBlock := self charBlock. "cache locally"
	start to: end do: [ :index |  aBlock value: (charBlock at: index) ]! !

!UniFlatSlice methodsFor: 'copying' stamp: 'KenD 2/17/2013 22:07'!
copyFrom: start to: stop 
	"Answer a UniFlatSlice which shares my string"
	
	| offsetStart offsetStop |
	offsetStart := start - 1 + self startIndex.
	offsetStop := stop  - 1 + self startIndex.
	
	"Handle odd case the same way as OrderedCollection"
	(stop < start) ifTrue: [^ UniFlatSlice fromString: ''].

	((1 <= start) and: [stop <= (self charBlock size)])
	ifTrue: [
		^(UniFlatSlice new initialize 
			charBlock: (self charBlock) 
			startIndex: offsetStart
			length: (stop - start + 1))
	]
	ifFalse: [
		(offsetStop > self charBlock size) 
		ifTrue: [self errorSubscriptBounds: stop]
		ifFalse: [self errorSubscriptBounds: start]
	]! !

!UniFlatSlice methodsFor: 'private' stamp: 'KenD 2/17/2013 16:36'!
depth
	"I am a leaf"

	^0! !

!UniFlatSlice methodsFor: 'enumerating' stamp: 'KenD 2/17/2013 20:07'!
do: aBlock
	"aBlock takes each Unicode character in me as an argument"

	self codePointDo: [ :codePoint |  aBlock value: (codePoint asUniChar) ]! !

!UniFlatSlice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 16:37'!
size

	^length! !

!UniFlatSlice methodsFor: 'private' stamp: 'KenD 2/17/2013 16:37'!
startIndex

	^startIndex! !

!UniSplice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 20:35'!
at: anIndex

	| leftLength |
	leftLength := self leftRope size.
	(anIndex <= leftLength)
	ifTrue:  [^leftRope  at: anIndex]
	ifFalse: [^rightRope at: (anIndex - leftLength)]! !

!UniSplice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 21:05'!
at: index put: aCharacter 

	"Answer a new UniString"
	| leftLength |
	leftLength := self leftRope size.
	(index <= leftLength)
	ifTrue: [ ^ (self leftRope at: index put: (aCharacter asUniChar)) , self rightRope]
	ifFalse: [ ^ self leftRope ,
		          (self rightRope at: (index - leftLength) put: (aCharacter asUniChar))]! !

!UniSplice methodsFor: 'private' stamp: 'KenD 2/17/2013 21:26'!
balanceAsRequired
	"Rebalance as required"

	(self depth > (UniString maxRopeDepth))
	ifTrue:  [ ^ self rebalance ]
	ifFalse: [ ^ self ]! !

!UniSplice methodsFor: 'enumerating' stamp: 'KenD 2/17/2013 21:40'!
codePointDo: aBlock
	"aBlock takes each codePoint in me as an argument"

	"recurse into the leaves, give them aBlock, and let them do the work"
	self leftRope  codePointDo: aBlock.
	self rightRope codePointDo: aBlock.! !

!UniSplice methodsFor: 'copying' stamp: 'KenD 2/17/2013 21:55'!
copyFrom: start to: stop 
	"Answer a UniString."
	
	| leftMaxIndex left right |
	"Handle odd case the same way as OrderedCollection"
	(stop < start) ifTrue: [^ UniFlat fromString: ''].

	((1 <= start) and: [stop <= self size])
	ifFalse: [
		(1 <= start) 
		ifTrue:  [self errorSubscriptBounds: stop]
		ifFalse: [self errorSubscriptBounds: start]
	].

	leftMaxIndex := self leftRope size.
	
	"Contained in left rope?"
	(stop <= leftMaxIndex)
	ifTrue: [^self leftRope copyFrom: start to: stop].
	
	"Contained in right ropt?"
	(start > leftMaxIndex)
	ifTrue: [^self rightRope copyFrom: (start - leftMaxIndex) to: (stop - leftMaxIndex)].
	
	"Spans both ropes"
	left   := self leftRope  copyFrom: start to: leftMaxIndex..
	right := self rightRope copyFrom: 1     to: (stop - leftMaxIndex).
	^UniSplice splice: left with: right

! !

!UniSplice methodsFor: 'private' stamp: 'KenD 2/17/2013 20:19'!
depth
	
	^depth! !

!UniSplice methodsFor: 'enumerating' stamp: 'KenD 2/17/2013 21:43'!
do: aBlock
	"aBlock takes each UniChar in me as an argument"

	"recurse into the leaves, give them aBlock, and let them do the work"
	self leftRope  do: aBlock.
	self rightRope do: aBlock.! !

!UniSplice methodsFor: 'private' stamp: 'KenD 2/17/2013 20:19'!
leftRope
	
	^leftRope! !

!UniSplice methodsFor: 'private' stamp: 'KenD 2/17/2013 20:19'!
rightRope
	
	^rightRope! !

!UniSplice methodsFor: 'accessing' stamp: 'KenD 2/17/2013 20:36'!
size

	^totalLength! !

!UniSplice methodsFor: 'initialize-release' stamp: 'KenD 2/17/2013 20:32'!
withLeft: aRope andRight: anotherRope

	leftRope := aRope asUniString .
	rightRope := anotherRope asUniString.
	totalLength := aRope size + anotherRope size.
	
	"Common special cases to optimize"
	
	"Meld two short flat ropes"
	(UniSplice shouldMeld: leftRope with: rightRope)
	ifTrue: [ ^ UniFlat fromString: ((aRope asString) , (anotherRope asString))]. "'FIXME: optimize"
	
	"If left rope has short right child and right rope is short, meld them"
	((leftRope class == UniSplice )
		and: [ UniSplice shouldMeld: (leftRope rightRope) with: rightRope ])
	ifTrue: [
		^((UniSplice 
			splice: (leftRope leftRope) "LeftRope's left child"
			with: rightRope
		    ) balanceAsRequired)
	].

	"The General Case"
	
	"depth is not defined for Strings; be sure to use Ropes"
	depth := 1 + (leftRope depth max: (rightRope depth)).
	^(self balanceAsRequired)! !

!UniSplice class methodsFor: 'class initialization' stamp: 'KenD 2/17/2013 16:42'!
initialize
	"UniSplice class initialization"
"
	UniSplice initialize.
"
	MeldThreshold := 17.! !

!UniSplice class methodsFor: 'private' stamp: 'KenD 2/17/2013 16:43'!
meldThreshold
	"Meld short Unicode character sequences if same representation size and (combined lenth < meldThreshold) get melded (joined) together"

	^MeldThreshold ! !

!UniSplice class methodsFor: 'private' stamp: 'KenD 2/17/2013 16:46'!
shouldMeld: aCharBlock with: anotherCharBlock

	^((aCharBlock size + anotherCharBlock size) < self meldThreshold) 
		and: [ (aCharBlock bytesPerElement) = (anotherCharBlock bytesPerElement) ]! !

!UniSplice class methodsFor: 'instance creation' stamp: 'KenD 2/17/2013 20:29'!
splice: aUniString with: anotherUniString

	"Answer a new UniString"

	"Don't bother to concat zero length strings"
	(aUniString size = 0)
		ifTrue: [^anotherUniString asUniString ].
		
	(anotherUniString size = 0)
		ifTrue: [^aUniString asUniString].

	"Non-trivial. Answer a new instance"	
	^(self new initialize withLeft: aUniString andRight: anotherUniString) "NB: may return a FlatRope"! !

!UniString methodsFor: 'copying' stamp: 'KenD 2/17/2013 20:40'!
, aStringOrUniString
	^ (UniSplice splice: self with: aStringOrUniString).! !

!UniString methodsFor: 'converting' stamp: 'KenD 2/17/2013 15:54'!
asString

	^self stringRepresentation! !

!UniString methodsFor: 'converting' stamp: 'KenD 2/17/2013 15:54'!
asText
	"Answer a Text whose ''string'' is the receiver."

	^Text fromString: self! !

!UniString methodsFor: 'converting' stamp: 'KenD 2/17/2013 15:54'!
asUniString

	^self! !

!UniString methodsFor: 'copying' stamp: 'KenD 2/17/2013 20:41'!
copyReplaceFrom: start to: stop with: aStringOrUniString

	^((self copyFrom: 1 to: (start - 1)) , aStringOrUniString asUniString , (self copyFrom: (stop + 1) to: (self size))) ! !

!UniString methodsFor: 'debugging' stamp: 'KenD 2/17/2013 22:06'!
doesNotUnderstand: aMessage

	"See what is missing from UniStrings"
	Transcript log: (String streamContents: [:s | aMessage storeOn: s]).
	
	"Do what a String would do"
	aMessage sendTo: (self asString)! !

!UniString methodsFor: 'private' stamp: 'KenD 2/17/2013 15:58'!
first
	"Answer first index -- like Text.
	 Nota Bene  *NOT* first element"
	
	^1! !

!UniString methodsFor: 'accessing' stamp: 'KenD 2/17/2013 21:25'!
hash
	| hash |

	hash _ self species hash.
	self codePointDo: [ :codePoint | hash _ (hash + codePoint hash) hashMultiply].
	^hash! !

!UniString methodsFor: 'private' stamp: 'KenD 2/17/2013 21:23'!
isBalanced
	"Answer if the Rope is balanced"

	| fib |
	fib := UniString fibonacci.
	(self depth >= (fib size - 2))
	ifTrue:  [^false]
	ifFalse: [^ (fib at: (self depth + 2)) <= self size]! !

!UniString methodsFor: 'private' stamp: 'KenD 2/17/2013 15:58'!
last
	"Answer last index -- like Text.  
	Nota Bene  *NOT*  first element"
	
	^self size! !

!UniString methodsFor: 'printing' stamp: 'KenD 2/17/2013 16:02'!
printOn: aStream
	"Look good in the inspector"

	aStream nextPutAll: 'UniString('.
	aStream nextPut: $' .
	aStream nextPutAll: self stringRepresentation.
	aStream nextPut: $' .
	aStream nextPut: $)! !

!UniString methodsFor: 'printing' stamp: 'KenD 2/17/2013 15:55'!
printString

	^String streamContents: [:s | self printOn: s]! !

!UniString methodsFor: 'private' stamp: 'KenD 2/17/2013 21:57'!
rebalance
	"Answer a new balanced rope with my data"

	| leafNodes toExamine |
	leafNodes  := OrderedCollection new.
	toExamine := OrderedCollection new.
	toExamine addLast: self.
	"depth first"
	[toExamine size > 0] whileTrue: [
		| node |
		node := toExamine removeFirst.
		(node class == UniSplice)
		ifTrue: [
			toExamine addLast: node rightRope.
			toExamine addLast: node leftRope
		]
		ifFalse: [leafNodes addLast: node]
	].
	^ UniString merge: leafNodes start: 1 end: (leafNodes size).! !

!UniString methodsFor: 'printing' stamp: 'KenD 2/17/2013 21:35'!
stringRepresentation

	"@@@ FIXME: BOGUS. Convert to UTF-8 @@@"
	
	^String streamContents: [:s | self codePointDo: [ :codePoint | s nextPut: (codePoint asCharacter ) ]]! !

!UniString class methodsFor: 'private' stamp: 'KenD 2/17/2013 15:51'!
fibonacci

"
	self fibonacci size.
"
	^Fibonacci ! !

!UniString class methodsFor: 'instance creation' stamp: 'KenD 2/17/2013 20:44'!
fromString: aString
	"Answer a new UniString"

	(aString class == String)
	ifTrue: [	 | charBlock |
		charBlock := ByteArray new: (aString size) withAll: 0.
		1 to: (aString size) do: [ :index |
			"@@@ FIXME: BOGUS: Assumes all codePoints are u8 @@@"
			charBlock at: index put: ((aString at: index) unicodeCodePoint) 
		].
		^(UniFlat new initialize with: charBlock) 
	]
	ifFalse: [ DomainError signal: 'UniString fromString: requires a String argument' ]! !

!UniString class methodsFor: 'class initialization' stamp: 'KenD 2/17/2013 21:26'!
initialize
"
	UniString initialize.
"
	Fibonacci :=   #( 0  1  1  2  3  5  8  13  21  34  55  89  144  233  377  610  987  1597  2584  4181  6765  10946  17711  28657  46368  75025  121393  196418  317811  514229  832040  1346269  2178309  3524578  5702887  9227465  14930352  24157817  39088169  63245986  102334155  165580141  267914296  433494437  701408733  1134903170  1836311903  2971215073  4807526976  7778742049  12586269025  20365011074  32951280099  53316291173  86267571272  139583862445  225851433717  365435296162  591286729879  956722026041  1548008755920  2504730781961  4052739537881  6557470319842  10610209857723  17167680177565  27777890035288  44945570212853  72723460248141  117669030460994  190392490709135  308061521170129  498454011879264  806515533049393  1304969544928657  2111485077978050  3416454622906707  5527939700884757  8944394323791464  14472334024676221  23416728348467685  37889062373143906  61305790721611591  99194853094755497  160500643816367088  259695496911122585  420196140727489673  679891637638612258  1100087778366101931  1779979416004714189  2880067194370816120  4660046610375530309  7540113804746346429 ).
	
	MaxRopeDepth := 96.  "rebalance ropes whose depth exceeds this"! !

!UniString class methodsFor: 'private' stamp: 'KenD 2/17/2013 15:51'!
maxRopeDepth
	"Rebalance a Rope when its depth exceeds this."
"
	self fibonacci size.
"
	^MaxRopeDepth ! !

!UniString class methodsFor: 'private' stamp: 'KenD 2/17/2013 15:51'!
merge: leafNodes start: start end: end
	"Answer a balanced rope based on data from Rope\>>rebalance"

	| range middle |
	range := end - start.
	
	(range = 1)
	ifTrue: [^ leafNodes at: start].
	
	(range = 2)
	ifTrue: [^ (leafNodes at: start) , (leafNodes at: (start + 1)) ].
	
	middle := start + (range // 2).
	
	^ (self merge: leafNodes start: start end: middle ) ,
	   (self merge: leafNodes start: middle end: end)
! !

!UniString class methodsFor: 'user interface' stamp: 'KenD 2/17/2013 19:42'!
openTextEditor

"
	UniString openTextEditor.
"
	SystemWindow 
		editText: (TextModel 
			withText: (FlatRope fromString: 'Let us see what these UniString things can do.')) 
			label: 'Text Editor' 
			wrap: true! !
UniSplice initialize!
UniString initialize!
