{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  mypkgs = import inputs.nixpkgs {
    system = pkgs.stdenv.system;
    config.allowUnfree = true;
  };

  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.stdenv.system;
    config.allowUnfree = true;
  };
in

{
  env.USER_DIR = "./app_data";
  env.TZ = "America/New_York";

  packages = [
    pkgs.git
    pkgs-unstable.google-chrome
  ];

  languages.javascript = {
    enable = true;
    package = pkgs-unstable.nodejs_22;
  };

  scripts.app.exec = ''
    export TZ=$TZ
  '';

  scripts.pre-commit.exec = ''
    APP_DATA_DIR="app_data"
    ARCHIVE_NAME="app_data.tar.xz"

    if [ -d "$APP_DATA_DIR" ]; then
        # Remove previous archive if it exists
        rm -f "$ARCHIVE_NAME"
        
        # Create new archive with maximum compression
        tar -cf - "$APP_DATA_DIR" | xz -9e > "$ARCHIVE_NAME"
        
        # Add the compressed archive to git
        git add "$ARCHIVE_NAME"
        
        echo "Successfully compressed $APP_DATA_DIR to $ARCHIVE_NAME"
    else
        echo "Error: $APP_DATA_DIR directory not found"
        exit 1
    fi
  '';

  scripts.post-commit.exec = ''
    APP_DATA_DIR="app_data"
    ARCHIVE_NAME="app_data.tar.xz"

    if [ -f "$ARCHIVE_NAME" ]; then
        # Remove previous archive if it exists
        rm -f "$ARCHIVE_NAME"

        echo "Successfully deleted $ARCHIVE_NAME"
    else
        echo "Error: $ARCHIVE_NAME file not found"
        exit 1
    fi
  '';

  # pre-commit.hooks.pre-commit = {
  #   enable = true;
  #   name = "pre-commit";
  #   description = "compress data folder";
  #   files = "";
  #   entry = "pre-commit";
  # };

  # git-hooks.hooks.unit-tests = {
  #   enable = true;

  #   # The name of the hook (appears on the report table):
  #   name = "pre-commit";

  #   # The command to execute (mandatory):
  #   entry = "pre-commit";

  #   # The language of the hook - tells pre-commit
  #   # how to install the hook (default: "system")
  #   # see also https://pre-commit.com/#supported-languages
  #   language = "system";

  #   # Set this to false to not pass the changed files
  #   # to the command (default: true):
  #   pass_filenames = false;
  # };

}
