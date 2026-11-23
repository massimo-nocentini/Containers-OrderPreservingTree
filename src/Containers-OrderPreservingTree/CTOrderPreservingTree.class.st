"
I am a tree, or a forest, given by the relation from each child to its parent. I remember the order in which the pairs were added, and I enumerate the children of a node in that order. The roots are ordered by the index of one of their pairs, not always the first one added.

## Building

- `parent:child:` adds a pair. It signals an `Error` when the child has another parent already.
- `parent:children:` adds a pair for each child of a collection.
- `parent:child:onCycleDo:` adds a pair and, when the parent descends from the child, evaluates the block with the cycle, a chain of `ValueLink` objects that starts and ends with the child.

## Looking at me

- `roots`, `leaves` and `asArray` answer arrays of nodes, the last one in preorder.
- `children` answers a dictionary from each node to the array of its children, and `parents` one from each child to its parent.
- `do:`, `associationsDo:`, `pre:post:` and `withIndexDo:` enumerate me. The blocks of `pre:post:` take a node and its level: the first before the children of the node, the second after them, with what the first block answered as its second argument.
- `select:` answers a new tree, without the nodes for which the block, of a child and its parent, answers false, and without their descendants. A root is given as its own parent, and one without any kept child is left out too.

```smalltalk
| tree |
tree := CTOrderPreservingTree new
	parent: 3 child: 4;
	parent: 4 child: 6;
	parent: 3 child: 5;
	yourself.
tree roots. ""#(3)""
tree asArray. ""#(3 4 6 5)""
tree leaves. ""#(6 5)""
tree children at: 3 ""#(4 5)""
```

My instance variable `parent` is an `IdentityDictionary` from each child to an association, whose key is the parent and whose value is the index of the pair.
"
Class {
	#name : #CTOrderPreservingTree,
	#superclass : #Object,
	#instVars : [
		'parent'
	],
	#category : #'Containers-OrderPreservingTree'
}

{ #category : #accessing }
CTOrderPreservingTree >> asArray [

	^ Array streamContents: [ :aStream | 
		  self do: [ :each | aStream nextPut: each ] ]
]

{ #category : #enumerating }
CTOrderPreservingTree >> associationsDo: aBlock [

	self do: [ :each | 
		parent
			at: each
			ifPresent: [ :anAssoc | aBlock value: anAssoc key -> each ] ]
]

{ #category : #accessing }
CTOrderPreservingTree >> children [

	^ self children: [ :anAssoc | anAssoc key ]
]

{ #category : #accessing }
CTOrderPreservingTree >> children: aBlock [

	| child |
	child := IdentityDictionary new.

	parent keysAndValuesDo: [ :aChild :anAssoc | 
		| children |
		children := child
			            at: anAssoc key
			            ifAbsentPut: [ self newCollection ].

		anAssoc key ~~ aChild ifTrue: [ 
			children add: aChild -> anAssoc value ].

		child at: aChild ifAbsentPut: [ self newCollection ] ].

	child keysDo: [ :each | 
		| children |
		children := (child at: each) collect: aBlock as: Array.

		child at: each put: children ].

	^ child
]

{ #category : #accessing }
CTOrderPreservingTree >> childrenWithIndexes [

	^ self children: [ :each | each ]
]

{ #category : #enumerating }
CTOrderPreservingTree >> do: aBlock [

	self pre: aBlock post: [ :anObj |  ]
]

{ #category : #initialization }
CTOrderPreservingTree >> initialize [

	super initialize.

	parent := IdentityDictionary new
]

{ #category : #testing }
CTOrderPreservingTree >> isEmpty [

	^ self size isZero
]

{ #category : #accessing }
CTOrderPreservingTree >> leaves [

	| children |
	children := self children.

	^ Array streamContents: [ :aStream | 
		  self do: [ :each | 
			  (children at: each) ifEmpty: [ aStream nextPut: each ] ] ]
]

{ #category : #accessing }
CTOrderPreservingTree >> newCollection [

	^ SortedCollection sortUsing: [ :assoc :anotherAssoc | 
		  assoc value < anotherAssoc value ]
]

{ #category : #accessing }
CTOrderPreservingTree >> parent: aParent child: aChild [

	parent
		at: aChild
		ifPresent: [ :anAssoc | 
		aParent == anAssoc key ifFalse: [ Error signal ] ]
		ifAbsentPut: [ 
			| order |
			order := parent size + 1.
			aParent -> order ]
]

{ #category : #accessing }
CTOrderPreservingTree >> parent: aParent child: aChild onCycleDo: aBlock [

	| cycle each detected |
	self parent: aParent child: aChild.

	detected := false.
	cycle := aChild ~~> nil.
	[ 
	detected not and: [ 
		each := cycle value.
		parent includesKey: each ] ] whileTrue: [ 
		cycle := (parent at: each) key ~~> cycle.
		cycle value == aChild ifTrue: [ 
			aBlock value: cycle reversed.
			detected := true ] ]
]

{ #category : #accessing }
CTOrderPreservingTree >> parent: aParent children: aCollection [

	aCollection do: [ :each | self parent: aParent child: each ]
]

{ #category : #accessing }
CTOrderPreservingTree >> parent: aChild ifAbsent: aBlock [

	^ parent
		  at: aChild
		  ifPresent: [ :anAssoc | anAssoc key ]
		  ifAbsent: aBlock
]

{ #category : #accessing }
CTOrderPreservingTree >> parents [

	| allParents |
	allParents := IdentityDictionary new.

	parent keysAndValuesDo: [ :aChild :anAssoc | 
		allParents at: aChild put: anAssoc key ].

	^ allParents
]

{ #category : #enumerating }
CTOrderPreservingTree >> pre: preBlock post: postBlock [

	| children |
	children := self children.

	self roots do: [ :aRoot | 
		self
			pre: preBlock
			post: postBlock
			parent: aRoot
			allChildren: children
			level: 0 ]
]

{ #category : #enumerating }
CTOrderPreservingTree >> pre: preBlock post: postBlock parent: aParent allChildren: children level: aLevel [

	| carry |
	carry := preBlock cull: aParent cull: aLevel.

	(children at: aParent)
		select: [ :aChild | aChild ~~ aParent ]
		thenDo: [ :aChild | 
			self
				pre: preBlock
				post: postBlock
				parent: aChild
				allChildren: children
				level: aLevel + 1 ].

	postBlock cull: aParent cull: carry cull: aLevel
]

{ #category : #enumerating }
CTOrderPreservingTree >> pre: preBlock post: postBlock withIndex: anIndex parent: aParent allChildren: children [

	| carry |
	carry := preBlock value: aParent value: anIndex.

	(children at: aParent) do: [ :anAssoc | 
		self
			pre: preBlock
			post: postBlock
			withIndex: anAssoc value
			parent: anAssoc key
			allChildren: children ].

	postBlock cull: aParent cull: anIndex cull: carry
]

{ #category : #accessing }
CTOrderPreservingTree >> roots [

	| roots alreadySeen |
	roots := self newCollection.

	alreadySeen := IdentitySet new.

	parent valuesDo: [ :anAssoc | 
		| aParent |
		aParent := anAssoc key.
		((alreadySeen includes: aParent) or: [ 
			 parent
				 at: aParent
				 ifPresent: [ :p | p key ~~ aParent ]
				 ifAbsent: [ false ] ]) ifFalse: [ 
			roots add: anAssoc.
			alreadySeen add: aParent ] ].

	^ roots collect: [ :anAssoc | anAssoc key ] as: Array
]

{ #category : #enumerating }
CTOrderPreservingTree >> select: aBlock [

	| tree children |
	children := self children.

	tree := self class new.

	self roots
		select: [ :each | aBlock cull: each cull: each ]
		thenDo: [ :each | 
			self
				select: aBlock
				parent: each
				allChildren: children
				tree: tree ].

	^ tree
]

{ #category : #enumerating }
CTOrderPreservingTree >> select: aBlock parent: aParent allChildren: children tree: tree [

	(children at: aParent)
		select: [ :aChild | aBlock cull: aChild cull: aParent ]
		thenDo: [ :aChild | 
			tree parent: aParent child: aChild.

			self
				select: aBlock
				parent: aChild
				allChildren: children
				tree: tree ]
]

{ #category : #accessing }
CTOrderPreservingTree >> size [

	^ self asArray size
]

{ #category : #enumerating }
CTOrderPreservingTree >> withIndexDo: aBlock [

	self withIndexPre: aBlock withIndexPost: [ :anObj :i |  ]
]

{ #category : #enumerating }
CTOrderPreservingTree >> withIndexPre: preBlock withIndexPost: postBlock [

	| roots |
	roots := self roots.

	roots withIndexDo: [ :aRoot :i | 
		self
			pre: preBlock
			post: postBlock
			withIndex: i - roots size
			parent: aRoot
			allChildren: self childrenWithIndexes ]
]
