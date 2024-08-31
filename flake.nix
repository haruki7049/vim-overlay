{
  description = "Vim overlay flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    vim-src = {
      url = "github:vim/vim";
      flake = false;
    };
  };

  outputs = { nixpkgs, vim-src, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        vim-overlay = final: prev: {
          vim = prev.vim.overrideAttrs (oldAttrs: {
            version = "latest";
            src = vim-src;
            configureFlags =
              oldAttrs.configureFlags
              ++ [
                "--enable-terminal"
                "--with-compiledby=vim-overlay"
                "--enable-luainterp"
                "--with-lua-prefix=${prev.lua}"
                "--enable-fail-if-missing"
              ];
            buildInputs =
              oldAttrs.buildInputs
              ++ [prev.gettext prev.lua prev.libiconv];
          });
        };
      in
      {
        overlays.default = vim-overlay;

        packages =
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              vim-overlay
            ];
          };
        in
        {
          vim = pkgs.vim;
          default = pkgs.vim;
        };
      });
}
