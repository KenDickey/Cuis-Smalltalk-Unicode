'From Cuis 4.1 of 12 December 2012 [latest update: #1620] on 5 March 2013 at 5:21:33 pm'!

!BitBlt methodsFor: 'copying' stamp: 'KenD 3/4/2013 21:12'!
basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font kern: kernDelta

	destY _ aPoint y.
	destX _ aPoint x.

	"the following are not really needed, but theBitBlt primitive will fail if not set"
	sourceX ifNil: [sourceX _ 100].
	width ifNil: [width _ 100].

	(aString isKindOf: UniString)
	ifTrue:  [ aString displayOn: self destForm from: startIndex to: stopIndex at: aPoint]
	ifFalse: [
		self primDisplayString: aString from: startIndex to: stopIndex
			map: font characterToGlyphMap xTable: font xTable
			kern: kernDelta.
	].
	^ destX@destY.
! !
