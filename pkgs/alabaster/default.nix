{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin rec {
  pname = "alabaster.nvim";
  version = "1fc9e29fbbce94f127cc8b21960b7e3c85187960";
  src = pkgs.fetchFromGitHub {
    owner = "p00f";
    repo = "alabaster.nvim";
    rev = version;
    sha256 = "sha256-Xng+shYT7BtrD6ZSnCGgt01lm9ZALfYwivYRGRjNpUo=";
  };
}
