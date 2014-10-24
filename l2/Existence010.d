import Existence;
import Experiment;
import Result;
import Interaction;
import Interaction010;

/**
 * An Existence010 simulates a "stream of intelligence" made of a succession of Experiences and Results.   
 * The Existence010 is SELF-SATISFIED when the Result corresponds to the Result it expected, and FRUSTRATED otherwise.
 * Additionally, the Existence0 is BORED when it has been SELF-SATISFIED for too long, which causes it to try another Experience.  
 * An Existence1 is still a single entity rather than being split into an explicit Agent and Environment.
 */
class Existence010 : Existence {

public:	
	enum LABEL_E1 = "e1"; 
	enum LABEL_E2 = "e2"; 
	enum LABEL_R1 = "r1";
	enum LABEL_R2 = "r2";
	enum Mood {SELF_SATISFIED, FRUSTRATED, BORED, PAINED, PLEASED};
	
	this(){
		initExistence();
	}	
	
	override string step() {
		
		Experiment experience = this.getPreviousExperience();
		if (this.getMood() == Mood.BORED){
			experience = getOtherExperience(experience);		
			this.setSelfSatisfactionCounter(0);
		}
		
		Result anticipatedResult = predict(experience);
		
		Result result = returnResult010(experience);
	
		this.addOrGetPrimitiveInteraction(experience, result);
		
		if (result == anticipatedResult){
			this.setMood(Mood.SELF_SATISFIED);
			this.incSelfSatisfactionCounter();
		}
		else{
			this.setMood(Mood.FRUSTRATED);
			this.setSelfSatisfactionCounter(0);
		}
		if (this.getSelfSatisfactionCounter() >= BOREDOME_LEVEL)
			this.setMood(Mood.BORED);
		
		this.setPreviousExperience(experience);
		
		return experience.getLabel() ~ result.getLabel() ~ " " ~ this.getMoodLabel();
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
	void setMood(Mood mood) {
		this.mood = mood;
	}

	Experiment getPreviousExperience() {
		return previousExperience;
	}
	void setPreviousExperience(Experiment previousExperience) {
		this.previousExperience = previousExperience;
	}

	int getSelfSatisfactionCounter() {
		return this.selfSatisfactionCounter;
	}
	void setSelfSatisfactionCounter(int selfSatisfactionCounter) {
		this.selfSatisfactionCounter = selfSatisfactionCounter;
	}
	void incSelfSatisfactionCounter(){
		this.selfSatisfactionCounter++;
	}

	/**
	 * The Environment010
	 * E1 results in R1. E2 results in R2.
	 * @param experience: The current experience.
	 * @return The result of this experience.
	 */
	Result returnResult010(Experiment experience){
		if( experience is addOrGetExperience(LABEL_E1) )
			return createOrGetResult(LABEL_R1);
		else
			return createOrGetResult(LABEL_R2);
	}
	
	
protected:
	Experiment[string] EXPERIENCES; 	// Map<string ,Experiment> EXPERIENCES = new HashMap<string ,Experiment>();
	Result[string] RESULTS; 					// Map<string ,Result> RESULTS = new HashMap<string ,Result>();
	Interaction[string] INTERACTIONS; 		// Map<string , Interaction> INTERACTIONS = new HashMap<string , Interaction>() ;

	enum BOREDOME_LEVEL = 4;	
	
	void initExistence(){
		Experiment e1 = addOrGetExperience(LABEL_E1);
		addOrGetExperience(LABEL_E2);
		this.setPreviousExperience(e1);
	}

	/**
	 * Create an interaction as a tuple <experience, result>.
	 * @param experience: The experience.
	 * @param result: The result.
	 * @return The created interaction
	 */
	Interaction addOrGetPrimitiveInteraction(Experiment experience, Result result) {
		Interaction interaction = addOrGetInteraction(experience.getLabel() ~ result.getLabel()); 
		interaction.setExperience(experience);
		interaction.setResult(result);
		return interaction;
	}

	/**
	 * Records an interaction in memory.
	 * @param label: The label of this interaction.
	 * @return The interaction.
	 */
	Interaction addOrGetInteraction(string label) {
		if( label !in INTERACTIONS )
			INTERACTIONS[label] = createInteraction( label );
		return INTERACTIONS[label];
	}
	
	Interaction010 createInteraction(string label){
		return new Interaction010(label);
	}
	
	/**
	 * Finds an interaction from its label
	 * @param label: The label of this interaction.
	 * @return The interaction.
	 */
	Interaction getInteraction(string label){
		return INTERACTIONS[label];
	}
	
	/**
	 * Finds an interaction from its experience
	 * @return The interaction.
	 */
	Result predict(Experiment experience){
		Interaction interaction = null;
		Result anticipatedResult = null;
		
		foreach( i; INTERACTIONS.values() )
			if( i.getExperience() == experience )
				interaction = i;
		
		if( interaction !is null)
			anticipatedResult = interaction.getResult();
		
		return anticipatedResult;
	}

	/**
	 * Creates a new experience from its label and stores it in memory.
	 * @param label: The experience's label
	 * @return The experience.
	 */
	Experiment addOrGetExperience(string label) {
		if( label !in EXPERIENCES )
			EXPERIENCES[label] = createExperience(label);
		return EXPERIENCES[label];
	}
	
	Experiment createExperience(string label){
		return new Experiment(label);
	}

	/**
	 * Finds an experience different from that passed in parameter.
	 * @param experience: The experience that we don't want
	 * @return The other experience.
	 */
	Experiment getOtherExperience(Experiment experience) {
		Experiment otherExperience = null;
		foreach( e; EXPERIENCES.values() ){
			if (e!=experience){
				otherExperience =  e;
				break;
			}
		}		
		return otherExperience;
	}

	/**
	 * Creates a new result from its label and stores it in memory.
	 * @param label: The result's label
	 * @return The result.
	 */
	Result createOrGetResult(string label) {
		if( label !in RESULTS)
			RESULTS[label] = new Result(label);
		return RESULTS[label];
	}	

	
private:
	Mood mood;
	int selfSatisfactionCounter = 0;
	Experiment previousExperience;

}
