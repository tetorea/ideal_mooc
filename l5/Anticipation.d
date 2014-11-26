import std.conv;

import Experiment;

/**
 * An Anticipation031 is created for each experience.
 * Anticipations031 are equal if they propose the same experience.
 * An Anticipation031 is greater than another if its proclivity is greater that the other's.
 */
class Anticipation {
public:
	Experiment experience;
	int proclivity;
	
	this( Experiment experience, int proclivity ){
		this.experience = experience;
		this.proclivity = proclivity;
	}
	
	/+int compareTo(Anticipation anticipation){
		int val = (cast(Anticipation031)anticipation).getProclivity();
		if( val < proclivity ) return 1;
		if( val > proclivity ) return -1;
		return 0;
	}+/
	override int opCmp( Object o ) {
		int val = (cast(Anticipation)o).proclivity;
		if( val > proclivity ) return 1;
		if( val < proclivity ) return -1;
		return 0;
	}

	bool equals(Anticipation otherProposition){
		return otherProposition.experience == experience;
	}
	
	override string toString(){
		return experience.label ~ " proclivity " ~ to!string(proclivity);
	}
	
	void addProclivity( int proclivity ) {
		this.proclivity += proclivity;
	}
}
