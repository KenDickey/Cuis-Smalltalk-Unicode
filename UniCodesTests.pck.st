'From Cuis 4.1 of 12 December 2012 [latest update: #1600] on 17 February 2013 at 9:58:25 pm'!
'Description Tests for UniCodes '!
!classDefinition: #UniCodesTests category: #UniCodesTests!
TestCase subclass: #UniCodesTests
	instanceVariableNames: 'flatRope longFlat shortFlat subRope concRope1 concRope2 concRope3'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'UniCodesTests'!
!classDefinition: 'UniCodesTests class' category: #UniCodesTests!
UniCodesTests class
	instanceVariableNames: ''!


!UniCodesTests commentStamp: '<historical>' prior: 0!
Tests for UniCodes -- Unicode code points!

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 21:10'!
setUp

	"Set up class variables (before each test)."
	"This could be done once, as UniStrings are immutable"
	| testString |
	testString := '1234abcd5678hijk90lm'.
	flatRope := UniFlat fromString: testString.
	"Build SubRope by hand as we need to test constructor"
	subRope := UniFlatSlice new initialize; charBlock: (flatRope charBlock) startIndex: 5 length: 12.
	concRope1 := UniSplice splice: subRope with: (' new string tail' asUniString).
	concRope2 := UniSplice splice: concRope1 with:concRope1.
	concRope3 := UniSplice splice: ('Now is the time ' asUniString) with: subRope.
	longFlat  := UniFlat fromString: '123456789012345678901234567890'. "long"
	shortFlat := UniFlat fromString: 'short'. "short"! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 17:19'!
testUniCharCreation
	"Can we create instances of UniChar?"

	| uc8 uc16 uc32 |
	uc8 := 16r34 asUniChar.
	uc16 := 16r1234 asUniChar.
	uc32 := 16r1234567 asUniChar.
	
	self assert: (uc8  class == UChar8).
	self assert: (uc16 class == UChar16).
	self assert: (uc32 class == UChar32).
	self assert: (uc8 codePoint = 16r34).
	self assert: (uc16 codePoint = 16r1234).
	self assert: (uc32 codePoint = 16r1234567).
	uc8 := $a asUniChar.
	self assert: (uc8 class == UChar8).
	self assert: (uc8 codePoint = 97).
	self assert: (($A asUniChar codePoint) = ($A asciiValue)).  "Generally true for ASCII; mostly true for so8859s15".
	
	
	! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 21:10'!
testUniStringAccess
	"Can we get there from here?"

	self assert: ((flatRope at: 5) asCharacter = $a).
	self assert: ((subRope at: 2) asCharacter = $b).
	self assert: ((concRope1 at: 2) asCharacter = $b).
	self assert: ((concRope1 at: 14) asCharacter = $n).
	self assert: ((concRope2 at: 5) asCharacter = $5).
	self assert: ((concRope2 at: (concRope1 size + 5)) asCharacter = $5).
	self assert: ((concRope3 at: 5) asCharacter = $i).
	self assert: ((concRope3 at: (16 + 5)) asCharacter = $5).! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 17:32'!
testUniStringCreation
	"Can we create instances of UniString?"

	| testString |
	testString :=  'A big little test'.
	self assert: ((UniString fromString: testString) asString = testString).! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 20:57'!
testUniStringMeld
	"Do we meld short ropes?"

	self assert: ( (shortFlat , shortFlat) class == UniFlat ).
	self deny: ( (longFlat , shortFlat) class == UniFlat ).
	self deny: ( (shortFlat , longFlat) class == UniFlat ).
	self deny: ( (longFlat , longFlat) class == UniFlat ).

	self assert: ( (shortFlat , shortFlat) depth = 0).
	self assert: ( (longFlat ,  shortFlat) depth = 1).
	self assert: ( (shortFlat , longFlat)  depth = 1).
	self assert: ( (longFlat ,  longFlat , longFlat) depth = 2 ).
	self assert: ( (longFlat , shortFlat , longFlat) depth = 2 ).
	self assert: ( (longFlat , shortFlat , shortFlat) depth = 1 ).
	self assert: ( (shortFlat , longFlat ,  longFlat) depth = 2 ).
	self assert: ( (shortFlat , shortFlat , longFlat) depth = 1 ).
	self assert: ( (shortFlat , longFlat , shortFlat) depth = 2 ).
	self assert: ( (shortFlat , shortFlat , shortFlat) depth = 0 ).
! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 20:57'!
testUniStringMutation
	"Can we make a change which makes a difference?"

	self assert: ((flatRope at: 1 put: $0) asString = '0234abcd5678hijk90lm' ).
	self assert: ((flatRope at: (flatRope size) put: $0) asString = '1234abcd5678hijk90l0'  ).
	self assert: ((flatRope at: 5 put: $5) asString = '12345bcd5678hijk90lm' ).
	
	self assert: ((subRope at: 5 put: $e) asString =  'abcde678hijk' ).
	self assert: ((subRope at: 1 put: $0) asString = '0bcd5678hijk' ).
	self assert: ((subRope at: (subRope size) put: $0) asString = 'abcd5678hij0' ).
	
	self assert: ((concRope1 at: 2 put: $0) asString =  'a0cd5678hijk new string tail' ).
	self assert: ((concRope1 at: 20 put: $0) asString =  'abcd5678hijk new st0ing tail' ).
	self assert: ((concRope1 at: (concRope1 size) put: $0) asString =  'abcd5678hijk new string tai0' ).

	self assert: ((concRope3 at: 2 put: $0) asString =   'N0w is the time abcd5678hijk' ).
	self assert: ((concRope3 at: 20 put: $0) asString =   'Now is the time abc05678hijk' ).
	self assert: ((concRope3 at: (concRope1 size) put: $0) asString =   'Now is the time abcd5678hij0' ).
! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 21:47'!
testUniStringPrint
	"What does it look like?"

	self assert: ((flatRope asString) = '1234abcd5678hijk90lm').
	self assert: ((subRope asString) = 'abcd5678hijk').
	self assert: ((concRope1 asString) = 'abcd5678hijk new string tail').
	self assert: ((concRope2 asString) =
				 'abcd5678hijk new string tailabcd5678hijk new string tail').
	self assert: ((concRope3 asString) =  'Now is the time abcd5678hijk').
	
	self assert: ((flatRope printString) =  'UniString(''1234abcd5678hijk90lm'')' ).
	self assert: ((subRope printString) =  'UniString(''abcd5678hijk'')' ).
	self assert: ((concRope1 printString) =  'UniString(''abcd5678hijk new string tail'')' ).
	self assert: ((concRope2 printString) =
				  'UniString(''abcd5678hijk new string tailabcd5678hijk new string tail'')' ).
	self assert: ((concRope3 printString) =  'UniString(''Now is the time abcd5678hijk'')').
! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 21:58'!
testUniStringRebalance

	| fr1 fr2 t1 t2 |
	fr1 := UniFlat fromString: '12345678901234567890'.
	fr2 := UniFlat fromString: 'abcdefghijklmnopqrstuvwxyz'.
	t1 := (fr1, fr2, fr1, fr2, fr1, fr2, fr1, fr2).
	t2 := (fr1, concRope1, fr2, concRope2, fr1, fr2, fr1, fr2, concRope3, fr1, fr2).

	self assert: ( t1 depth = 7 ).
	self assert: ( t1 rebalance depth = 3 ).
	self assert: ( t2 depth = 11 ).
	self assert: ( t2 rebalance depth = 4 ).! !

!UniCodesTests methodsFor: 'testing' stamp: 'KenD 2/17/2013 21:08'!
testUniSubstring
	"Can we copy?"

	self assert: ((flatRope copyFrom: 5 to: 8) asString = 'abcd').
	self assert: ((flatRope copyFrom: 1 to: (flatRope size)) == flatRope). "return self"
	self should: [flatRope copyFrom: -3 to: 5] raise: Error.
	self should: [flatRope copyFrom: 2 to: 55] raise: Error.
	self assert: ((flatRope copyFrom: 10 to: 5) asString = '' ).

	self assert: ((subRope copyFrom: 5 to: 8) asString = '5678').
	self should: [subRope copyFrom: -3 to: 5] raise: Error.
	self should: [subRope copyFrom: 2 to: 55] raise: Error.
	self assert: ((subRope copyFrom: 10 to: 5) asString = '' ).


	"from left rope"
	self assert: ((concRope1 copyFrom: 2 to:5) asString = 'bcd5').
	"fron right rope"
	self assert: ((concRope1  copyFrom: 14 to: 16) asString = 'new').
	"copy spans both ropes"
	self assert: ((concRope1  copyFrom: 9 to: 16) asString = 'hijk new').

	self should: [concRope1 copyFrom: -3 to: 5] raise: Error.
	self should: [concRope1 copyFrom: 2 to: 55] raise: Error.
	self assert: ((concRope1 copyFrom: 10 to: 5) asString = '' ).

	"span above meld trreshold"
	self assert: ((concRope2 copyFrom: 22 to:30) asString = 'ng tailab').
	self assert: ((concRope3 copyFrom: 12 to: 20) asString =  'time abcd').
	"span is less than meld threshold"
	self assert: ((concRope2 copyFrom: 26 to: 30) asString = 'ailab').
	self assert: ((concRope3 copyFrom: 14 to: 18) asString =  'me ab').
	
	self assert: ((concRope1 copyReplaceFrom: 9 to: 19  with: '@@ new stuff @@') asString
					=  'abcd5678@@ new stuff @@ring tail' ).
	self assert: ((concRope1 copyReplaceFrom: 9 to: 9  with: '@@ new stuff @@') asString
					=  'abcd5678@@ new stuff @@ijk new string tail' ).

! !
