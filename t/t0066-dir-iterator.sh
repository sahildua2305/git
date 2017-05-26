#!/bin/sh

test_description='Test directory iteration.'

. ./test-lib.sh

test_expect_success 'setup' '
	mkdir -p dir &&
	mkdir -p dir/a/b/c/ &&
	>dir/b &&
	>dir/c &&
	mkdir -p dir/d/e/d/ &&
	>dir/a/b/c/d &&
	>dir/a/e &&
	>dir/d/e/d/a &&

	mkdir -p dir2/a/b/c/ &&
	>dir2/a/b/c/d &&

	>file
'

cat >expect-sorted-output <<-\EOF &&
[d] (a) [a] ./dir/a
[d] (a/b) [b] ./dir/a/b
[d] (a/b/c) [c] ./dir/a/b/c
[d] (d) [d] ./dir/d
[d] (d/e) [e] ./dir/d/e
[d] (d/e/d) [d] ./dir/d/e/d
[f] (a/b/c/d) [d] ./dir/a/b/c/d
[f] (a/e) [e] ./dir/a/e
[f] (b) [b] ./dir/b
[f] (c) [c] ./dir/c
[f] (d/e/d/a) [a] ./dir/d/e/d/a
EOF

test_expect_success 'dir-iterator should iterate through all files' '
	test-dir-iterator --pre-order ./dir >out &&
	sort <out >./actual-pre-order-sorted-output &&

	test_cmp expect-sorted-output actual-pre-order-sorted-output
'

test_expect_success 'dir-iterator should iterate through all files on post-order mode' '
	test-dir-iterator --post-order ./dir >out &&
	sort <out >actual-post-order-sorted-output &&

	test_cmp expect-sorted-output actual-post-order-sorted-output
'


test_expect_success 'dir-iterator should list files properly on pre-order mode' '
	cat >expect-pre-order-output <<-\EOF &&
	[d] (a) [a] ./dir2/a
	[d] (a/b) [b] ./dir2/a/b
	[d] (a/b/c) [c] ./dir2/a/b/c
	[f] (a/b/c/d) [d] ./dir2/a/b/c/d
	EOF

	test-dir-iterator --pre-order ./dir2 >actual-pre-order-output &&
	test_cmp expect-pre-order-output actual-pre-order-output
'

test_expect_success 'dir-iterator should list files properly on post-order mode' '
	cat >expect-post-order-output <<-\EOF &&
	[f] (a/b/c/d) [d] ./dir2/a/b/c/d
	[d] (a/b/c) [c] ./dir2/a/b/c
	[d] (a/b) [b] ./dir2/a/b
	[d] (a) [a] ./dir2/a
	EOF

	test-dir-iterator --post-order ./dir2 >actual-post-order-output &&
	test_cmp expect-post-order-output actual-post-order-output
'

test_expect_success 'dir-iterator should list files properly on pre-order + post-order + root-dir mode' '
	cat >expect-pre-order-post-order-root-dir-output <<-\EOF &&
	[d] (.) [dir2] ./dir2
	[d] (a) [a] ./dir2/a
	[d] (a/b) [b] ./dir2/a/b
	[d] (a/b/c) [c] ./dir2/a/b/c
	[f] (a/b/c/d) [d] ./dir2/a/b/c/d
	[d] (a/b/c) [c] ./dir2/a/b/c
	[d] (a/b) [b] ./dir2/a/b
	[d] (a) [a] ./dir2/a
	[d] (.) [dir2] ./dir2
	EOF

	test-dir-iterator --pre-order --post-order --list-root-dir ./dir2 >actual-pre-order-post-order-root-dir-output &&
	test_cmp expect-pre-order-post-order-root-dir-output actual-pre-order-post-order-root-dir-output
'

test_expect_success 'dir-iterator should return ENOENT upon opening non-existing directory' '
	cat >expect-non-existing-dir-output <<-\EOF &&
	begin failed: 2
	EOF

	test-dir-iterator ./dir3 >actual-non-existing-dir-output &&
	test_cmp expect-non-existing-dir-output actual-non-existing-dir-output
'

test_expect_success 'dir-iterator should return ENOTDIR upon opening non-directory path' '
	cat >expect-not-a-directory-output <<-\EOF &&
	begin failed: 20
	EOF

	test-dir-iterator ./file >actual-not-a-directory-output &&
	test_cmp expect-not-a-directory-output actual-not-a-directory-output
'

test_done
