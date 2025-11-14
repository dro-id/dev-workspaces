{ pkgs, lib, ... }: 

let
  enableAllPrecommitHooks = false;
in
{

  name = "CDKTF Development Sandbox";


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
          };
          extensions = [
            # Standard
            "github.github-vscode-theme"
            "github.codespaces"
            "github.copilot"
            "github.copilot-chat"
            "asciidoctor.asciidoctor-vscode"
            "mkhl.direnv"
            # Stack specific
            "hashicorp.terraform"
            "dbaeumer.vscode-eslint"
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
      # Optional: Secret asked when starting the devcontainer
      secrets = {};
    };
  };

  # Enable starship for a better prompt
  # Will load a project starship.toml
  starship = {
    enable = true;
    config.enable = false;
  };

  # Common packages for developers
  difftastic.enable = true;
  packages = with pkgs; [ 
    # Standard
    curl
    git
    gh
    jq
    # Stack specific, mandatory
    awscli2     # root cli
    cdktf-cli   # CDKTF CLI
    # Stack specific, optional
    localstack  # Run locally, mocking AWS api 
    trivy       # Static scanning 
    infracost   # Get cost, hopefully once in trivy
  ];

  # Toolchain: CDKTF (Terraform + TypeScript/JavaScript)
  languages = {
    terraform.enable = true;
    typescript.enable = true;
  };
  
  # Pre-commit hooks: CDKTF
  git-hooks.hooks = {
    terraform-format.enable = enableAllPrecommitHooks; # formatter
    tflint.enable = enableAllPrecommitHooks;           # linter
    eslint.enable = enableAllPrecommitHooks;           # TypeScript/JavaScript linter
  };

  # Additional services (attached resources)
  # No additional services, this is a sandbox
  services = {};

  # Environment variables
  dotenv.enable = false;
  env = {
    DEVENV_STACK = "cdktf";
    # Localstack, set your token and activate pro feature
    # LOCALSTACK_AUTH_TOKEN = "";
    # ACTIVATE_PRO = 1;
  };
 
  # Special hosts
  # Can be used to mock external attached resources
  hosts = {
    "locahost" = "127.0.0.1";
  };

  # Scripts: CDKTF
  # Can be used as aliases
  scripts = {
    # Status message
    status.exec = ''
      clear
      echo "【ツ】Welcome to your 🔧 CDKTF (stable) Sandbox!"
      printf "Terraform v%s\n" `terraform version --json | jq -r '.["terraform_version"]'`
      printf "CDKTFv%s\n" `cdktf --version 2>/dev/null | head -n 1`
      printf "Node v%s\n" `node --version`
      printf "TypeScript v%s\n" `tsc --version | cut -d " " -f 2`
      printf "\nIt comes with some additional optional goodies...\n"
      printf "Trivy %s\n" `trivy -v | cut -d " " -f 2`
      printf "Localstack v%s\n" `localstack --version`
      printf "Infracost %s\n\n" `infracost --version 2>/dev/null | cut -d " " -f 2`
    '';
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
      cdktf init --template=typescript --local
    '';
    synth.exec = ''
      cdktf synth
    '';
    diff.exec = ''
      cdktf diff
    '';
    deploy.exec = ''
      cdktf deploy
    '';
    destroy.exec = ''
      cdktf destroy
    '';
    get.exec = ''
      cdktf get
    '';
  };

}
