{
  description = "Easily-archivable IPFS sites";
  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.update-directory-hashes;
    packages.x86_64-linux.update-directory-hashes =
      let pkgs = import nixpkgs { system = "x86_64-linux"; }; in
      pkgs.stdenv.mkDerivation {
        name = "update-directory-hashes";
        src = self;
        propagatedBuildInputs = with pkgs; [kubo jq nodejs-slim]; # TODO: actually fixup the script
        buildPhase = ''
          mkdir "$out"
          mkdir "$out/bin"
          mkdir -p "$out/nix-support"
          echo "$propagatedBuildInputs" > "$out/nix-support/propagated-build-inputs"
          cp find_vanity.js micro_ipfs.js sha256.js "$out/bin/"
          cp update_directory_hashes.sh "$out/bin/update-directory-hashes"
        '';
      };
  };
}
