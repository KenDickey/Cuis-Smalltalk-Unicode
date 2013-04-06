'From Cuis 4.1 of 12 December 2012 [latest update: #1661] on 3 April 2013 at 2:47:25 pm'!

!GrafPort methodsFor: 'text' stamp: 'KenD 4/3/2013 14:47'!
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
	^ destX@destY! !


!String class methodsFor: 'as yet unclassified' stamp: 'KenD 4/3/2013 14:59'!
defaultFontClass

	^StrikeFont! !


!CharacterScanner methodsFor: 'scanning' stamp: 'KenD 4/3/2013 14:56'!
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
	"<primitive: 103>"
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


!GrafPort methodsFor: 'text' stamp: 'KenD 4/3/2013 15:03'!
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
	^ destX@destY! !

!GrafPort methodsFor: 'private' stamp: 'KenD 4/3/2013 14:52'!
installStrikeFont: aStrikeFont foregroundColor: foregroundColor

	| targetColor sourceDepth destDepth |
	aStrikeFont class = UniTestFont ifTrue: [ ^self ].
	sourceForm _ aStrikeFont glyphs.
	sourceDepth _ sourceForm depth.
	destDepth _ destForm depth.
	halftoneForm _ nil.	"Don't use fillColor. Use a more powerful ColorMap"
	sourceY _ 0.
	height _ aStrikeFont height.

	sourceDepth = 1 ifTrue: [
		self combinationRule: Form paint.
		"Set up color map for a different source depth (color font)"
		"Uses caching for reasonable efficiency"
		colorMap _ self cachedFontColormapFrom1BitTo: destDepth.
		colorMap at: 1 put: (destForm pixelValueFor: Color transparent).
		colorMap at: 2 put: (destForm pixelValueFor: foregroundColor) ]
	
	ifFalse: [
		"Enable subpixel rendering if requested, but never for translucent text:
		This technique always draws opaque text. This could be added, by using an extra colormap for the rgbMul phase...
		So far, no need arised for doing so."
		(Preferences subPixelRenderFonts and: [ foregroundColor = Color black or: [ 
				Preferences subPixelRenderColorFonts and: [ foregroundColor isOpaque ]]]) ifTrue: [
			destDepth > 8 ifTrue: [
				"rgbMul is equivalent to component alpha blend if text is black (only faster, hehe)"
				self combinationRule: 37.		"rgbMul"
				colorMap _ (foregroundColor ~= Color black or: [
						destDepth = 32 and: [ destForm ~~ Display or: [Preferences properDisplayAlphaForFonts] ]]) ifTrue: [
					"rgbMul / rgbAdd IS component alpha blend for any color of text (neat trick, eh!!)"
					"This colorMap is to be used on the second pass with rule 20 (rgbAdd)
					See #displayString:from:to:at:strikeFont:color:kern:"
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
			colorMap _ self colorConvertingMap: foregroundColor from: sourceDepth to: destDepth keepSubPixelAA: false]]! !


!Text methodsFor: 'emphasis' stamp: 'KenD 4/3/2013 15:01'!
fontIfApplying: textAttributes
	"Answer the font for characters as specified by the argument.
	Note: Does -not- include kern."

	self withFormattingAttributeValues: textAttributes do: [ :familyName :pointSize :emphasis :kern :color :alignment :characterStyle :paragraphStyle |
		^((AbstractFont familyName: familyName pointSize: pointSize) 
			ifNil: [  string class defaultFontClass default baseFont ])
			emphasized: emphasis ]! !


!String class reorganize!
('instance creation' crString crlfString fromPacked: fromString: fromUtf8: fromUtf8:hex:trimLastNull: lfString newLineString readFrom: tab value:)
('examples' example)
('initialization' initialize)
('primitives' findFirstInString:inSet:startingAt: indexOfAscii:inString:startingAt: stringHash:initialHash: translate:from:to:table:)
('character collation' does:caseInsensitiveCollateBefore: does:collateAfter: does:collateBefore:)
('*unicode')
('as yet unclassified' defaultFontClass)
!

!Text methodsFor: '*unicode' stamp: 'KenD 4/3/2013 15:38'!
asUniString
	"Answer my string as a UniString"
	
	^ self string asUniString ! !


!Text reorganize!
('accessing' append: at: at:put: commandForReplaceFrom:to:with: customizeExplorerContents embeddedMorphs embeddedMorphsFrom:to: findString:startingAt: findString:startingAt:caseSensitive: lineCount prepend: rangeOf:startingAt: replaceFrom:to:with: size string)
('comparing' = hash is:)
('copying' copy copyFrom:to: copyReplaceFrom:to:with: copyReplaceTokens:with:)
('converting' asNumber asString asStringOrText asText replaceFrom:to:with:startingAt: replaceFrom:to:withString:attributes:startingAt: reversed withCuisLineEndings)
('emphasis' addAttribute: addAttribute:from:to: alignmentAt: allBold attributesAt: attributesFrom:to:do: characterStyleOrNilAt: characterStyleOrNilIfApplying: commandForAddAttribute:from:to: commandForRemoveAttributes:from:to: emphasisAt: find: font: fontAt: fontIfApplying: makeBoldFrom:to: makeSelectorBold makeSelectorBoldIn: paragraphStyleOrNilAt: paragraphStyleOrNilIfApplying: removeAttributes:from:to: runLengthFor: withFormattingAttributeValues:do:)
('printing' printOn: storeOn:)
('private' basicReplaceAttributesFrom:to:with: fixParagraphAttributesFrom:to: privateSetParagraphAttributes:from:to: privateSetRuns: runs setString:setRuns:)
('attributes' canJoin:and: hasAnyAttribute unembellished)
('user interface' edit editLabel:)
('paragraph support' encompassLine: encompassParagraph:)
('as yet unclassified' paragraphStyleChunksDo:)
('*unicode' asUniString)
!


!FormCanvas methodsFor: 'drawing-text' stamp: 'KenD 4/3/2013 16:44'!
drawString: aString from: firstIndex to: lastIndex at: aPoint font: fontOrNil color: aColor kern: kernOrNil

	| p1 font kern insideColor |
	p1 _ currentTransformation intTransform: aPoint.
	(aString isKindOf: UniString) ifTrue: [
		^(aString copyFrom: firstIndex to: lastIndex) displayOn: form at: p1 ].	port colorMap: nil.
	font _ fontOrNil ifNil: [ StrikeFont default ].
	kern _ kernOrNil ifNil: [ font baseKern negated ].
	insideColor _ shadowColor ifNil: [ aColor ].
	port
		displayString: aString
		from: firstIndex
		to: lastIndex
		at: p1
		strikeFont: font
		color: insideColor
		kern: kern! !


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

