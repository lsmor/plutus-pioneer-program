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

# This opens a nix shell with previous builds available. WARNING!! First time, it takes a while: read the note at the end of the section..
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

> first time you execute `nix-shell` It takes long. Some users have experienced really really long execution time, hence don't panic if it seems hanging, just let it work. The output is similar to the following:
> ```
> [~/plutus] nix-shell
> 
> trace: To materialize project.plan-nix for Agda entirely
> copying path '/nix/store/181ikn3j5j069ly2acikyzwhi77s4vcj-01-index.tar.gz-at-2021-02-24T000000Z' W
> copying path '/nix/store/4d4wf7mgplwf5jlyq1wnv905wfwrj660-cabal-install-exe-cabal-3.2.0.0' 
>
> .
> . # loooong output
> . 
>
> In order, the following would be built (use -v for more details):
>  - STMonadTrans-0.4.5 (lib) (requires download & build)
>  - alex-3.2.6 (exe:alex) (requires download & build)
>
> .
> . # loooonger outputW
> . 
>
> building '/nix/store/5aa81g4fib06gfb0rwmqgg8zn6l339jg-update-metadata-samples.drv'...
> building '/nix/store/1bkd0rsfhm1pn5g043v0i07jc5kb3jbc-updateMaterialized.drv'...
> nix-pre-commit-hooks: updating /home/<USERNAME>/Cardano/plutus-git repo
> pre-commit installed at .git/hooks/pre-commit
> pid 292692's current affinity list: 0-3
> pid 292692's new affinity list: 0-3
> 
> [nix-shell: ~/plutus] 
> ```


## Build the front-end

In other console run

```bash
[~] cd plutus
[~/plutus] nix-shell
[nix-shell: ~/plutus/] cd plutus-playground-client
[nix-shell: ~/plutus/plutus-playground-client] npm run start # This compiles the frontend. It should end in wdm｣: Compiled successfully.
```

Now your app is running at `https://localhost:8009/`
