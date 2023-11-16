{
  description = "Easily-archivable IPFS sites";
  outputs = { self, nixpkgs }: {
    defaultPackage.x86_64-linux = self.packages.x86_64-linux.update-directory-hashes;
    packages.x86_64-linux.update-directory-hashes =
      let pkgs = import nixpkgs { system = "x86_64-linux"; }; in
      pkgs.stdenv.mkDerivation {
        name = "update-directory-hashes";
        src = self;
        buildInputs = with pkgs; [kubo jq nodejs-slim];
        buildPhase = ''
          cp update_directory_hashes.sh "$out"
        '';
      };
  };
}
