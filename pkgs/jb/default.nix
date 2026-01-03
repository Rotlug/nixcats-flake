{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin rec {
  pname = "jb.nvim";
  version = "10e5efc6bfa1b40dee7d8f19c9a2199a7f141329";
  src = pkgs.fetchFromGitHub {
    owner = "nickkadutskyi";
    repo = "jb.nvim";
    rev = version;
    sha256 = "sha256-kO6dlxJTC1nBKVCiaMAOyT8+ULX7c/CaZR1EyoXVmMA=";
  };
}
