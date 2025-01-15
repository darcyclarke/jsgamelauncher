#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

# Not sure why nvm has all these functions but I don't mind them
my_has() {
  type "$1" > /dev/null 2>&1
}

my_distro_check() {
  if [ -f "/usr/bin/rocknix-config.sh" ]; then
    return 0  # True
  else 
    return 1  # False
  fi
}

my_echo() {
  command printf %s\\n "$*" 2>/dev/null
}

#
# Unsets the various functions defined
# during the execution of the install script
#
my_reset() {
  unset -f my_has my_echo my_distro_check
}
my_echo "=> STARTING INSTALL"

if [ -z "${BASH_VERSION}" ] || [ -n "${ZSH_VERSION}" ]; then
  my_echo >&2 'Error: the install instructions explicitly say to pipe the install script to `bash`; please follow them'
  exit 1
fi

my_grep() {
  GREP_OPTIONS='' command grep "$@"
}

# check to see if I'm running on a knulli/batocera device
my_distro_check() {
  if [ -f "/usr/bin/rocknix-config" ]; then
    return 0  # True
  else
    return 1  # False
  fi
}

# NVM can't update the .bash_profile if one doesn't exist
touch ~/.bash_profile

my_echo "=> Installing NVM"

# Download and execute the nvm installation script . . . move this below if the version of NVM doesn't matter
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

# make sure nvm is in the path
if ! grep -q "nvm.sh" ~/.bash_profile; then
  echo "export NVM_DIR=\"$HOME/.nvm\"" >> ~/.bash_profile
  echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >> ~/.bash_profile
  my_echo "=> Note: I updated your bash_profile to include nvm"
else 
  my_echo "=> Note: You already have nvm in your bash_profile"
fi

cd ~
my_echo "=> Cleaning up old files"
if [ -d "$HOME/newjsgamelaunchermain.zip" ]; then
  my_echo "=> File ~/newjsgamelaunchermain.zip exists. Deleting..."
  rm -rf ~/newjsgamelaunchermain.zip
fi
if [ -d "$HOME/jsgamelauncher-main" ]; then
  my_echo "=> Folder ~/jsgamelauncher-main exists. Deleting..."
  rm -rf ~/jsgamelauncher-main
fi

my_echo "=> Downloading jsgamelauncher"
curl -o newjsgamelaunchermain.zip -L https://github.com/monteslu/jsgamelauncher/archive/refs/heads/main.zip
unzip newjsgamelaunchermain.zip


if my_distro_check; then
  my_echo "=> This is a compatible device, so I'm moving files around! And running npm install in the jsgamelauncher directory"
  if [ -d "$HOME/jsgamelauncher" ]; then
    my_echo "=> Folder ~/jsgamelauncher exists. Deleting..."
    rm -rf ~/jsgamelauncher
  else 
    my_echo "=> Folder ~/jsgamelauncher does not exist. Copying ..."
  fi
  mkdir ~/jsgamelauncher
  mv jsgamelauncher-main/* ~/jsgamelauncher/

  # Rocknix has the BusyBox ls and tar, we need the GNU versions for nvm to work
  mv ~/jsgamelauncher/systems/tools/jsbin.tar ~
  cd ~
  tar -xvf jsbin.tar
  chmod +x ~/jsbin/ls
  chmod +x ~/jsbin/tar
  cd ~/jsbin

  # Go get ffmpeg
  curl -O -L https://github.com/MarcA711/Rockchip-FFmpeg-Builds/releases/download/6.1-6/ffmpeg
  curl -O -L https://github.com/MarcA711/Rockchip-FFmpeg-Builds/releases/download/6.1-6/ffplay
  curl -O -L https://github.com/MarcA711/Rockchip-FFmpeg-Builds/releases/download/6.1-6/ffprobe

  chmod +x ~/jsbin/ffmpeg
  chmod +x ~/jsbin/ffplay
  chmod +x ~/jsbin/ffprobe
  # make sure jsbin tools is in the path
  if ! grep -q "jsbin" ~/.bash_profile; then
    echo "export PATH=\"/storage/jsbin:$PATH\"" >> ~/.bash_profile
    echo "export LD_LIBRARY_PATH=\"/storage/jsbin\"" >> ~/.bash_profile
    my_echo "=> Note: I updated your bash_profile to include GNU jsbin tools"
  else 
    my_echo "=> Note: You already have jsbin tools in your bash_profile"
  fi

  my_echo "=> Installing Node.js version 22"
  source ~/.bash_profile
  nvm install 22

  # Clean up after move
  rm newjsgamelaunchermain.zip

  chmod +x ~/jsgamelauncher/systems/rocknix/run.sh
  cp ~/jsgamelauncher/systems/rocknix/es_systems_jsgames.cfg /storage/.config/emulationstation/

  if [ -d "/roms/jsgames" ]; then
    my_echo "=> Folder /roms/jsgames exists, no need to create it."
  else 
    mkdir /roms/jsgames
  fi

  source ~/.bash_profile
  cd ~/jsgamelauncher
  npm install
  my_echo "=> INSTALL SUCCESSFUL!"
  cd ~
else
  my_echo "=> my_distro_check says this is NOT is a compatible device for this installer, so I'm not moving files around!"
  my_echo "=> INSTALL FAILED!"
fi

my_reset

} # this ensures the entire script is downloaded