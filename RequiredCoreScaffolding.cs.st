'From Cuis 4.2 of 25 July 2013 [latest update: #1978] on 1 May 2014 at 4:17:44.01451 pm'!

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


!CharacterScanner methodsFor: 'scanning' stamp: 'jmv 5/1/2014 16:14'!
scanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernValue
	"Primitive. This is the inner loop of text display--but see
	scanCharactersFrom: to:rightX: which would get the string,
	stopConditions and displaying from the instance. March through source
	String from startIndex to stopIndex. If any character is flagged with a
	non-nil entry in stops, then return the corresponding value. Determine
	width of each character from xTable, indexed by map.
	If dextX would exceed rightX, then return stops at: 258.
	Advance destX by the width of the character. If stopIndex has been
	reached, then return stops at: 257. Optional.
	See Object documentation whatIsAPrimitive."
	| nextDestX char |
"	<primitive: 103>"
	lastIndex _ startIndex.
	[ lastIndex <= stopIndex ]
		whileTrue: [
			char _ sourceString at: lastIndex.
			"stops are only defined for the first 256 characters.
			If we (ever) handle Character like objects beyond those in ISO-8859-15,
			thenf #iso8859s15Code shound answer nil!!"
			char iso8859s15Code ifNotNil: [ :code |
				(stops at: code + 1) ifNotNil: [ :stop | ^stop ]].
			nextDestX _ destX + (font widthOf: char).
			nextDestX > rightX ifTrue: [
				^stops at: CharacterScanner crossedXCode ].
			destX _ nextDestX.
			lastIndex _ lastIndex + 1 ].
	lastIndex _ stopIndex.
	^ stops at: CharacterScanner endOfRunCode! !


!Text methodsFor: 'emphasis' stamp: 'jmv 5/1/2014 16:16'!
fontIfApplying: textAttributes
	"Answer the font for characters as specified by the argument."

	self withAttributeValues: textAttributes do: [ :familyName :pointSize :emphasis :color :alignment :characterStyle :paragraphStyle |
		^((AbstractFont familyName: familyName pointSize: pointSize) ifNil: [ string class defaultFontClass default baseFont ])
			emphasized: emphasis ]! !


!FormCanvas methodsFor: 'drawing-text' stamp: 'jmv 5/1/2014 16:16'!
drawString: aString from: firstIndex to: lastIndex at: aPoint font: fontOrNil color: aColor

	| p1 font insideColor |
	"Don't waste any time if NOP"
	lastIndex = 0 ifTrue: [
		^self ].
	p1 _ currentTransformation intTransform: aPoint.
	(aString isKindOf: UniString) ifTrue: [
		^(aString copyFrom: firstIndex to: lastIndex) displayOn: form at: p1 ].	port colorMap: nil.
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

