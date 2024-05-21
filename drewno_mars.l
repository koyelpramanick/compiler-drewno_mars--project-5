%{
#include <string>
#include <limits.h>

/* Get our custom yyFlexScanner subclass */
#include "scanner.hpp"
#undef YY_DECL
#define YY_DECL int drewno_mars::Scanner::yylex(drewno_mars::Parser::semantic_type * const lval)

using TokenKind = drewno_mars::Parser::token;

/* define yyterminate as returning an EOF token (instead of NULL) */
#define yyterminate() return ( TokenKind::END )

/* exclude unistd.h for Visual Studio compatibility. */
#define YY_NO_UNISTD_H

#define EXIT_ON_ERR 0


%}

%option nodefault
%option yyclass="drewno_mars::Scanner"
%option noyywrap
%option c++

DIGIT [0-9]
WHITESPACE [\040\t]
LETTER [a-zA-Z]
ESCAPEE [nt'"\\]

 /* */ 
BADESC [\\][^nt"\\\n]
STRELT (\\[nt"\\])|([^\\\n"])

%%
%{
	this->yylval = lval;
%}

24Kmagic    { return makeBareToken(TokenKind::MAGIC); }
bool 	    { return makeBareToken(TokenKind::BOOL); }
class	    { return makeBareToken(TokenKind::CLASS); }
else	    { return makeBareToken(TokenKind::ELSE); }
false	    { return makeBareToken(TokenKind::FALSE); }
give	    { return makeBareToken(TokenKind::GIVE); }
if  	    { return makeBareToken(TokenKind::IF); }
int 	    { return makeBareToken(TokenKind::INT); }
perfect	    { return makeBareToken(TokenKind::PERFECT); }
return	    { return makeBareToken(TokenKind::RETURN); }
take	    { return makeBareToken(TokenKind::TAKE); }
true	    { return makeBareToken(TokenKind::TRUE); }
void	    { return makeBareToken(TokenKind::VOID); }
while	    { return makeBareToken(TokenKind::WHILE); }
"too hot"   { return makeBareToken(TokenKind::FALSE); }
"today I don't feel like doing any work"    { return makeBareToken(TokenKind::EXIT); }
"and"        { return makeBareToken(TokenKind::AND); }
"or"	    { return makeBareToken(TokenKind::OR); }
"="         { return makeBareToken(TokenKind::ASSIGN); }
":"         { return makeBareToken(TokenKind::COLON); }
","         { return makeBareToken(TokenKind::COMMA); }
"+"         { return makeBareToken(TokenKind::CROSS); }
"-"         { return makeBareToken(TokenKind::DASH); }
"=="        { return makeBareToken(TokenKind::EQUALS); }
">"         { return makeBareToken(TokenKind::GREATER); }
">="        { return makeBareToken(TokenKind::GREATEREQ); }
"{"	    { return makeBareToken(TokenKind::LCURLY); }
"<"	    { return makeBareToken(TokenKind::LESS); }
"<="	    { return makeBareToken(TokenKind::LESSEQ); }
"("	    { return makeBareToken(TokenKind::LPAREN); }
"!"	    { return makeBareToken(TokenKind::NOT); }
"!="	    { return makeBareToken(TokenKind::NOTEQUALS); }
"--"	    { return makeBareToken(TokenKind::POSTDEC); }
"++"	    { return makeBareToken(TokenKind::POSTINC); }
"}"	    { return makeBareToken(TokenKind::RCURLY); }
")"	    { return makeBareToken(TokenKind::RPAREN); }
";"	    { return makeBareToken(TokenKind::SEMICOL); }
"/"	    { return makeBareToken(TokenKind::SLASH); }
"*"	    { return makeBareToken(TokenKind::STAR); }
({LETTER}|_)({LETTER}|{DIGIT}|_)* { 
			  Position * pos = new Position(lineNum, colNum,
				lineNum, colNum + yyleng);
		            yylval->transToken = 
		            new IDToken(pos, yytext);
		            colNum += yyleng;
		            return TokenKind::ID; }

{DIGIT}+	    { double asDouble = std::stod(yytext);
			          int intVal = atoi(yytext);
			          bool overflow = false;
			          if (asDouble > INT_MAX){ overflow = true; }

								std::string str = yytext;
				  			std::string suffix = "";
				  			for(int i = 0 ; i < str.length(); i++){
									if (str[i] != '0'){
										suffix = str.substr(i, std::string::npos);
										break;
									}
				  			}
			          if (suffix.length() > 10){ overflow = true; }

			          if (overflow){
										Position pos(lineNum,colNum,lineNum,colNum+yyleng);
				            errIntOverflow(&pos);
					    intVal = 0;
			          }
				  			Position * pos = new Position(lineNum, colNum,
									lineNum, colNum + yyleng);
			          yylval->transToken = 
			              new IntLitToken(pos, intVal);
			          colNum += yyleng;
			          return TokenKind::INTLITERAL; }


\"{STRELT}*\" {
			Position * pos;
			pos = new Position(lineNum, colNum, lineNum, colNum + yyleng);
   		          yylval->transToken = 
                    new StrToken(pos, yytext);
		            this->colNum += yyleng;
		            return TokenKind::STRINGLITERAL; }

\"{STRELT}* {
			Position pos(lineNum, colNum, lineNum, colNum + yyleng);
		            errStrUnterm(&pos);
		            colNum += yyleng; /*Upcoming \n resets lineNum */
			    #if EXIT_ON_ERR
			    exit(1);
			    #endif
		            }

["]({STRELT}*{BADESC}{STRELT}*)+(\\["])? {
                // Bad, unterm string lit
		Position pos(lineNum,colNum,lineNum,colNum+yyleng);
		errStrEscAndUnterm(&pos);
                colNum += yyleng;
        }

["]({STRELT}*{BADESC}{STRELT}*)+["] {
                // Bad string lit
		Position pos(lineNum,colNum,lineNum,colNum+yyleng);
		errStrEsc(&pos);
                colNum += yyleng;
        }

\n|(\r\n)     { lineNum++; colNum = 1; }


[ \t]+	      { colNum += yyleng; }

[\/][\/][^\n]* 	{ /* Comment. No token, but update the 
                   char num in the very specific case of 
                   getting the correct EOF position */ 
		   colNum += yyleng;
		  }

.	          { 
		
		    Position pos(lineNum,colNum,lineNum,colNum+yyleng);
		    errIllegal(&pos, yytext);
		    #if EXIT_ON_ERR
		    exit(1);
		    #endif
	            this->colNum += yyleng; }
%%
