# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit qt4-build-edge

DESCRIPTION="The Qt3 support module for the Qt toolkit"
SLOT="4"
KEYWORDS=""
IUSE="+accessibility kde phonon"

DEPEND="~x11-libs/qt-core-${PV}[debug=,qt3support,stable-branch=]
	~x11-libs/qt-gui-${PV}[accessibility=,debug=,qt3support,stable-branch=]
	~x11-libs/qt-sql-${PV}[debug=,qt3support,stable-branch=]
	phonon? (
		!kde? ( || ( ~x11-libs/qt-phonon-${PV}[debug=,stable-branch=]
			media-libs/phonon[gstreamer] ) )
		kde? ( media-libs/phonon[gstreamer] ) )"
RDEPEND="${DEPEND}"

pkg_setup() {
	QT4_TARGET_DIRECTORIES="
		src/qt3support
		src/tools/uic3
		tools/designer/src/plugins/widgets
		tools/qtconfig
		tools/porting"
	QT4_EXTRACT_DIRECTORIES="src include tools"

	qt4-build-edge_pkg_setup
}

src_configure() {
	myconf="${myconf} -qt3support
		$(qt_use phonon gstreamer)
		$(qt_use phonon)
		$(qt_use accessibility)"
	qt4-build-edge_src_configure
}
