#!/bin/bash

TMP_CWD="$(pwd)"

[ -z "$CF_CPUARCH_DEB_DIST" ] && {
	echo "Empty env var CF_CPUARCH_DEB_DIST. Aborting." >/dev/stderr
	exit 1
}

TMP_MH_VERS="head"

echo -e "\n- cd src\n"
cd src || exit 1

[ ! -d github.com/mailhog ] && {
	echo -e "- go get github.com/mailhog/MailHog\n"
	go get github.com/mailhog/MailHog || exit 1
}

echo -e "- cd github.com/mailhog\n"
cd github.com/mailhog || exit 1

echo -e "\n- cd MailHog\n"
cd MailHog || exit 1

[ ! -x MailHog ] && {
	echo -e "\n- go build\n"
	go build || exit 1
}

cd "$TMP_CWD"

TMP_MS_BD="$TMP_CWD/src/github.com/mailhog/MailHog"

TMP_TAR_BFN="mailhog-$TMP_MH_VERS-$CF_CPUARCH_DEB_DIST"

if [ ! -f "release/$TMP_TAR_BFN.tgz" ]; then
	TMP_REL_DIR="release/$TMP_TAR_BFN"
	[ ! -d "$TMP_REL_DIR" ] && {
		mkdir -p "$TMP_REL_DIR" || exit 1
	}

	echo -e "\n- cd $TMP_CWD/$TMP_REL_DIR\n"
	cd "$TMP_REL_DIR" || exit 1

	echo -e "\n- Copy release files...\n"

	cp "$TMP_MS_BD/MailHog" . || exit 1

	echo -e "\n- cd ..\n"
	cd ..

	echo -e "\n- Create tarball '$TMP_TAR_BFN.tgz'\n"
	tar czf "$TMP_TAR_BFN.tgz" "$TMP_TAR_BFN" || exit 1
	rm -r "$TMP_TAR_BFN" || exit 1
fi

echo -e "\n- done.\n"

cd "$TMP_CWD"

exit 0
