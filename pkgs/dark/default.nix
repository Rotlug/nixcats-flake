{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin rec {
  pname = "arctic.nvim";
  version = "812d43389d63a9e9d160258d04fa392daef593c2";
  src = pkgs.fetchFromGitHub {
    owner = "doums";
    repo = "dark.nvim";
    rev = version;
    sha256 = "sha256-t3jCNS50lNyJAwcORe3vO3vP5qDrfPCBXn62VGrzOos=";
  };
}
