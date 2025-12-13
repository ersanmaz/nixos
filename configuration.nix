# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  user = "ersan";
  jdk17 = pkgs.openjdk17;
  jdks = pkgs.buildEnv {
    name = "java-env";
    paths = [ jdk17 ];
  };
in

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix      
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.autoUpgrade.enable = true;
  system.autoUpgrade.flags = [
    "--delete-older-than" "3"
  ];

  system.activationScripts.pruneOldGenerations.text = ''
    echo "Pruning old system generations..."
    ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/system --delete-generations +3 || true
  '';

  nix.settings.keep-derivations = false;
  nix.settings.keep-outputs = false;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3";
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = "ersan";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      (vim-full.customize {
        name = "vim";
        vimrcConfig.customRC = ''
          set number            " Enable line numbers
          set ignorecase        " Ignore case in search patterns
          set mouse=a           " Enable mouse support
		  set tabstop=4
    	  set shiftwidth=4
		  set smartindent
		  set clipboard=unnamedplus
          syntax enable         " Enable syntax highlighting
        '';
      })
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes + new nix commands
  #nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.permittedInsecurePackages = [
    "qtwebengine-5.15.19"
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    curl
	bat
    vim
    neovim
    zsh
    zsh-powerlevel10k
    zsh-autosuggestions
    zsh-syntax-highlighting
    meslo-lgs-nf
    unzip
    openssl
    dconf
    gnome-tweaks
    gnome-terminal
    papirus-icon-theme
    tela-icon-theme
    yaru-theme
    libgtop
    vscode
    jetbrains.idea-ultimate
    google-chrome
    stremio
    kubectl
    k9s
    helm
    fzf
    fish
    zellij
    unzip
    gnutar
    zip
    jq
    htop
    jdks
    qpdfview
    whatsie
    hypnotix
    vlc
    wl-clipboard
    flatpak
  ];

  # Podman
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    autoPrune.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Powerlevel10k (optional)
    promptInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';

    interactiveShellInit = ''
      # Set up history size
      HISTSIZE=50000
      SAVEHIST=50000

      # Set history file path
      HISTFILE="$HOME/.zsh_history"

      setopt AUTO_CD             # Change directory just by typing the name
      
      # Set history options (Equivalent to ignoreAllDups = true)
      setopt HIST_FIND_NO_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS          # Important: ensures no duplicates are saved to the file
      setopt APPEND_HISTORY             # Append to the history file, don't overwrite
      setopt SHARE_HISTORY              # Share history among all open shells
      setopt HIST_REDUCE_BLANKS
      setopt INC_APPEND_HISTORY
      
      # Set environment variables
      export EDITOR="vim"
      export XDG_DATA_DIRS=$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:/home/ersan/.local/share/flatpak/exports/share

      # Remove redundant/conflicting bindings
      bindkey -r "^[n"
      bindkey -r "^[p"
      bindkey -r "^[[P"
      bindkey -r "^[[Q"
      bindkey -r "^[[R"
      bindkey -r "^[[S"

      bindkey -e

      # Move cursor by word like in Bash
      bindkey '^[[1;5C' forward-word      # Ctrl + Right
      bindkey '^[[1;5D' backward-word     # Ctrl + Left

      # Fish-style up/down arrow history search
      bindkey "^[OA" history-search-backward
      bindkey "^[OB" history-search-forward
      bindkey "^[[A" history-search-backward
      bindkey "^[[B" history-search-forward

      bindkey "^I" complete-word

      ###################################################
      # Fish-like TAB completion menu                   #
      ###################################################

      zstyle ":completion:*" menu yes select
      zstyle ":completion:*" verbose yes
      zstyle ":completion:*" group-name ""
      zstyle ":completion:*:descriptions" format "%F{yellow}%d%f"
      zstyle ":completion:*" list-colors ""

      zstyle ":completion:*" matcher-list \
        "m:{a-zA-Z}={A-Za-z}" \
        "r:|[._-]=* r:|=*"

      # Ctrl-R incremental search (fzf widget)
      if [ -f "${pkgs.fzf}/share/fzf/key-bindings.zsh" ]; then
        source "${pkgs.fzf}/share/fzf/key-bindings.zsh"
      fi
    '';

    # --- Aliases ---
    shellAliases = {
      nix-up = "sudo nixos-rebuild switch";
      nix-gc = "nix-collect-garbage -d";
    };

  };

  system.userActivationScripts.createEmptyZshrc = ''
    echo 'source /etc/zshrc' > $HOME/.zshrc
    chmod 644 $HOME/.zshrc
  '';


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
