import std.stdio;
import std.string;

import Anticipation;
import Anticipation031;
import Existence031;
import Experiment;
import Experiment040;
import Result;
import Interaction;
import Interaction030;
import Interaction031;

/** 
* Existence040 implements two-step self-programming.
*/
class Existence040 : Existence031 {

private:
	Interaction031 previousSuperInteraction;
	Interaction031 lastSuperInteraction;
	Experiment penultimateExperience;

public:	
	override string step() 
	{
		debug writeln("s1");
		auto anticipations = anticipate!Anticipation031();
		debug writeln("s2");
		Experiment040 experience = cast(Experiment040)selectExperience( anticipations );
		debug writeln("s3");
		Interaction031 intendedInteraction = experience.getIntendedInteraction();

		debug writeln("s4");
		Interaction031 enactedInteraction = enact(intendedInteraction);
		writeln( " -- Enacted "~ enactedInteraction.toString() );
		
		debug writeln("s5");
		if( enactedInteraction != intendedInteraction && experience.isAbstract() ){
			Result failResult = createOrGetResult( translate( enactedInteraction.getLabel(), makeTrans("er","ER") )~">" );
			debug writeln("s6");
			int valence = enactedInteraction.getValence(); 
			debug writeln("s7");
			enactedInteraction = addOrGetPrimitiveInteraction!Interaction031(experience, failResult, valence);
		}
		
		debug writeln("s8");
		if( enactedInteraction.getValence() >= 0 ) setMood( Mood.PLEASED );
		else setMood( Mood.PAINED );

		debug writeln("s9");
		learnCompositeInteraction( enactedInteraction );
		
		debug writeln("s10");
		setPreviousSuperInteraction( getLastSuperInteraction() );
		debug writeln("s11");
		setEnactedInteraction( enactedInteraction );
		
		debug writeln("s12");
		return getMoodLabel();
	}
	
	/**
	 * Learn composite interactions from 
	 * the previous super interaction, the context interaction, and the enacted interaction
	 */
	void learnCompositeInteraction(T)( T enactedInteraction)
	{
		debug writeln("lci 1");
		T previousInteraction = getEnactedInteraction!T(); 
		debug writeln("lci 2");
		T lastInteraction = cast(T)enactedInteraction;
		debug writeln("lci 3");
		T previousSuperInteraction = getPreviousSuperInteraction();
		debug writeln("lci 4");
		T lastSuperIntearction = null;
        // learn [previous current] called the super interaction
		if( previousInteraction !is null )
			lastSuperIntearction = addOrGetAndReinforceCompositeInteraction( previousInteraction, lastInteraction );
		debug writeln("lci 5");
		
		// Learn higher-level interactions
        if( previousSuperInteraction !is null 
        		//&& previousInteraction.isPrimitive() && lastInteraction.isPrimitive()
        		){	
            // learn [penultimate [previous current]]
            addOrGetAndReinforceCompositeInteraction( cast(Interaction031)previousSuperInteraction.getPreInteraction(), lastSuperIntearction );
			debug writeln("lci 6");
            // learn [[penultimate previous] current]
            addOrGetAndReinforceCompositeInteraction( previousSuperInteraction, lastInteraction );
        }
		debug writeln("lci 7");
        setLastSuperInteraction( lastSuperIntearction );
		debug writeln("lci 8");
	}
	
	T addOrGetAndReinforceCompositeInteraction(T)( T preInteraction, T postInteraction )
	{
		debug writeln("aogarci 1");
		T compositeInteraction = addOrGetCompositeInteraction( preInteraction, postInteraction );
		debug writeln("aogarci 2");
		compositeInteraction.incrementWeight();
		if( compositeInteraction.getWeight() == 1 ) version(info1) writeln( "learn "~ compositeInteraction.toString() );
		else version(info1) writeln( "reinforce "~ compositeInteraction.toString() );

		return compositeInteraction;
	}

	/**
	 * Records or get a composite interaction in memory
	 * If a new composite interaction is created, then a new abstract experience is also created and associated to it.
	 * @param preInteraction: The composite interaction's pre-interaction
	 * @param postInteraction: The composite interaction's post-interaction
	 * @return the learned composite interaction
	 */
	Interaction031 addOrGetCompositeInteraction(T)( T preInteraction, T postInteraction ) 
	{
		debug writeln("aogci 1");
		string label = "<" ~ preInteraction.getLabel() ~ postInteraction.getLabel() ~ ">";
		//string label = preInteraction.getLabel() ~ postInteraction.getLabel();
		debug writeln("aogci 2 : "~ label );
        Interaction031 interaction = getInteraction!Interaction031( label );
		debug writeln("aogci 3");
        if( interaction is null ){
			interaction = addOrGetInteraction!Interaction031(label); 
			debug writeln("aogci 4");
			interaction.setPreInteraction(preInteraction);
			debug writeln("aogci 5");
			interaction.setPostInteraction(postInteraction);
			debug writeln("aogci 6");
			interaction.setValence(preInteraction.getValence() + postInteraction.getValence());
			debug writeln("aogci 7");
			addOrGetAbstractExperience(interaction);
			//interaction.setExperience(abstractExperience);
        }
		debug writeln("aogci 8");
    	return interaction;
	}
	
    Experiment040 addOrGetAbstractExperience( Interaction031 interaction ) 
    {
        string label = translate( interaction.getLabel(), makeTrans("er>","ER|") );
        if( label !in EXPERIENCES ){
        	Experiment040 abstractExperience = new Experiment040(label);
        	abstractExperience.setIntendedInteraction(interaction);
			interaction.setExperience(abstractExperience);
            EXPERIENCES[label] = abstractExperience;
        }
        return cast(Experiment040)EXPERIENCES[label];
    }

	Result returnResult041( Experiment experience )
	{
		Result result = this.createOrGetResult(this.LABEL_R1);

		if (this.getAntePenultimateExperience() != experience &&
			this.getPenultimateExperience() == experience &&
			this.getPreviousExperience() == experience)
			result =  this.createOrGetResult(this.LABEL_R2);
		
		this.setAntePenultimateExperience(this.getPenultimateExperience());
		this.setPenultimateExperience(this.getPreviousExperience());
		this.setPreviousExperience(experience);
		
		return result;
	}

	/**
	 * Get the list of activated interactions
	 * from the enacted Interaction, the enacted interaction's post-interaction if any, 
	 * and the last super interaction
	 * @param the enacted interaction
	 * @return the list of anticipations
	 */
	T[] getActivatedInteractions(T)() 
	{
		debug writeln("Exist40:gai 1");
		T[] contextInteractions;
		debug writeln("Exist40:gai 2");
		auto enacInter = getEnactedInteraction!T();
		
		if( enacInter !is null ){
			contextInteractions ~= enacInter;
			if( !enacInter.isPrimitive() ) contextInteractions ~= cast(T)enacInter.getPostInteraction();
			if( getLastSuperInteraction() !is null ) contextInteractions ~= getLastSuperInteraction();
		}
		
		T[] activatedInteractions;
		foreach( interaction ; INTERACTIONS.values() ){
			T activatedInteraction = cast(T)interaction;
			if( !activatedInteraction.isPrimitive() )
				foreach( ci; contextInteractions ) {
					if( activatedInteraction.getPreInteraction() != ci ) continue;
					activatedInteractions ~= activatedInteraction;
					version(info1) writeln("activated " ~ activatedInteraction.toString() );
					break;
				}
		}
		return activatedInteractions;
	}	


	Interaction031 enact( Interaction030 intendedInteraction )
	{
		if( intendedInteraction.isPrimitive() )
			return enactPrimitiveIntearction(intendedInteraction);

		// Enact the pre-interaction
		Interaction031 enactedPreInteraction = enact( intendedInteraction.getPreInteraction() );
		if( enactedPreInteraction != intendedInteraction.getPreInteraction() )
			// if the preInteraction failed then the enaction of the intendedInteraction is interrupted here.
			return enactedPreInteraction;

		// Enact the post-interaction
		Interaction031 enactedPostInteraction = enact( intendedInteraction.getPostInteraction() );
		return cast(Interaction031)addOrGetCompositeInteraction( enactedPreInteraction, enactedPostInteraction );
	}

	/**
	 * Implements the cognitive coupling between the agent and the environment
	 * @param intendedPrimitiveInteraction: The intended primitive interaction to try to enact against the environment
	 * @param The actually enacted primitive interaction.
	 */
	Interaction031 enactPrimitiveIntearction( Interaction030 intendedPrimitiveInteraction ) 
	{
		Experiment experience = intendedPrimitiveInteraction.getExperience();
		/** Change the returnResult() to change the environment 
		 *  Change the valence of primitive interactions to obtain better behaviors */		
		//Result result = returnResult010(experience);
		//Result result = returnResult030(experience);
		//Result result = returnResult031(experience);
		Result result = returnResult040( experience );
		//Result result = returnResult041(experience);
		return addOrGetPrimitiveInteraction!Interaction031( experience, result, 0 );
	}

	Interaction031 getPreviousSuperInteraction() {
		return previousSuperInteraction;
	}
	void setPreviousSuperInteraction( Interaction031 previousSuperInteraction ) {
		this.previousSuperInteraction = previousSuperInteraction;
	}
	Interaction031 getLastSuperInteraction() {
		return lastSuperInteraction;
	}
	void setLastSuperInteraction( Interaction031 lastSuperInteraction ) {
		this.lastSuperInteraction = lastSuperInteraction;
	}

	Result returnResult040( Experiment experience )
	{
		Result result = createOrGetResult( LABEL_R1 );

		if( getPenultimateExperience() != experience && getPreviousExperience() == experience )
			result = createOrGetResult( LABEL_R2 );
		
		setPenultimateExperience( getPreviousExperience() );
		setPreviousExperience( experience );
		
		return result;
	}


protected:	
	override void initExistence()
	{
		Experiment040 e1 = cast(Experiment040)addOrGetExperience(LABEL_E1);
		Experiment040 e2 = cast(Experiment040)addOrGetExperience(LABEL_E2);
		Result r1 = createOrGetResult(LABEL_R1);
		Result r2 = createOrGetResult(LABEL_R2);
		/** Change the valence depending on the environment to obtain better behaviors */
		Interaction031 e11 = addOrGetPrimitiveInteraction!Interaction031( e1, r1, -1 );
		Interaction031 e12 = addOrGetPrimitiveInteraction!Interaction031( e1, r2, 1  ); // Use valence 1 for Environment040 and 2 for Environment041
		Interaction031 e21 = addOrGetPrimitiveInteraction!Interaction031( e2, r1, -1 );
		Interaction031 e22 = addOrGetPrimitiveInteraction!Interaction031( e2, r2, 1  ); // Use valence 1 for Environment040 and 2 for Environment041
		e1.setIntendedInteraction(e12); e1.resetAbstract();
		e2.setIntendedInteraction(e22); e2.resetAbstract();
	}

	override T[] getDefaultAnticipations(T)()
	{
		Anticipation[] anticipations;
		foreach( experience ; EXPERIENCES.values() ){
			Experiment040 defaultExperience = cast(Experiment040)experience;
			if (!defaultExperience.isAbstract()){
				Anticipation031 anticipation = new Anticipation031(experience, 0);
				anticipations ~= anticipation;
			}
		}
		return anticipations;
	}

	override Experiment040 createExperience(string label){
		return new Experiment040(label);
	}


	/**
	 * Environment040
	 * Results in R2 when the current experience equals the previous experience and differs from the penultimate experience.
	 * and in R1 otherwise.
	 * e1->r1 e1->r2 e2->r1 e2->r2 etc. 
	 */
	void setPenultimateExperience( Experiment penultimateExperience ){
		this.penultimateExperience = penultimateExperience;
	}
	Experiment getPenultimateExperience(){
		return penultimateExperience;
	}

	
	/**
	 * Environment041
	 * The agent must alternate experiences e1 and e2 every third cycle to get one r2 result the third time:
	 * e1->r1 e1->r1 e1->r2 e2->r1 e2->r1 e2->r2 etc. 
	 */
	Experiment antepenultimateExperience;
	
	void setAntePenultimateExperience( Experiment antepenultimateExperience ){
		antepenultimateExperience = antepenultimateExperience;
	}
	Experiment getAntePenultimateExperience(){
		return antepenultimateExperience;
	}

}
