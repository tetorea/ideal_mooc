import std.conv;

import Interaction010;

/**
 * An Interaction020 is an Interaction010 with a valence. 
 */
class Interaction020 : Interaction010{
	
private:
	int valence;
	
public:
	this(string label){
		super(label);
	}

	void setValence(int valence){
		this.valence = valence;
	}
	
	int getValence(){
		return valence;
	}

	override string toString(){
		return getLabel() ~ "," ~ to!string( getValence() );
	}

}
