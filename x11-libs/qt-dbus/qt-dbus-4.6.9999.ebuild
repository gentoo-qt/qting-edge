# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit qt4-build-edge

DESCRIPTION="The DBus module for the Qt toolkit"
SLOT="4"
KEYWORDS=""
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=,kde-qt=,stable-branch=]
	>=sys-apps/dbus-1.0.2"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="
src/dbus
tools/qdbus/qdbus
tools/qdbus/qdbusxml2cpp
tools/qdbus/qdbuscpp2xml"
QCONFIG_ADD="dbus dbus-linked"
QCONFIG_DEFINE="QT_DBUS"

#FIXME: Check if these are still needed with the header package
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/QtCore
include/QtDBus
include/QtXml
src/corelib
src/xml"

src_prepare() {
	qt4-build-edge_src_prepare
	if use stable-branch || use kde-qt; then
		epatch "${FILESDIR}"/qt-4.6-nolibx11.diff
	else
		epatch "${FILESDIR}"/qt-4.6-master-nolibx11.patch
	fi
}

src_configure() {
	myconf="${myconf} -dbus-linked"
	qt4-build-edge_src_configure
}
