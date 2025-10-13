{
  # a helpful description
  description = "Showcase of using nix for development";

  # think of inputs as dependencies of your development environment configuration
  inputs = {
    # nixpkgs is the source of all our packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # github actions integration
    nix-github-actions = {
      # more often than not the url will be a link to a github repository containing the source
      url = "github:nix-community/nix-github-actions";
      # the dependencies of our dependencies can be pinned to use the same version as we are
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # git commit hooks
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # for formatting our codebase
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # here the fun part begins! in the outputs we declare what our flake produces
  outputs =
    {
      nixpkgs,
      treefmt-nix,
      pre-commit-hooks,
      nix-github-actions,
      home-manager,
      self,
      ...
    }:
    # all variables defined inside of this let binding are available for the scope below
    let
      # the systems we want to support
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
      ];
      # a helper function to map all the configurations to each system
      eachSystem =
        f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              config = { };
              overlays = [ ];
            }
          )
        );

      # our treefmt config
      treefmt = eachSystem (
        pkgs:
        treefmt-nix.lib.evalModule pkgs (_: {
          # used to find the project root
          projectRootFile = "flake.nix";
          programs = {
            # go formatter
            gofmt.enable = true;
            # adds missing & removes unused go imports
            goimports.enable = true;
            # markdown formatter
            mdformat.enable = true;
            # nix formatter
            nixfmt.enable = true;
            # static linting for nix files
            statix.enable = false;
          };
          settings.formatter.mdformat = {
            excludes = [ "presentation.md" ];
            number = true;
            wrap = 80;
          };
        })
      );
    in
    {
      # arguably the most important part, our shell
      devShells = eachSystem (pkgs: rec {
        my-dev-shell =
          let
            inherit (self.checks.${pkgs.system}) pre-commit-check;
          in
          pkgs.mkShell {
            # shell hook to lint and format our codebase before each commit
            inherit (pre-commit-check) shellHook;
            # packages needed for the above to work
            buildInputs = pre-commit-check.enabledPackages;
            # packages needed for development (in this case go toolchain)
            packages = with pkgs; [
              go
              gotools
              golangci-lint
            ];
          };
        # setting the default shell so that we can run nix develop instead of nix develop .#my-dev-shell
        default = my-dev-shell;
      });

      # can be built through `nix build`
      packages = eachSystem (pkgs: rec {
        my-package = pkgs.buildGoModule {
          name = "nix-as-a-devtool";
          version = "0.0.1";
          src = ./.;
          vendorHash = null;
        };
        default = my-package;
      });

      # can be run through `nix run`
      apps = eachSystem (pkgs: rec {
        # a cool presentation
        presentation = {
          type = "app";
          program = "${pkgs.writeShellScript "presentation" "${pkgs.slides}/bin/slides ${./presentation.md}"}";
        };
        # our package
        my-app = {
          type = "app";
          program = "${self.packages.${pkgs.system}.my-package}/bin/nix-as-a-devtool";
        };
        default = my-app;
      });

      # can be run through `nix flake check`
      checks = eachSystem (
        pkgs:
        let
          expectedOutput = "'Hello world'";
        in
        {
          # will be run before each commit through including the shellHook in our devShell
          pre-commit-check = pre-commit-hooks.lib.${pkgs.system}.run {
            src = ./.;
            hooks = {
              # running go test
              gotest.enable = true;
              # the formatting config we declared before
              treefmt = {
                enable = true;
                packageOverrides.treefmt = treefmt.${pkgs.system}.config.build.wrapper;
              };
            };
          };
          # test with a simple shell script
          simple-check = pkgs.runCommandLocal "simple-check" { } ''
            ${self.packages.${pkgs.system}.my-package}/bin/nix-as-a-devtool | grep -q ${expectedOutput}
            mkdir "$out"
          '';
          # test inside a virtual machine
          vm-test = pkgs.nixosTest {
            name = "vm-test";
            # python script to run inside of the vm
            testScript = ''
              result = machine.succeed("nix-as-a-devtool | grep -q ${expectedOutput}")
            '';
            # vm for isolated testing
            nodes.my-vm =
              { modulesPath, ... }:
              {
                imports = [ "${modulesPath}/virtualisation/qemu-vm.nix" ];
                # setting a user
                users.users.alice = {
                  isNormalUser = true;
                  initialPassword = "test";
                  extraGroups = [ "wheel" ];
                };
                # adding our package to the vm
                environment.systemPackages = [ self.packages.${pkgs.system}.my-package ];
                boot.loader.grub.devices = [ "/dev/sda" ];
                system.stateVersion = "25.05";
              };
          };
        }
      );

      # can be run through `nix fmt`
      formatter = eachSystem (pkgs: treefmt.${pkgs.system}.config.build.wrapper);

      # lets github know which tests to run
      githubActions = nix-github-actions.lib.mkGithubMatrix {
        checks =
          let
            # github doesn't support all architectures
            onlySupported = nixpkgs.lib.getAttrs [
              "x86_64-linux"
              "x86_64-darwin"
            ];
          in
          (onlySupported self.checks) // (onlySupported self.packages);
      };

      # can be used as a template through `nix flake init --template github:omega-800/nix-as-a-devtool`
      templates.default = {
        description = "This repo can be used as a template";
        path = ./.;
      };

      # homeManager configurations to be used with eg. `home-manager switch --flake .#x86_64-linux`
      homeConfigurations = eachSystem (
        pkgs:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ self.homeManagerModules.default ];
        }
      );

      # homeManager modules
      homeManagerModules.default = _: {
        programs.direnv = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
          enableFishIntegration = true;
          enableNushellIntegration = true;
          nix-direnv.enable = true;
          config = {
            strict_env = true;
            load_dotenv = true;
          };
        };
        home = rec {
          username = "alice";
          homeDirectory = "/home/${username}";
          stateVersion = "25.05";
        };
      };
    };
}
