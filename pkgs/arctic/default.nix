{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin rec {
  pname = "arctic.nvim";
  version = "9052ab87b1d6e9b746ab8dde6576e2876ffda4c7";
  src = pkgs.fetchFromGitHub {
    owner = "rockyzhang24";
    repo = "arctic.nvim";
    rev = version;
    sha256 = "sha256-4A457/kIKwqad6kEJI+jeiAVUS08v509NpLtbKIE920=";
  };

  propagatedBuildInputs = with pkgs; [
    luajitPackages.lush-nvim
  ];
}
