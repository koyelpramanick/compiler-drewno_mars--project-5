#ifndef DREWNO_MARS_NAME_ERROR_REPORTING_HH
#define DREWNO_MARS_NAME_ERROR_REPORTING_HH

#include "errors.hpp"

namespace drewno_mars {

class NameErr{
public:
static bool undeclID(const Position * pos){
	Report::fatal(pos, "Undeclared identifier");
	return false;
}
static bool badVarType(const Position * pos){
	Report::fatal(pos, "Invalid type in declaration");
	return false;
}
static bool multiDecl(const Position * pos){
	Report::fatal(pos, "Multiply declared identifier");
	return false;
}
};

} //End namespace drewno_mars

#endif
