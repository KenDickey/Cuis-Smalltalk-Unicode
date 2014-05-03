'From Cuis 4.2 of 25 July 2013 [latest update: #1978] on 2 May 2014 at 8:52:29.402264 pm'!

!String class methodsFor: 'as yet unclassified' stamp: 'KenD 4/3/2013 14:59'!
defaultFontClass

	^StrikeFont! !


!Text methodsFor: '*unicode' stamp: 'KenD 4/3/2013 15:38'!
asUniString
	"Answer my string as a UniString"
	
	^ self string asUniString ! !


!GrafPort methodsFor: 'text' stamp: 'jmv 5/1/2014 16:15'!
basicDisplayString: aString from: startIndex to: stopIndex at: aPoint strikeFont: font

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
			kern: font baseKern ].
	^ destX@destY! !


!SequenceableCollection methodsFor: 'private' stamp: 'KenD 4/8/2013 19:35'!
copyReplaceAll: oldSubstring with: newSubstring asTokens: ifTokens
	"Answer a copy of the receiver in which all occurrences of
	oldSubstring have been replaced by newSubstring.
	ifTokens (valid for Strings only) specifies that the characters
	surrounding the recplacement must not be alphanumeric.
		Bruce Simth,  must be incremented by 1 and not 
	newSubstring if ifTokens is true.  See example below. "

	| aString startSearch currentIndex endIndex |
	(ifTokens and: [(self isKindOf: String) not])
		ifTrue: [((self isKindOf: Text) or: [self isKindOf: UniString])
			 ifFalse: [
				self error: 'Token replacement only valid for Strings']].
	aString _ self.
	startSearch _ 1.
	[(currentIndex _ aString indexOfSubCollection: oldSubstring startingAt: startSearch)
			 > 0]
		whileTrue: 
		[endIndex _ currentIndex + oldSubstring size - 1.
		(ifTokens not
			or: [(currentIndex = 1
					or: [(aString at: currentIndex-1) isGenerallyValidInIdentifiers not])
				and: [endIndex = aString size
					or: [(aString at: endIndex+1) isGenerallyValidInIdentifiers not]]])
			ifTrue: [aString _ aString
					copyReplaceFrom: currentIndex
					to: endIndex
					with: newSubstring.
				startSearch _ currentIndex + newSubstring size]
			ifFalse: [
				ifTokens 
					ifTrue: [startSearch _ currentIndex + 1]
					ifFalse: [startSearch _ currentIndex + newSubstring size]]].
	^ aString
	
! !


!Text methodsFor: 'converting' stamp: 'KenD 4/5/2013 14:16'!
replaceFrom: start to: stop withString: replacementString attributes: attributesArray startingAt: repStart 
	"This destructively replaces elements from start to stop in the receiver starting at index, repStart, in replacementCollection. 
	Do it to both the string and the runs.
	The size does not change"

	| newRepRuns |
	string := string replaceFrom: start to: stop with: replacementString startingAt: repStart.
	newRepRuns _ RunArray new: stop-start+1 withAll: attributesArray.
	self privateSetRuns: (runs copyReplaceFrom: start to: stop with: newRepRuns).
	"Ensure the ParagraphAttributes invariant for the interval that could have been affected"
	self fixParagraphAttributesFrom: start to: start + replacementString size - 1! !

!Text methodsFor: 'emphasis' stamp: 'jmv 5/1/2014 16:16'!
fontIfApplying: textAttributes
	"Answer the font for characters as specified by the argument."

	self withAttributeValues: textAttributes do: [ :familyName :pointSize :emphasis :color :alignment :characterStyle :paragraphStyle |
		^((AbstractFont familyName: familyName pointSize: pointSize) ifNil: [ string class defaultFontClass default baseFont ])
			emphasized: emphasis ]! !


!TextEditor methodsFor: 'accessing-selection' stamp: 'KenD 4/5/2013 14:26'!
selection
	"Answer the text that is currently selected."

	| t firstIndex lastIndex |
	t _ model actualContents.
	firstIndex _ self startIndex.
	lastIndex _ self stopIndex - 1.
	(firstIndex = 1 and: [ lastIndex = t size ])
		ifTrue: [ ^t ].
	(t string isKindOf: UniString)
	ifTrue: [^ ( t string copyFrom: firstIndex to: lastIndex) asText  ]
	ifFalse: [
		^Text streamContents: [ :strm |
			"Multiple selection"
			selectionStartBlocks with: selectionStopBlocks do: [ :startBlock :stopBlock | | toAppend |
				toAppend _ t copyFrom: startBlock stringIndex to: stopBlock stringIndex - 1.
				toAppend size > 0 ifTrue: [
					strm nextPutAll: toAppend.
					strm withAttributes: (toAppend attributesAt: toAppend size) do: [ strm newLine ]]].
			"Regular selection"
			strm nextPutAll: ( t copyFrom: firstIndex to: lastIndex ) ]
	]! !


!FormCanvas methodsFor: 'drawing-text' stamp: 'KenD 5/2/2014 20:31'!
drawString: aString from: firstIndex to: lastIndex at: aPoint font: fontOrNil color: aColor

	| p1 font insideColor |
	"Don't waste any time if NOP"
	lastIndex = 0 ifTrue: [
		^self ].
	p1 _ currentTransformation intTransform: aPoint.
	(aString isKindOf: UniString) ifTrue: [
		^(aString copyFrom: firstIndex to: lastIndex) displayOn: form at: p1 ].
	port colorMap: nil.
	font _ fontOrNil ifNil: [ AbstractFont default ].
	insideColor _ shadowColor ifNil: [ aColor ].
	port
		displayString: aString
		from: firstIndex
		to: lastIndex
		at: p1
		strikeFont: font
		color: insideColor! !

