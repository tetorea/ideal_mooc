import std.string;

import Interaction;
import Existence;

class Environment050 {
	Existence existence;
	Interaction previousInteraction;
	Interaction penultimateInteraction;

	this( Existence existence ){
		this.existence = existence;
		init();
	}
	
	void init()
	{
		existence.addOrGetPrimitiveInteraction( existence.LABEL_E1 ~ existence.LABEL_R1, -1 );
		Interaction i12 = existence.addOrGetPrimitiveInteraction( existence.LABEL_E1 ~ existence.LABEL_R2, 1);
		existence.addOrGetPrimitiveInteraction( existence.LABEL_E2 ~ existence.LABEL_R1, -1);
		Interaction i22 = existence.addOrGetPrimitiveInteraction( existence.LABEL_E2 ~ existence.LABEL_R2, 1);
		existence.addOrGetAbstractExperience(i12);
		existence.addOrGetAbstractExperience(i22);
	}

	
	Interaction enact( Interaction intendedInteraction ) 
	{
		Interaction enactedInteraction;
	
		if( indexOf( intendedInteraction.label, existence.LABEL_E1 ) > -1 ){
			if( previousInteraction !is null &&
				(penultimateInteraction is null || indexOf( penultimateInteraction.label, existence.LABEL_E2 ) > -1 ) &&
				indexOf( previousInteraction.label, existence.LABEL_E1 ) > -1 )
				enactedInteraction = existence.addOrGetPrimitiveInteraction( existence.LABEL_E1 ~ existence.LABEL_R2, 0);
			else
				enactedInteraction = existence.addOrGetPrimitiveInteraction( existence.LABEL_E1 ~ existence.LABEL_R1, 0);
		}
		else{
			if (previousInteraction !is null &&
				(penultimateInteraction is null || indexOf( penultimateInteraction.label, existence.LABEL_E1 ) > -1 ) &&
				indexOf( previousInteraction.label, existence.LABEL_E2 ) > -1 )
				enactedInteraction = existence.addOrGetPrimitiveInteraction(existence.LABEL_E2 ~ existence.LABEL_R2, 0);
			else
				enactedInteraction = existence.addOrGetPrimitiveInteraction(existence.LABEL_E2 ~ existence.LABEL_R1, 0);
		}
			
		penultimateInteraction = previousInteraction;
		previousInteraction = enactedInteraction;

		return enactedInteraction;
	}
}	
