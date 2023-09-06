Class {
	#name : #IniWriterTest,
	#superclass : #TestCase,
	#category : #'INI-Parser-Tests'
}

{ #category : #support }
IniWriterTest >> newDictionary [

	^ OrderedDictionary new
]

{ #category : #tests }
IniWriterTest >> testWrite [

	| d s expected |
	d := self newDictionary
		     at: 'default' put: (self newDictionary
				      at: 'key' put: 'value';
				      yourself);
		     at: '' put: (self newDictionary
			      at: 'global' put: 'global value';
			      yourself);
		     yourself.

	s := IniWriter toString: d.

	expected := String streamContents: [ :stream |
		            stream
			            nextPutAll: 'global = global value';
			            crlf;
			            crlf;
			            nextPutAll: '[default]';
			            crlf;
			            nextPutAll: 'key = value';
			            crlf;
			            crlf ].
	self assert: s equals: expected
]

{ #category : #tests }
IniWriterTest >> testWriteMultipleSections [

	| d s expected |
	d := self newDictionary
		     at: 'default' put: (self newDictionary
				      at: 'key' put: 'value';
				      yourself);
		     at: 'subsection' put: (self newDictionary
			      at: 'overwrite' put: true;
			      yourself);
		     yourself.

	s := IniWriter toString: d.

	expected := String streamContents: [ :stream |
		            stream
			            nextPutAll: '[subsection]';
			            crlf;
			            nextPutAll: 'overwrite = true';
			            crlf;
			            crlf;
			            nextPutAll: '[default]';
			            crlf;
			            nextPutAll: 'key = value';
			            crlf;
			            crlf ].
	self assert: s equals: expected
]
