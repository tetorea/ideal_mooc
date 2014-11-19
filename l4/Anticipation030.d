import Anticipation;
import Interaction030;

/**
 * An Anticipation030 is created for each proposed primitive interaction.
 * An Anticipation030 is greater than another if its interaction has a greater valence than the other's.
 */
class Anticipation030 : Anticipation {
public:	
	Interaction030 interaction;
	
	this( Interaction030 interaction ){
		this.interaction = interaction;
	}
	
	Interaction030 getInteraction(){
		return interaction;
	}

	int compareTo( Anticipation anticipation ) {
		int val = (cast(Anticipation030)anticipation).getInteraction().getValence();
		if( val < interaction.getValence() ) return 1;
		if( val > interaction.getValence() ) return -1;
		return 0;
	}

	override int opCmp( Object o ) {
		int val = (cast(Anticipation030)o).getInteraction().getValence();
		if( val < interaction.getValence() ) return 1;
		if( val > interaction.getValence() ) return -1;
		return 0;
	}
}
