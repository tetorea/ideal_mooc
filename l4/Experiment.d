
/+
  An experiment that can be chosen by the agent.
 +/
class Experiment {
	
private:
	// The experience's label.
	string label;

public:
	this(string label){
		this.label = label;
	}
	
	string getLabel(){
		return this.label;
	}	
}
