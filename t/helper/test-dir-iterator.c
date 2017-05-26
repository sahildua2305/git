#include "git-compat-util.h"
#include "strbuf.h"
#include "iterator.h"
#include "dir-iterator.h"

int cmd_main(int argc, const char **argv)
{
	const char **myargv = argv;
	int myargc = argc;

	struct strbuf path = STRBUF_INIT;
	struct dir_iterator *diter;

	unsigned flag = 0;

	while (--myargc && starts_with(*++myargv, "--")) {
		if (!strcmp(*myargv, "--pre-order"))
			flag |= DIR_ITERATOR_PRE_ORDER_TRAVERSAL;
		else if (!strcmp(*myargv, "--post-order"))
			flag |= DIR_ITERATOR_POST_ORDER_TRAVERSAL;
		else if (!strcmp(*myargv, "--list-root-dir"))
			flag |= DIR_ITERATOR_LIST_ROOT_DIR;
		else if (!strcmp(*myargv, "--")) {
			myargc--;
			myargv++;
			break;
		} else
			die("Unrecognized option: %s", *myargv);
	}

	if (myargc != 1)
		die("expected exactly one non-option argument");
	strbuf_addstr(&path, *myargv);

	diter = dir_iterator_begin(path.buf, flag);
	if (diter == NULL) {
		printf("begin failed: %d\n", errno);
		return 0;
	}

	while (dir_iterator_advance(diter) == ITER_OK) {
		if (S_ISDIR(diter->st.st_mode))
			printf("[d] ");
		else if (S_ISREG(diter->st.st_mode))
			printf("[f] ");
		else
			printf("[?] ");

		printf("(%s) [%s] %s\n", diter->relative_path, diter->basename, diter->path.buf);
	}

	return 0;
}
