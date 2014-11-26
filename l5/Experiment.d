import Interaction;

class Experiment {
	
public:
	string label;
	Interaction intendedInteraction;
	bool isAbstractP = true;
	Interaction[] enactedInteractions;

	this( string label ){
		this.label = label;
	}

	void addEnactedInteraction( Interaction enactedInteraction ){
		foreach( ei; enactedInteractions ){
			if( ei == enactedInteraction ) return;
		}
		enactedInteractions ~= enactedInteraction;
	}
	
	void resetAbstract(){
		isAbstractP = false;
	}
	
}
