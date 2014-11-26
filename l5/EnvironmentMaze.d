import std.stdio;

import Interaction;
import Existence;

/**
 * This class implements the Small Loop Environment
 *  
 * The Small Loop Problem: A challenge for artificial emergent cognition. 
 * Olivier L. Georgeon, James B. Marshall. 
 * BICA2012, Annual Conference on Biologically Inspired Cognitive Architectures. 
 * Palermo, Italy. (October 31, 2012).
 * http://e-ernest.blogspot.fr/2012/05/challenge-emergent-cognition.html
 */
class EnvironmentMaze 
{
	static final int ORIENTATION_UP    = 0;
	static final int ORIENTATION_RIGHT = 1;
	static final int ORIENTATION_DOWN  = 2;
	static final int ORIENTATION_LEFT  = 3;
	
	// The Small Loop Environment
	
	static final int WIDTH = 6;	
	static final int HEIGHT = 6;	
	int m_x = 4;
	int m_y = 1;
	int m_o = 2;
	
	Existence existence;
	
	char[][] m_board = 
		[
		 ['x', 'x', 'x', 'x', 'x', 'x'],
		 ['x', ' ', ' ', ' ', ' ', 'x'],
		 ['x', ' ', 'x', 'x', ' ', 'x'],
		 ['x', ' ', ' ', 'x', ' ', 'x'],
		 ['x', 'x', ' ', ' ', ' ', 'x'],
		 ['x', 'x', 'x', 'x', 'x', 'x'],
		];
	
	char[] m_agent = [ '^', '>', 'v', '<' ];
	
	this( Existence existence ){
		this.existence = existence;
		init();
	}
	
	void init()
	{
		//Settings for a nice demo in the Simple Maze 
		Interaction turnLeft = existence.addOrGetPrimitiveInteraction("^t", -3); // Left toward empty
		Interaction turnRight = existence.addOrGetPrimitiveInteraction("vt", -3); // Right toward empty
		Interaction touchRight = existence.addOrGetPrimitiveInteraction("\\t", -1); // Touch right wall
		existence.addOrGetPrimitiveInteraction("\\f", -1); // Touch right empty
		
		Interaction touchLeft = existence.addOrGetPrimitiveInteraction("/t", -1); // Touch left wall
		existence.addOrGetPrimitiveInteraction("/f", -1); // Touch left empty
		
		Interaction froward = existence.addOrGetPrimitiveInteraction(">t",  5); // Move
		existence.addOrGetPrimitiveInteraction(">f", -10); // Bump		
		
		Interaction touchForward = existence.addOrGetPrimitiveInteraction("-t", -1); // Touch wall
		existence.addOrGetPrimitiveInteraction("-f", -1); // Touch empty
		existence.addOrGetAbstractExperience(turnLeft);
		existence.addOrGetAbstractExperience(turnRight);
		existence.addOrGetAbstractExperience(touchRight);
		existence.addOrGetAbstractExperience(touchLeft);
		existence.addOrGetAbstractExperience(froward);
		existence.addOrGetAbstractExperience(touchForward);
	}

	Interaction enact( Interaction intendedInteraction )
	{
		Interaction enactedInteraction;

		if( intendedInteraction.label[0] == '>' ) enactedInteraction = move();
		else if( intendedInteraction.label[0] == '^' ) enactedInteraction = left();
		else if( intendedInteraction.label[0] == 'v' ) enactedInteraction = right();
		else if( intendedInteraction.label[0] == '-' ) enactedInteraction = Touch();
		else if( intendedInteraction.label[0] == '\\' ) enactedInteraction = TouchRight();
		else if( intendedInteraction.label[0] == '/' ) enactedInteraction = TouchLeft();
		
		// print the maze
		for( int i = 0; i < HEIGHT; i++ ) {
			for( int j = 0; j < WIDTH; j++ ) {
				if( i == m_y && j== m_x ) write( m_agent[m_o] );
				else write( m_board[i][j] );
			}
			writeln(" |");
		}
		
		return enactedInteraction;
	}

	Interaction right()
	{		
		m_o++;		
		if( m_o > ORIENTATION_LEFT ) m_o = ORIENTATION_UP;
		return existence.addOrGetPrimitiveInteraction("vt",0);
	}
	
	Interaction left()
	{
		m_o--;
		if( m_o < 0 ) m_o = ORIENTATION_LEFT;
		return existence.addOrGetPrimitiveInteraction("^t",0);
	}
	
	// Move forward to the direction of the current orientation.
	Interaction move()
	{
		Interaction enactedInteraction = existence.addOrGetPrimitiveInteraction(">f",0);	

		if( (m_o == ORIENTATION_UP) && (m_y > 0) && (m_board[m_y - 1][m_x] == ' ' ) ){
			m_y--; 
			enactedInteraction = existence.addOrGetPrimitiveInteraction(">t",0);
		}

		if( (m_o == ORIENTATION_DOWN) && (m_y < HEIGHT) && (m_board[m_y + 1][m_x] == ' ' ) ){
			m_y++; 
			enactedInteraction = existence.addOrGetPrimitiveInteraction(">t",0);	
		}

		if( (m_o == ORIENTATION_RIGHT) && ( m_x < WIDTH ) && (m_board[m_y][m_x + 1] == ' ' ) ){
			m_x++; 
			enactedInteraction = existence.addOrGetPrimitiveInteraction(">t",0);
		}
		if( (m_o == ORIENTATION_LEFT) && ( m_x > 0 ) && (m_board[m_y][m_x - 1] == ' ' ) ){
			m_x--; 
			enactedInteraction = existence.addOrGetPrimitiveInteraction(">t",0);
		}

		return enactedInteraction;
	}
	
	/**
	 * Touch the square forward.
	 * Succeeds if there is a wall, fails otherwise 
	 */
	Interaction Touch()
	{
		Interaction enactedInteraction = existence.addOrGetPrimitiveInteraction("-t",0);	

		if( ((m_o == ORIENTATION_UP) && (m_y > 0) && (m_board[m_y - 1][m_x] == ' ')) ||
			((m_o == ORIENTATION_DOWN) && (m_y < HEIGHT) && (m_board[m_y + 1][m_x] == ' ')) ||
			((m_o == ORIENTATION_RIGHT) && (m_x < WIDTH) && (m_board[m_y][m_x + 1] == ' ')) ||
			((m_o == ORIENTATION_LEFT) && (m_x > 0) && (m_board[m_y][m_x - 1] == ' ')) ) {
			enactedInteraction = existence.addOrGetPrimitiveInteraction("-f",0);	
		}

		return enactedInteraction;
	}
	
	/**
	 * Touch the square to the right.
	 * Succeeds if there is a wall, fails otherwise. 
	 */
	Interaction TouchRight()
	{
		Interaction enactedInteraction = existence.addOrGetPrimitiveInteraction("\\t",0);	

		if( ((m_o == ORIENTATION_UP) && (m_x > 0) && (m_board[m_y][m_x + 1] == ' ')) ||
			((m_o == ORIENTATION_DOWN) && (m_x < WIDTH) && (m_board[m_y][m_x - 1] == ' ')) ||
			((m_o == ORIENTATION_RIGHT) && (m_y < HEIGHT) && (m_board[m_y + 1][m_x] == ' ')) ||
			((m_o == ORIENTATION_LEFT) && (m_y > 0) && (m_board[m_y - 1][m_x] == ' ')) ) {
			enactedInteraction = existence.addOrGetPrimitiveInteraction("\\f",0);
		}

		return enactedInteraction;
	}

	/**
	 * Touch the square forward.
	 * Succeeds if there is a wall, fails otherwise 
	 */
	Interaction TouchLeft()
	{
		Interaction enactedInteraction = existence.addOrGetPrimitiveInteraction("/t",0);	
	
		if( ((m_o == ORIENTATION_UP) && (m_x > 0) && (m_board[m_y][m_x - 1] == ' ')) ||
			((m_o == ORIENTATION_DOWN) && (m_x < WIDTH) && (m_board[m_y][m_x + 1] == ' ')) ||
			((m_o == ORIENTATION_RIGHT) && (m_y > 0) && (m_board[m_y - 1][m_x] == ' ')) ||
			((m_o == ORIENTATION_LEFT) && (m_y < HEIGHT) && (m_board[m_y + 1][m_x] == ' ')) ) {
			enactedInteraction = existence.addOrGetPrimitiveInteraction("/f",0);
		}

		return enactedInteraction;
	}
}
