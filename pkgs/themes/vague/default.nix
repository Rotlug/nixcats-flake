{pkgs, ...}:
pkgs.vimUtils.buildVimPlugin rec {
  pname = "vague.nvim";
  version = "fcc283576764474ccfbbcca240797d5d7f4d8a78";

  src = pkgs.fetchFromGitHub {
    owner = "vague-theme";
    repo = "vague.nvim";
    rev = version;
    sha256 = "sha256-upqvTAnmJBAIoyzGxv+hq04dvS5wv3bjkbx2pWLCp+s=";
  };
}
