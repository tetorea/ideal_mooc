import Interaction031;

/**
 * An interaction040 is an Interaction031 that has an Experience040
 * Composite interactions now have an abstract experience.
 */
class Interaction040 : Interaction031 {
public:
	this( string label ){
		super(label);
	}
		
	//override Experiment040 getExperience() {
	//	return cast(Experiment040)super.getExperience(); 
	//}
}
