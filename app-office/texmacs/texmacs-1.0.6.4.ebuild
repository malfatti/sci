# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# although flag-o-matic functions in portage, we should inherit it
inherit flag-o-matic eutils

MY_P=${P/tex/TeX}-src
S=${WORKDIR}/${MY_P}

DESCRIPTION="GNU TeXmacs is a free GUI scientific editor, inspired by TeX and GNU Emacs."
SRC_URI="ftp://ftp.texmacs.org/pub/TeXmacs/targz/${MY_P}.tar.gz
	 ftp://ftp.texmacs.org/pub/TeXmacs/targz/TeXmacs-600dpi-fonts.tar.gz"
HOMEPAGE="http://www.texmacs.org/"
LICENSE="GPL-2"

SLOT="0"
IUSE="ispell aspell static"
# TeXmacs 1.0.X-r? -> stable release, TeXmacs 1.0.X.Y -> development release
KEYWORDS="~x86"

RDEPEND="virtual/tetex
	>=dev-util/guile-1.4
	>=sys-apps/sed-4
	media-libs/freetype
	|| ( ( x11-libs/libX11
		   x11-libs/libICE )
		virtual/x11
	)
	media-libs/imlib2
	ispell? ( >=app-text/ispell-3.2 )
	aspell? ( >=app-text/aspell-0.5 )"

DEPEND="${RDEPEND}
	|| ( x11-proto/xproto
	     virtual/x11 )
	virtual/ghostscript"

src_unpack() {
	unpack ${A}
	cd "${S}"
	use aspell && sed -i -e 's/ispell -a -d/aspell -a -d/' src/Plugins/Ispell/ispell.cpp
}

src_compile() {

	# we're not trusting texmacs optimisations here, so
	# we only want the following two
	strip-flags
	append-flags -fno-default-inline
	append-flags -fno-inline

	econf || die
	# and now replace the detected optimisations with our safer ones
	sed -i "s:\(^CXXOPTIMIZE = \).*:\1${CXXFLAGS}:" src/common.makefile
	# emake b0rked
	if use static ; then
		emake -j1 STATIC_TEXMACS || die
	else
		emake -j1 || die
	fi

}


src_install() {

	make DESTDIR=${D} install || die
	dodoc COMPILE

	insinto /usr/share/applications
	doins ${FILESDIR}/TeXmacs.desktop

	# now install the fonts
	cd ${WORKDIR}
	dodir /usr/share/texmf
	cp -r fonts ${D}/usr/share/texmf/

}
