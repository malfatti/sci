# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit distutils-r1

DESCRIPTION="Pure python library for libconfig syntax"
HOMEPAGE="https://github.com/heinzK1X/pylibconfig2"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

LICENSE="BSD"
SLOT="0"

RDEPEND="
	dev-python/pyparsing[${PYTHON_USEDEP}]
	"
DEPEND="${RDEPEND}"
