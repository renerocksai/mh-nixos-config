# adopted to mitchell's framework


# sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
# sudo nix-channel --update
#
# In configuration.nix:
# imports =
#   [ # Include the results of the hardware scan.
#     ./hardware-configuration.nix
#     <home-manager/nixos>
#     ./home.nix
#   ];
#
{ isWSL, inputs, ... }:

  { config, lib, pkgs, ... }:

let
  sources = import ../../nix/sources.nix;
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

in {

    home.stateVersion = "23.05";

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    # pkgs._1password
    # pkgs.asciinema
    pkgs.bat
    pkgs.eza
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.sentry-cli
    pkgs.tree
    pkgs.watch

    pkgs.zigpkgs."0.13.0"

    # Node is required for Copilot.vim
    pkgs.nodejs
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
    pkgs.tailscale
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    pkgs.chromium
    pkgs.firefox
    pkgs.rofi
    pkgs.valgrind

    pkgs.wget
    pkgs.neovim
    pkgs.git
    pkgs.git-crypt
    pkgs.stow
    pkgs.tmux
    pkgs.file
    pkgs.nix-index
    pkgs.htop
    pkgs.ncdu
    pkgs.xclip
    pkgs.unixtools.killall
    pkgs.ripgrep
    pkgs.bat
    pkgs.neofetch

    pkgs.python312Full
    pkgs.python312Packages.python-lsp-server

    pkgs.lazyjj

    pkgs.binutils pkgs.gnutar pkgs.gzip pkgs.gnumake pkgs.gcc pkgs.binutils pkgs.coreutils pkgs.gawk pkgs.gnused pkgs.patchelf pkgs.findutils
    pkgs.elfutils pkgs.colordiff pkgs.diff-so-fancy
    pkgs.ninja pkgs.cmake pkgs.pkg-config pkgs.cloc

    pkgs.gtk4
    pkgs.adwaita-icon-theme
    pkgs.glib

    # ghdl gtkwave
    # pkgs.gnome3.adwaita-icon-theme
    # pkgs.breeze-icons
    pkgs.starship


    pkgs.stylua
    (pkgs.lua.withPackages(ps: with ps; [ busted luafilesystem luacheck ]))
    pkgs.sumneko-lua-language-server

    pkgs.zip
    pkgs.unzip
    pkgs.p7zip
    # pkgs.rar -- not available for aarch64-linux
    pkgs.xz
    pkgs.unrar

    pkgs.ffmpeg
    # pkgs.flameshot
    # pkgs.gimp
    pkgs.imagemagick
    pkgs.mediainfo
    # pkgs.obs-studio kdenlive krita mypaint kicad freecad

    # nodejs nodePackages.yarn
    # pkgs.nodePackages.markdownlint-cli    # this

    # pkgs.SDL2
    # xorg.libX11
    # xorg.libX11.dev
    # xorg.libXcursor
    # xorg.libXinerama
    # xorg.xinput
    # pkgs.xorg.libXrandr
    # pkgs.glew
    # pkgs.gtk3
    # pkgs.libGL

    # pkgs.google-chrome -- doesn't work: qemo-x86_64: .... ld-linux-aarch64.so.1: Invalid ELF image for this architecture


    # texlive.combined.scheme-full
    # NixOS 22.05: smbclient -> samba
    # samba
    # audacity


    # zig zls
    # gnome.zenity # for slides to launch outside of nix-shell

    pkgs.pavucontrol pkgs.pasystray
    pkgs.xorg.xhost
    # pkgs.ueberzug  # for telekasten img preview, xhost +

    # pkgs.youtube-dl vlc mpv haruna mplayer
    # ghostscript okular
    pkgs.feh

    # file manager(s)
    # dolphin : can't get thumbnails to work
    # pkgs.dolphin
    # pkgs.xfce.thunar pkgs.xfce.tumbler pkgs.ffmpegthumbnailer
    # pkgs.gnome.nautilus pkgs.gnome.sushi

    pkgs.openssl

    # furhat SDK
    # appimage-run

    # NAO SDK and RobotSettings
    # steam-run

    # eventually, we need some office crap
    # libreoffice-qt

    # signal-desktop

    pkgs.cmus


    # pkgs.wineWowPackages.stable
    # pkgs.winetricks

    # maybe later
    # steam

  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    # MANPAGER = "${manpager}/bin/manpager";
  };

  home.file = {
        # source "${config.home-manager.users.rs.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    ".profile".text = ''
        source "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
        export BROWSER="firefox"
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_BIN_HOME="$HOME/.local/bin"
        export XDG_LIB_HOME="$HOME/.local/lib"
        export XDG_CACHE_HOME="$HOME/.cache"

        export PATH="$PATH:$HOME/bin"

        export EDITOR='nvim'
        export VTERM='kitty'
        export TERM=xterm-256color
    '';
    ".gdbinit".source = ./gdbinit;
    ".inputrc".source = ./inputrc;
  } // (if isDarwin then {
    "Library/Application Support/jj/config.toml".source = ./jujutsu.toml;
  } else {});

  xdg.configFile = {
    "i3/config".text = builtins.readFile ./i3;
    "rofi/config.rasi".text = builtins.readFile ./rofi_config.rasi;
    "rofi/purple.rasi".text = builtins.readFile ./rofi_purple.rasi;

    # tree-sitter parsers
    # "nvim/parser/proto.so".source = "${pkgs.tree-sitter-proto}/parser";
    # "nvim/queries/proto/folds.scm".source =
    #   "${sources.tree-sitter-proto}/queries/folds.scm";
    # "nvim/queries/proto/highlights.scm".source =
    #   "${sources.tree-sitter-proto}/queries/highlights.scm";
    # "nvim/queries/proto/textobjects.scm".source =
    #   ./textobjects.scm;
  } // (if isDarwin then {
    # Rectangle.app. This has to be imported manually using the app.
    "rectangle/RectangleConfig.json".text = builtins.readFile ./RectangleConfig.json;
  } else {}) // (if isLinux then {
    "ghostty/config".text = builtins.readFile ./ghostty.linux;
    "jj/config.toml".source = ./jujutsu.toml;
  } else {});

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------


    programs.gpg.enable = !isDarwin;

    programs.autorandr = {
      enable = true;
    };

    programs.zsh = {
      enable = true;
	  autosuggestion.enable = true;
	  oh-my-zsh = {
	      enable = true;
	      plugins = [
            "git"
		    "sudo"
		    "zsh-syntax-highlighting"
	      ];
	      theme = "robyrussel";

	      extraConfig = ''
	        zstyle ':completion:*' rehash true
	      '';

	  };
    };

    programs.kitty  = {
       enable = true;
       font.name = "JetBrains Mono";
       font.size = 11;
       shellIntegration.enableZshIntegration = true;

       settings = {
           symbol_map="U+E0A0-U+E0A2,U+E0B0-U+E0B3 PowerlineSymbols";
           background = "#181818";
           dim_opacity = "0.75";
       };
    };

    programs.git = {
      enable = true;
      userEmail = "rene@renerocks.ai";
      userName = "Rene Schallner";
      aliases = {
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        st = "status -uno";
        fix = "!f() { vim -p +/HEAD $(git diff --relative --name-only | uniq); }; f";
        conflicts = "diff --name-only --diff-filter=U";
        vim = "!f() { nvim +'Gina status';};f";
      };

      delta.enable = true;
      delta.options = {
        features = "decorations";
      };

      extraConfig = {
        core = {
            # pager = "less -MIFRX";
            editor = "nvim";
        };

        color.ui = true;

        push.default = "upstream";

        color.diff-highlight = {
            oldNormal = "red bold";
            oldHighlight = "red bold 52";
            newNormal = "green bold";
            newHighlight = "green bold 22";
        };

        color.diff = {
           meta = 11;
           frag = "magenta bold";
           func = "146 bold";
           commit = "yellow bold";
           old = "red bold";
           new = "green bold";
           whitespace = "red reverse";
        };

        init.defaultBranch = "master";
      };
    };

    programs.git-cliff.enable = true;

    programs.jujutsu = {
      enable = true;

      # mitchell says:
      # I don't use "settings" because the path is wrong on macOS at
      # the time of writing this.
    };

    programs.tmux = {
      enable = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "tmux-256color";
      mouse = true;
      extraConfig = ''
        set -ga terminal-overrides ",*256col*:Tc"
        # default statusbar colors
        set-option -g status-bg colour231
        set-option -g status-fg colour130

        # pane number display
        set-option -g display-panes-active-colour brightred
        set-option -g display-panes-colour brightblue

        # clock
        set-window-option -g clock-mode-colour green

        # set -g status-right '#(battery -t -p -g blue -m blue -w red ) | %a %d %b %R'
        # set -g status-right '#(/Users/rs/bin/battery -t -p -a -g blue -m blue -w red ) | %a %d %b %R'

        set-option -g lock-command "cmatrix -C blue"

        set -as terminal-overrides ',xterm*:sitm=\E[3m'

        # nvim
        set-option -sg escape-time 10
        set-option -sa terminal-overrides ',xterm-256color:RGB'
        set -g focus-events on

        bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -sel clip -i"

        # vim style movements
        bind -r k select-pane -U
        bind -r j select-pane -D
        bind -r h select-pane -L
        bind -r l select-pane -R

        # Smart pane switching with awareness of Vim splits.
        # See: https://github.com/christoomey/vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        # if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        #    "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };

    programs.ssh = {
      enable = true;
      compression = true;

      matchBlocks = {
        "gitlab.com" = {
            hostname = "gitlab.com";
            user = "rs";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };

        "dsws" = {
            hostname = "192.168.100.31";
            port = 22;
            serverAliveInterval = 60;
            serverAliveCountMax = 2;
            user = "dl";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };

        "dsws2" = {
            hostname = "192.168.100.33";
            port = 22;
            serverAliveInterval = 60;
            serverAliveCountMax = 2;
            user = "nim";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };

        "github.com" = {
            hostname = "github.com";
            user = "renerocksai";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };

        "datascience" = {
            hostname = "51.136.19.198";
            user = "dsuser";
            identityFile = "/home/rs/.ssh/id_rsa_firmenlaptop";
        };

        "git.eu-2.platform.sh" = {
            hostname = "git.eu-2.platform.sh";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };

        "ssh.eu-2.platform.sh" = {
            hostname = "ssh.eu-2.platform.sh";
            # identityFile = "/home/rs/.ssh/caffe-key_rescha";
            identityFile = "/home/rs/.ssh/id_rsa_platform.sh";
        };

        "GPU" = {
            hostname = "108.143.61.155";
            serverAliveInterval = 60;
            serverAliveCountMax = 2;
            user = "rene";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
            localForwards = [
                { bind.port = 7777; host.address = "localhost"; host.port = 7777; }
                { bind.port = 7778; host.address = "localhost"; host.port = 7778; }
                { bind.port = 7779; host.address = "localhost"; host.port = 7779; }
            ];
        };

        "GPU2" = {
            hostname = "40.114.138.215";
            serverAliveInterval = 60;
            serverAliveCountMax = 2;
            user = "rene";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };

        "gaming" = {
            hostname = "192.168.100.32";
            user = "rene";
            port = 22222;
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
            localForwards = [
              { bind.port = 9080; host.address = "192.168.100.42"; host.port = 8080; }
            ];
        };

        "pilot" = {
            hostname = "51.136.9.21";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
            user = "ds";
        };

        "experiment" = {
            hostname = "3.122.206.33";
            identityFile = "/home/rs/.ssh/rene-aws-experiment.pem";
            user = "ubuntu ";
        };

        "gaming-remote" = {
            hostname = "82.135.101.36";
            user = "rene";
            port = 22222;
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
            localForwards = [
                { bind.port = 7777; host.address = "localhost"; host.port = 7777; }
                # xwiki
                { bind.port = 9080; host.address = "192.168.100.42"; host.port = 8080; }
            ];
        };

        "awsgpu" = {
            hostname = "18.192.12.206";
            #    hostname = "52.59.224.173	";
            identityFile = "/home/rs/.ssh/rene-aws-experiment.pem";
            user = "ubuntu";
            serverAliveInterval = 30;
            serverAliveCountMax = 2;
            localForwards = [
                { bind.port = 7778; host.address = "localhost"; host.port = 7777; }
                { bind.port = 7779; host.address = "localhost"; host.port = 7778; }
                { bind.port = 7780; host.address = "localhost"; host.port = 7779; }
            ];
        };


        "hroot" = {
            hostname = "hroot-nim.westeurope.cloudapp.azure.com";
            user = "AzureUser";
            identityFile = "/home/rs/.ssh/caffe-key_rescha";
        };


        "git.sr.ht" = {
            identityFile = "/home/rs/.ssh/id_ed25519";
        };

        "zigzap" = {
            hostname = "98.71.128.110";
            identityFile = "/home/rs/.ssh/id_rsa_firmenlaptop";
            user = "azureuser";
        };
      };
    };


    home.shellAliases = {
    	tmux = "tmux -2";
      ll = "ls -l";
      la = "ls -la";
      ta = "tmux attach";
    };

    programs.starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          # Füge eine Leerzeile zwischen den Eingabeaufforderungen ein
          add_newline = true;

          aws.symbol = "  ";

          conda.symbol = " ";

          dart.symbol = " ";

          directory.read_only = " ";

          docker_context.symbol = " ";

          elixir.symbol = " ";

          elm.symbol = " ";

          git_branch.symbol = " ";

          golang.symbol = " ";

          hg_branch.symbol = " ";

          java.symbol = " ";

          julia.symbol = " ";

          memory_usage.symbol = " ";

          nim.symbol = " ";

          nix_shell.symbol = " ";

          # package.symbol = " "

          perl.symbol = " ";

          php.symbol = " ";

          python.symbol = " ";

          ruby.symbol = " ";

          rust.symbol = " ";

          scala.symbol = " ";

          shlvl.symbol = " ";

          swift.symbol = "ﯣ ";


          # Ersetze das "❯" Symbol der Eingabeaufforderung mit "➜"
          character = {                           # Der Name des Moduls, welches wir konfigurieren ist "character"
              success_symbol = "[➜](bold green)";     # Das "succes_symbol" Segment wird zu "➜" eingestellt und ist "bold green" (fettgedrucktes grün) gefärbt
	  };

          # Deaktiviere das "package" Modul, damit es aus der Eingabeaufforderung komplett verschwindet
          package.disabled = true;

        };
    };


  services.gpg-agent = {
    enable = isLinux;
    pinentryPackage = pkgs.pinentry-tty;

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  # Make cursor not tiny on HiDPI screens
  home.pointerCursor = lib.mkIf (isLinux && !isWSL) {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
    x11.enable = true;
  };
}
