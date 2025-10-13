---

author: omega-800 
date: dd.mm.YYYY 
paging: page %d / %d

---

# Nix as a devtool

## Welcome!    

This project aims to show how nix can integrate into the software-development workflow in various stages.    

```sh
git clone https://github.com/omega-800/nix-as-a-devtool
```
---

## Getting Started

Steps 2 and 3 are optional but recommended

1. [Installing nix](https://nixos.org/download/)
2. [Installing home-manager](https://home-manager.dev/manual/24.11/index.xhtml#ch-installation)
3. Installing direnv through home-manager

```nix
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
```

---

## Prerequisites

4. Cloning the repo

```sh
# using git
git clone https://www.github.com/omega-800/nix-as-a-devtool
# alternatively, using nix with the template output of this repo's flake
nix flake new --template github:omega-800/nix-as-a-devtool ./nix-as-a-devtool
```

Or you can just try it out in the [codespace](https://literate-guide-rpq69g9q9772696.github.dev/)

---

## Usage

- Formatting: `nix fmt`
- Testing: `nix flake check`
- Running: `nix run`
- Building: `nix build`
- Developing (if not using direnv): `nix develop`
- Inspecting the flake: `nix flake show`
- Applying home-manager: `home-manager switch --flake .#${your-system}`
  - eg: `home-manager switch --flake .#x86_64-linux`
- Using this repo as a template: `nix flake init --template github:omega-800/nix-as-a-devtool`

---

## Flake anatomy

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = inputs: {
  
  };
}
```

---

## Resources

- [flake anatomy](https://vtimofeenko.com/posts/practical-nix-flake-anatomy-a-guided-tour-of-flake.nix/)
- [devshell templates](https://github.com/the-nix-way/dev-templates)
- [nix-direnv](https://github.com/nix-community/nix-direnv)
- [NixOS and flakes book](https://nixos-and-flakes.thiscute.world/)
- [nixpkgs search](https://search.nixos.org)
- [search tool for nix functions (like hoogle)](https://noogle.dev)
