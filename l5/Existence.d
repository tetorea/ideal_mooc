import std.algorithm;
import std.conv;
import std.random;
import std.stdio;
import std.string;

import Anticipation;
import Experiment;
import Interaction;

import Environment050;
//import EnvironmentMaze;


class Existence {
public:
	enum LABEL_E1 = "e1"; 
	enum LABEL_E2 = "e2"; 
	enum LABEL_R1 = "r1";
	enum LABEL_R2 = "r2";
	enum Mood {SELF_SATISFIED, FRUSTRATED, BORED, PAINED, PLEASED};

	Experiment[string] EXPERIENCES;
	Interaction[string] INTERACTIONS;

	Mood mood;
	
	Interaction previousSuperInteraction;
	Interaction lastSuperInteraction;
	Interaction enactedInteraction;

	Environment050 environment;
	
	void initExistence(){
		environment = new Environment050( this );
		//environment = new EnvironmentMaze(this);
	}
	
	this(){
		initExistence();
	}	
	
	string step()
	{
		Anticipation[] anticipations = anticipate();		// ok !!
		Experiment experience = selectExperience( anticipations );	// ok !!

		Interaction intendedInteraction = experience.intendedInteraction;
		writeln( "Intended "~ intendedInteraction.toString() );

		enactedInteraction = enact( intendedInteraction );	// ok !!
		
		if( enactedInteraction != intendedInteraction )
			experience.addEnactedInteraction( enactedInteraction );

		writeln( "Enacted "~ enactedInteraction.toString() );
		
		if( enactedInteraction.valence >= 0 ) setMood( Mood.PLEASED );
		else setMood( Mood.PAINED );

		learnCompositeInteraction( enactedInteraction );		// ok !!
		previousSuperInteraction = lastSuperInteraction;
		
		return getMoodLabel();
	}

	Anticipation[] anticipate()
	{
		Anticipation[] anticipations = getDefaultAnticipations();
		Interaction[] activatedInteractions = getActivatedInteractions();
		
		if( enactedInteraction !is null ) {
			foreach( activatedInteraction ; activatedInteractions ){
				if( activatedInteraction.postInteraction.experience !is null ){
					Anticipation anticipation = new Anticipation( activatedInteraction.postInteraction.experience, activatedInteraction.weight * activatedInteraction.postInteraction.valence );
					int index = indexOfExp( anticipation, anticipations );
					if( index < 0 ) anticipations ~= anticipation;
					else anticipations[index].addProclivity( activatedInteraction.weight * activatedInteraction.postInteraction.valence );
				}
			}
		}
		
		foreach( anticipation ; anticipations ) {
			foreach( interaction ; anticipation.experience.enactedInteractions ){
				foreach( activatedInteraction ; activatedInteractions ){
					if( interaction == activatedInteraction.postInteraction ){
						int proclivity = activatedInteraction.weight * interaction.valence; 
						anticipation.addProclivity( proclivity );
					}
				}
			}
		}

		return anticipations;
	}

	Anticipation[] getDefaultAnticipations()
	{
		Anticipation[] anticipations;
		foreach( experience ; EXPERIENCES.values() ){
			Experiment defaultExperience = experience;
			if( defaultExperience.intendedInteraction.isPrimitive() ){
				anticipations ~= new Anticipation( experience, 0 );
			}
		}
		return anticipations;
	}
	
	Interaction[] getActivatedInteractions() 
	{
		debug writeln("Exist40:gai 1");
		Interaction[] contextInteractions;
		debug writeln("Exist40:gai 2");
		auto enacInter = enactedInteraction;
		
		if( enacInter !is null ){
			contextInteractions ~= enacInter;
			if( !enacInter.isPrimitive() ) contextInteractions ~= enacInter.postInteraction;
			if( lastSuperInteraction !is null ) contextInteractions ~= lastSuperInteraction;
		}
		
		Interaction[] activatedInteractions;
		foreach( interaction ; INTERACTIONS.values() ){
			if( interaction.isPrimitive() ) continue;
			foreach( ci; contextInteractions ) {
				if( interaction.preInteraction != ci ) continue;
				activatedInteractions ~= interaction;
				version(info1) writeln("activated " ~ interaction.toString() );
				break;
			}
		}
		return activatedInteractions;
	}	
	int indexOfExp( Anticipation obj, Anticipation[] arr )
	{
		foreach( i, o; arr ) {
			if( o.experience == obj.experience ) return i;
		}
		return -1;
	}

	Experiment selectExperience( Anticipation[] anticipations ) {
		// The list of anticipations is never empty because all the experiences are proposed by default with a proclivity of 0
		sort( anticipations );
		foreach( anticipation ; anticipations)
			version(info1) writeln(" -- propose " ~ anticipation.toString() );
		
		auto selectedAnticipation = anticipations[0];
		if( selectedAnticipation.proclivity < 0 )
			selectedAnticipation = anticipations[ uniform(1,anticipations.length) ];
		return selectedAnticipation.experience;
	}

	Interaction enact( Interaction intendedInteraction )
	{
		if( intendedInteraction.isPrimitive() )
			return environment.enact( intendedInteraction );

		// Enact the pre-interaction
		Interaction enactedPreInteraction = enact( intendedInteraction.preInteraction );
		if( enactedPreInteraction != intendedInteraction.preInteraction )
			// if the preInteraction failed then the enaction of the intendedInteraction is interrupted here.
			return enactedPreInteraction;

		// Enact the post-interaction
		Interaction enactedPostInteraction = enact( intendedInteraction.postInteraction );
		return addOrGetCompositeInteraction( enactedPreInteraction, enactedPostInteraction );
	}

	Interaction addOrGetCompositeInteraction( Interaction preInteraction, Interaction postInteraction ) 
	{
		debug writeln("aogci 1");
		string label = "<" ~ preInteraction.label ~ postInteraction.label ~ ">";
		debug writeln("aogci 2 : "~ label );
        Interaction interaction = getInteraction( label );
		debug writeln("aogci 3");
        if( interaction is null ){
			interaction = addOrGetInteraction(label); 
			debug writeln("aogci 4");
			interaction.preInteraction = preInteraction;
			debug writeln("aogci 5");
			interaction.postInteraction = postInteraction;
			debug writeln("aogci 6");
			interaction.valence = preInteraction.valence + postInteraction.valence;
			debug writeln("aogci 7");
			addOrGetAbstractExperience( interaction );
			//interaction.setExperience(abstractExperience);
        }
		debug writeln("aogci 8");
    	return interaction;
	}
	Interaction getInteraction( string label ){
		if( label in INTERACTIONS ) return INTERACTIONS[label];
		return null;
	}
	Interaction addOrGetInteraction(string label) {
		if( label !in INTERACTIONS )
			INTERACTIONS[label] = createInteraction( label );
		return INTERACTIONS[label];
	}
	Interaction createInteraction(string label){
		return new Interaction(label);
	}
    Experiment addOrGetAbstractExperience( Interaction interaction ) 
    {
        string label = translate( interaction.label, makeTrans("er>","ER|") );
        if( label !in EXPERIENCES ){
        	Experiment abstractExperience = new Experiment(label);
        	abstractExperience.intendedInteraction = interaction;
			interaction.experience = abstractExperience;
            EXPERIENCES[label] = abstractExperience;
        }
        return EXPERIENCES[label];
    }
    
	void learnCompositeInteraction( Interaction enactedInteraction )
	{
		debug writeln("lci 1");
		auto previousInteraction = this.enactedInteraction; 
		debug writeln("lci 2");
		auto lastInteraction = enactedInteraction;
		debug writeln("lci 3");
		lastSuperInteraction = null;
        // learn [previous current] called the super interaction
		if( previousInteraction !is null )
			lastSuperInteraction = addOrGetAndReinforceCompositeInteraction( previousInteraction, lastInteraction );
		debug writeln("lci 5");
		
		// Learn higher-level interactions
        if( previousSuperInteraction !is null ){	
            // learn [penultimate [previous current]]
            addOrGetAndReinforceCompositeInteraction( previousSuperInteraction.preInteraction, lastSuperInteraction );
			debug writeln("lci 6");
            // learn [[penultimate previous] current]
            addOrGetAndReinforceCompositeInteraction( previousSuperInteraction, lastInteraction );
        }
		debug writeln("lci 7");
	}
	
	Interaction addOrGetAndReinforceCompositeInteraction( Interaction preInteraction, Interaction postInteraction )
	{
		debug writeln("aogarci 1");
		Interaction compositeInteraction = addOrGetCompositeInteraction( preInteraction, postInteraction );
		debug writeln("aogarci 2");
		compositeInteraction.incrementWeight();
		if( compositeInteraction.weight == 1 ) version(info1) writeln( "learn "~ compositeInteraction.toString() );
		else version(info1) writeln( "reinforce "~ compositeInteraction.toString() );

		return compositeInteraction;
	}

	Interaction addOrGetPrimitiveInteraction( string label, int valence ) {
		if( label !in INTERACTIONS ){
			Interaction interaction = createInteraction( label );
			interaction.valence = valence;
			INTERACTIONS[label] = interaction;			
		}
		Interaction interaction = INTERACTIONS[label];
		return interaction;
	}
	    
	Mood getMood() {
		return mood;
	}
	string getMoodLabel() {
		switch( mood ) {
			case Mood.SELF_SATISFIED: return "SELF_SATISFIED";
			case Mood.FRUSTRATED: return "FRUSTRATED";
			case Mood.BORED: return "BORED";
			case Mood.PAINED: return "PAINED";
			case Mood.PLEASED: return "PLEASED";
			default: return "";
		}
	}
	void setMood( Mood mood ) {
		this.mood = mood;
	}
	
}
