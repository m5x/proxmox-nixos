{
  lib,
  stdenv,
  fetchgit,
  markedjs,
  nodePackages,
  sassc,
  pve-update-script,
}:

stdenv.mkDerivation rec {
  pname = "proxmox-widget-toolkit";
  version = "5.1.8";

  src = fetchgit {
    url = "git://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "a5d03fff8f116c720e68394f7d6fbd41afe3e5bc";
    hash = "sha256-b16nK3GYZXa/+LGi596m7lOiNF7ifmPHBg27qfqAzx8=";
  };

  sourceRoot = "${src.name}/src";

  postPatch = ''
    sed -i defines.mk -e "s,/usr,,"
    sed -i Makefile -e "/BUILD_VERSION=/d" -e "/BIOME/d"
  '';

  buildInputs = [
    nodePackages.uglify-js
    sassc
  ];

  makeFlags = [
    "DESTDIR=$(out)"
    "MARKEDJS=${markedjs}/lib/node_modules/marked/lib/marked.umd.js"
  ];

  postInstall = ''
    cp api-viewer/APIViewer.js $out/share/javascript/proxmox-widget-toolkit
  '';

  # https://github.com/tteck/Proxmox/blob/d07353534663f87186eceaf8c4a76ce9e886e0df/misc/post-pve-install.sh#L144
  postFixup = ''
    sed -i "/^ *checked_command:/,/^ *[a-zA-Z_]+:/{ s/status\.toLowerCase() !== 'active'/\0 \&\& false/ }" $out/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
  '';

  passthru.updateScript = pve-update-script { };

  meta = with lib; {
    description = "";
    homepage = "https://git.proxmox.com/?p=proxmox-widget-toolkit.git";
    license = with licenses; [ ];
    maintainers = with maintainers; [
      camillemndn
      julienmalka
    ];
    platforms = platforms.linux;
  };
}
