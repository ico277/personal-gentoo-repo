# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="${PN/-bin/}"
MY_PV="${PV/-r*/}"

CHROMIUM_LANGS="
    af am ar bg bn ca cs da de el en-GB en-US es es-419 et fa fi fil fr gu he hi
    hr hu id it ja kn ko lt lv ml mr ms nb nl pl pt-BR pt-PT ro ru sk sl sr sv
    sw ta te th tr uk ur vi zh-CN zh-TW
"

inherit chromium-2 desktop linux-info optfeature unpacker xdg

DESCRIPTION="ArmCord is a custom client designed to enhance your Discord experience while keeping everything lightweight."
HOMEPAGE="https://armcord.app/"
SRC_URI="https://github.com/ArmCord/ArmCord/releases/download/v${MY_PV}/ArmCord-${MY_PV}.tar.gz"
#SRC_URI="https://dl.discordapp.net/apps/linux/${MY_PV}/${MY_PN}-${MY_PV}.tar.gz"

LICENSE="OSL-3.0"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip test"
IUSE="+appindicator"

RDEPEND="
    >=app-accessibility/at-spi2-core-2.46.0:2
    app-crypt/libsecret
    dev-libs/expat
    dev-libs/glib:2
    dev-libs/nspr
    dev-libs/nss
    media-libs/alsa-lib
    media-libs/fontconfig
    media-libs/mesa[gbm(+)]
    net-print/cups
    sys-apps/dbus
    sys-apps/util-linux
    sys-libs/glibc
    x11-libs/cairo
    x11-libs/libdrm
    x11-libs/gdk-pixbuf:2
    x11-libs/gtk+:3
    x11-libs/libX11
    x11-libs/libXScrnSaver
    x11-libs/libXcomposite
    x11-libs/libXdamage
    x11-libs/libXext
    x11-libs/libXfixes
    x11-libs/libXrandr
    x11-libs/libxcb
    x11-libs/libxkbcommon
    x11-libs/libxshmfence
    x11-libs/pango
    appindicator? ( dev-libs/libayatana-appindicator )
"

DESTDIR="/opt/ArmCord"

QA_PREBUILT="*"

CONFIG_CHECK="~USER_NS"

#S="${WORKDIR}/${MY_PN^}"
S="${WORKDIR}/ArmCord-${MY_PV}"

src_unpack() {
    unpack ArmCord-${MY_PV}.tar.gz
}

src_configure() {
    default
    chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
    default
    # cleanup languages
    pushd "locales/" >/dev/null || die "location change for language cleanup failed"
    chromium_remove_language_paks
    popd >/dev/null || die "location reset for language cleanup failed"
    # USE seccomp
#   if ! use seccomp; then
#        sed -i '/Exec/s/Discord/Discord --disable-seccomp-filter-sandbox/' \
#            "${MY_PN}.desktop" ||
#            die "sed failed for seccomp"
#    fi
}

src_install() {
    newicon -s 256 "${FILESDIR}/armcord.png" "armcord.png"

    # install .desktop file
    domenu "${FILESDIR}/${MY_PN}.desktop"

    exeinto "${DESTDIR}"

	exeopts -m755
    doexe "${MY_PN}" chrome-sandbox libEGL.so libffmpeg.so libGLESv2.so libvk_swiftshader.so

    insinto "${DESTDIR}"
    doins chrome_100_percent.pak chrome_200_percent.pak icudtl.dat resources.pak snapshot_blob.bin v8_context_snapshot.bin
    insopts -m0755
    doins -r locales resources

    # Chrome-sandbox requires the setuid bit to be specifically set.
    # see https://github.com/electron/electron/issues/17972
    fowners root "${DESTDIR}/chrome-sandbox"
    fperms 4711 "${DESTDIR}/chrome-sandbox"

    # Crashpad is included in the package once in a while and when it does, it must be installed.
    # See #903616 and #890595
    [[ -x chrome_crashpad_handler ]] && doins chrome_crashpad_handler

    dosym "${DESTDIR}/${MY_PN}" "/usr/bin/${MY_PN}"

    # https://bugs.gentoo.org/898912
    #if use appindicator; then
    #    dosym ../../usr/lib64/libayatana-appindicator3.so /opt/discord/libappindicator3.so
    #fi
}

pkg_postinst() {
    xdg_pkg_postinst

    optfeature "sound support" \
        media-sound/pulseaudio media-sound/apulse[sdk] media-video/pipewire
}
