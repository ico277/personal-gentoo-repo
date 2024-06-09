# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="auto-ryzenadj - automatically applies custom ryzenadj profiles"
HOMEPAGE="https://github.com/ico277/auto-ryzenadj/"
SRC_URI="https://github.com/ico277/auto-ryzenadj/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/boost
        dev-cpp/cli11
        sys-power/ryzenadj"
RDEPEND="${DEPEND}"

src_unpack() {
    default
}

src_prepare() {
    default
}

src_compile() {
    emake
}

src_install() {
    emake PREFIX="${D}" install
    # Create the /var/log/auto-ryzenadj directory
    dodir /var/log/auto-ryzenadj
    
    # Install the example config file
    insinto /etc
    doins "${S}/auto-ryzenadj.conf.example"
}

pkg_postinst() {
    # Display a message after installation
    elog "A new log directory has been created at /var/log/auto-ryzenadj"
    elog "An example config file has been installed at /etc/auto-ryzenadj.conf.example"
    elog "You may want to copy it to /etc/auto-ryzenadj.conf and edit it according to your needs."
}
