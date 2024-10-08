{ pkgs, lib, ... }: 

let
  enableAllPrecommitHooks = false;
in
{

  name = "Python Development Sandbox";

  # Enable devcontainer support
  # Note: features are not used and replaced by devenv
  devcontainer = {
    enable = true;
    settings = {
      customizations = {
        vscode = {
          settings = {
            # Standard
            update.showReleaseNotes = false;
            window.commandCenter = false;
            workbench.colorTheme = "GitHub Dark Default";
            workbench.preferredDarkColorTheme = "GitHub Dark Default";
            workbench.preferredLightColorTheme = "GitHub Light Default";
            workbench.preferredHighContrastColorTheme = "GitHub Dark High Contrast";
            workbench.preferredHighContrastLightColorTheme = "GitHub Light High Contrast";
            editor.formatOnSave = true;
            editor.formatOnPaste = true;
            editor.minimap.autohide = true;
            asciidoc.antora.enableAntoraSupport = false;
            asciidoc.extensions.enableKroki = true;
            # Stack Specific
            python.defaultInterpreterPath = ".devenv/profile/bin/python";
          };
          extensions = [
            # Standard
            "github.github-vscode-theme"
            "github.codespaces"
            "github.copilot"
            "github.copilot-chat"
            "asciidoctor.asciidoctor-vscode"
            "mkhl.direnv"
            # Notebooks and additional features
            "marimo-team.vscode-marimo"
            # Stack specific
            "ms-python.python"
          ]; 
        };
        codespaces = {
          "openFiles" = [
            # Open README at launch
            "README.md"
          ];
        };
      };
      # Capacity requested for devcontainer
      hostRequirements = {
        cpus = 2;
        memory = "8gb";
        storage = "32gb";
      };
      # Optional: Secret asked when starting the dev devcontainer
      secrets = {};
    };
  };

  # Enable starship for a better prompt
  # Will load a project starship.toml
  starship = {
    enable = true;
    config.enable = true;
  };

  # Common packages for developers
  difftastic.enable = true;
  packages = with pkgs; [ 
    # Standard
    curl
    git
    gh
    jq
    # Stack specific
    zlib  # Required for numpy and other data package
  ];

  # Toolchain: Python with poetry
  # Note: the venv is deactivated by default
  languages.python = {
    enable = true;
    uv = {
      enable = true;
    };
  };

  # Pre-commit hooks: Python
  pre-commit.hooks = {
    flake8.enable = enableAllPrecommitHooks;
    autoflake.enable = enableAllPrecommitHooks;
    black.enable = enableAllPrecommitHooks;
    mypy.enable = enableAllPrecommitHooks;
  };

  # Additional services (attached resources)
  # No additional services, this is a sandbox
  services = {};

  # Environment variables
  dotenv.enable = false;
  env = {
    DEVENV_STACK = "python";
  };
 
  # Special hosts
  # Can be used to mock external attached resources
  hosts = {
    "locahost" = "127.0.0.1";
  };

  # Scripts: Python
  # Can be used as aliases
  scripts = {
    # Workflow shortcuts
    new.exec = ''
      printf "\033[1m%s\033[0m\n" "Create New Project"
      printf " ! Organisation: "
      read -r my_orga
      printf " ! Repository Name: "
      read -r my_repo_name
      printf " ✓ Creating a new repo \033[3m%s\033[0m in organisation \033[3m%s\033[0m based on template \033[3m%s\033[0m!\n" "''${my_repo_name}" "''${my_orga}" "''${DEVENV_STACK}-template" 
      gh create "''${my_repo_name}" --clone --template "https://github.com/''${my_orga}/''${DEVENV_STACK}-workspace.git"
    '';
    init.exec = ''
      uv init
      uv --all-extras --dev
    '';
    update.exec = ''
      uv lock --upgrade
    '';
    build.exec = ''
      uv build
    '';
    run.exec = ''
      uv run $*
    '';
    test.exec = ''
      uv run pytest tests
    '';
  };

  # Startup commands
  enterShell = ''
    clear
    echo "【ツ】Welcome to your 🐍 Python Sandbox!"
    python --version
    uv --version
  '';

}
