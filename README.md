# EnvIn - Environment Installer (WIP)

EnvIn is my personal environment installer. It is a tool that I use to install and configure the loads of tools and utilities that I use:

- generic installed packages
- tools/binaries from
	- LinuxBrew
	- Cargo
	- Go
	- Python
- Gnome configuration (I use this DE everywhere apart from my WSL on my desktop Windows)
- terminal configuration (dconf based configuration)
- VSCode extensions
- dotfiles

## Quick Install & Usage

In a fresh environment:

```bash
bash <(GET https://raw.githubusercontent.com/Nephylhim/EnvIn/master/envin)
```

When it has already been ran once:

```bash
cd ~/.envin; ./envin
```

EnvIn is idempotent and can be relaunched to sync the installations.

## Updating packages / tools / binaries

EnvIn ensures that the packages, tools and binaries are installed, but doesn't take care of the update part. For this matter, I use [topgrade](https://github.com/topgrade-rs/topgrade), an amazing tool that updates everything on the go, without even needing any configuration. You can however configure it to make it update some git repositories (like EnvIn) and run custom commands (like EnvIn). This way, once you have launched EnvIn a first time, you can simply launch `topgrade` to update your whole system, and then sync your configurations from EnvIn.

## Limits and prospects

- Currently, EnvIn works only with a debian based OS. This is a fairly big issue in my opinion, and I have plans to support other distributions (like ArchLinux).
- The EnvIn exec "engine" is mixed with custom code that address my needs. I'd like to transform it to a more generic tool, and separate it from the configuration repository.
- I'd like to add a plugin system to add custom code and handlers
- You need to be root to run EnvIn, it currently cannot work if you don't have root rights in your machine
- I'd prefer to use a toml configuration file instead of all these custom configuration files
- Also I might rewrite this tool in a new language (a compiled one), but a lot of issues are keeping me from doing so at the time being
## What and why?

This tool is used to ensure that _my_ environment (and yours if you adapt it) is correcly installed on a given computer. I use multiple computers (for work and personnal use) and I like my tools, settings, configurations to be correctly set for each of them. Keeping track of the installations and updates of configurations is a tedious work and it doesn't have to be.

So the main objective is to aggregate all important tools and configurations in a single repository and have a tool ensure all of these are correctly setup. This is this repository and the `envin` executable file.

## How does it work?

The tool use internal, hard written rules and configurations files to setup everything.

The configuration files are:

* packages.cfg
	* debian packages names
* brew_formulaes.cfg
* cargo_bins.cfg
* git_dirs.cfg
* gnome_extensions.cfg
* go_packages.cfg
* pip_packages.cfg
* vscode_extensions.cfg


