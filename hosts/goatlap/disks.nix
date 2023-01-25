{ pkgs, config, lib, ... }:
{
  # Needed for ZFS
  networking.hostId = "8c347b6a";
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  };
}
