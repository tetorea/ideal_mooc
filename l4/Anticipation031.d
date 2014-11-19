import std.conv;

import Anticipation;
import Experiment;

/**
 * An Anticipation031 is created for each experience.
 * Anticipations031 are equal if they propose the same experience.
 * An Anticipation031 is greater than another if its proclivity is greater that the other's.
 */
class Anticipation031 : Anticipation {
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
		int val = (cast(Anticipation031)o).getProclivity();
		if( val > proclivity ) return 1;
		if( val < proclivity ) return -1;
		return 0;
	}

	bool equals(Anticipation otherProposition){
		return (cast(Anticipation031)otherProposition).getExperience() == experience;
	}
	
	Experiment getExperience() {
		return experience;
	}

	void setExperience( Experiment experience ) {
		this.experience = experience;
	}

	int getProclivity() {
		return proclivity;
	}

	void addProclivity( int proclivity ) {
		this.proclivity += proclivity;
	}
	
	override string toString(){
		return experience.getLabel() ~ " proclivity " ~ to!string(proclivity);
	}

}
