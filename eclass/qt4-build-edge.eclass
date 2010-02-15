# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: qt4-build-edge.eclass
# @MAINTAINER:
# Qt herd <qt@gentoo.org>
# @BLURB: Eclass for Qt4 split ebuilds in qting-edge overlay.
# @DESCRIPTION:
# This eclass contains various functions that are used when building Qt4

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

inherit base eutils multilib toolchain-funcs flag-o-matic git versionator

MY_PV=${PV/_/-}
MY_PV=${MY_PV/alpha-pre/tp}
if version_is_at_least 4.5.99999999; then
	MY_P=qt-everywhere-opensource-src-${MY_PV}
else
	MY_P=qt-x11-opensource-src-${MY_PV}
fi

HOMEPAGE="http://qt.nokia.com/"
SRC_URI="http://get.qt.nokia.com/qt/source/${MY_P}.tar.gz"
[[ ${PV} == *.9999 ]] && SRC_URI=

LICENSE="|| ( LGPL-2.1 GPL-3 )"

IUSE="aqua debug pch"
if [[ ${CATEGORY}/${PN} != x11-libs/qt-xmlpatterns ]]; then
	if [[ ${CATEGORY}/${PN} == x11-libs/qt-core ]]; then
		# >=qt-xmlpatterns-4.6 needs this enabled in qt-core
		# so lets enable it by default and save some users
		# the trouble of remerging it
		IUSE="${IUSE} +exceptions"
	else
		IUSE="${IUSE} exceptions"
	fi
fi
case "${PV}" in
	4.9999)
		IUSE="${IUSE} +stable-branch"
		;;
	4.6.9999)
		IUSE="${IUSE} stable-branch +kde-qt"
		;;
	4.5.9999)
		IUSE="${IUSE} +kde-qt"
		;;
esac

[[ ${PV} == *.9999 ]] && DEPEND="dev-lang/perl"
RDEPEND="
	!<x11-libs/qt-assistant-${PV}
	!>x11-libs/qt-assistant-${PV}-r9999
	!<x11-libs/qt-core-${PV}
	!>x11-libs/qt-core-${PV}-r9999
	!<x11-libs/qt-dbus-${PV}
	!>x11-libs/qt-dbus-${PV}-r9999
	!<x11-libs/qt-demo-${PV}
	!>x11-libs/qt-demo-${PV}-r9999
	!<x11-libs/qt-gui-${PV}
	!>x11-libs/qt-gui-${PV}-r9999
	!<x11-libs/qt-multimedia-${PV}
	!>x11-libs/qt-multimedia-${PV}-r9999
	!<x11-libs/qt-opengl-${PV}
	!>x11-libs/qt-opengl-${PV}-r9999
	!<x11-libs/qt-phonon-${PV}
	!>x11-libs/qt-phonon-${PV}-r9999
	!<x11-libs/qt-qt3support-${PV}
	!>x11-libs/qt-qt3support-${PV}-r9999
	!<x11-libs/qt-script-${PV}
	!>x11-libs/qt-script-${PV}-r9999
	!<x11-libs/qt-sql-${PV}
	!>x11-libs/qt-sql-${PV}-r9999
	!<x11-libs/qt-svg-${PV}
	!>x11-libs/qt-svg-${PV}-r9999
	!<x11-libs/qt-test-${PV}
	!>x11-libs/qt-test-${PV}-r9999
	!<x11-libs/qt-webkit-${PV}
	!>x11-libs/qt-webkit-${PV}-r9999
	!<x11-libs/qt-xmlpatterns-${PV}
	!>x11-libs/qt-xmlpatterns-${PV}-r9999
"

S=${WORKDIR}/${MY_P}

# @FUNCTION: qt4-build-edge_pkg_setup
# @DESCRIPTION:
# Sets up PATH, {,DY}LD_LIBRARY_PATH and EGIT_* variables.
qt4-build-edge_pkg_setup() {
	case "${PV}" in
		4.9999)
			if use stable-branch; then
				MY_PV_EXTRA="${PV}-stable"
			else
				MY_PV_EXTRA="${PV}"
			fi
			;;
		4.6.9999)
			if use kde-qt; then
				if use stable-branch; then
					MY_PV_EXTRA="${PV}-kde-qt-stable"
				else
					MY_PV_EXTRA="${PV}-kde-qt"
				fi
			else
				if use stable-branch; then
					MY_PV_EXTRA="${PV}-stable"
				else
					MY_PV_EXTRA="${PV}"
				fi
			fi
			;;
		4.5.9999)
			if use kde-qt; then
				MY_PV_EXTRA="${PV}-kde-qt"
			else
				MY_PV_EXTRA="${PV}"
			fi
			;;
		*)
			MY_PV_EXTRA="${PV}"
			;;
	esac

	case "${MY_PV_EXTRA}" in
		4.6.9999-kde-qt-stable)
			EGIT_REPO_URI="git://gitorious.org/+kde-developers/qt/kde-qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="4.6-stable-patched"
			EGIT_COMMIT="${EGIT_BRANCH}"
			;;
		4.6.9999-kde-qt)
			EGIT_REPO_URI="git://gitorious.org/+kde-developers/qt/kde-qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="master"
			EGIT_COMMIT="${EGIT_BRANCH}"
			;;
		4.5.9999-kde-qt)
			EGIT_REPO_URI="git://gitorious.org/+kde-developers/qt/kde-qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="4.5.3-patched"
			EGIT_COMMIT="${EGIT_BRANCH}"
			;;
		4.?.9999 | 4.?.9999-stable)
			EGIT_REPO_URI="git://gitorious.org/qt/qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="${MY_PV_EXTRA/.9999}"
			EGIT_COMMIT="${EGIT_BRANCH}"
			;;
		4.9999-stable)
			EGIT_REPO_URI="git://gitorious.org/qt/qt.git"
			EGIT_PROJECT="qt-${PV}"
			EGIT_BRANCH="master-stable"
			EGIT_COMMIT="${EGIT_BRANCH}"
			;;
		4.9999)
			EGIT_REPO_URI="git://gitorious.org/qt/qt.git"
			EGIT_PROJECT="qt-${PV}"
			;;
	esac

	if [[ -z ${I_KNOW_WHAT_I_AM_DOING} ]]; then
		ewarn
		ewarn "Please file bugs on bugs.gentoo.org and prepend the summary"
		ewarn "with [qting-edge]. Alternatively, contact <qt@gentoo.org>."
		ewarn "Thank you for using qting-edge overlay."
		ewarn
	fi

	[[ ${EAPI} == 2 ]] && use !prefix && EPREFIX=

	PATH="${S}/bin${PATH:+:}${PATH}"
	if [[ ${CHOST} != *-darwin* ]]; then
		LD_LIBRARY_PATH="${S}/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"
	else
		DYLD_LIBRARY_PATH="${S}/lib${DYLD_LIBRARY_PATH:+:}${DYLD_LIBRARY_PATH}"
		# On MacOS we *need* at least src/gui/kernel/qapplication_mac.mm for
		# platform detection. Note: needs to come before any directories to
		# avoid extract failure.
		[[ ${CHOST} == *-apple-darwin* ]] && \
			QT4_EXTRACT_DIRECTORIES="src/gui/kernel/qapplication_mac.mm ${QT4_EXTRACT_DIRECTORIES}"
	fi

	# Make sure ebuilds use the required EAPI
	if [[ ${EAPI} != [23] ]]; then
		eerror "The ${ECLASS} eclass requires EAPI=2 or EAPI=3, but this ebuild is using EAPI=${EAPI:-0}."
		eerror "The ebuild author or editor failed. This ebuild needs to be fixed."
		die "${ECLASS} eclass requires EAPI=2 or EAPI=3"
	fi

	# Let users know what they are getting themselves into ;-)
	if [[ -z ${I_KNOW_WHAT_I_AM_DOING} ]]; then
		echo
		case "${MY_PV_EXTRA}" in
			4.?.9999-kde-qt)
				ewarn "The ${PV} version ebuilds with kde-qt USE flag install kde-qt from gitorious kde-qt repository."
				;;
			4.?.9999-kde-qt-stable)
				ewarn "The ${PV} version ebuilds with kde-qt and stable-branch	USE flags install kde-qt from"
				ewarn "gitorious kde-qt repository, '4.6-stable-patched' branch."
				;;
			4.?.9999-stable | 4.9999-stable)
				ewarn "The ${PV} version ebuilds install live git code from Nokia Qt Software - stable branch."
				ewarn "See http://labs.trolltech.com/blogs/2009/07/28/getting-the-best-out-of-two-worlds/"
				;;
			4.?.9999 | 4.9999)
				ewarn "The ${PV} version ebuilds install live git code from Nokia Qt Software."
				;;
			4.6.0_alpha_pre*)
				ewarn "The ${PV} version ebuilds install a technical preview from Nokia Qt Software."
				ewarn "See http://labs.trolltech.com/blogs/2009/09/09/qt-460-tech-preview-1/"
				;;
			4.*.*_*)
				ewarn "The ${PV} version ebuilds install a pre-release from Nokia Qt Software."
				;;
		esac
		echo
	fi

	if ! version_is_at_least 4.1 $(gcc-version); then
		ewarn "Using a GCC version lower than 4.1 is not supported!"
		echo
	fi
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
	setqtenv

	local target= targets=
	for target in configure LICENSE.{GPL3,LGPL} projects.pro \
			src/{qbase,qt_targets,qt_install}.pri \
			bin config.tests mkspecs qmake \
			${QT4_EXTRACT_DIRECTORIES}; do
		targets="${targets} ${MY_P}/${target}"
	done

	case "${PV}" in
		*.9999)
			git_src_unpack
			;;
		*)
			echo tar xzpf "${DISTDIR}"/${MY_P}.tar.gz ${targets}
			tar xzpf "${DISTDIR}"/${MY_P}.tar.gz ${targets} || die
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
	setqtenv

	[[ ${PV} == *.9999 ]] && generate_include

	if [[ ${PN} != qt-core ]]; then
		skip_qmake_build
		skip_project_generation
		symlink_binaries_to_buildtree
	fi

	# qmake bus errors with -O2 but -O3 works
	[[ ${CHOST} == *86*-apple-darwin* ]] && replace-flags -O2 -O3

	# Bug 282984 && Bug 295530
	sed -e "s:\(^SYSTEM_VARIABLES\):CC=$(tc-getCC)\nCXX=$(tc-getCXX)\n\1:" \
		-i configure || die "sed qmake compilers failed"
	sed -e "s:\(\$MAKE\):\1 CC=$(tc-getCC) CXX=$(tc-getCXX) LD=$(tc-getCXX):" \
		-i config.tests/unix/compile.test || die "sed configure tests compilers failed"

	# Bug 178652
	if [[ $(gcc-major-version) == 3 ]] && use amd64; then
		ewarn "Appending -fno-gcse to CFLAGS/CXXFLAGS"
		append-flags -fno-gcse
	fi

	# Unsupported old gcc versions - hardened needs this :(
	if [[ $(gcc-major-version) -lt 4 ]] ; then
		ewarn "Appending -fno-stack-protector to CXXFLAGS"
		append-cxxflags -fno-stack-protector
		# Bug 253127
		sed -e "/^QMAKE_CFLAGS\t/ s:$: -fno-stack-protector-all:" \
			-i "${S}"/mkspecs/common/g++.conf \
			|| die "sed mkspecs/common/g++.conf failed"
	fi

	# Bug 261632
	if use ppc64; then
		ewarn "Appending -mminimal-toc to CFLAGS/CXXFLAGS"
		append-flags -mminimal-toc
	fi

	# Bug 172219
	sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
		-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
		-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
		-e "s:X11R6/::" \
		-i "${S}"/mkspecs/$(qt_mkspecs_dir)/qmake.conf \
		|| die "sed mkspecs/$(qt_mkspecs_dir)/qmake.conf failed"

	if [[ ${CHOST} != *-darwin* ]]; then
		sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
			-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
			-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=${LDFLAGS}:" \
			-i "${S}"/mkspecs/common/g++.conf \
			|| die "sed mkspecs/common/g++.conf failed"
	else
		# Set FLAGS *and* remove -arch, since our gcc-apple is multilib
		# crippled (by design) :/
		sed -e "s:QMAKE_CFLAGS_RELEASE.*=.*:QMAKE_CFLAGS_RELEASE=${CFLAGS}:" \
			-e "s:QMAKE_CXXFLAGS_RELEASE.*=.*:QMAKE_CXXFLAGS_RELEASE=${CXXFLAGS}:" \
			-e "s:QMAKE_LFLAGS_RELEASE.*=.*:QMAKE_LFLAGS_RELEASE=-headerpad_max_install_names ${LDFLAGS}:" \
			-e "s:-arch\s\w*::g" \
			-i "${S}"/mkspecs/common/mac-g++.conf \
			|| die "sed mkspecs/common/mac-g++.conf failed"

		# Fix configure's -arch settings that appear in qmake/Makefile and also
		# fix arch handling (automagically duplicates our -arch arg and breaks
		# pch). Additionally disable Xarch support.
		sed \
			-e "s:-arch i386::" \
			-e "s:-arch ppc::" \
			-e "s:-arch x86_64::" \
			-e "s:-arch ppc64::" \
			-e "s:-arch \$i::" \
			-e "/if \[ ! -z \"\$NATIVE_64_ARCH\" \]; then/,/fi/ d" \
			-e "s:CFG_MAC_XARCH=yes:CFG_MAC_XARCH=no:g" \
			-e "s:-Xarch_x86_64::g" \
			-e "s:-Xarch_ppc64::g" \
			-i configure mkspecs/common/mac-g++.conf \
			|| die "sed configure failed"

		# On Snow Leopard don't fall back to 10.5 deployment target.
		if [[ ${CHOST} == *-apple-darwin10 ]] ; then
			sed -e "s:QMakeVar set QMAKE_MACOSX_DEPLOYMENT_TARGET.*:QMakeVar set QMAKE_MACOSX_DEPLOYMENT_TARGET 10.6:g" \
				-e "s:-mmacosx-version-min=10.[0-9]:-mmacosx-version-min=10.6:g" \
				-i configure mkspecs/common/mac-g++.conf || die "sed configure failed"
		fi
	fi

	# this one is needed for all systems with a separate -liconv, apart from
	# Darwin, for which the sources already cater for -liconv
	if use !elibc_glibc && [[ ${CHOST} != *-darwin* ]] ; then
		sed \
			-e "s|mac:LIBS += -liconv|LIBS += -liconv|g" \
			-i config.tests/unix/iconv/iconv.pro \
			|| die "sed on iconv.pro failed"
	fi

	# Solaris support
	sed -i -e '/^QMAKE_LFLAGS_THREAD/a\QMAKE_LFLAGS_DYNAMIC_LIST = -Wl,--dynamic-list,' \
		mkspecs/$(qt_mkspecs_dir)/qmake.conf || die
	# use GCC over SunStudio
	sed -i -e '/PLATFORM=solaris-cc/s/cc/g++/' configure || die
	# don't flirt with non-Prefix stuff, we're quite possessive
	sed -i -e '/^QMAKE_\(LIB\|INC\)DIR\(_X11\|_OPENGL\|\)\t/s/=.*$/=/' \
		mkspecs/$(qt_mkspecs_dir)/qmake.conf || die

	# Bug 275710
	# Avoid adding C[XX]FLAGS to .qmake.cache as this is used in addition
	# to the mkspecs while building qt
	sed -e "s:SYSTEM_VARIABLES=\"CC CXX CFLAGS CXXFLAGS LDFLAGS\":SYSTEM_VARIABLES=\"CC CXX\":" \
		-i "${S}"/configure || die "sed configure failed"

	base_src_prepare
}

# @FUNCTION: qt4-build-edge_src_configure
# @DESCRIPTION:
# Runs ./configure with appropriate arguments. You can use
# the ${myconf} variable to pass additional arguments.
qt4-build-edge_src_configure() {
	setqtenv

	myconf="$(standard_configure_options) ${myconf}"

	# This one is needed for all systems with a separate -liconv, apart from
	# Darwin, for which the sources already cater for -liconv
	use !elibc_glibc && [[ ${CHOST} != *-darwin* ]] && \
		myconf="${myconf} -liconv"

	if has glib ${IUSE//+} && use glib; then
		# use -I, -L and -l from configure
		local glibflags="$(pkg-config --cflags --libs glib-2.0 gthread-2.0)"
		# avoid the -pthread argument
		myconf="${myconf} ${glibflags//-pthread}"
		unset glibflags
	fi

	if use aqua ; then
		# On (snow) leopard use the new (frameworked) cocoa code.
		if [[ ${CHOST##*-darwin} -ge 9 ]] ; then
			myconf="${myconf} -cocoa -framework"

			# We are crazy and build cocoa + qt3support :-)
			if use qt3support; then
				sed -e "/case \"\$PLATFORM,\$CFG_MAC_COCOA\" in/,/;;/ s|CFG_QT3SUPPORT=\"no\"|CFG_QT3SUPPORT=\"yes\"|" \
					-i configure || die
			fi

			# We need the source's headers, not the installed ones.
			myconf="${myconf} -I${S}/include"

			# Add hint for the framework location.
			myconf="${myconf} -F${QTLIBDIR}"
		fi
	else
		# freetype2 include dir is non-standard, thus include it on configure
		# use -I from configure
		myconf="${myconf} $(pkg-config --cflags freetype2)"
	fi

	echo ./configure ${myconf}
	./configure ${myconf} || die "configure failed"

	unset myconf
}

# @FUNCTION: qt4-build-edge_src_compile
# @DESCRIPTION:
# Compiles the code in ${QT4_TARGET_DIRECTORIES}.
qt4-build-edge_src_compile() {
	setqtenv
	build_directories ${QT4_TARGET_DIRECTORIES}
}

# @FUNCTION: fix_includes
# @DESCRIPTION:
# For MacOSX we need to add some symlinks when frameworks are
# being used, to avoid complications with some more or less stupid packages.
fix_includes() {
	if use aqua && [[ ${CHOST##*-darwin} -ge 9 ]] ; then
		# Some packages tend to include <Qt/...>
		dodir "${QTHEADERDIR#${EPREFIX}}"/Qt

		# Fake normal headers when frameworks are installed... eases life later on
		local dest f
		for frw in "${D}${QTLIBDIR}"/*.framework; do
			[[ -e "${frw}"/Headers ]] || continue
			f=$(basename ${frw})
			dest="${QTHEADERDIR#${EPREFIX}}"/${f%.framework}
			dosym "${QTLIBDIR#${EPREFIX}}"/${f}/Headers "${dest}"

			# Link normal headers as well
			for hdr in "${D}/${QTLIBDIR}/${f}"/Headers/*; do
				h=$(basename ${hdr})
				dosym "${QTLIBDIR#${EPREFIX}}"/${f}/Headers/${h} "${QTHEADERDIR#${EPREFIX}}"/Qt/${h}
			done
		done
	fi
}

# @FUNCTION: qt4-build-edge_src_install
# @DESCRIPTION:
# Performs the actual installation including some library fixes.
qt4-build-edge_src_install() {
	[[ ${EAPI} == 2 ]] && use !prefix && ED=${D}
	setqtenv
	install_directories ${QT4_TARGET_DIRECTORIES}
	install_qconfigs
	fix_library_files
	fix_includes
}

# @FUNCTION: setqtenv
# @DESCRIPTION:
# Prepares the environment. This function is called
# at the beginning of each ebuild phase.
setqtenv() {
	QTBASEDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QTPREFIXDIR=${EPREFIX}/usr
	QTBINDIR=${EPREFIX}/usr/bin
	QTLIBDIR=${EPREFIX}/usr/$(get_libdir)/qt4
	QMAKE_LIBDIR_QT=${QTLIBDIR}
	QTPCDIR=${EPREFIX}/usr/$(get_libdir)/pkgconfig
	QTDATADIR=${EPREFIX}/usr/share/qt4
	QTDOCDIR=${EPREFIX}/usr/share/doc/qt-${PV}
	QTHEADERDIR=${EPREFIX}/usr/include/qt4
	QTPLUGINDIR=${QTLIBDIR}/plugins
	QTSYSCONFDIR=${EPREFIX}/etc/qt4
	QTTRANSDIR=${QTDATADIR}/translations
	QTEXAMPLESDIR=${QTDATADIR}/examples
	QTDEMOSDIR=${QTDATADIR}/demos
	QT_INSTALL_PREFIX=${EPREFIX}/usr/$(get_libdir)/qt4
	PLATFORM=$(qt_mkspecs_dir)

	unset QMAKESPEC
}

# @FUNCTION: standard_configure_options
# @DESCRIPTION:
# Sets up some standard configure options, like libdir (if necessary), whether
# debug info is wanted or not, exceptions support, arch, etc...
standard_configure_options() {
	local myconf=

	[[ $(get_libdir) != lib ]] && myconf="${myconf} -L${EPREFIX}/usr/$(get_libdir)"

	# Disable visibility explicitly if gcc version isn't 4
	if [[ $(gcc-major-version) -lt 4 ]]; then
		myconf="${myconf} -no-reduce-exports"
	fi

	# precompiled headers don't work on hardened, where the flag is masked.
	myconf="${myconf} $(qt_use pch)"

	if use debug; then
		myconf="${myconf} -debug"
	else
		myconf="${myconf} -release"
	fi
	myconf="${myconf} -no-separate-debug-info"

	use aqua && myconf="${myconf} -no-framework"

	# ARCH is set on Gentoo. Qt now falls back to generic on an unsupported
	# $(tc-arch). Therefore we convert it to supported values.
	case "$(tc-arch)" in
		amd64|x64-*) myconf="${myconf} -arch x86_64" ;;
		ppc-macos) myconf="${myconf} -arch ppc" ;;
		ppc|ppc64|ppc-*) myconf="${myconf} -arch powerpc" ;;
		sparc|sparc-*) myconf="${myconf} -arch sparc" ;;
		x86-macos) myconf="${myconf} -arch x86" ;;
		x86|x86-*) myconf="${myconf} -arch i386" ;;
		alpha|arm|ia64|mips|s390|sparc) myconf="${myconf} -arch $(tc-arch)" ;;
		hppa|sh) myconf="${myconf} -arch generic" ;;
		*) die "$(tc-arch) is unsupported by this eclass. Please file a bug." ;;
	esac

	local exceptions=
	has exceptions "${IUSE}" && exceptions="$(qt_use exceptions)"

	# reduce-relocations seems to introduce major breakage to applications,
	# mostly to be seen as a core dump with the message "QPixmap: Must
	# construct a QApplication before a QPaintDevice" on Solaris
	[[ ${CHOST} != *-solaris* ]] && myconf="${myconf} -reduce-relocations"

	myconf="${myconf} -platform $(qt_mkspecs_dir)
		-stl -verbose -largefile -confirm-license
		-prefix ${QTPREFIXDIR} -bindir ${QTBINDIR} -libdir ${QTLIBDIR}
		-datadir ${QTDATADIR} -docdir ${QTDOCDIR} -headerdir ${QTHEADERDIR}
		-plugindir ${QTPLUGINDIR} -sysconfdir ${QTSYSCONFDIR}
		-translationdir ${QTTRANSDIR} -examplesdir ${QTEXAMPLESDIR}
		-demosdir ${QTDEMOSDIR} -silent -fast -opensource
		${exceptions} -nomake examples -nomake demos"

	echo "${myconf}"
}

# @FUNCTION: build_directories
# @USAGE: < directories >
# @DESCRIPTION:
# Compiles the code in the given directories.
build_directories() {
	local x=
	for x in "$@"; do
		pushd "${S}"/${x} > /dev/null || die "can't pushd ${S}/${x}"
		# avoid running over the maximum number of arguments, bug #299810
		# FIXME: investigate whether this sed can be moved outside of the for loop
		{
			echo "${S}"/mkspecs/common/*.conf
			find "${S}" -name '*.pr[io]'
		} | xargs sed -i -e "s:\$\$\[QT_INSTALL_LIBS\]:${QTLIBDIR}:g" || die
		"${S}"/bin/qmake "LIBS+=-L${QTLIBDIR}" "CONFIG+=nostrip" || die "qmake in ${x} failed"
		emake CC="@echo compiling \$< && $(tc-getCC)" \
			CXX="@echo compiling \$< && $(tc-getCXX)" \
			LINK="@echo linking \$@ && $(tc-getCXX)" || die "emake in ${x} failed"
		popd > /dev/null || die "can't popd from ${S}/${x}"
	done
}

# @FUNCTION: install_directories
# @USAGE: < directories >
# @DESCRIPTION:
# Runs emake install in the given directories, which are separated by spaces.
install_directories() {
	local x=
	for x in "$@"; do
		pushd "${S}"/${x} > /dev/null || die "can't pushd ${S}/${x}"
		emake INSTALL_ROOT="${D}" install || die "emake install in ${x} failed"
		popd > /dev/null || die "can't popd from ${S}/${x}"
	done
}

# @ECLASS-VARIABLE: QCONFIG_ADD
# @DESCRIPTION:
# List options that need to be added to QT_CONFIG in qconfig.pri
QCONFIG_ADD="${QCONFIG_ADD:-}"

# @ECLASS-VARIABLE: QCONFIG_REMOVE
# @DESCRIPTION:
# List options that need to be removed from QT_CONFIG in qconfig.pri
QCONFIG_REMOVE="${QCONFIG_REMOVE:-}"

# @ECLASS-VARIABLE: QCONFIG_DEFINE
# @DESCRIPTION:
# List variables that should be defined at the top of QtCore/qconfig.h
QCONFIG_DEFINE="${QCONFIG_DEFINE:-}"

# @FUNCTION: install_qconfigs
# @DESCRIPTION:
# Installs Gentoo-specific mkspecs configurations.
install_qconfigs() {
	local x=
	if [[ -n ${QCONFIG_ADD} || -n ${QCONFIG_REMOVE} ]]; then
		for x in QCONFIG_ADD QCONFIG_REMOVE; do
			[[ -n ${!x} ]] && echo ${x}=${!x} >> "${T}"/${PN}-qconfig.pri
		done
		insinto ${QTDATADIR#${EPREFIX}}/mkspecs/gentoo
		doins "${T}"/${PN}-qconfig.pri || die "installing ${PN}-qconfig.pri failed"
	fi

	if [[ -n ${QCONFIG_DEFINE} ]]; then
		for x in ${QCONFIG_DEFINE}; do
			echo "#define ${x}" >> "${T}"/gentoo-${PN}-qconfig.h
		done
		insinto ${QTHEADERDIR#${EPREFIX}}/Gentoo
		doins "${T}"/gentoo-${PN}-qconfig.h || die "installing gentoo-${PN}-qconfig.h failed"
	fi
}

# @FUNCTION: generate_qconfigs
# @DESCRIPTION:
# Generates Gentoo-specific configurations.
generate_qconfigs() {
	if [[ -n ${QCONFIG_ADD} || -n ${QCONFIG_REMOVE} || -n ${QCONFIG_DEFINE} || ${CATEGORY}/${PN} == x11-libs/qt-core ]]; then
		local x qconfig_add qconfig_remove qconfig_new
		for x in "${ROOT}${QTDATADIR}"/mkspecs/gentoo/*-qconfig.pri; do
			[[ -f ${x} ]] || continue
			qconfig_add="${qconfig_add} $(sed -n 's/^QCONFIG_ADD=//p' "${x}")"
			qconfig_remove="${qconfig_remove} $(sed -n 's/^QCONFIG_REMOVE=//p' "${x}")"
		done

		# these error checks do not use die because dying in pkg_post{inst,rm}
		# just makes things worse.
		if [[ -e "${ROOT}${QTDATADIR}"/mkspecs/gentoo/qconfig.pri ]]; then
			# start with the qconfig.pri that qt-core installed
			if ! cp "${ROOT}${QTDATADIR}"/mkspecs/gentoo/qconfig.pri \
				"${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri; then
				eerror "cp qconfig.pri failed!"
				return 1
			fi

			# generate list of QT_CONFIG entries from the existing list
			# including qconfig_add and excluding qconfig_remove
			for x in $(sed -n 's/^QT_CONFIG +=//p' \
					"${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri) \
					${qconfig_add}; do
				hasq ${x} ${qconfig_remove} || qconfig_new="${qconfig_new} ${x}"
			done

			# replace the existing QT_CONFIG list with qconfig_new
			if ! sed -i -e "s/QT_CONFIG +=.*/QT_CONFIG += ${qconfig_new}/" \
					"${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri; then
				eerror "Sed for QT_CONFIG failed!"
				return 1
			fi

			# create Gentoo/qconfig.h
			if [[ ! -e ${ROOT}${QTHEADERDIR}/Gentoo ]]; then
				if ! mkdir -p "${ROOT}${QTHEADERDIR}"/Gentoo; then
					eerror "mkdir ${QTHEADERDIR}/Gentoo failed"
					return 1
				fi
			fi
			: > "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-qconfig.h
			for x in "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-*-qconfig.h; do
				[[ -f ${x} ]] || continue
				cat "${x}" >> "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-qconfig.h
			done
		else
			rm -f "${ROOT}${QTDATADIR}"/mkspecs/qconfig.pri
			rm -f "${ROOT}${QTHEADERDIR}"/Gentoo/gentoo-qconfig.h
			rmdir "${ROOT}${QTDATADIR}"/mkspecs \
				"${ROOT}${QTDATADIR}" \
				"${ROOT}${QTHEADERDIR}"/Gentoo \
				"${ROOT}${QTHEADERDIR}" 2>/dev/null
		fi
	fi
}

# @FUNCTION: qt4-build-edge_pkg_postrm
# @DESCRIPTION:
# Generates configuration when the package is completely removed.
qt4-build-edge_pkg_postrm() {
	generate_qconfigs
}

# @FUNCTION: qt4-build-edge_pkg_postinst
# @DESCRIPTION:
# Generates configuration, plus throws a message about possible
# breakages and proposed solutions.
qt4-build-edge_pkg_postinst() {
	generate_qconfigs
}

# @FUNCTION: skip_qmake_build
# @DESCRIPTION:
# Skip qmake build, as it's already installed by qt-core
skip_qmake_build() {
	sed -i -e 's:if true:if false:g' "${S}"/configure || die "${FUNCNAME}: sed failed."
}

# @FUNCTION: skip_project_generation
# @DESCRIPTION:
# Exit the script early by throwing in an exit before all of the .pro files are scanned
skip_project_generation() {
	sed -i -e 's:echo "Finding:exit 0\n\necho "Finding:g' "${S}"/configure || die "${FUNCNAME}: sed failed."
}

# @FUNCTION: symlink_binaries_to_buildtree
# @DESCRIPTION:
# Symlink generated binaries to buildtree so they can be used during compilation time
symlink_binaries_to_buildtree() {
	for bin in qmake moc uic rcc; do
		ln -s ${QTBINDIR}/${bin} "${S}"/bin/ || die "${FUNCNAME}: symlinking ${bin} to ${S}/bin failed."
	done
}

# @FUNCTION: generate_include
# @DESCRIPTION:
# Internal function, required for live ebuilds.
generate_include() {
	QTDIR="." perl bin/syncqt
}

# @FUNCTION: fix_library_files
# @DESCRIPTION:
# Fixes the pathes in *.la, *.prl, *.pc, as they are wrong due to sandbox and
# moves the *.pc files into the pkgconfig directory.
fix_library_files() {
	local libfile=
	for libfile in "${D}"/${QTLIBDIR}/{*.la,*.prl,pkgconfig/*.pc}; do
		if [[ -e ${libfile} ]]; then
			sed -i -e "s:${S}/lib:${QTLIBDIR}:g" ${libfile} || die "${FUNCNAME}: sed on ${libfile} failed."
		fi
	done

	# pkgconfig files refer to ${WORKDIR}/bin, as the moc and uic locations. Fix them.
	for libfile in "${D}"/${QTLIBDIR}/pkgconfig/*.pc; do
		if [[ -e ${libfile} ]]; then
			sed -i -e "s:${S}/bin:${QTBINDIR}:g" ${libfile} || die "${FUNCNAME}: sed on ${libfile} failed."
			# Move .pc files into the pkgconfig directory
			dodir ${QTPCDIR#${EPREFIX}}
			mv ${libfile} "${D}"/${QTPCDIR}/ \
				|| die "${FUNCNAME}: moving ${libfile} to ${D}/${QTPCDIR}/ failed."
		fi
	done

	# Don't install an empty directory
	rmdir "${D}"/${QTLIBDIR}/pkgconfig
}

# @FUNCTION: qt_use
# @USAGE: < flag > [ feature ] [ enableval ]
# @DESCRIPTION:
# This will echo "${enableval}-${feature}" if <flag> is enabled, or
# "-no-${feature}" if the flag is disabled. If [feature] is not specified <flag>
# will be used for that. If [enableval] is not specified, that part is omitted.
qt_use() {
	local feature="${2:-$1}"
	local enableval=

	[[ -n ${3} ]] && enableval="-${3}"

	if use ${1}; then
		echo "${enableval}-${feature}"
	else
		echo "-no-${feature}"
	fi
}

# @FUNCTION: qt_mkspecs_dir
# @RETURN: the specs-directory w/o path
# @DESCRIPTION:
# Allows us to define which mkspecs dir we want to use.
qt_mkspecs_dir() {
	local spec=
	case ${CHOST} in
		*-freebsd*|*-dragonfly*)
			spec=freebsd ;;
		*-openbsd*)
			spec=openbsd ;;
		*-netbsd*)
			spec=netbsd ;;
		*-darwin*)
			if use aqua; then
				# mac with carbon/cocoa
				spec=macx
			else
				# darwin/mac with x11
				spec=darwin
			fi
			;;
		*-solaris*)
			spec=solaris ;;
		*-linux-*|*-linux)
			spec=linux ;;
		*)
			die "Unknown CHOST '${CHOST}', no platform chosen."
	esac

	local CXX=$(tc-getCXX)
	if [[ ${CXX} == *g++* ]]; then
		spec="${spec}-g++"
	elif [[ ${CXX} == *icpc* ]]; then
		spec="${spec}-icc"
	else
		die "Unknown compiler '${CXX}'."
	fi

	if [[ -n ${LIBDIR/lib} ]]; then
		spec="${spec}-${LIBDIR/lib}"
	fi

	# Add -64 for 64bit profiles
	if use amd64-linux ||
		use x64-freebsd ||
		use x64-macos ||
		use x64-solaris ||
		use sparc64-solaris
	then
		spec="${spec}-64"
	fi

	echo "${spec}"
}

EXPORT_FUNCTIONS pkg_setup src_unpack src_prepare src_configure src_compile src_install pkg_postrm pkg_postinst
