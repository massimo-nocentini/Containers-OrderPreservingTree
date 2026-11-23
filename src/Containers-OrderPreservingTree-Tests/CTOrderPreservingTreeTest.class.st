"
A `CTOrderPreservingTreeTest` is a test class for testing the behavior of `CTOrderPreservingTree`
"
Class {
	#name : #CTOrderPreservingTreeTest,
	#superclass : #TestCase,
	#category : #'Containers-OrderPreservingTree-Tests'
}

{ #category : #tests }
CTOrderPreservingTreeTest >> testAdd [

	| tree children |
	tree := CTOrderPreservingTree new.

	tree
		parent: 3 child: 4;
		parent: 4 child: 6;
		parent: 3 child: 5;
		parent: 3 child: 2;
		parent: 5 child: 1;
		parent: 7 child: 8;
		parent: 4 child: 9.

	tree asTreePresenter open.

	children := tree children.

	self
		deny: tree isEmpty;
		assert: tree size equals: 9;
		assert: tree asArray equals: #( 3 4 6 9 5 1 2 7 8 );
		assert: tree roots equals: #( 3 7 );
		assert: (children at: 3) equals: #( 4 5 2 );
		assert: (children at: 4) equals: #( 6 9 );
		assert: (children at: 5) equals: #( 1 );
		assert: (children at: 6) equals: #(  );
		assert: (children at: 7) equals: #( 8 );
		assert: (children at: 8) equals: #(  );
		assert: (Array streamContents: [ :aStream | 
					 tree withIndexDo: [ :each :i | aStream nextPut: each -> i ] ])
		equals: { 
				(3 -> -1).
				(4 -> 1).
				(6 -> 2).
				(9 -> 7).
				(5 -> 3).
				(1 -> 5).
				(2 -> 4).
				(7 -> 0).
				(8 -> 6) };
		assert: tree leaves equals: #( 6 9 1 2 8 )
]

{ #category : #tests }
CTOrderPreservingTreeTest >> testCreation [

	self assertEmpty: CTOrderPreservingTree new
]

{ #category : #tests }
CTOrderPreservingTreeTest >> testCycle [

	| tree aCycle |
	tree := CTOrderPreservingTree new.

	tree
		parent: 2 child: 3;
		parent: 2 child: 4;
		parent: 1 child: 2.

	tree parent: 3 child: 1 onCycleDo: [ :cycle | aCycle := cycle ].

	self
		assert: aCycle asLinkedList
		equals: (1 ~~> (3 ~~> (2 ~~> (1 ~~> nil)))) asLinkedList
]
