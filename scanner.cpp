#include <fstream>
#include "scanner.hpp"

using namespace drewno_mars;

using TokenKind = drewno_mars::Parser::token;
using Lexeme = drewno_mars::Parser::semantic_type;

void Scanner::outputTokens(std::ostream& outstream){
	Lexeme lex;
	int tokenKind;
	while(true){
		tokenKind = this->yylex(&lex);
		if (tokenKind == TokenKind::END){
			outstream << "EOF" 
			  << " [" << this->lineNum 
			  << "," << this->colNum << "]"
			  << std::endl;
			return;
		} else {
			outstream << lex.lexeme->toString()
			  << std::endl;
		}
	}
}
