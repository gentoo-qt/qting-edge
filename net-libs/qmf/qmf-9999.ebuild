# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

if [[ ${PV} == *9999 ]]; then
	EGIT_REPO_URI="git://gitorious.org/qt-labs/messagingframework.git
		https://git.gitorious.org/qt-labs/messagingframework.git"
	SCM_ECLASS="git-2"
	SRC_URI=
else
	YYMM="${PV#*_p}"
	TAG="20${YYMM:0:2}W${YYMM:2:2}"
	SRC_URI="http://qt.gitorious.org/qt-labs/messagingframework/archive-tarball/${TAG} -> ${P}.tar.gz"
	S="${WORKDIR}/qt-labs-messagingframework"
fi

inherit qt4-r2 ${SCM_ECLASS}

DESCRIPTION="The Qt Messaging Framework"
HOMEPAGE="http://qt.gitorious.org/qt-labs/messagingframework"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="debug doc examples test"

RDEPEND="
	dev-libs/icu
	sys-libs/zlib
	>=x11-libs/qt-gui-4.6.0
	>=x11-libs/qt-sql-4.6.0
	examples? ( >=x11-libs/qt-webkit-4.6.0 )
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	test? ( >=x11-libs/qt-test-4.6.0 )
"

DOCS="CHANGES"
PATCHES=(
	# http://bugreports.qt.nokia.com/browse/QTMOBILITY-374
	"${FILESDIR}/${PN}-use-standard-install-paths.patch"
)

src_prepare() {
	qt4-r2_src_prepare

	sed -i	-e '/benchmarks/d' \
		-e '/tests/d' \
		messagingframework.pro || die

	if ! use examples; then
		sed -i -e '/examples/d' messagingframework.pro || die
	fi
}

src_test() {
	echo ">>> Test phase [QTest]: ${CATEGORY}/${PF}"
	cd "${S}"/tests

	einfo "Building tests"
	eqmake4 && emake

	einfo "Running tests"
	export QMF_DATA="${T}"
	local fail=false test=
	for test in locks longstream longstring python_email qlogsystem \
			qmailaddress qmailcodec qmaillog qmailmessage \
			qmailmessagebody qmailmessageheader qmailmessagepart \
			qmailnamespace qprivateimplementation; do
		if ! LC_ALL=C ./tst_${test}/tst_${test}; then
			eerror "'${test}' test failed!"
			fail=true
		fi
		echo
	done
	${fail} && die "some tests have failed!"
}

src_install() {
	qt4-r2_src_install

	if use doc; then
		dohtml -r doc/html/*
		emake qch_docs
		dodoc doc/html/qmf.qch
		docompress -x /usr/share/doc/${PF}/qmf.qch
	fi
}
