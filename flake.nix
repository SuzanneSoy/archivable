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
          cp update_directory_hashes.sh "$out/bin/update-directory-hashes"
        '';
      };
  };
}
