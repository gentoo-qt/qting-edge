# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/PyQt4/PyQt4-4.5.2.ebuild,v 1.1 2009/07/14 19:29:14 hwoarang Exp $

EAPI="2"

inherit distutils python qt4 toolchain-funcs

MY_PN="PyQt-x11-gpl"
MY_PV="${PV/_pre/-snapshot-}"
MY_P="${MY_PN}-${MY_PV}"

QTVER="4.5.1"

DESCRIPTION="A set of Python bindings for the Qt toolkit"
HOMEPAGE="http://www.riverbankcomputing.co.uk/software/pyqt/intro/"
SRC_URI="http://dev.gentooexperimental.org/~hwoarang/distfiles/${MY_P}.tar.gz"

SLOT="0"
LICENSE="|| ( GPL-2 GPL-3 )"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
IUSE="X assistant +dbus debug doc examples kde opengl phonon sql svg webkit xmlpatterns"

DEPEND=">dev-python/sip-4.8.1
	>=x11-libs/qt-core-${QTVER}:4
	>=x11-libs/qt-script-${QTVER}:4
	>=x11-libs/qt-test-${QTVER}:4
	X? ( >=x11-libs/qt-gui-${QTVER}:4[dbus?] )
	assistant? ( >=x11-libs/qt-assistant-${QTVER}:4 )
	dbus? (
		>=dev-python/dbus-python-0.80
		>=x11-libs/qt-dbus-${QTVER}:4
	)
	opengl? ( >=x11-libs/qt-opengl-${QTVER}:4 )
	phonon? (
		!kde? ( || ( >=x11-libs/qt-phonon-${QTVER}:4 media-sound/phonon ) )
		kde? ( media-sound/phonon )
	)
	sql? ( >=x11-libs/qt-sql-${QTVER}:4 )
	svg? ( >=x11-libs/qt-svg-${QTVER}:4 )
	webkit? ( >=x11-libs/qt-webkit-${QTVER}:4 )
	xmlpatterns? ( >=x11-libs/qt-xmlpatterns-${QTVER}:4 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PATCHES=(
	"${FILESDIR}/configure.py.patch"
)

src_prepare() {
	if ! use dbus; then
		sed -i -e 's,^\([[:blank:]]\+\)check_dbus(),\1pass,' \
			"${S}"/configure.py || die
	fi
	qt4_src_prepare

	# Remove this code after removing Python 2 from the tree.
	python_version
	if [[ "${PYVER:0:1}" == "3" ]]; then
		rm -fr pyuic/uic/port_v2
	else
		rm -fr pyuic/uic/port_v3
	fi
}

pyqt4_use_enable() {
	use $1 && echo "--enable=${2:-$1}"
}

src_configure() {
	python_version

	local myconf="${python} configure.py
			--confirm-license
			--bindir=/usr/bin
			--destdir=$(python_get_sitedir)
			--sipdir=/usr/share/sip
			$(use debug && echo '--debug')
			--enable=QtCore
			--enable=QtNetwork
			--enable=QtScript
			--enable=QtTest
			--enable=QtXml
			$(pyqt4_use_enable X QtGui)
			$(pyqt4_use_enable X QtDesigner)
			$(pyqt4_use_enable assistant QtAssistant)
			$(pyqt4_use_enable assistant QtHelp)
			$(pyqt4_use_enable opengl QtOpenGL)
			$(pyqt4_use_enable phonon)
			$(pyqt4_use_enable sql QtSql)
			$(pyqt4_use_enable svg QtSvg)
			$(pyqt4_use_enable webkit QtWebKit)
			$(pyqt4_use_enable xmlpatterns QtXmlPatterns)
			CC=$(tc-getCC) CXX=$(tc-getCXX)
			LINK=$(tc-getCXX) LINK_SHLIB=$(tc-getCXX)
			CFLAGS='${CFLAGS}' CXXFLAGS='${CXXFLAGS}' LFLAGS='${LDFLAGS}'"
	echo ${myconf}
	eval ${myconf} || die "configuration failed"

	for mod in QtCore $(use X && echo "QtDesigner QtGui"); do
		# Run eqmake4 inside the qpy subdirs to prevent
		# stripping and many other QA issues
		cd "${S}"/qpy/${mod}
		eqmake4 $(ls w_qpy*.pro)

		# Fix insecure runpaths
		sed -i -e "/^LFLAGS/s:-Wl,-rpath,${S}/qpy/${mod}::" \
			"${S}"/${mod}/Makefile || die "failed to fix rpath issues"
	done
}

src_install() {
	python_need_rebuild

	# INSTALL_ROOT is needed for the QtDesigner module,
	# the other Makefiles use DESTDIR.
	emake DESTDIR="${D}" INSTALL_ROOT="${D}" install || die "installation failed"

	dodoc ChangeLog NEWS THANKS || die

	if use doc; then
		dohtml -r doc/html/* || die
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples || die
	fi
}
