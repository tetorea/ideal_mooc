
// A result of an experience.
class Result {
private:
	// The result's label.
	string label;
	
public:	
	this( string label ){
		this.label = label;
	}
	
	string getLabel(){
		return label;
	}

}
