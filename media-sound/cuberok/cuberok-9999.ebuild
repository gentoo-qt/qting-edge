# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit eutils multilib qt4-edge subversion

DESCRIPTION="Qt4 lightweight music player"
HOMEPAGE="http://code.google.com/p/cuberok/"
ESVN_REPO_URI="http://cuberok.googlecode.com/svn/trunk/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug ffmpeg gstreamer kde mp3 phonon"

DEPEND="media-libs/taglib
	x11-libs/qt-gui:4
	x11-libs/qt-sql:4
	ffmpeg? (
		media-libs/libsdl
		>=media-video/ffmpeg-0.5[mp3?]
	)
	gstreamer? (
		media-libs/gstreamer
	)
	phonon? (
		kde? ( media-sound/phonon )
		!kde? ( || ( >=x11-libs/qt-phonon-4.5:4 media-sound/phonon ) )
	)"
RDEPEND="${DEPEND}
	gstreamer? ( mp3? ( media-plugins/gst-plugins-mad ) )"

PATCHES=(
	"${FILESDIR}/${P}-no-automagic-deps.patch"
)

pkg_setup() {
	qt4-edge_pkg_setup

	if ! use ffmpeg && ! use gstreamer && ! use phonon; then
		echo
		ewarn "You didn't select any audio backend, cuberok won't be able"
		ewarn "to play anything! This is probably not what you want."
		ewarn
		ewarn "The available backends (ffmpeg, gstreamer, phonon)"
		ewarn "can be selected by enabling the corresponding USE flag."
		echo
		ebeep
	fi
}

src_prepare() {
	qt4-edge_src_prepare
}

src_configure() {
	player_use() { use $1 && echo "CONFIG+=player_$1"; }

	eqmake4 $(player_use ffmpeg) \
		$(player_use gstreamer) \
		$(player_use phonon)
}

src_install() {
	emake INSTALL_ROOT="${D}/usr" install || die "emake install failed"
	dodoc ChangeLog || die
	doicon images/cuberok.png || die
}
