{
  users = {
    mutableUsers = false;
    users = {
      root.hashedPassword = "$y$j9T$5dPSadwSHYi8a4JwmaEa7.$qAZyiDxJLrLfmprp5TSA.jiaWMnNxGIcDoNnwqICeC.";
      julian = {
        isNormalUser = true;
        extraGroups = [ "wheel" "adbusers" "dialout" "docker" ]; # Enable ‘sudo’ for the user.
        hashedPassword = "$y$j9T$TQkTrUBV89LOJmCUQ5mv6/$f3VfxKcS0B8IIUhhcZc0kKW.oCx.VRhWF.ny7P3xS11";
        openssh.authorizedKeys.keys = [
          # No ssh keys yet
        ];
      };
    };
  };
}
