#!/bin/bash

# based on:
#   https://github.com/mailslurper/mailslurper

TMP_CWD="$(pwd)"

function _buildBin() {
	echo -e "\n- go get...\n"
	go get || exit 1

	echo -e "\n- go generate...\n"
	go generate || exit 1

	echo -e "\n- go build...\n"
	go build || exit 1
}

[ -z "$CF_CPUARCH_DEB_DIST" ] && {
	echo "Empty env var CF_CPUARCH_DEB_DIST. Aborting." >/dev/stderr
	exit 1
}

echo -e "\n- cd src\n"
cd src || exit 1

[ ! -d github.com/mailslurper ] && {
	mkdir -p github.com/mailslurper || exit 1
}

echo -e "- cd github.com/mailslurper\n"
cd github.com/mailslurper || exit 1

echo -e "- Clone mailslurper git repo...\n"
[ ! -d mailslurper ] && {
	git clone https://github.com/mailslurper/mailslurper.git || exit 1
}

if [ ! -d ../mjibson/esc ]; then
	echo -e "\n- go get github.com/mjibson/esc...\n"
	go get github.com/mjibson/esc || exit 1
fi

echo -e "\n- cd mailslurper/cmd/mailslurper\n"
cd mailslurper/cmd/mailslurper || exit 1

[ ! -x mailslurper ] && _buildBin

echo -e "\n- cd ../createcredentials\n"
cd ../createcredentials || exit 1

[ ! -x createcredentials ] && _buildBin

cd "$TMP_CWD"

TMP_MS_BD="$TMP_CWD/src/github.com/mailslurper/mailslurper"

TMP_MS_VERS_FN="$TMP_MS_BD/cmd/mailslurper/version.json"
[ ! -f "$TMP_MS_VERS_FN" ] && {
	echo "Could not find '$TMP_MS_VERS_FN'. Aborting." >/dev/stderr
	exit 1
}

TMP_MS_VERS_NR="$(grep '"version":' "$TMP_MS_VERS_FN" | cut -f2 -d: | cut -f2 -d\")"
[ -z "$TMP_MS_VERS_NR" ] && {
	echo "Empty version number in TMP_MS_VERS_NR. Aborting." >/dev/stderr
	exit 1
}

TMP_TAR_BFN="mailslurper-$TMP_MS_VERS_NR-$CF_CPUARCH_DEB_DIST"

if [ ! -f "release/$TMP_TAR_BFN.tgz" ]; then
	TMP_REL_DIR="release/$TMP_TAR_BFN"
	[ ! -d "$TMP_REL_DIR" ] && {
		mkdir -p "$TMP_REL_DIR" || exit 1
	}

	echo -e "\n- cd $TMP_CWD/$TMP_REL_DIR\n"
	cd "$TMP_REL_DIR" || exit 1

	echo -e "\n- Copy release files...\n"

	cp "$TMP_MS_BD/cmd/mailslurper/config.json" . || exit 1
	cp "$TMP_MS_BD/LICENSE" . || exit 1
	cp "$TMP_MS_BD/logo/logo.png" . || exit 1
	cp "$TMP_MS_BD/README.md" . || exit 1
	cp "$TMP_MS_BD/bin/create-mssql.sql" . || exit 1
	cp "$TMP_MS_BD/bin/create-mysql.sql" . || exit 1
	cp "$TMP_MS_BD/cmd/mailslurper/mailslurper" . || exit 1
	cp "$TMP_MS_BD/cmd/createcredentials/createcredentials" . || exit 1

	echo -e "\n- cd ..\n"
	cd ..

	echo -e "\n- Create tarball '$TMP_TAR_BFN.tgz'\n"
	tar czf "$TMP_TAR_BFN.tgz" "$TMP_TAR_BFN" || exit 1
	rm -r "$TMP_TAR_BFN" || exit 1
fi

echo -e "\n- done.\n"

cd "$TMP_CWD"

exit 0
