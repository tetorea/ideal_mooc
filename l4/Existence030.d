import std.algorithm;
import std.conv;
import std.stdio;

import Anticipation;
import Anticipation030;
import Existence020;
import Interaction;
import Interaction030;

/**
 * Existence030 is a sort of Existence020.
 * It learns composite interactions (Interaction030). 
 * It bases its next choice on anticipations that can be made from reactivated composite interactions.
 * Existence030 illustrates the benefit of basing the next decision upon the previous enacted Interaction.   
 */
class Existence030 : Existence020 {
public:
	override string step() {
		auto anticipations = anticipate!Anticipation030();
		Experiment experience =  selectInteraction( anticipations ).getExperience();
		
		/** Change the call to the function returnResult to change the environment */
		Result result = returnResult010( experience );
		//Result result = returnResult030( experience );
		Interaction030 enactedInteraction = getInteraction!Interaction030( experience.getLabel() ~ result.getLabel() );
		version(info1) writeln( " -- Enacted "~ enactedInteraction.toString() );
		
		if( enactedInteraction.getValence() >= 0 ) setMood( Mood.PLEASED );
		else setMood( Mood.PAINED );
		
		learnCompositeInteraction( enactedInteraction );
		setEnactedInteraction( enactedInteraction );
		return getMoodLabel();
	}


	/**
	 * Learn the composite interaction from the previous enacted interaction and the current enacted interaction
	 */
	void learnCompositeInteraction(T)( T interaction ){
		T preInteraction = getEnactedInteraction!T();
		T postInteraction = interaction;
		if( preInteraction !is null ) addOrGetCompositeInteraction( preInteraction, postInteraction );
	}

	/**
	 * Records a composite interaction in memory
	 * @param preInteraction: The composite interaction's pre-interaction
	 * @param postInteraction: The composite interaction's post-interaction
	 * @return the learned composite interaction
	 */
	T addOrGetCompositeInteraction(T)( T preInteraction, T postInteraction) {
		int valence = preInteraction.getValence() + postInteraction.getValence();
		T interaction = addOrGetInteraction!T(preInteraction.getLabel() ~ postInteraction.getLabel()); 
		interaction.setPreInteraction(preInteraction);
		interaction.setPostInteraction(postInteraction);
		interaction.setValence(valence);
		version(info1) writeln( " -- learn " ~ interaction.getLabel() );
		return interaction;
	}


	/**
	 * Computes the list of anticipations
	 * @return the list of anticipations
	 */
	T[] anticipate(T)(){
		T[] anticipations;;
		if( getEnactedInteraction!Interaction030() !is null ){
			foreach( activatedInteraction ; getActivatedInteractions() ){
				Interaction030 proposedInteraction = (cast(Interaction030)activatedInteraction).getPostInteraction();
				anticipations ~= new T( proposedInteraction );
				version(info1) writeln(" -- afforded " ~ proposedInteraction.toString() );
			}
		}
		return anticipations;
	}
	

	/**
	 * Get the list of activated interactions
	 * An activated interaction is a composite interaction whose preInteraction matches the enactedInteraction
	 * @return the list of anticipations
	 */
	Interaction[] getActivatedInteractions() {
		Interaction[] activatedInteractions;
		if( getEnactedInteraction!Interaction030() !is null )
			foreach( activatedInteraction ; INTERACTIONS.values() )
				if( (cast(Interaction030)activatedInteraction).getPreInteraction() is getEnactedInteraction!Interaction030() )
					activatedInteractions ~= cast(Interaction030)activatedInteraction;
		return activatedInteractions;
	}	

	Interaction030 getOtherInteraction( Interaction interaction ) {
		// Interaction030 otherInteraction = cast(Interaction030)((INTERACTIONS.values)[0]);
		Interaction030 otherInteraction = cast(Interaction030)(INTERACTIONS["e1r1"]);
		if( interaction !is null )
			foreach( Interaction e ; INTERACTIONS.values() ){
				if( e.getExperience() !is null && e.getExperience() !is interaction.getExperience() ){
					otherInteraction =  cast(Interaction030)e;
					break;
				}
			}
		return otherInteraction;
	}
	
protected:
	override void initExistence(){
		Experiment e1 = addOrGetExperience( LABEL_E1 );
		Experiment e2 = addOrGetExperience( LABEL_E2 );
		Result r1 = createOrGetResult( LABEL_R1 );
		Result r2 = createOrGetResult( LABEL_R2 );
		addOrGetPrimitiveInteraction!Interaction030( e1, r1, -1 );
		addOrGetPrimitiveInteraction!Interaction030( e1, r2, 1 );
		addOrGetPrimitiveInteraction!Interaction030( e2, r1, -1 );
		addOrGetPrimitiveInteraction!Interaction030( e2, r2, 1 );
	}

	T createInteraction(T)(string label){
		return new T(label);
	}

	Interaction030 selectInteraction( Anticipation030[] anticipations ){
		Interaction030 intendedInteraction;
		if( anticipations.length > 0){
			sort( anticipations );
			Interaction030 affordedInteraction = (anticipations[0]).getInteraction();
			if( affordedInteraction.getValence() >= 0)
				intendedInteraction = affordedInteraction;
			else
				intendedInteraction = cast(Interaction030)this.getOtherInteraction(affordedInteraction);
		}
		else 
			intendedInteraction = this.getOtherInteraction(null);
		return intendedInteraction;
	}

	T getInteraction(T)( string label ){
		if( label in INTERACTIONS ) return cast(T)INTERACTIONS[label];
		return null;
	}

	void setEnactedInteraction( Interaction030 enactedInteraction ){
		this.enactedInteraction = cast(Interaction030)enactedInteraction;
	}
	
	T getEnactedInteraction(T)(){
		return cast(T)enactedInteraction;
	}

	/**
	 * Environment030
	 * Results in R1 when the current experience equals the previous experience
	 * and in R2 when the current experience differs from the previous experience.
	 */
	Result returnResult030(Experiment experience){
		Result result = null;
		if( getPreviousExperience() == experience)
			result =  createOrGetResult(LABEL_R1);
		else
			result =  createOrGetResult(LABEL_R2);
		setPreviousExperience(experience);

		return result;
	}	

private:
	Interaction030 enactedInteraction;
	
}
