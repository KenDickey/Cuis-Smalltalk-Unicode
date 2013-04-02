'From Cuis 4.1 of 12 December 2012 [latest update: #1626] on 6 March 2013 at 5:04:01 pm'!

!String class methodsFor: 'as yet unclassified' stamp: 'jmv 3/6/2013 16:50'!
defaultFontClass
	^StrikeFont! !


!BitBlt methodsFor: 'private' stamp: 'jmv 3/6/2013 15:35'!
installStrikeFont: aStrikeFont foregroundColor: foregroundColor

	| lastSourceDepth targetColor sourceDepth destDepth |
	aStrikeFont class = UniTestFont ifTrue: [ ^self ].
	sourceForm ifNotNil: [ lastSourceDepth _ sourceForm depth ].
	sourceForm _ aStrikeFont glyphs.
	sourceDepth _ sourceForm depth.
	destDepth _ destForm depth.
	"Ignore any halftone pattern since we use a color map approach here"
	halftoneForm _ nil.
	sourceY _ 0.
	height _ aStrikeFont height.

	sourceDepth = 1 ifTrue: [
		self combinationRule: Form paint.
		(colorMap isNil or: [ lastSourceDepth ~= sourceDepth ]) ifTrue: [
			"Set up color map for a different source depth (color font)"
			"Uses caching for reasonable efficiency
			Warning: We are not considering that destDepth could change too, requiring a new colormap
			This seems not to cause any problems..."
			colorMap _ self cachedFontColormapFrom1BitTo: destDepth.
			colorMap at: 1 put: (destForm pixelValueFor: Color transparent)].
		colorMap at: 2 put: (destForm pixelValueFor: foregroundColor) ]
	
	ifFalse: [
		"Enable subpixel rendering if requested, but never for translucent text."
		(Preferences subPixelRenderFonts and: [ foregroundColor = Color black or: [ 
				Preferences subPixelRenderColorFonts and: [ foregroundColor isOpaque ]]]) ifTrue: [
			destDepth > 8 ifTrue: [
				"rgbMul is equivalent to component alpha blend if text is black (only faster, hehe)"
				self combinationRule: 37.		"rgbMul"
				colorMap _ (foregroundColor ~= Color black or: [
						destDepth = 32 and: [ destForm ~~ Display or: [Preferences properDisplayAlphaForFonts] ]]) ifTrue: [
					"rgbMul / rgbAdd IS component alpha blend for any color of text (neat trick, eh!!)"
					"This colorMap is to be used on the second pass with rule 20 (rgbAdd)
					See #displayString:from:to:at:strikeFont:kern:"
					"Note: In 32bpp, if we want the correct alpha in the result, we need the second pass, as the destination could have transparent pixels, 
					and we need to add to the alpha channel"
					self colorConvertingMap: foregroundColor from: sourceDepth to: destDepth keepSubPixelAA: true]]
			ifFalse: [
				self combinationRule: 25.		"Paint"
				targetColor _ foregroundColor = Color black ifFalse: [ foregroundColor ].
				colorMap _ self colorConvertingMap: targetColor from: sourceDepth to: destDepth keepSubPixelAA: true]]
		ifFalse: [
			"Do not use rule 34 for 16bpp display. TTCFont uses it, but it builds a glyphs cache for each color used!!"
			self combinationRule: (destDepth = 32 ifTrue: [34 "alphaBlendScaled"] ifFalse: [25 "Paint"]).
			colorMap _ self colorConvertingMap: foregroundColor from: sourceDepth to: destDepth keepSubPixelAA: false]].! !


!Character methodsFor: 'accessing' stamp: 'jmv 3/5/2013 21:57'!
asciiValue
	"Answer the value of the receiver that represents its ISO 8859-15 encoding.
	This is the same as ASCII for the first 128 characters."

	^value! !


!CharacterScanner methodsFor: 'scanning' stamp: 'jmv 3/5/2013 22:02'!
scanCharactersFrom: startIndex to: stopIndex in: sourceString rightX: rightX stopConditions: stops kern: kernDelta
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
			For Unicode Code Points above 255, please answer nil!!"
			char iso8859s15Code ifNotNil: [ :code |
				(stops at: code + 1) ifNotNil: [ :stop | ^stop ]].

			"Note: The following is querying the font about the width
			since the primitive may have failed due to a non-trivial
			mapping of characters to glyphs or a non-existing xTable."
			nextDestX _ destX + (font widthOf: char).
			nextDestX > rightX ifTrue: [ ^stops at: CharacterScanner crossedXCode ].
			destX _ nextDestX + kernDelta.
			lastIndex _ lastIndex + 1 ].
	lastIndex _ stopIndex.
	^stops at: CharacterScanner endOfRunCode! !


!CharacterTest methodsFor: 'UTF-8 conversion' stamp: 'jmv 3/5/2013 22:07'!
testSomeLatinCharsToUtf8
	"
	CharacterTest new testSomeLatinCharsToUtf8
	"
	| characters bytes |
	characters _ 'áåæñÆ¥ü' readStream.
	bytes _ ByteArray streamContents: [ :strm |
		[ characters atEnd ] whileFalse: [
			Character
				evaluate: [ :byte | strm nextPut: byte ]
				withUtf8BytesOfUnicodeCodePoint: characters next unicodeCodePoint ]].
	self assert: bytes hex = 'C3A1C3A5C3A6C3B1C386C2A5C3BC'! !


!FormCanvas methodsFor: 'drawing-text' stamp: 'jmv 3/6/2013 17:00'!
drawString: aString from: firstIndex to: lastIndex at: aPoint font: fontOrNil color: c kern: kernOrNil

	| p1 font kern |
	p1 _ currentTransformation transform: aPoint.
	(aString isKindOf: UniString) ifTrue: [
		^(aString copyFrom: firstIndex to: lastIndex) displayOn: form at: p1 ].
	port colorMap: nil.
	font _ fontOrNil ifNil: [ StrikeFont default ].
	kern _ kernOrNil ifNil: [ font baseKern negated ].
	"Slight optimization when there's nothing to do."
	port clipHeight = 0 ifTrue: [^self].
	port clipWidth = 0 ifTrue: [^self].
	port installStrikeFont: font foregroundColor: (shadowColor ifNil: [ c ]).
	port
		displayString: aString
		from: firstIndex
		to: lastIndex
		at: p1
		strikeFont: font
		kern: kern! !


!Text methodsFor: 'emphasis' stamp: 'jmv 3/6/2013 16:51'!
fontIfApplying: textAttributes
	"Answer the font for characters as specified by the argument.
	Note: Does -not- include kern."

	self withFormattingAttributeValues: textAttributes do: [ :familyName :pointSize :emphasis :kern :color :alignment :characterStyle :paragraphStyle |
		^((AbstractFont familyName: familyName pointSize: pointSize) ifNil: [ string class defaultFontClass default baseFont ])
			emphasized: emphasis ]! !

!methodRemoval: Character #asciiCode!
Character removeSelector: #asciiCode!
