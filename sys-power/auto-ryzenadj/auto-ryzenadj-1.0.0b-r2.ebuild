# Copyright 2024 ico277
# Distributed under the terms of the MIT License

EAPI=8

MY_PV="${PV/-r*/}"

DESCRIPTION="auto-ryzenadj - automatically applies custom ryzenadj profiles"
HOMEPAGE="https://github.com/ico277/auto-ryzenadj/"
SRC_URI="https://github.com/ico277/auto-ryzenadj/archive/v${MY_PV}2.tar.gz -> ${P}2.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="systemd"

DEPEND="dev-libs/boost
		dev-cpp/cli11
		sys-power/RyzenAdj
		dev-cpp/tomlplusplus"
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
	# create required log directory
	dodir /var/log/auto-ryzenadj

	# install the example config file
	insinto /etc
	doins "${S}/auto-ryzenadj.conf.example"

	# install the executables without .out extension
	exeinto /usr/bin
	newexe "${S}/auto-ryzenadjd.out" "auto-ryzenadjd"		# Rename and install without .out
	newexe "${S}/auto-ryzenadjctl.out" "auto-ryzenadjctl"	# Rename and install without .out

	# install the systemd service
	if use systemd; then
		systemd_dounit "${S}/auto-ryzenadjd.service"
	else
		# Install the OpenRC init script
		newinitd "${S}/auto-ryzenadjd-openrc" auto-ryzenadjd
	fi

}

pkg_postinst() {
	# Display a message after installation
	elog "A log directory has been created at /var/log/auto-ryzenadj"
	elog "An example config file has been installed at /etc/auto-ryzenadj.conf.example"
	elog "You are required to create a config file, otherwise it will crash and die."
	elog "Feel free to copy the example config to /etc/auto-ryzenadj.conf and edit it"
	elog "according to your needs."

	# Inform about systemd service installation
	if use systemd; then
		elog "A systemd service 'auto-ryzenadjd.service' has been installed."
		elog "You can start it with 'systemctl start auto-ryzenadjd.service'."
	else
		# Inform about OpenRC init script installation
		elog "An OpenRC init script 'auto-ryzenadjd' has been installed."
		elog "You can start it with 'rc-service auto-ryzenadjd start'."
	fi
}
