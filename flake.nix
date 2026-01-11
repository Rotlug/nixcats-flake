{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = ./.;
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = {
      # allowUnfree = true;
    };
    dependencyOverlays =
      /*
      (import ./overlays inputs) ++
      */
      [
        (utils.standardPluginOverlay inputs)
      ];

    categoryDefinitions = {
      pkgs,
      settings,
      categories,
      extra,
      name,
      mkPlugin,
      ...
    } @ packageDef: {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
          wl-clipboard
        ];

        nix = with pkgs; [
          nixd
          alejandra
        ];

        python = with pkgs; [
          pyright
          ruff
        ];

        lua = with pkgs; [
          lua-language-server
          stylua
        ];

        go = with pkgs; [
          goimports-reviser
          golines
          gopls
        ];

        webdev = with pkgs; [
          typescript-language-server
          emmet-language-server
          tailwindcss-language-server
          vscode-langservers-extracted
          prettierd
        ];

        rust = with pkgs; [
          rustfmt
          rust-analyzer
          clippy
          taplo # Format toml files
        ];

        c = with pkgs; [
          clang-tools
          cmake-language-server
          cmake-format
        ];

        qml = with pkgs; [
          kdePackages.qtdeclarative # includes qmlls
        ];

        godot = with pkgs; [
          gdscript-formatter
        ];
      };

      startupPlugins = {
        general = with pkgs.vimPlugins; {
          always = [
            lze
            lzextras
            vim-repeat
            plenary-nvim
            (nvim-notify.overrideAttrs {doCheck = false;}) # TODO: remove overrideAttrs after check is fixed
          ];
          extra = [
            oil-nvim
            nvim-web-devicons
          ];
        };
        transparent = with pkgs.vimPlugins; [
          transparent-nvim
        ];

        themer = with pkgs.vimPlugins; {
          "onedark" = onedark-nvim;
          "catppuccin" = catppuccin-nvim;
          "catppuccin-mocha" = catppuccin-nvim;
          "tokyonight" = tokyonight-nvim;
          "tokyonight-day" = tokyonight-nvim;
          "kanagawa" = kanagawa-nvim;

          "duskfox" = nightfox-nvim;
          "nightfox" = nightfox-nvim;
          "dawnfox" = nightfox-nvim;
          "carbonfox" = nightfox-nvim;
          "dayfox" = nightfox-nvim;

          "everforest" = everforest;
          "arctic" = pkgs.callPackage ./pkgs/themes/arctic {};
          "jb" = pkgs.callPackage ./pkgs/themes/jb {};
          "alabaster" = pkgs.callPackage ./pkgs/themes/alabaster {};
          "vague" = pkgs.callPackage ./pkgs/themes/vague {};
        };
      };

      optionalPlugins = {
        format = with pkgs.vimPlugins; [
          conform-nvim
        ];
        markdown = with pkgs.vimPlugins; [
          markdown-preview-nvim
        ];
        general = {
          blink = with pkgs.vimPlugins; [
            luasnip
            cmp-cmdline
            blink-cmp
            blink-compat
            colorful-menu-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          always = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim
            gitsigns-nvim
            vim-sleuth
            vim-fugitive
            vim-rhubarb
            nvim-surround
            mini-pairs
            nvim-ufo
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            # lualine-lsp-progress
            which-key-nvim
            comment-nvim
            undotree
            vim-startuptime
            todo-comments-nvim
            # If it was included in your flake inputs as plugins-hlargs,
            # this would be how to add that plugin in your config.
            # pkgs.neovimPlugins.hlargs
          ];
          # IDE-Like plugins
          ide = with pkgs.vimPlugins; [
            nvim-tree-lua
          ];
        };
        webdev = with pkgs.vimPlugins; [
          nvim-ts-autotag
        ];
        rust = with pkgs.vimPlugins; [
          rustaceanvim
        ];
      };
    };

    packageDefinitions = {
      nvim = {
        pkgs,
        name,
        ...
      } @ misc: {
        settings = {
          suffix-path = true;
          suffix-LD = true;
          # WARNING: MAKE SURE THESE DONT CONFLICT WITH OTHER INSTALLED PACKAGES ON YOUR PATH
          # That would result in a failed build, as nixos and home manager modules validate for collisions on your path
          aliases = ["vim" "vimcat"];

          # explained below in the `regularCats` package's definition
          # OR see :help nixCats.flake.outputs.settings for all of the settings available
          wrapRc = true;
          configDirName = "nixCats-nvim";
          # neovim-unwrapped = inputs.neovim-nightly-overlay.packages.${pkgs.system}.neovim;
          hosts.python3.enable = true;
          hosts.node.enable = true;
        };
        # enable the categories you want from categoryDefinitions
        categories = {
          markdown = true;
          general = true;
          format = true;

          transparent = false;
          dynamic_theme = true;

          # Languages
          nix = true;
          python = true;
          webdev = true;
          lua = true;
          go = true;
          rust = true;
          qml = true;
          godot = true;
          c = true;

          themer = true;

          # If the dyanmic_theme category is disabled,
          # This config will use the dark theme
          theme_light = "dayfox";
          theme_dark = "vague";
        };
        extra = {
          nixdExtras = {
            nixpkgs = ''import ${pkgs.path} {}'';
            # or inherit nixpkgs;
          };
        };
      };
    };

    defaultPackageName = "nvim";
  in
    forEachSystem (system: let
      nixCatsBuilder =
        utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions;
      defaultPackage = nixCatsBuilder defaultPackageName;

      pkgs = import nixpkgs {inherit system;};
    in {
      packages = utils.mkAllWithDefault defaultPackage;

      devShells = {
        default = pkgs.mkShell {
          name = defaultPackageName;
          packages = [defaultPackage];
          inputsFrom = [];
          shellHook = ''
          '';
        };
      };
    })
    // (let
      nixosModule = utils.mkNixosModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
      homeModule = utils.mkHomeModules {
        moduleNamespace = [defaultPackageName];
        inherit
          defaultPackageName
          dependencyOverlays
          luaPath
          categoryDefinitions
          packageDefinitions
          extra_pkg_config
          nixpkgs
          ;
      };
    in {
      overlays =
        utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        }
        categoryDefinitions
        packageDefinitions
        defaultPackageName;

      nixosModules.default = nixosModule;
      homeModules.default = homeModule;

      inherit utils nixosModule homeModule;
      inherit (utils) templates;
    });
}
