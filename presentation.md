______________________________________________________________________

## author: omega-800 date: dd.mm.YYYY paging: page %d / %d

# Nix as a devtool

Welcome!

```sh
git clone https://github.com/omega-800/nix-as-a-devtool
```

______________________________________________________________________

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
