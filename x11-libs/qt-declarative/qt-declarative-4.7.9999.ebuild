# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit qt4-build-edge

DESCRIPTION="The Declarative module for the Qt toolkit"
SLOT="4"
KEYWORDS=""
IUSE="private-headers"

DEPEND="~x11-libs/qt-core-${PV}[stable-branch=]
	~x11-libs/qt-gui-${PV}[stable-branch=]
	~x11-libs/qt-multimedia-${PV}[stable-branch=]
	~x11-libs/qt-opengl-${PV}[stable-branch=]
	~x11-libs/qt-script-${PV}[stable-branch=]
	~x11-libs/qt-sql-${PV}[stable-branch=]
	~x11-libs/qt-webkit-${PV}[stable-branch=]
	~x11-libs/qt-xmlpatterns-${PV}[stable-branch=]"
RDEPEND="${DEPEND}"

pkg_setup() {
	QT4_TARGET_DIRECTORIES="
		src/declarative
		tools/qml"
	QT4_EXTRACT_DIRECTORIES="
		include/
		src/
		tools/"

	qt4-build-edge_pkg_setup
}

src_configure() {
	myconf="${myconf} -declarative"
	qt4-build-edge_src_configure
}

src_install() {
	qt4-build-edge_src_install
	if use private-headers; then
		insinto ${QTHEADERDIR}
		doins -r src/declarative/qml/*_p.h
	fi
}
