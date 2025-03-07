"
I parse a ReadStream containing the contents of an INI file into a two level dictionary. 

I don't perform any type conversion, the keys and values of the dictionary are Strings.

## Public API and Key Messages

- IniReader on: aREadStream. Create a IniReader object using the input ReadStream.
- IniReader parse. Convert the ReadStream into a Dictionary. 

An INI file looks something like the following:

	[Section]

	key = value 
	key2 = value2 
	key with spaces = value with spaces
	key =
	
	[ Another Section ]
	key = value
   
Parsing this will create the following data structure:

	{ 'Section' -> { 'key' -> 'value'. 'key2' -> 'value2'. 'key with spaces' -> 'value with spaces', 'key' -> '' }. 'Another Section' -> { 'key' -> 'value' } }
	
Keys and values are separated by $= by default and are trimmed during parsing so that leading and 
trailing whitespace is removed. The separater can be changed with the IniReader>>>keyValueSeparator:
message. When there is only whitespace after the separator the value for the key will be an empty string.

## Internal Representation and Key Implementation Points.

    Instance Variables
	data:		Dictionary
	keyValueSeparator:	 String
	readStream:		ReadStream

"
Class {
	#name : #IniReader,
	#superclass : #Object,
	#instVars : [
		'readStream',
		'data',
		'keyValueSeparator'
	],
	#category : #'INI-Parser'
}

{ #category : #'instance creation' }
IniReader class >> on: readStream [
	"Initialize on readStream, which should be a character stream that 
	implements #next, #peek, #atEnd and (optionally) #close."

	^ self new on: readStream;
		yourself
]

{ #category : #private }
IniReader >> consumeWhitespace [
	"Strip whitespaces from the input stream."

	[ readStream atEnd not and: [ readStream peek isSeparator ] ]
		whileTrue: [ 
			readStream next ]
]

{ #category : #configuration }
IniReader >> defaultKeyValueSeparator [
	^ $=.
]

{ #category : #private }
IniReader >> expectChar: character [
	"Expect character and consume input and optional whitespace at the end,
	 throw an error otherwise."

	(self matchChar: character)
		ifFalse: [ self error: character asString, ' expected' ]
]

{ #category : #'instance creation' }
IniReader >> initialize [
	super initialize .
	data := OrderedDictionary new.
]

{ #category : #configuration }
IniReader >> keyValueSeparator [
	keyValueSeparator ifNil: [ keyValueSeparator := self defaultKeyValueSeparator  ].
	^keyValueSeparator.
]

{ #category : #configuration }
IniReader >> keyValueSeparator: aCharacter [
	keyValueSeparator := aCharacter 
]

{ #category : #private }
IniReader >> matchChar: character [
	"Tries to match character, consume input and 
	answer true if successful and consumes whitespace at the end.
	When character does not match, return false and leave stream untouched."

	^ (readStream peekFor: character)
		ifTrue: [ 
			self consumeWhitespace.
			true ]
		ifFalse: [ false ]
]

{ #category : #'instance creation' }
IniReader >> on: aReadStream [
	"Initialize on aReadStream, which should be a character stream that 
	implements #next, #peek, #atEnd and (optionally) #close."
	
	readStream := aReadStream
]

{ #category : #parsing }
IniReader >> parse [

	"Main entry point. Returns a two level dictionary of the stream contents"

	| char section keyValue |
	section := ''.

	[ readStream atEnd ] whileFalse: [ 
		self consumeWhitespace.
		char := readStream peek.
		char = $[ ifTrue: [ 
			section := self parseSection.
			data at: section put: OrderedDictionary new.
			char := readStream peek ].
		char = $; ifTrue: [ 
			self parseComment.
			char := readStream peek ].
		char = $# ifTrue: [ 
			self parseComment.
			char := readStream peek ].
		self consumeWhitespace .
		char := readStream peek.
		readStream atEnd ifFalse: [ 
			';#[' detect: [ :each | each = char ] ifNone: [ 
				keyValue := self parseKeyValuePair.
				data at: section at: (keyValue at: 1) put: (keyValue at: 2) ] ] ].
	^ data
]

{ #category : #parsing }
IniReader >> parseCharacter [
	| char |
	(char := readStream next) = $\ 
		ifFalse: [ ^ char ].
	('/"\' includes: (char := readStream next))
		ifTrue: [ ^ char ].
	('bfnrt' includes: char)
		ifTrue: [ ^ self unescapeChar: char ].
	char = $u
		ifTrue: [ ^ self parseCharacterHex ].
	char 
		ifNil: [ self error: 'invalid escape, end of file' ]
		ifNotNil: [ self error: 'invalid escape character \' , char asString ]
]

{ #category : #private }
IniReader >> parseCharacterHex [
	| value codePoint |
	value := self parseCharacterHex4Value.
	(value < 16rD800 or: [ value > 16rDBFF ])
		ifTrue: [ codePoint := value ]
		ifFalse: [ | leadSurrogate trailSurrogate |
			"Characters not in the Basic Multilingual Plane are encoded as a UTF-16 surrogate pair"
			"See https://tools.ietf.org/html/rfc7159#section-7"
			leadSurrogate := value.
			trailSurrogate := self parseTrailingSurrogateHexEscape.
			codePoint := (leadSurrogate - 16rD800) * 16r400 + (trailSurrogate - 16rDC00).
			codePoint := 16r10000 + codePoint ].
	^ Character codePoint: codePoint
]

{ #category : #private }
IniReader >> parseCharacterHex4Value [
	| value |
	value := self parseCharacterHexDigit.
	3 timesRepeat: [ 
		value := (value << 4) + self parseCharacterHexDigit ].
	^ value
]

{ #category : #private }
IniReader >> parseCharacterHexDigit [
	| digit |
	readStream atEnd 
		ifFalse: [ 
			digit := readStream next asInteger.
			(digit between: "$0" 48 and: "$9" 57)
				ifTrue: [ ^ digit - 48 ].
			(digit between: "$A" 65 and: "$F" 70)
				ifTrue: [ ^ digit - 55 ].
			(digit between: "$a" 97 and: "$f" 102)
				ifTrue: [ ^ digit - 87 ] ].
	self error: 'hex-digit expected'
]

{ #category : #parsing }
IniReader >> parseComment [
	"A comment is any line where the first non-whitespace character is a # or ;"
	
	readStream nextLine .
]

{ #category : #parsing }
IniReader >> parseKeyValuePair [
	"parse a key-value pair from a line"
	
	| key value |

	key := String streamContents: [ :stream | 
		[ readStream atEnd or: [ readStream peek = self keyValueSeparator  ] ] 
			whileFalse: [ stream nextPut: self parseCharacter ] ].
		
	(readStream peekFor: self keyValueSeparator) 
		ifFalse: [self error: ('<1s> expected' expandMacrosWith: self keyValueSeparator asString)].
		
	value := String streamContents: [ :stream | 
		[ readStream atEnd or: [ (readStream peek = Character cr) | (readStream peek = Character lf) ] ] 
			whileFalse: [ stream nextPut: self parseCharacter ] ].

	^ { key trimBoth. value trimBoth. }
]

{ #category : #parsing }
IniReader >> parseSection [
	"Get the section titles.
	
	 The readStream should be at a [  character and we want to consume everything
	 up until the ] character as the section name.
	"	
	| result |
	(readStream peekFor: $[)
		ifFalse: [ self error: '" expected' ].
	result := String streamContents: [ :stream | 
		[ readStream atEnd or: [ readStream peek = $] ] ] 
			whileFalse: [ stream nextPut: self parseCharacter ] ].
	self expectChar: $].
	^ result
]

{ #category : #private }
IniReader >> parseTrailingSurrogateHexEscape [
	(readStream next = $\ and: [ readStream next = $u ])
		ifTrue: [ ^ self parseCharacterHex4Value ]
		ifFalse: [ self error: 'trailing surrogate hex escape expected' ]
]

{ #category : #private }
IniReader >> unescapeChar: char [
	"Handle one of the named character escapes, b, f, n, r or t. Else fail."
	
	char = $b
		ifTrue: [ ^ Character backspace ].
	char = $f
		ifTrue: [ ^ Character newPage ].
	char = $n
		ifTrue: [ ^ Character lf ].
	char = $r
		ifTrue: [ ^ Character cr ].
	char = $t
		ifTrue: [ ^ Character tab ].
	self error: 'Unknown escape char: ', (String with: char)
]
