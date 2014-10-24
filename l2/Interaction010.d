
import Experiment;
import Interaction;
import Result;

/**
 * An interaction010 is the association of an experience with a result.
 */
class Interaction010 : Interaction
{
private:
	string label;
	
protected:	
	Experiment experience;
	Result result;
	
public: 
	this(string label){
		this.label = label;
	}
	
	string getLabel(){
		return this.label;
	}
	
	Experiment getExperience() {
		return experience;
	}

	void setExperience(Experiment experience) {
		this.experience = experience;
	}

	Result getResult() {
		return result;
	}

	void setResult(Result result) {
		this.result = result;
	}

	string tostring(){
		return this.experience.getLabel() ~ this.result.getLabel();
	}
}
