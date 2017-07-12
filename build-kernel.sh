#!/bin/bash
set -e
set -x
KERNEL_REPO="https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git"
UPSTREAM_BRANCH="linux-4.11.y"
kernel_version="v4.9.36"


kernel_path=$(pwd)/cc-linux

die() {
	echo >&2 -e "\e[1mERROR\e[0m: $*"
	exit 1
}

info() {
	echo -e "\e[1mINFO\e[0m: $*"
}

usage() { 
	echo "Usage: $0 <subcommand>" 1>&2;
	echo "Options:" 1>&2;
	echo "-h                  : show this help" 1>&2;
	echo "-k <kernel-path>    : path to pull linux kernel and use to build" 1>&2;
	echo "-v <x.y.x>         : kernel version to build example 4.9.36 " 1>&2;
	echo "" 1>&2;
	echo "Subcommands:" 1>&2;
	echo "prepare : clone linux source code and patch it with clear-containers configuration" 1>&2;
	echo "build   : build a kernel configured by prepare subcommand" 1>&2;
	exit 1; 
}                                                                                                 

prepare_kernel(){
	#--depth n to not pull all the kernel
	if [ ! -d "$kernel_path" ]; then
		git clone --depth 1 -b "${UPSTREAM_BRANCH}" "${KERNEL_REPO}" "${kernel_path}"
	fi
	pushd "$kernel_path"
		git remote set-branches origin '*'
		info "fetch version ${kernel_version}"
		git fetch origin tag ${kernel_version} --depth 1 || die "failed to fetch changes from ${kernel_version} branch"
		info "deleting old backup branch linux-container-old"
		git branch -D linux-container-old || true
		info "Moving linux-container branch to linux-container-old"
		git branch -m linux-container linux-container-old || true
		info "Creating branch linux-container branch"
		git checkout -b linux-container "${kernel_version}" || die "failed to create branch linux-container"
		info "Patching linux source code"
		if ! git am ../patches-4.9.x/*; then
			git am --abort && true
			die "failed to apply patches" 
		fi
		info "Using $CONFIG Clear Containers configuration"
		ln -sf "../kernel-config-4.9.x" "$(pwd)/.config"
	popd
}

build_kernel(){
	[ -d "$kernel_path" ] || die "${kernel_path} repository not found, use run $0 prepare"
	pushd "$kernel_path"
	make -j"$(nproc)" || die "failed to build vmlinux"
		[ -f "$kernel_path/vmlinux" ] || die "failed to generate vmlinux"
		info "Kernel ready in $kernel_path/vmlinux"
	popd
}

while getopts hk:v: opt
do
	case $opt in
		h)	usage ;;
		k)	kernel_path="${OPTARG}" ;;
		v)	kernel_version=v"${OPTARG}" ;;
	esac
done

shift $(($OPTIND - 1))
SUBCOMMAND=$1

case "$SUBCOMMAND" in
	prepare)
		prepare_kernel "$@"                                                                        
		;;
	build)
		build_kernel "$@"                                                                        
		;;
	*)
		usage
		exit 1
		;;
esac
