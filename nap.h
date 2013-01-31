/* License: public domain */

#ifndef nap_h_included
#define nap_h_included

#ifdef __cplusplus
extern "C" {
#endif

typedef struct nap_token
{
	char *str;
} nap_token;

typedef struct nap
{
	int  error;
	char err[1024];

	int  indent_stack[100];
	int  indent_stack_ptr;

	nap_token **tokens;
	int  ntokens;
	int  linenum;
} nap;


nap    *nap_create(char *t);
void    nap_free(nap *n);

/* semantic actions */
void    nap_function(nap *n, nap_token *func_name, nap_token *ret);
void    nap_class(nap *n, nap_token *class_name);
void    nap_meet_pass(nap *n);

#ifdef __cplusplus
}
#endif

#endif

