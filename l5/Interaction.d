import std.conv;

import Experiment;

class Interaction{
public:
	string label;
	Experiment experience;
	string result;

	int weight = 0;
	int valence;

	Interaction preInteraction;
	Interaction postInteraction;
	
	this( string label ){
		this.label = label;
	}
			
	void incrementWeight() {
		weight++;
	}
	
	override string toString(){
		return label ~ " valence " ~ to!string( valence ) ~ ", weight " ~ to!string( weight );
	}	
	
	bool isPrimitive(){
		return (preInteraction is null);
	}
	
}
