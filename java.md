# Java

`java` is deliberately **not** in [`mise.toml`](mise.toml). It is the one tool
the old toolchain had (SDKMAN, initialized from `.zshrc`) that this migration
did not move over. This file documents why, and what to do when you need a JDK.

## Why java is held back: shims and `JAVA_HOME`

This repo activates mise in **shims mode** (`.zshrc`):

```zsh
eval "$(mise activate zsh --shims)"
```

That expands to a single line — `export PATH="$HOME/.local/share/mise/shims:$PATH"`
— and nothing else. No `mise hook-env` ever runs in your shell. That is the
point of shims (every child process resolves tools, no per-prompt work), and it
is also the problem for java. From the
[mise java docs](https://mise.jdx.dev/lang/java.html):

> mise sets `JAVA_HOME` for commands run with `mise exec`, tasks, and activated
> shells. Shell activation updates the parent shell itself; **running a shim
> does not export `JAVA_HOME` back into that parent shell.**

With java in `mise.toml` under shims mode:

| What | Works |
|---|---|
| `java` / `javac` / `jar` in terminals, scripts, nvim, git hooks | ✅ the shim runs and exports `JAVA_HOME` **to the java process and its children** |
| `echo $JAVA_HOME` in your interactive shell | ❌ empty — the shell never runs hook-env |
| Gradle / Maven / IDEs / launchers reading `JAVA_HOME` from the shell | ❌ see nothing |
| Anything run via `mise exec` / `mise run` | ✅ full environment |

The same applies to every `[env]` variable in `mise.toml`: in shims mode they
reach mise-managed child processes only, never the interactive shell. Java just
makes the gap obvious, because the JVM ecosystem wants `JAVA_HOME` specifically
— not merely `java` on `PATH`.

## Options when you add java

### A. Keep shims, export `JAVA_HOME` by hand (smallest change)

```zsh
# .zshrc, after the mise activation line
jhome="$(mise where java 2>/dev/null)"
[ -d "$jhome" ] && export JAVA_HOME="$jhome"
unset jhome
```

Re-evaluated on every shell start, so it always tracks whatever `mise.toml`
selects, and it is a no-op until java is declared. Shims-mode activation stays
exactly as it is.

### B. Switch to PATH activation (full mise behavior)

```zsh
eval "$(mise activate zsh)"   # instead of the --shims line
```

mise then recomputes `PATH` **and** env vars (`JAVA_HOME`, anything in `[env]`)
at every prompt and on `cd`. This is what mise recommends for interactive use.
Trade-offs against shims (see [shims vs path](https://mise.jdx.dev/dev-tools/shims.html#shims-vs-path)):

- interactive shells get all env vars, including `JAVA_HOME`
- `which java` prints the real install path again; `cd`/`enter`/`leave` hooks start working
- only shells that ran activation get the environment — scripts and CI should use `mise exec` / `mise run` regardless
- cost moves from per-call shim dispatch to per-prompt hook evaluation

### C. Scripts and tasks (either way)

```zsh
mise exec -- ./gradlew build   # JAVA_HOME + PATH set for this command only
mise run <task>
```

## Adding it

```toml
# mise.toml, [tools]
java = "temurin-21"
```

- Prefer a vendor prefix (`temurin-21`, `zulu-21`, `corretto-21`): a bare
  `java = "21"` resolves through `java.shorthand_vendor` (default `openjdk`),
  and vendors have different support policies.
- Or run `mise use java@temurin-21` from inside this repo — it edits this
  repo's `mise.toml` directly. Then `./install.sh` to install and re-lock.
- Bump later with `mise lock --bump java` (commit `mise.toml` + `mise.lock`).

### Migrating from SDKMAN / existing projects

- `.sdkmanrc` (and `.java-version`) files are understood once enabled:
  `mise settings add idiomatic_version_file_enable_tools java`.
  A `java` entry in `mise.toml` still takes precedence.
- JDKs already installed by SDKMAN or elsewhere can be adopted instead of
  re-downloaded: `mise link java@local /path/to/jdk-home` then
  `mise use java@local`, or `java = { path = "/path/to/jdk-home" }`.
- Some SDKMAN vendors are unsupported (`graal`, `nik`, `bsg`) — use option 2
  above for those.

### macOS `/usr/libexec/java_home`

Apps that locate JDKs through `/usr/libexec/java_home` do not see mise's
install automatically. Register the selected JDK if a tool needs it (full
snippet in the [mise java docs](https://mise.jdx.dev/lang/java.html)):

```sh
mise where java   # if it contains Contents/, symlink it into
                  # /Library/Java/JavaVirtualMachines/ as documented
```

The link is static — it does not follow later version bumps.

### Gradle toolchains

```properties
# gradle.properties — let Gradle consider the mise-selected JDK
org.gradle.java.installations.fromEnv=JAVA_HOME
```

Run Gradle through mise (`mise exec -- ./gradlew ...`) so it inherits the env,
and `./gradlew --stop` after switching versions.
