import std.stdio;
import std.string;

import Existence;

/**
 * instantiates an Existence.,
 * runs the Existence step by step in a loop
 * and prints the Existence's activity as it runs.
 */
void main( string[] args )
{
	auto existence = new Existence();

	// Change this line to adjust the number of cycles of the loop:
	foreach( i; 0 .. 200 ) {
		string stepTrace = existence.step();
		writeln( i,": ", stepTrace );
	}
}
