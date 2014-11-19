import std.stdio;
import std.string;

import Existence;
import Existence020;
import Existence030;
import Existence031;
import Existence040;

/** Uncomment these lines to instantiate other existences: */
//import existence.Existence030;
//import existence.Existence031;
//import existence.Existence032;
//import existence.Existence040;
//import existence.Existence050;

/**
 * instantiates an Existence.,
 * runs the Existence step by step in a loop
 * and prints the Existence's activity as it runs.
 */
void main( string[] args )
{
		/** Change this line to instantiate another existence: */
		//auto existence = new Existence020();
		//auto existence = new Existence030();
		//auto existence = new Existence031();
		//Existence existence = new Existence032();
		auto existence = new Existence040();
		//Existence existence = new Existence050();
		//Existence existence = new Existence051();

		/** Change this line to adjust the number of cycles of the loop: */
		foreach( i; 0 .. 25 ) {
			string stepTrace = existence.step();
			writeln( i,": ", stepTrace );
		}
}

