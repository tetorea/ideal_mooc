import Experiment;
import Interaction031;

/**
 * An Experiment040 is an Experiment that can be primitive or abstract.
 * An abstract Experiment has an intendedInteraction 
 * which is the sensorimotor pattern to try to enact if this experiment is selected.
 */
class Experiment040 : Experiment {

	/**
	 * The experience's interaction.
	 */
private:
	Interaction031 intendedInteraction;
	bool isAbstractP = true;
	
public: 
	this( string label){
		super(label);
	}

	bool isAbstract(){
		return isAbstractP;
	}
	
	void resetAbstract(){
		isAbstractP = false;
	}
	
	void setIntendedInteraction( Interaction031 intendedInteraction ){
		this.intendedInteraction = intendedInteraction;
	}
	
	Interaction031 getIntendedInteraction(){
		return intendedInteraction;
	}

}
