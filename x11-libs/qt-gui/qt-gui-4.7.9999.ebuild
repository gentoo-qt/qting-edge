# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit confutils eutils qt4-build-edge

DESCRIPTION="The GUI module for the Qt toolkit"
SLOT="4"
KEYWORDS=""
IUSE="+accessibility cups dbus egl +glib gtk mng nas nis private-headers +raster tiff trace qt3support xinerama"

RDEPEND="media-libs/fontconfig
	media-libs/freetype:2
	media-libs/jpeg:0
	media-libs/libpng
	sys-libs/zlib
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXrandr
	x11-libs/libXcursor
	x11-libs/libXfont
	x11-libs/libSM
	x11-libs/libXi
	~x11-libs/qt-core-${PV}[debug=,glib=,qt3support=,stable-branch=]
	~x11-libs/qt-script-${PV}[debug=,stable-branch=]
	cups? ( net-print/cups )
	dbus? ( ~x11-libs/qt-dbus-${PV}[debug=,stable-branch=] )
	gtk? ( x11-libs/gtk+:2 )
	mng? ( >=media-libs/libmng-1.0.9 )
	nas? ( >=media-libs/nas-1.5 )
	tiff? ( media-libs/tiff )
	xinerama? ( x11-libs/libXinerama )"
DEPEND="${RDEPEND}
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/xextproto
	x11-proto/inputproto"
PDEPEND="qt3support? ( ~x11-libs/qt-qt3support-${PV}[debug=,stable-branch=] )"

pkg_setup() {
	if ! use qt3support; then
		ewarn "WARNING: if you need 'qtconfig', you _must_ enable qt3support."
	fi

	confutils_use_depend_all gtk glib

	QT4_TARGET_DIRECTORIES="
		src/gui
		src/scripttools
		tools/designer
		tools/linguist/linguist
		src/plugins/imageformats/gif
		src/plugins/imageformats/ico
		src/plugins/imageformats/jpeg
		src/plugins/inputmethods"

	QT4_EXTRACT_DIRECTORIES="
		include
		src
		tools/linguist/phrasebooks
		tools/linguist/shared
		tools/shared"

	use dbus && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} tools/qdbus/qdbusviewer"
	use mng && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/mng"
	use tiff && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/imageformats/tiff"
	use accessibility && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES} src/plugins/accessible/widgets"
	use trace && QT4_TARGET_DIRECTORIES="${QT4_TARGET_DIRECTORIES}	src/plugins/graphicssystems/trace"

	QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES} ${QT4_EXTRACT_DIRECTORIES}"

	qt4-build-edge_pkg_setup
}

src_prepare() {
	# bug #313619
	if use stable-branch; then
		epatch "${FILESDIR}/qtbug-9691-egl.patch"
		epatch"${FILESDIR}/qtbug-9691-Xdefs.patch"
		epatch "${FILESDIR}"/qt-4.7-eglfix.patch
	fi
	qt4-build-edge_src_prepare

	# Don't build plugins this go around, because they depend on qt3support lib
	sed -i -e "s:CONFIG(shared:# &:g" "${S}"/tools/designer/src/src.pro
}

src_configure() {
	export PATH="${S}/bin:${PATH}"
	export LD_LIBRARY_PATH="${S}/lib:${LD_LIBRARY_PATH}"

	myconf="$(qt_use accessibility)
		$(qt_use cups)
		$(qt_use egl)
		$(qt_use glib)
		$(qt_use mng libmng system)
		$(qt_use nis)
		$(qt_use tiff libtiff system)
		$(qt_use dbus qdbus)
		$(qt_use dbus)
		$(qt_use qt3support)
		$(qt_use gtk gtkstyle)
		$(qt_use xinerama)"

	use nas	&& myconf="${myconf} -system-nas-sound"
	use raster && myconf="${myconf} -graphicssystem raster"

	myconf="${myconf} -qt-gif -system-libpng -system-libjpeg
		-no-sql-mysql -no-sql-psql -no-sql-ibase -no-sql-sqlite -no-sql-sqlite2
		-no-sql-odbc -xrender -xrandr -xkb -xshape -sm -no-svg -no-webkit
		-no-phonon -no-opengl"

	qt4-build-edge_src_configure
}

src_install() {
	QCONFIG_ADD="x11sm xshape xcursor xfixes xrandr xrender xkb fontconfig
		$(usev accessibility) $(usev xinerama) $(usev cups) $(usev nas)
		gif png system-png system-jpeg
		$(use mng && echo system-mng)
		$(use tiff && echo system-tiff)"
	QCONFIG_REMOVE="no-gif no-png"
	QCONFIG_DEFINE="$(use accessibility && echo QT_ACCESSIBILITY)
			$(use cups && echo QT_CUPS) QT_FONTCONFIG QT_IMAGEFORMAT_JPEG
			$(use mng && echo QT_IMAGEFORMAT_MNG)
			$(use nas && echo QT_NAS)
			$(use nis && echo QT_NIS) QT_IMAGEFORMAT_PNG QT_SESSIONMANAGER QT_SHAPE
			$(use tiff && echo QT_IMAGEFORMAT_TIFF) QT_XCURSOR
			$(use xinerama && echo QT_XINERAMA) QT_XFIXES QT_XKB QT_XRANDR QT_XRENDER"

	qt4-build-edge_src_install

	# remove some unnecessary headers
	rm -f "${D}${QTHEADERDIR}"/{Qt,QtGui}/{qmacstyle_mac.h,qwindowdefs_win.h} \
		"${D}${QTHEADERDIR}"/QtGui/QMacStyle

	# qt-creator
	# some qt-creator headers are located
	# under /usr/include/qt4/QtDesigner/private.
	# those headers are just includes of the headers
	# which are located under tools/designer/src/lib/*
	# So instead of installing both, we create the private folder
	# and drop tools/designer/src/lib/* headers in it.
	dodir /usr/include/qt4/QtDesigner/private/ || die
	insinto /usr/include/qt4/QtDesigner/private/
	doins "${S}"/tools/designer/src/lib/shared/* || die
	doins "${S}"/tools/designer/src/lib/sdk/* || die
	#install private headers
	if use private-headers; then
		insinto ${QTHEADERDIR}/QtGui/private
		find "${S}"/src/gui -type f -name "*_p.h" -exec doins {} \;
	fi

	# install correct designer and linguist icons, bug 241208
	doicon tools/linguist/linguist/images/icons/linguist-128-32.png \
		tools/designer/src/designer/images/designer.png || die
	# Note: absolute image path required here!
	make_desktop_entry /usr/bin/linguist Linguist \
			/usr/share/pixmaps/linguist-128-32.png \
			'Qt;Development;GUIDesigner' || die
	make_desktop_entry /usr/bin/designer Designer \
			/usr/share/pixmaps/designer.png \
			'Qt;Development;GUIDesigner' || die
}
