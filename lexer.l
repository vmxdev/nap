/* License: public domain */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "grammar.h"
#include "nap.h"

#define LF         10000
#define SAME_SUITE 10001

void *ParseAlloc();
void  ParseFree();
void  Parse();

static int get_indent_token(nap *n, char **s, int *dedents);

static int
scan(nap *n, char **s, char **tbegin)
{
again:
	*tbegin = *s;
/*!re2c
	re2c:define:YYCTYPE  = "char";
	re2c:define:YYCURSOR = (*s);
	re2c:variable:yych   = curr;
	re2c:indent:top      = 2;
	re2c:yyfill:enable   = 0;
	re2c:yych:conversion = 1;
	re2c:labelprefix     = scan;

	WS		= [ \t\v\r]+ ;
	NL		= [\n] ;

	EOF		= [\000] ;
	D		= [0-9] ;
	L		= [a-zA-Z_] ;

	WS		{ goto again; }
	NL		{ return LF; }

	EOF		{ return 0; }

	"("		{ return LPAREN; }
	")"		{ return RPAREN; }
	":"		{ return COLON; }
	","		{ return COMMA; }
	"="		{ return EQ; }

	"pass"		{ return PASS; }
	"class"		{ return CLASS; }
	"def"		{ return DEF; }
	"returns"	{ return RETURNS; }
	"as"		{ return AS; }

	D+		{ return INT; }

	L (L|D|"_")*	{ return ID; }
	.		{ return -1; }
*/
	return 0;
}

static nap_token *
mk_token(nap *n, char *s, size_t len)
{
	size_t i;
	nap_token *buf;

	buf = malloc(sizeof(nap_token));
	buf->str = malloc(len + 1);
	for (i=0; i<len; i++) {
		buf->str[i] = tolower(s[i]);
	}
	buf->str[len] = '\0';

	n->ntokens++;
	n->tokens = realloc(n->tokens, sizeof(nap_token *) * n->ntokens);
	n->tokens[n->ntokens - 1] = buf;

	return buf;
}

struct nap*
nap_create(char *t)
{
	void *parser;
	char *ptr;
	nap *n;
	int linebegin = 1;

	n = malloc(sizeof(nap));
	if (!n) return NULL;
	n->error = 0;

	n->indent_stack[0]  = 0;
	n->indent_stack_ptr = 0;
	n->tokens = NULL;
	n->ntokens = 0;

	n->linenum = 1;

	parser = (void *)ParseAlloc(malloc);

	ptr = t;

	for (;;) {
		int r = 0, got_token = 0;
		char *tokb = NULL;
		nap_token *tok = NULL;
		int dedents = 0;

		if (linebegin) {
			r = get_indent_token(n, &ptr, &dedents);
			if (r < 0) break;
			if (r != SAME_SUITE) {
				got_token = 1;
			}
			linebegin = 0;
		}
		if (!got_token) {
			r = scan(n, &ptr, &tokb);
		}

		if (r == 0) {
			/* eof, dedent all */
			int i;
			for (i=0; i<n->indent_stack_ptr; i++) {
				Parse(parser, DEDENT, NULL, n);
				if (n->error) break;
			}
			if (n->error) {
				snprintf(n->err, sizeof(n->err), "indentation error, line %d", n->linenum);
			}
			break;
		}
		if (r == LF) {
			n->linenum++;
			linebegin = 1;
			continue;
		}
		if (r == DEDENT) {
			int i;
			for (i=0; i<dedents; i++) {
				Parse(parser, DEDENT, NULL, n);
				if (n->error) break;
			}
			if (n->error) {
				snprintf(n->err, sizeof(n->err), "indentation error, line %d", n->linenum);
				break;
			}
			continue;
		}

		if (r != INDENT) {
			tok = mk_token(n, tokb, ptr - tokb);
		}

		if (r < 0) {
			snprintf(n->err, sizeof(n->err), "unknown token '%s', line %d", tok->str, n->linenum);
			n->error = 1;
			break;
		}
		Parse(parser, r, tok, n);
		if (n->error) {
			snprintf(n->err, sizeof(n->err), "something wrong near token '%s', line %d", tok ? tok->str : "unknown token", n->linenum);
			break;
		}
	}
	if (!n->error) {
		Parse(parser, 0, 0, n);
	}
	ParseFree(parser, free);
	return n;
}

void
nap_free(nap *n)
{
	int i;
	for (i=0; i<n->ntokens; i++) {
		nap_token *t = n->tokens[i];
		free(t->str);
		free(t);
	}
	free(n->tokens);
}

static int
get_indent_token(nap *n, char **s, int *dedents)
{
	int spaces, i;

	/* leading spaces */
	if (strlen(*s) > 0) {
		for (spaces=0; *(*s) == ' '; spaces++, (*s)++) ;
	} else {
		/* eof */
		return 0;
	}

	/* empty line */
	if (*(*s) == '\n') {
		(*s)++;
		return LF;
	}

	if (spaces == n->indent_stack[n->indent_stack_ptr]) {
		/* we still in the same suite */
		return SAME_SUITE;
	}

	if (spaces > n->indent_stack[n->indent_stack_ptr]) {
		n->indent_stack_ptr++;
		n->indent_stack[n->indent_stack_ptr] = spaces;
		return INDENT;
	}

	if (n->indent_stack_ptr <= 0) {
		snprintf(n->err, sizeof(n->err), "indentation error, line %d", n->linenum);
		n->error = 1;
		return -1;
	}

	for (i=0; i<n->indent_stack_ptr; i++) {
		if (n->indent_stack[i] == spaces) {
			*dedents = n->indent_stack_ptr - i;
			n->indent_stack_ptr -= *dedents;
			return DEDENT;
		}
	}

	snprintf(n->err, sizeof(n->err), "indentation error, line %d", n->linenum);
	n->error = 1;
	return -1;
}

