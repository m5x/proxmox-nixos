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
  version = "5.1.5";

  src = fetchgit {
    url = "git://git.proxmox.com/git/proxmox-widget-toolkit.git";
    rev = "e0798f947fb727ce57f3423e782465a3c9115cfe";
    hash = "sha256-wXHVgWnq/HUDJ3O6Jkgk521+AQwd9cLR4StACGO6buc=";
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
