{
  description = "A pure shell to download, validate, and configure upstream DNS servers for dnsproxy and AdGuardHome";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          dns-upstream = pkgs.stdenvNoCC.mkDerivation {
            pname = "dns-upstream";
            version = "unstable-${builtins.substring 0 8 self.lastModifiedDate}";
            src = ./.;
            nativeBuildInputs = [ pkgs.makeWrapper ];
            dontBuild = true;
            installPhase = ''
              install -Dm755 dns-upstream.sh $out/bin/dns-upstream
              wrapProgram $out/bin/dns-upstream \
                --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.jq ]}
            '';
          };
        in {
          inherit dns-upstream;
          default = dns-upstream;
        });
    };
}
