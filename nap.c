/* License: public domain */

#include <stdio.h>
#include <stdlib.h>

#include "nap.h"

int
main(int argc, char *argv[])
{
	nap *n;
	char *src;

	FILE *f;
	size_t filesize;

	if (argc < 2) {
		printf("Usage: %s source.nap\n", argv[0]);
		return EXIT_FAILURE;
	}

	f = fopen(argv[1], "rt");
	if (!f) {
		printf("Can't open file %s for reading\n", argv[1]);
		return EXIT_FAILURE;
	}

	fseek(f, 0, SEEK_END);
	filesize = ftell(f);
	rewind(f);
	src = malloc(filesize + 1);
	fread(src, 1, filesize, f);
	fclose(f);

	src[filesize] = '\0';

	printf("Parsing...\n");
	n = nap_create(src);
	if (n->error) {
		printf("Parsing failed, error: %s\n", n->err);
	} else {
		printf("Parsing ok\n");
	}
	nap_free(n);

	free(n);
	free(src);

	return EXIT_SUCCESS;
}

/* semantic actions */
void
nap_function(nap *n, nap_token *func_name, nap_token *ret)
{
	printf("function '%s' returns '%s'\n", func_name->str, ret->str);
}

void
nap_class(nap *n, nap_token *class_name)
{
	printf("class '%s'\n", class_name->str);
}

void
nap_meet_pass(nap *n)
{
	printf("pass\n");
}


