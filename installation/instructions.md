## Install Nix and Setup cache 

- install nix with: `curl -L https://nixos.org/nix/install | sh` (probably better `sudo curl -L https://nixos.org/nix/install | sh`)
    - Note2: Some people experience problems with multi-user instalation. Try [single-user](https://nixos.org/manual/nix/stable/#sect-single-user-installation) if you run into troubles. Make sure you create `/nix` with permission `chown <youruser> /nix`
- Notice that the output of nix instalation awares you to set enviroment variables, and display a command you **must** execute. It looks like this:
```bash
Installation finished!  To ensure that the necessary environment
variables are set, either log in again, or type

  . /home/<youruser>/.nix-profile/etc/profile.d/nix.sh ## Type this in your console, and ensure your ~/.profile has a nix-related path
```
- Be sure your $PATH contains nix-related bin. This could be different in each system. Mine looks `/home/luis/.nix-profile/bin`. Apparently, debian users have problems with this.
- Once installed, edit `/etc/nix/nix.conf` (create it if you don't have it) file and add the following lines (always check the [original repo](https://github.com/input-output-hk/plutus#how-to-set-up-the-iohk-binary-caches****))

```bash
substituters = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/
trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
```

If running multi-user, after editing `nix.conf`, restart the daemon

```bash
[~] sudo systemctl restart nix-daemon.service  # On distros that use systemd
```

## Build the backend

Now we are going build everything for the backend and generate the needed javascript files.

```bash
[~] git clone https://github.com/input-output-hk/plutus.git
[~] cd plutus

# This command output is something like "build 1/17 ..."
[~/plutus] nix build -f default.nix plutus.haskell.packages.plutus-core.components.library

[~/plutus] nix-build -A plutus-playground.client
[~/plutus] nix-build -A plutus-playground.server   # <<< This command is outdated in the original repo
[~/plutus] nix-build -A plutus-playground.generate-purescript
[~/plutus] nix-build -A plutus-playground.start-backend
[~/plutus] nix-build -A plutus-pab

# This opens a nix shell with previous builds available. First time it copies many things.
[~/plutus] nix-shell

[nix-shell: ~/plutus] cd plutus-pab
[nix-shell: ~/plutus/plutus-pab] plutus-pab-generate-purs # End line of output message is "Done: generated"

[nix-shell: ~/plutus/plutus-pab] cd ..
[nix-shell: ~/plutus] cd plutus-playground-server
[nix-shell: ~/plutus/plutus-playground-server] plutus-playground-generate-purs # There is a long message ending in "Done: generated"

[nix-shell: ~/plutus/plutus-playground-server] plutus-playground-server # This executes the backend. The output looks like
plutus-playground-server: for development use only
[Info] Running: (Nothing,Webserver {_port = 8080})
Initializing Context
Initializing Context
Warning: GITHUB_CLIENT_ID not set
Warning: GITHUB_CLIENT_SECRET not set
Warning: JWT_SIGNATURE not set
Interpreter ready
```

Leave this running an open ANOTHER console

## Build the front-end

In other console run

```bash
[~] cd plutus
[~/plutus] nix-shell
[nix-shell: ~/plutus/] cd plutus-playground-client
[nix-shell: ~/plutus/plutus-playground-client] npm run start # This compiles the frontend. It should end in wdm｣: Compiled successfully.
```

Now your app is running at `https://localhost:8009/`
