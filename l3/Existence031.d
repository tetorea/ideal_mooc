import std.algorithm;
import std.conv;
import std.random;
import std.stdio;

import Anticipation031;
import Existence030;
import Experiment;
import Interaction030;
import Interaction031;
import Result;

/**
 * Existence031 can adapt to Environment010 020 030 031.
 * Like Existence030, Existence031 seeks to enact interactions that have positive valence.
 * Existence031 illustrates the benefit of reinforcing the weight of composite interactions
 * and of using the weight of activated interactions to balance the decision.   
 */
class Existence031 : Existence030 {

public: 
	override string step() {
		auto anticipations = anticipate!Anticipation031();
		//writeln("anticipations :");
		//writeln( anticipations );
		Experiment experience =  selectExperience(anticipations);
		//writeln("experience : "~ experience.getLabel() );
		
		/** Change the call to the function returnResult to change the environment */
		//Result result = returnResult010(experience);
		//Result result = returnResult030(experience);
		Result result = returnResult031(experience);
		
		//writeln("result : "~ result.getLabel() );

		Interaction031 enactedInteraction = getInteraction!Interaction031(experience.getLabel() ~ result.getLabel());
		writeln( " -- Enacted "~ enactedInteraction.toString() );

		if( enactedInteraction.getValence() >= 0)
			setMood(Mood.PLEASED);
		else
			setMood(Mood.PAINED);
		
		learnCompositeInteraction!Interaction031( enactedInteraction );
		
		setEnactedInteraction( cast(Interaction030)enactedInteraction );
		//writeln("getEnactedInteraction "~getEnactedInteraction!Interaction031().toString() );
		
		return getMoodLabel();
	}

	/**
	 * Record the composite interaction from the context interaction and the enacted interaction.
	 * Increment its weight.
	 */
	void learnCompositeInteraction(T)( T enactedInteraction){
		T preInteraction = getEnactedInteraction!T();
		//writeln("preInteraction");
		//writeln( preInteraction );
		T postInteraction = enactedInteraction;
		//writeln("postInteraction");
		//writeln( postInteraction );
		if( preInteraction !is null ){
			Interaction031 interaction = cast(Interaction031)addOrGetCompositeInteraction(preInteraction, postInteraction);
			interaction.incrementWeight();
			//writeln("Composite interaction added!");
			//writeln( interaction );
		}
	}
	/**
	 * Computes the list of anticipations
	 * @return the list of anticipations
	 */
	T[] anticipate(T)(){	// Anticipation031
		T[] anticipations = getDefaultAnticipations!T(); 
		
		if( getEnactedInteraction!Interaction030() !is null){
			foreach( activatedInteraction ; getActivatedInteractions()){
				T proposition = new T((cast(Interaction031)activatedInteraction).getPostInteraction().getExperience(), (cast(Interaction031)activatedInteraction).getWeight() * (cast(Interaction031)activatedInteraction).getPostInteraction().getValence());
				int index = indexOfExp( proposition, anticipations );
				if (index < 0)
					anticipations ~= proposition;
				else
					(anticipations[index]).addProclivity((cast(Interaction031)activatedInteraction).getWeight() * (cast(Interaction031)activatedInteraction).getPostInteraction().getValence());
			}
		}
		return anticipations;
	}
	
	int indexOfExp(T)( T obj, T[] arr )
	{
		foreach( i, o; arr ) {
			if( o.getExperience() == obj.getExperience() ) return i;
		}
		return -1;
	}	


	Experiment selectExperience(T)(T[] anticipations){
		// The list of anticipations is never empty because all the experiences are proposed by default with a proclivity of 0
		sort( anticipations );
		foreach( anticipation ; anticipations)
			writeln(" -- propose " ~ (anticipation).toString());
		
		T selectedAnticipation = anticipations[0];
		if( selectedAnticipation.getProclivity() < 0 )
			selectedAnticipation = anticipations[ uniform(1,anticipations.length) ];
		return selectedAnticipation.getExperience();
	}
	

	Result returnResult031(Experiment experience){
		Result result;
		incClock();
		
		if (getClock() <= T1 || getClock() > T2){
			if( experience is addOrGetExperience(LABEL_E1) )
				result =  createOrGetResult(LABEL_R1);
			else
				result = createOrGetResult(LABEL_R2);
		} 
		else {
			if( experience is addOrGetExperience(LABEL_E1) )
				result = createOrGetResult(LABEL_R2);
			else
				result = createOrGetResult(LABEL_R1);
		}
		return result;
	}
	
protected:	
	override void initExistence(){
		Experiment e1 = addOrGetExperience( LABEL_E1 );
		Experiment e2 = addOrGetExperience( LABEL_E2 );
		Result r1 = createOrGetResult( LABEL_R1 );
		Result r2 = createOrGetResult( LABEL_R2 );
		addOrGetPrimitiveInteraction!Interaction031( e1, r1, -1 );
		addOrGetPrimitiveInteraction!Interaction031( e1, r2, 1 );
		addOrGetPrimitiveInteraction!Interaction031( e2, r1, -1 );
		addOrGetPrimitiveInteraction!Interaction031( e2, r2, 1 );
	}
	
	/**
	 * all experiences as proposed by default with a proclivity of 0
	 * @return the list of anticipations
	 */
	T[] getDefaultAnticipations(T)(){
		T[] anticipations;
		foreach( experience ; EXPERIENCES.values() ){
			T anticipation = new T(experience, 0);
			anticipations ~= anticipation;
		}
		//writeln("default anticipations");
		//writeln( anticipations );
		return anticipations;
	}

	/**
	 * Environment031
	 * Before time T1 and after time T2: E1 results in R1; E2 results in R2
	 * between time T1 and time T2: E1 results R2; E2results in R1.
	 */
	int T1 = 8;
	int T2 = 15;
	
	int getClock(){
		return clock;
	}
	void incClock(){
		clock++;
	}

private:
	int clock = 0;

}
