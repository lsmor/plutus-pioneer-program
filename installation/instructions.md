## Install Nix and set up cache

Nix can be installed single-user or multi-user

More detailed info can be found in the
[Nix Package Manager Guide](https://nixos.org/manual/nix/stable)


### single-user

Single-user Nix installation has advantages. 1) No daemon and socket are
created, 2) a group of a dozen or so nix users doesn't get created on the
system, 3) nothing is written into `/etc`

Install nix

```bash
[~]$ sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

The installer should create the `/nix` directory for you with the proper
permissions. When it's done you will see

```bash
Installation finished!  To ensure that the necessary environment
variables are set, either log in again, or type

  . /home/<youruser>/.nix-profile/etc/profile.d/nix.sh
```

Execute the above command now to set the environment in this shell (also
logout/login will achieve this)

Make sure the changes the installer just made to your `~/.bash_profile` or
`~/.profile` make sense.

Next we will add IOG's caches to Nix to speed up our development significantly
by using their build artifacts. This is very important and means the difference
between 3+ hours and less than 10 minutes!

```bash
[~]$ mkdir ~/.config/nix
[~]$ echo 'substituters = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/' >> ~/.config/nix/nix.conf
[~]$ echo 'trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=' >> ~/.config/nix/nix.conf
```


### multi-user

If you decide you'd like to go with multi-user Nix, read on.

The multi-user installer requires `rsync`

```bash
[~]$ which rsync || sudo sh -c 'apt update ; apt install rsync'  # For Ubuntu and other Debian-based distros
```

Install nix

```bash
[~]$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

This will run a wizard, prompting you for some things. When it's done we need
to set the environment in this shell (also logout/login will also achieve this)

```bash
[~]$ . /etc/profile.d/nix.sh
```

Next we will add IOG's caches to Nix to speed up our development significantly
by using their build artifacts. This is very important and means the difference
between 3+ hours and less than 10 minutes!

```bash
[~]$ sudo sh -c "echo 'substituters = https://hydra.iohk.io https://iohk.cachix.org https://cache.nixos.org/' >> /etc/nix/nix.conf"
[~]$ sudo sh -c "echo 'trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=' >> /etc/nix/nix.conf"
[~]$ sudo systemctl restart nix-daemon.service  # On Linux distros that use systemd, like Ubuntu and most Debians
```

### After either Nix installation method

If everything worked you should be able to do this

```bash
[~]$ nix-env --version
nix-env (Nix) 2.3.10
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


## (Optional) Plutus Documentation

Documentation is built automatically (I think). You shoud see a symbolic link in `~/plutus` which looks like:

```bash
# the documentation folder includes the word haddock    -|
result -> /nix/store/p9zqm03qmc7p5p1vfdbl06xysm85ir4f-haddock-join/
```

If this folder isn't in under `~/plutus` you can build it with 

```bash
[~/plutus] nix-build -A plutus-playground.haddock
```

You can see the plutus documentation in your regular browser. for example:

```
brave-browser ~/plutus/result/share/doc/index.html
```


## Miscellaneous

### Completely uninstalling Nix

Nix (unfortunately) installs with a non-distro-specific and not-reversible
method and so requires careful unistallation if you don't want it any longer.
The Nix documentation says simply removing `/nix` is the way but this leaves a
lot of unneeded files on your system. We can clean this up properly.

These instructions work equally well for single- or multi-user Nix.

First, disable and stop the systemd units if they exist. This is harmless to
do if they don't exist.

```bash
[~]$ sudo systemctl disable --now nix-daemon.service
[~]$ sudo systemctl disable --now nix-daemon.socket
```

Then delete the many directories and files that are on the system

```bash
[~]$ rm -rf $HOME/{.nix-*,.cache/nix,.config/nix}
[~]$ sudo rm -rf /root/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.cache/nix}
[~]$ sudo rm -rf /etc/{nix,profile.d/nix.sh*}
[~]$ sudo rm -rf /nix
```

Finally remove the line that was added to your `$HOME/.bash_profile` or
`$HOME/.profile` to source the nix environment.
