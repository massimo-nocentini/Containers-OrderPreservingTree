Class {
	#name : #BaselineOfContainersOrderPreservingTree,
	#superclass : #BaselineOf,
	#category : #BaselineOfContainersOrderPreservingTree
}

{ #category : #baselines }
BaselineOfContainersOrderPreservingTree >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'ContainersEssentials'
			with: [
			spec repository: 'github://massimo-nocentini/Containers-Essentials:master' ].

		spec
			package: 'Containers-OrderPreservingTree'
			with: [ spec requires: #( 'ContainersEssentials' ) ];
			package: 'Containers-OrderPreservingTree-Tests'
			with: [ spec requires: #( 'Containers-OrderPreservingTree' ) ];
			package: 'Containers-OrderPreservingTree-Visualizations'
			with: [ spec requires: #( 'Containers-OrderPreservingTree' ) ] ]
]
