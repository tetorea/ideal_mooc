import std.conv;

import Existence010;
import Interaction020;

/**
 * An Existence020 is a sort of Existence010 in which each Interaction has a predefined Valence.
 * When a given Experience is performed and a given Result is obtained, the corresponding Interaction is considered enacted.
 * The Existence020 is PLEASED when the enacted Interaction has a positive or null Valence, and PAINED otherwise.
 * An Existence020 is still a single entity rather than being split into an explicit Agent and Environment. 
 * An Existence020 demonstrates a rudimentary decisional mechanism and a rudimentary learning mechanism.
 * It learns to choose the Experience that induces an Interaction that has a positive valence.  
 * Try to change the Valences of interactions and the method giveResult(experience) 
 * and observe that the Existence020 still learns to enact interactions that have positive valences.  
 */
class Existence020 : Existence010 {

public:	
	override string step() {
		Experiment experience = getPreviousExperience();
		if( getMood() == Mood.PAINED || getMood() == Mood.BORED ) {
			experience = getOtherExperience( experience );
			setSelfSatisfactionCounter(0);		// or we can comment this so that even the unpleasant known experiment can get the agent bored too!
		}
		
		Result anticipatedResult = predict( experience );
		Result result = returnResult010( experience );

		Interaction020 enactedInteraction = addOrGetPrimitiveInteraction( experience, result, 0 );
		if( enactedInteraction.getValence() >= 0 ) {
			setMood( Mood.PLEASED );
			if( result == anticipatedResult ){
				setMood( Mood.SELF_SATISFIED );
				incSelfSatisfactionCounter();
			}
			else
				setSelfSatisfactionCounter(0);

		}else{
			setMood( Mood.PAINED );
			if( result == anticipatedResult ) incSelfSatisfactionCounter();
			else setSelfSatisfactionCounter(0);
		}

		if( getSelfSatisfactionCounter() >= BOREDOME_LEVEL )
			setMood( Mood.BORED );
		
		setPreviousExperience( experience );
		
		return experience.getLabel() ~ result.getLabel() ~ " " ~ getMoodLabel();
	}

	
protected:
	override void initExistence(){
		Experiment e1 = addOrGetExperience(LABEL_E1);
		Experiment e2 = addOrGetExperience(LABEL_E2);
		Result r1 = createOrGetResult(LABEL_R1);
		Result r2 = createOrGetResult(LABEL_R2);
		/** Change the valence of interactions to change the agent's motivation */
		addOrGetPrimitiveInteraction(e1, r1, -1);  
		addOrGetPrimitiveInteraction(e1, r2, 1);
		addOrGetPrimitiveInteraction(e2, r1, -1);
		addOrGetPrimitiveInteraction(e2, r2, 1);		
		setPreviousExperience(e1);
	}

	/**
	 * Create an interaction as a tuple <experience, result>.
	 * @param experience: The experience.
	 * @param result: The result.
	 * @param valence: the interaction's valence
	 * @return The created interaction
	 */
	Interaction020 addOrGetPrimitiveInteraction( Experiment experience, Result result, int valence ) {
		string label = experience.getLabel() ~ result.getLabel();
		if( label !in INTERACTIONS ){
			Interaction020 interaction = createInteraction( label );
			interaction.setExperience( experience );
			interaction.setResult( result );
			interaction.setValence( valence );
			INTERACTIONS[label] = interaction;
		}
		Interaction020 interaction = cast(Interaction020)INTERACTIONS[label];
		return interaction;
	}
		
	override Interaction020 createInteraction( string label ){
		return new Interaction020( label );
	}

	override Interaction020 getInteraction( string label ){
		return cast(Interaction020)INTERACTIONS[ label ];
	}
	
}
