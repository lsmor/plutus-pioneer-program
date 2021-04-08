## Install Nix and Setup cache 

- install nix with: `curl -L https://nixos.org/nix/install | sh`
- Once installed, edit `/etc/nix/nix.conf` file and add the following lines (always check the [original repo](https://github.com/input-output-hk/plutus#how-to-set-up-the-iohk-binary-caches****))

```bash
substituters = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/
trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
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

# This opens a nix shell with previous builts available. First time it copies many things.
[~/plutus] nix-shell

[nix-shell: ~/plutus] cd plutus-pab
[nix-shell: ~/plutus/plutus-pab] plutus-pab-generate-purs # En line of output message is "Done: generated"

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
[~] git clone https://github.com/input-output-hk/plutus.git
[~] cd plutus

# This command output is something like "build 1/17 ..."
[~/plutus] nix build -f default.nix plutus.haskell.packages.plutus-core.components.library

# I think these are redundant, but I've executed just trying different things
[~/plutus] nix-build -A plutus-playground.client
[~/plutus] nix-build -A plutus-playground.server   # <<< This command is outdated in the repo
[~/plutus] nix-build -A plutus-playground.generate-purescript
[~/plutus] nix-build -A plutus-playground.start-backend
[~/plutus] nix-build -A plutus-pab

# This opens a nix shell with previous builts available. First time it copies many things.
[~/plutus] nix-shell

# Again, I think this is redundant.
[nix-shell: ~/plutus] cd plutus-pab
[nix-shell: ~/plutus/plutus-pab] plutus-pab-generate-purs # En line of output message is "Done: generated"

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

Let this running an open ANOTHER console

## Build the front-end

In other console run

```bash
[~] cd plutus
[~/plutus] nix-shell
[nix-shell: ~/plutus/] cd plutus-playground-client
[nix-shell: ~/plutus/plutus-playground-client] npm run start # This compiles the frontend. It should end in wdm｣: Compiled successfully.
```

Now your app is running at `https://localhost:8009/`