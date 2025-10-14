#include "symbol.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


lobject intern(char* name) {
  symbol_t* p = (symbol_t*)malloc(sizeof(symbol_t));
  p->tag = TAG_SYMBOL;
  p->name = name;
  return ADD_PTAG(p, PTAG_OTHER);
}
