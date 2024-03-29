# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix = 
    {
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

  nix.binaryCachePublicKeys = [ "tunnelvr.cachix.org-1:IZUIF+ytsd6o+5F0wi45s83mHI+aQaFSoHJ3zHrc2G0=" ];
  nix.binaryCaches = [ "https://tunnelvr.cachix.org" ];
  nix.trustedBinaryCaches = [ "https://tunnelvr.cachix.org" ];

  imports =
    [ # Include the results of the hardware scan.
      ../../mixins/common.nix
      ./hardware-configuration.nix
      ./hardware-specific.nix
      ./users.nix
      ./disks.nix
    ];

  services.tailscale.enable = true;
  programs.ssh.knownHosts."100.107.23.115".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDI4IbP4dyTV0nv1XAt7wtqf2GwacrgDCseTTUosFtDF5+YtHUJfPY1KkDwjA5taeE7qSEWCtTX83QhawueHj9TANX3IN5SGn9XrCZthOB4QL2wCvwkts8Tyex1QTIA5d2JrcNRFtJohqFzhaPDYN+cq81W34DqthhzmfrPdfgb8k/QCoIWrQnP+JQBVyuSpnrgin3ad9ZdpNj2TcuUVQKTY0gUem/eVuyimt5SF6Gq8N3cBOuV07tiwpJPB3kLM4Rvhwp6KZlvcuVpvLQOdTYYSDMSRWt7qgEkzUNMM+cCbJNIuY/FmMyscINSrYlgKMMT0BCeML9Z9deO4WCCm+U5Tn9n/VSZrkZXCDDQp0MJSD71lo/11sPljuH7bTYD9Ubahkm7+VxIMJ0e2tFFQ5OFzCD7ELPV7fbmc55CnZQWTTZHE5dOqopkhtj6pYUYINW67QSSTop1u/uqhU8eUeaE/tU55jpoBpXLXaF1CtD16iq66uTOFPa4IN4PVfcE2iHyabnj0NvYtPDxKzDsF0QLs9JV5SZ49Tq5a9xFM3vBNAmEpKHgaGwqmjVgSMaW6wEFmoh53bsV+AGmZGY8AqGBCWRrz3eoz82l4IYat2wYzES4uxWAorkUGpE6TOrlFUm7boAz+TNow82U56XZ9Of6AvFGxl3b5uU8wl+JrmjUIQ==";
  programs.ssh.knownHosts."100.107.23.115".hostNames = [ "100.107.23.115" ];
  
  programs.adb.enable = true;
  fonts.fonts = [ pkgs.xorg.fontmiscmisc ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "goatlap"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # @hsngrmpf's advice for running podman
  virtualisation.podman.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "gb";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint hplip ];
  };

  # Enable the avahi daemon for mDNS, this also allows printer discovery.
  services.avahi = {
    nssmdns = true; # Allows software to use Avahi to resolve.
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  
  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    firefox
    chromium
    git
    htop
    btop
    gnumake
    picocom
    mosquitto
    librecad
    gimp
    usbutils
    geany
    libreoffice
    tdesktop
    xorg.xkill
    docker-compose
    magic-wormhole
    vlc
    jre8
    gnome.gedit
    blender
    cloudcompare
    freecad
  ];

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

  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 4546 4547 8000 ];
  networking.firewall.allowedUDPPorts = [ 4546 4547 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
