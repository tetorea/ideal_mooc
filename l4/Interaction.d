import Experiment;
import Result;

interface Interaction{
public:
	/**
	 * @return The interaction's label
	 */
	string getLabel();
	
	/**
	 * @return The interaction's experience
	 */
	Experiment getExperience();

	/**
	 * @return The interaction's result
	 */
	Result getResult();

	/**
	 * @param experience: The interaction's experience.
	 */
	void setExperience(Experiment experience) ;

	/**
	 * @param result: The interaction's result.
	 */
	void setResult(Result result);

}
