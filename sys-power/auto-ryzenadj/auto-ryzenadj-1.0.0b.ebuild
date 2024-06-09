# Copyright 2024 ico277
# Distributed under the terms of the MIT License

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
        sys-power/RyzenAdj"
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
    # Create necessary directories
    dodir /var/log/auto-ryzenadj

    # Install the example config file
    insinto /etc
    doins "${S}/auto-ryzenadj.conf.example"

    # Install the executables without .out extension
    exeinto /usr/bin
    newexe "${S}/auto-ryzenadjd.out" "auto-ryzenadjd"       # Rename and install without .out
    newexe "${S}/auto-ryzenadjctl.out" "auto-ryzenadjctl"   # Rename and install without .out
}

pkg_postinst() {
    # Display a message after installation
    elog "A log directory has been created at /var/log/auto-ryzenadj"
    elog "An example config file has been installed at /etc/auto-ryzenadj.conf.example"
    elog "You may want to copy it to /etc/auto-ryzenadj.conf and edit it according to your needs."
}
