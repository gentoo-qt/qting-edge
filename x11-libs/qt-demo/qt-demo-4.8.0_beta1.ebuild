# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"
inherit qt4-build

DESCRIPTION="Demonstration module of the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="~x11-libs/qt-assistant-${PV}:${SLOT}
	~x11-libs/qt-core-${PV}:${SLOT}
	~x11-libs/qt-dbus-${PV}:${SLOT}
	~x11-libs/qt-gui-${PV}:${SLOT}
	~x11-libs/qt-multimedia-${PV}:${SLOT}
	~x11-libs/qt-opengl-${PV}:${SLOT}
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT} media-libs/phonon )
	~x11-libs/qt-script-${PV}:${SLOT}
	~x11-libs/qt-sql-${PV}:${SLOT}
	~x11-libs/qt-svg-${PV}:${SLOT}
	~x11-libs/qt-test-${PV}:${SLOT}
	~x11-libs/qt-webkit-${PV}:${SLOT}
	~x11-libs/qt-xmlpatterns-${PV}:${SLOT}"

RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-4.6-plugandpaint.patch"
)

pkg_setup() {
	QT4_TARGET_DIRECTORIES="demos
		examples"
	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
		doc/src/images
		src/
		include/
		tools/"

	qt4-build_pkg_setup
}

src_install() {
	insinto ${QTDOCDIR}/src
	doins -r "${S}"/doc/src/images || die "Installing images failed."

	qt4-build_src_install
}
