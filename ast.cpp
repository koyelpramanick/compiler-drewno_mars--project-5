#include "ast.hpp"

drewno_mars::ProgramNode::ProgramNode(std::list<DeclNode *> * globalsIn)
: ASTNode(new Position(0,0,0,0)), myGlobals(globalsIn){
	if (!globalsIn->empty()){
		myPos = new Position(
			myGlobals->front()->pos(),
			myGlobals->back()->pos()
		);
	}
}
