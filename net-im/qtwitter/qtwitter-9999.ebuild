# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

LANGS="pt_BR"
LANGSLONG="ca_ES de_DE es_ES fr_FR ja_JP pl_PL"

inherit qt4-edge git

DESCRIPTION="A Qt client for Twitter"
HOMEPAGE="http://www.qt-apps.org/content/show.php/qTwitter?content=99087"
EGIT_REPO_URI="git://github.com/ayoy/qtwitter.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="debug"

DEPEND="x11-libs/qt-gui:4"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_prepare() {
	qt4-edge_src_prepare
	echo "CONFIG += nostrip" >> "${S}"/${PN}.pro

	local langs=
	for lingua in $LINGUAS; do
		if has $lingua $LANGS; then
			langs="$langs loc/${PN}_${lingua}.ts"
		else
			for a in $LANGSLONG; do
				if [[ $lingua == ${a%_*} ]]; then
					langs="$langs loc/${PN}_${a}.ts"
				fi
			done
		fi
	done

	# remove translations and add only the selected ones
	sed -i -e '/^ *loc.*\.ts/d' \
		-e "/^TRANSLATIONS/s:loc.*:${langs}:" \
			qtwitter-app/qtwitter-app.pro || die "sed failed"
	# first line fixes bug about unsecure runpaths
	# second disables docs installation by make (done by dodoc in install)
	sed -i -e '/-Wl,-rpath,\$\${TOP}/d' \
		-e '/doc \\/d' \
		qtwitter-app/qtwitter-app.pro || die "sed failed"

	sed -i "s/\$\${INSTALL_PREFIX}\/lib/\$\${INSTALL_PREFIX}\/$(get_libdir)/" \
		twitterapi/twitterapi.pro urlshortener/urlshortener.pro || die "sed failed"

}

src_install() {
	emake INSTALL_ROOT="${D}" install || die "emake install failed"
	dodoc README || die "dodoc failed"
}
