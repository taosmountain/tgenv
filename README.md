> Ported form [tfutils/tfenv](https://github.com/tfutils/tfenv/tree/0494129a4ad5dfde0cdd9a68ce54b6c7a53afc3f), modified to work with terragrunt.

# tgenv

Terragrunt version manager inspired by [rbenv](https://github.com/rbenv/rbenv)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Support](#support)
- [Installation](#installation)
- [Usage](#usage)
- [.terragrunt-version file](#terragrunt-version-file)
- [Upgrading](#upgrading)
- [Uninstalling](#uninstalling)
- [LICENSES](#licenses)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Support

Currently tgenv supports the following OSes

- Mac OS X (64bit)
- Linux
  - 64bit
  - Arm
- Windows (64bit) - only tested in git-bash - currently presumed failing due to symlink issues in git-bash

## Installation

1. Check out tgenv into any path (here is `${HOME}/.tgenv`)

  ```console
  $ git clone https://github.com/taosmountain/tgenv.git ~/.tgenv
  $
  $ # Or clone a specific version
  $ git clone 0.1.0 https://github.com/taosmountain/tgenv.git ~/.tgenv
  ```

2. Add `~/.tgenv/bin` to your `$PATH` any way you like

  ```console
  $ echo 'export PATH="$HOME/.tgenv/bin:$PATH"' >> ~/.bash_profile
  ```

  OR you can make symlinks for `tgenv/bin/*` scripts into a path that is already added to your `$PATH` (e.g. `/usr/local/bin`) `OSX/Linux Only!`

  ```console
  $ ln -s ~/.tgenv/bin/* /usr/local/bin
  ```

  On Ubuntu/Debian touching `/usr/local/bin` might require sudo access, but you can create `${HOME}/bin` or `${HOME}/.local/bin` and on next login it will get added to the session `$PATH`
  or by running `. ${HOME}/.profile` it will get added to the current shell session's `$PATH`.

  ```console
  $ mkdir -p ~/.local/bin/
  $ . ~/.profile
  $ ln -s ~/.tgenv/bin/* ~/.local/bin
  $ which tgenv
  ```

## Usage

### tgenv install [version]

Install a specific version of Terragrunt.

If no parameter is passed, the version to use is resolved automatically via .terragrunt-version files, defaulting to 'latest' if none are found.

If a parameter is passed, available options:

- `i.j.k` exact version to install
- `latest` is a syntax to install latest version
- `latest:<regex>` is a syntax to install latest version matching regex (used by grep -e)
- `min-required` is a syntax to recursively scan your Terragrunt files to detect which version is minimally required. See [required_version](https://www.terragrunt.io/docs/configuration/terragrunt.html) docs. Also [see min-required](#min-required) section below.

```console
$ tgenv install
$ tgenv install 0.24.0
$ tgenv install latest
$ tgenv install latest:^0.25
```

#### .terragrunt-version

If you use a [.terragrunt-version file](#terragrunt-version-file), `tgenv install` (no argument) will install the version written in it.

### Environment Variables

#### TGENV

##### `TGENV_ARCH`

String (Default: amd64)

Specify architecture. Architecture other than the default amd64 can be specified with the `TGENV_ARCH` environment variable

```console
TGENV_ARCH=arm tgenv install 0.25.5
```

##### `TGENV_AUTO_INSTALL`

String (Default: true)

Should tgenv automatically install terragrunt if the version specified by defaults or a .terragrunt-version file is not currently installed.

```console
TGENV_AUTO_INSTALL=false terragrunt plan
```

##### `TGENV_CURL_OUTPUT`

Integer (Default: 2)

Set the mechanism used for displaying download progress when downloading terragrunt versions from the remote server.

* 2: v1 Behaviour: Pass `-#` to curl
* 1: Use curl default
* 0: Pass `-s` to curl

##### `TGENV_DEBUG`

Integer (Default: 0)

Set the debug level for TGENV.

* 0: No debug output
* 1: Simple debug output
* 2: Extended debug output, with source file names and interactive debug shells on error
* 3: Debug level 2 + Bash execution tracing

##### `TGENV_REMOTE`

String (Default: https://github.com/gruntwork-io)

To install from a remote other than the default

```console
TGENV_REMOTE=https://example.jfrog.io/artifactory/hashicorp
```

> NOTE: This is currently setup to use github. Changing remote may cause issues.

#### Bashlog Logging Library

##### `BASHLOG_COLOURS`

Integer (Default: 1)

To disable colouring of console output, set to 0.


##### `BASHLOG_DATE_FORMAT`

String (Default: +%F %T)

The display format for the date as passed to the `date` binary to generate a datestamp used as a prefix to:

* `FILE` type log file lines.
* Each console output line when `BASHLOG_EXTRA=1`

##### `BASHLOG_EXTRA`

Integer (Default: 0)

By default, console output from tgenv does not print a date stamp or log severity.

To enable this functionality, making normal output equivalent to FILE log output, set to 1.

##### `BASHLOG_FILE`

Integer (Default: 0)

Set to 1 to enable plain text logging to file (FILE type logging).

The default path for log files is defined by /tmp/$(basename $0).log
Each executable logs to its own file.

e.g.

```console
BASHLOG_FILE=1 tgenv use latest
```

will log to `/tmp/tgenv-use.log`

##### `BASHLOG_FILE_PATH`

String (Default: /tmp/$(basename ${0}).log)

To specify a single file as the target for all FILE type logging regardless of the executing script.

##### `BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX`

String (Default: "")

*BE CAREFUL - MISUSE WILL DESTROY EVERYTHING YOU EVER LOVED*

This variable allows you to pass a string containing a command that will be executed using `eval` in order to produce a prefix to each console output line, and each FILE type log entry.

e.g.

```console
BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX='echo "${$$} "'
```
will prefix every log line with the calling process' PID.

##### `BASHLOG_JSON`

Integer (Default: 0)

Set to 1 to enable JSON logging to file (JSON type logging).

The default path for log files is defined by /tmp/$(basename $0).log.json
Each executable logs to its own file.

e.g.

```console
BASHLOG_JSON=1 tgenv use latest
```

will log in JSON format to `/tmp/tgenv-use.log.json`

JSON log content:

`{"timestamp":"<date +%s>","level":"<log-level>","message":"<log-content>"}`

##### `BASHLOG_JSON_PATH`

String (Default: /tmp/$(basename ${0}).log.json)

To specify a single file as the target for all JSON type logging regardless of the executing script.

##### `BASHLOG_SYSLOG`

Integer (Default: 0)

To log to syslog using the `logger` binary, set this to 1.

The basic functionality is thus:

```console
local tag="${BASHLOG_SYSLOG_TAG:-$(basename "${0}")}";
local facility="${BASHLOG_SYSLOG_FACILITY:-local0}";
local pid="${$}";

logger --id="${pid}" -t "${tag}" -p "${facility}.${severity}" "${syslog_line}"
```

##### `BASHLOG_SYSLOG_FACILITY`

String (Default: local0)

The syslog facility to specify when using SYSLOG type logging.

##### `BASHLOG_SYSLOG_TAG`

String (Default: $(basename $0))

The syslog tag to specify when using SYSLOG type logging.

Defaults to the PID of the calling process.


### tgenv use [version]

Switch a version to use

If no parameter is passed, the version to use is resolved automatically via .terragrunt-version files, defaulting to 'latest' if none are found.

`latest` is a syntax to use the latest installed version

`latest:<regex>` is a syntax to use latest installed version matching regex (used by grep -e)

`min-required` will switch to the version minimally required by your terragrunt sources (see above `tgenv install`)

```console
$ tgenv use
$ tgenv use 0.24.0
$ tgenv use latest
$ tgenv use latest:^0.25
```

### tgenv uninstall &lt;version>

Uninstall a specific version of Terragrunt
`latest` is a syntax to uninstall latest version
`latest:<regex>` is a syntax to uninstall latest version matching regex (used by grep -e)

```console
$ tgenv uninstall 0.24.0
$ tgenv uninstall latest
$ tgenv uninstall latest:^0.25
```

### tgenv list

List installed versions

```console
% tgenv list
* 0.26.7 (set by /opt/tgenv/version)
  0.26.7
  0.24.0
  0.23.40
  0.22.5
  0.22.4
```

### tgenv list-remote

List installable versions

```console
% tgenv list-remote
0.26.3
0.26.2
0.26.0
0.25.5
0.25.4
0.25.3
0.25.2
0.25.1
0.25.0
0.24.4
0.24.3
0.24.2
0.24.1
0.24.0
0.23.40
0.23.39
...
```

## .terragrunt-version file

If you put a `.terragrunt-version` file on your project root, or in your home directory, tgenv detects it and uses the version written in it. If the version is `latest` or `latest:<regex>`, the latest matching version currently installed will be selected.

```console
$ cat .terragrunt-version
0.26.6

$ terragrunt --version
terragrunt version v0.26.6

Your version of Terragrunt is out of date! The latest version
is 0.26.7. You can update by downloading from www.terragrunt.io

$ echo 0.26.7 > .terragrunt-version

$ terragrunt --version
terragrunt version v0.26.7

$ echo latest:^0.25 > .terragrunt-version

$ terragrunt --version
terragrunt version v0.25.5
```

## Upgrading

```console
$ git --git-dir=~/.tgenv/.git pull
```

## Uninstalling

```console
$ rm -rf /some/path/to/tgenv
```

## LICENSES

- [tfenv]
  - tgenv uses a majority of tfenv's source code.
- [rbenv]
  - tgenv partially uses rbenv's source code


[tfenv]: https://github.com/tfutils/tfenv/blob/master/LICENSE
[rbenv]: https://github.com/rbenv/rbenv/blob/master/LICENSE
