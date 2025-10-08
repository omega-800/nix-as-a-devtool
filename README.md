<div align="center">

# Nix as a devtool

[![nix](https://img.shields.io/static/v1?logo=nixos&color=415e9a&logoColor=D9E0EE&labelColor=699ad7&label=built%20with&message=nixpkgs&link=https%3A%2F%2Fgithub.com%2Fnixos%2Fnixpkgs)](https://github.com/nixos/nixpkgs)
[![nix-github-actions](https://img.shields.io/static/v1?logo=nixos&color=415e9a&logoColor=D9E0EE&labelColor=699ad7&label=built%20with&message=nix-github-actions&link=https%3A%2F%2Fgithub.com%2Fnix-community%2Fnix-github-actions)](https://github.com/nix-community/nix-github-actions)
[![git-hooks.nix](https://img.shields.io/static/v1?logo=nixos&color=415e9a&logoColor=D9E0EE&labelColor=699ad7&label=built%20with&message=pre-commit-hooks&link=https%3A%2F%2Fgithub.com%2Fcachix%2Fgit-hooks.nix)](https://github.com/cachix/git-hooks.nix)
[![treefmt-nix](https://img.shields.io/static/v1?logo=nixos&color=415e9a&logoColor=D9E0EE&labelColor=699ad7&label=built%20with&message=treefmt-nix&link=https%3A%2F%2Fgithub.com%2Fnumtide%2Ftreefmt-nix)](https://github.com/numtide/treefmt-nix)

</div>

## About

This project aims to show how nix can integrate into the software-development workflow in various stages.

## Getting Started

### Prerequisites

Steps 2 and 3 are optional but recommended

1. [Installing nix](https://nixos.org/download/)
1. [Installing home-manager](https://home-manager.dev/manual/24.11/index.xhtml#ch-installation)
1. Installing direnv through home-manager

```nix
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

4. Cloning the repo

```sh
# using git
git clone https://www.github.com/omega-800/nix-as-a-devtool
# alternatively, using nix with the template output of this repo's flake
nix flake new --template github:omega-800/nix-as-a-devtool ./nix-as-a-devtool
```

Or you can just try it out in the [codespace](https://literate-guide-rpq69g9q9772696.github.dev/)

## Usage

- Formatting: `nix fmt`
- Testing: `nix flake check`
- Running: `nix run`
- Building: `nix build`
- Developing (if not using direnv): `nix develop`
- Inspecting the flake: `nix flake show`

## Resources

- [flake anatomy](https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/)
- [devshell templates](https://github.com/the-nix-way/dev-templates)
- [nix-direnv](https://github.com/nix-community/nix-direnv)
- [NixOS and flakes book](https://nixos-and-flakes.thiscute.world/)
- [nixpkgs search](https://search.nixos.org)
- [search tool for nix functions (like hoogle)](https://noogle.dev)

## License

Distributed under the baba yaga license. See [LICENSE.txt](LICENSE.txt) for more information.

## Acknowledgments

- [Software Crafters Meetup](https://www.github.com/Software-Crafters-Meetup/Software-Crafters)
