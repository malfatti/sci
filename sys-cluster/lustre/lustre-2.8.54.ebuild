# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

WANT_AUTOCONF="2.5"
WANT_AUTOMAKE="1.15"
WANT_LIBTOOL="latest"

if [[ $PV = *9999* ]]; then
	KEYWORDS=""
	EGIT_BRANCH="master"
else
	KEYWORDS="~amd64"
	EGIT_TAG="${PV}"
fi

inherit git-r3 autotools linux-mod toolchain-funcs udev flag-o-matic

DESCRIPTION="Lustre is a parallel distributed file system"
HOMEPAGE="http://wiki.whamcloud.com/"
SRC_URI=""
EGIT_REPO_URI="git://git.whamcloud.com/fs/lustre-release.git"

LICENSE="GPL-2"
SLOT="0"
IUSE="+client +utils +modules server readline tests"

RDEPEND="
	virtual/awk
	readline? ( sys-libs/readline:0 )
	server? (
		>=sys-kernel/spl-0.6.1
		>=sys-fs/zfs-kmod-0.6.1
		sys-fs/zfs
	)
	"
DEPEND="${RDEPEND}
	virtual/linux-sources"

REQUIRED_USE="
	client? ( modules )
	server? ( modules )"

PATCHES=(
	"${FILESDIR}/0001-LU-8056-libcfs-Support-for-linux-4.2-kernels.patch"
	"${FILESDIR}/0002-LU-8056-o2iblnd-ib_query_device-removed-in-4.5.patch"
	"${FILESDIR}/0003-LU-8056-socklnd-NETIF_F_ALL_CSUM-renamed-to-NETIF_F_.patch"
	"${FILESDIR}/0004-LU-8056-llite-use-inode_lock-to-access-i_mutex.patch"
	"${FILESDIR}/0005-LU-8056-llite-inode_operations-interface-changed-in-.patch"
	"${FILESDIR}/0006-LU-8056-llite-POSIX_ACL_XATTR_-ACCESS-DEFAULT-remove.patch"
	"${FILESDIR}/0007-LU-8056-lloop-fix-bio_for_each_segment_all-for-newer.patch"
	"${FILESDIR}/0008-Fix-build-error-with-gcc-6.1.patch"
	)

pkg_setup() {
	filter-mfpmath sse
	filter-mfpmath i386
	filter-flags -msse* -mavx* -mmmx -m3dnow
	linux-mod_pkg_setup
	ARCH="$(tc-arch-kernel)"
	ABI="${KERNEL_ABI}"
}

src_prepare() {
	if [ ! -z ${#PATCHES[0]} ]; then
		epatch ${PATCHES[@]}
	fi
	eapply_user
	# replace upstream autogen.sh by our src_prepare()
	local DIRS="libcfs lnet lustre snmp"
	local ACLOCAL_FLAGS
	for dir in $DIRS ; do
		ACLOCAL_FLAGS="$ACLOCAL_FLAGS -I $dir/autoconf"
	done
	_elibtoolize -q
	eaclocal -I config $ACLOCAL_FLAGS
	eautoheader
	eautomake
	eautoconf
}

src_configure() {
	local myconf
	if use server; then
		SPL_PATH=$(basename $(echo "${EROOT}usr/src/spl-"*)) \
			myconf="${myconf} --with-spl=${EROOT}usr/src/${SPL_PATH} \
							--with-spl-obj=${EROOT}usr/src/${SPL_PATH}/${KV_FULL}"
		ZFS_PATH=$(basename $(echo "${EROOT}usr/src/zfs-"*)) \
			myconf="${myconf} --with-zfs=${EROOT}usr/src/${ZFS_PATH} \
							--with-zfs-obj=${EROOT}usr/src/${ZFS_PATH}/${KV_FULL}"
	fi
	econf \
		${myconf} \
		--without-ldiskfs \
		--with-linux="${KERNEL_DIR}" \
		$(use_enable client) \
		$(use_enable utils) \
		$(use_enable modules) \
		$(use_enable server) \
		$(use_enable readline) \
		$(use_enable tests)
}

src_compile() {
	default
}

src_install() {
	default
}