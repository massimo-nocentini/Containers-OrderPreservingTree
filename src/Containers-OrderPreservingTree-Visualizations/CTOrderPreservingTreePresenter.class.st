"
I present a `CTOrderPreservingTree`, my `tree`, as a tree table, my `treePresenter`. I have no column: who makes me adds them with `withTreePresenterDo:`, as `asPresenter` of the tree does.

```smalltalk
(CTOrderPreservingTree new
	parent: 3 child: 4;
	parent: 3 child: 5;
	yourself) asPresenter open
```
"
Class {
	#name : #CTOrderPreservingTreePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'tree',
		'treePresenter'
	],
	#category : #'Containers-OrderPreservingTree-Visualizations'
}

{ #category : #initialization }
CTOrderPreservingTreePresenter >> initializePresenters [

	| children |
	children := tree children.

	treePresenter := self newTreeTable
		                 activateOnSingleClick;
		                 roots: tree roots;
		                 children: [ :each | children at: each ];
		                 beResizable;
		                 yourself.


	self layout: (SpBoxLayout newTopToBottom
			 add: treePresenter expand: true;
			 yourself)
]

{ #category : #initialization }
CTOrderPreservingTreePresenter >> initializeWindow: aWindow [

	aWindow
		initialExtent: 1 @ Float silverRatio * 1e3;
		title: tree className , ' (' , tree size asString , ' elements)'
]

{ #category : #initialization }
CTOrderPreservingTreePresenter >> setModelBeforeInitialization: aDomainObject [

	tree := aDomainObject
]

{ #category : #initialization }
CTOrderPreservingTreePresenter >> withTreePresenterDo: aBlock [

	^ aBlock value: treePresenter
]
