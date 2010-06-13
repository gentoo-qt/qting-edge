# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/elltube/elltube-0.3.ebuild,v 1.1 2009/02/15 23:20:17 hwoarang Exp $

inherit eutils subversion

DESCRIPTION="A YouTube Downloader and Converter"
HOMEPAGE="http://sourceforge.net/projects/elltube"
ESVN_REPO_URI="http://elltube.svn.sourceforge.net/svnroot/elltube/trunk/"
ESVN_PROJECT="elltube"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=dev-lang/python-2.4
	dev-python/PyQt4
	media-video/ffmpeg"

src_compile() {
	#just pass since make command does nasty stuff :)
	true
}

src_install() {
	emake DESTDIR="${D}" PREFIX="/usr" install || die "emake install failed"
	dodoc CHANGELOG || die "dodoc failed"
}
