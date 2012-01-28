# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: qt4-build-edge.eclass
# @MAINTAINER:
# Qt herd <qt@gentoo.org>
# @BLURB: Eclass for Qt4 split ebuilds in qting-edge overlay.
# @DESCRIPTION:
# This eclass contains various functions that are used when building Qt4.

# WARNING: This eclass requires EAPI=2 or EAPI=3
#
# NOTES:
#
#	4.9999 and 4.?.9999[-kde-qt]
#			stands for live ebuilds from qtsoftware's git repository
#			(that is Nokia, previously trolltech)
#	4.?.9999[kde-qt]
#			stands for live ebuilds from kde-qt git repository
#	4.*.*_{beta,rc,}* and *
#			are official releases or snapshots from Nokia
#

MY_EGIT_COMMIT=${EGIT_COMMIT:=}

inherit eutils git-2 qt4-build

if [[ ${PV} == *.9999 ]]; then
	SRC_URI=
	DEPEND="dev-lang/perl"
fi

# @FUNCTION: qt4-build-edge_pkg_setup
# @DESCRIPTION:
# Sets up PATH, {,DY}LD_LIBRARY_PATH and EGIT_* variables.
qt4-build-edge_pkg_setup() {
	debug-print-function $FUNCNAME "$@"

	MY_PV_EXTRA="${PV}"

	case "${MY_PV_EXTRA}" in
		4.?.9999)
			EGIT_REPO_URI="git://gitorious.org/qt/qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="${MY_PV_EXTRA/.9999}"
			;;
		4.9999)
			EGIT_REPO_URI="git://gitorious.org/qt/qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="master"
			;;
	esac

	EGIT_COMMIT=${MY_EGIT_COMMIT:=${EGIT_BRANCH}}

	# Let users know what they are getting themselves into ;-)
	if [[ -z ${I_KNOW_WHAT_I_AM_DOING} ]]; then
		echo
		ewarn "Please file bugs on bugs.gentoo.org and prepend the summary"
		ewarn "with [qting-edge]. Alternatively, contact <qt@gentoo.org>."
		ewarn "Thank you for using qting-edge overlay."
		ewarn
		case "${MY_PV_EXTRA}" in
			4.?.9999 | 4.9999)
				ewarn "The ${PV} version ebuilds install live git code from Nokia Qt Software."
				;;
			4.*.*_*)
				ewarn "The ${PV} version ebuilds install a pre-release from Nokia Qt Software."
				;;
		esac
		echo
	fi

	qt4-build_pkg_setup
}

# @ECLASS-VARIABLE: QT4_TARGET_DIRECTORIES
# @DESCRIPTION:
# Arguments for build_target_directories. Takes the directories in which the
# code should be compiled. This is a space-separated list of relative paths.

# @ECLASS-VARIABLE: QT4_EXTRACT_DIRECTORIES
# @DESCRIPTION:
# Space-separated list of directories that will be extracted from Qt tarball.

# @FUNCTION: qt4-build-edge_src_unpack
# @DESCRIPTION:
# Unpacks the sources.
qt4-build-edge_src_unpack() {
	debug-print-function $FUNCNAME "$@"
	setqtenv

	local target= targets=
	for target in configure LICENSE.{GPL3,LGPL} projects.pro \
			src/{qbase,qt_targets,qt_install}.pri \
			bin config.tests mkspecs qmake \
			${QT4_EXTRACT_DIRECTORIES}; do
		targets+=" ${MY_P}/${target}"
	done

	case "${PV}" in
		*.9999)
			git-2_src_unpack
			;;
		*)
			echo tar xzf "${DISTDIR}"/${MY_P}.tar.gz ${targets}
			tar xzf "${DISTDIR}"/${MY_P}.tar.gz ${targets} || die
			;;
	esac
}

# @ECLASS-VARIABLE: PATCHES
# @DESCRIPTION:
# In case you have patches to apply, specify them here. Make sure to specify
# the full path. This variable is necessary for src_prepare phase.
# Example:
# PATCHES=( "${FILESDIR}"/mypatch.patch
# "${FILESDIR}"/mypatch2.patch )

# @FUNCTION: qt4-build-edge_src_prepare
# @DESCRIPTION:
# Prepares the sources before the configure phase. Strips C(XX)FLAGS if necessary, and fixes
# source files in order to respect CFLAGS/CXXFLAGS/LDFLAGS specified on /etc/make.conf.
qt4-build-edge_src_prepare() {
	debug-print-function $FUNCNAME "$@"
	generate_include
	# We need to remove any specific hardcoded compiler flags
	sed -i -e '/^QMAKE_CFLAGS[^_.*]/s:\+=.*:=:' \
		-e '/^QMAKE_CXXFLAGS[^_.*]/s:\+=.*:=:' \
		-e '/^QMAKE_LFLAGS[^_.*]/s:\+=.*:=:' \
		"${S}"/mkspecs/common/g++.conf

	qt4-build_src_prepare
}

# @FUNCTION: qt4-build-edge_src_configure
# @DESCRIPTION:
# Runs ./configure with appropriate arguments. You can use
# the ${myconf} variable to pass additional arguments.
qt4-build-edge_src_configure() {
	debug-print-function $FUNCNAME "$@"
	qt4-build_src_configure
}

# @FUNCTION: qt4-build-edge_src_compile
# @DESCRIPTION:
# Compiles the code in ${QT4_TARGET_DIRECTORIES}.
qt4-build-edge_src_compile() {
	debug-print-function $FUNCNAME "$@"
	qt4-build_src_compile
}

# @FUNCTION: qt4-build-edge_src_install
# @DESCRIPTION:
# Performs the actual installation including some library fixes.
qt4-build-edge_src_install() {
	debug-print-function $FUNCNAME "$@"
	qt4-build_src_install
}

# @FUNCTION: qt4-build-edge_src_test
# @DESCRIPTION:
# Runs make check in target directories only (required for live ebuilds).
qt4-build-edge_src_test() {
	debug-print-function $FUNCNAME "$@"
	qt4-build_src_test
}

# @FUNCTION: qt4-build-edge_pkg_postrm
# @DESCRIPTION:
# Generates configuration when the package is completely removed.
qt4-build-edge_pkg_postrm() {
	debug-print-function $FUNCNAME "$@"
	qt4-build_pkg_postrm
}

# @FUNCTION: qt4-build-edge_pkg_postinst
# @DESCRIPTION:
# Generates configuration after the package is installed.
qt4-build-edge_pkg_postinst() {
	debug-print-function $FUNCNAME "$@"
	qt4-build_pkg_postinst
}

# @FUNCTION: generate_include
# @DESCRIPTION:
# Internal function, required for live ebuilds.
generate_include() {
	QTDIR="." perl bin/syncqt
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_install src_test pkg_postrm pkg_postinst
