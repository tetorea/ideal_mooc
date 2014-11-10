import std.stdio;

import Interaction020;

/**
 * An Interaction030 is an Interaction020 that can be primitive or composite
 * A composite interaction has a preInteraction and a postInteraction.
 */
class Interaction030 : Interaction020{
	
private:
	Interaction030 preInteraction;
	Interaction030 postInteraction;

public: 
	this( string label ){
		super(label);
	}
	
	Interaction030 getPreInteraction() {
		return this.preInteraction;
	}

	void setPreInteraction(Interaction030 preInteraction) {
		this.preInteraction = preInteraction;
	}

	Interaction030 getPostInteraction() {
		return postInteraction;
	}
	
	void setPostInteraction(Interaction030 postInteraction) {
		this.postInteraction = postInteraction;
	}
	
	bool isPrimitive(){
		return getPreInteraction() is null;
	}
}
