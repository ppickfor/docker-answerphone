#!/bin/bash
get_git_repo_version () {
	repo_dir=${1:?specify repodirectory}
	var=${2}
	ver=$(cd  ${repo_dir};git describe --long --tags origin/master | sed 's/\([^-]*-g\)/r\1/;s/-/./g' )
	if [[ -z "$var" ]]
	then
		retunr $ver
	else
		eval "$var=$ver"
	fi
}
get_git_repo_version ~/work/mgetty MGETTY_VGETTY_GIT_VERSION
get_git_repo_version ~/work/vocp VOCP_GIT_VERSION
docker build --build-arg=MGETTY_VGETTY_GIT_VERSION=${MGETTY_VGETTY_GIT_VERSION} --build-arg=VOCP_GIT_VERSION=${VOCP_GIT_VERSION} -t ppickfor/answerphone .
