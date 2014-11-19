import std.conv;

import Interaction030;

/**
 * An Interaction031 is an Interaction030 with a weight.
 */
class Interaction031 : Interaction030 {
	
private:
	int weight = 0;

public:
	this(string label){
		super(label);
	}
	
	int getWeight() {
		return weight;
	}

	void incrementWeight() {
		weight++;
	}
	
	override string toString(){
		return this.getLabel() ~ " valence " ~ to!string(this.getValence()) ~ ", weight " ~ to!string(weight);
	}	

}
