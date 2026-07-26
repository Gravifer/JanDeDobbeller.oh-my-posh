# Discussion title

Gravifer Tokyo — a bracketed Git + Jujutsu PowerShell theme

# Published discussion

https://github.com/JanDeDobbeleer/oh-my-posh/discussions/7723

# Discussion body

<!-- Upload one sanitized real-terminal screenshot here. -->

I wanted a prompt that stays readable in a branchful Git workflow, including repositories that are also colocated with Jujutsu. Gravifer Tokyo keeps the palette of Oh My Posh's built-in `tokyo` theme, but replaces large capsules with a consistent bracket grammar and combines related SCM state into one visual unit.

The result is information-dense without making every piece compete for attention:

- Git-only, JJ-only, and colocated Git+JJ repositories use the same visual grammar.
- Jujutsu contributes its Change ID and JJ-only working-copy state.
- Git contributes the branch, divergence, working/staging counts, stash count, and linked-worktree context.
- Duplicate working-copy information is suppressed when Git already reports the same changed files.
- The path is shortened around repository landmarks rather than uniformly abbreviating every directory.
- Date/time, session, RAM, battery, execution time, and optional cloud/project context remain available on separate rows.

The theme is provisional and Windows/PowerShell-first, but it is the prompt I use rather than a static mock-up.

## SCM modes

<!-- Upload or arrange the Git-only, JJ-only, and colocated captures here. -->

### Git only

The Git bracket shows the branch and relevant divergence, working, staging, and stash state.

### Jujutsu only

The JJ bracket shows the working-copy Change ID and status. The segment uses:

```json
"ignore_working_copy": true
```

This is deliberate: rendering the prompt must not cause Jujutsu to snapshot or update the working copy.

### Colocated Git and Jujutsu

When both repositories are present, the theme composes JJ and Git into one bracket rather than rendering two unrelated SCM capsules. JJ working-copy status is shown only when Git is not already reporting working or staged changes.

The current released theme uses the backward-compatible combined `.ChangeID`. If [#7720](https://github.com/JanDeDobbeleer/oh-my-posh/pull/7720) lands, the same identifier can later render its shortest unique prefix brightly and the extra minimum-length characters dimly without changing the text.

## Repository-aware path compression

<!-- Add one full-path versus shortened-path capture here. -->

Long paths inside Git repositories preserve the pieces I use for orientation:

- the drive, home, or mapped origin;
- useful context immediately below that origin;
- the actual repository directory;
- the first repository-relative component;
- the current directory and the longest useful trailing context.

For example:

```text
D:/tests/vsc_repos/gravifer-tokyo-showcase/03-git-and-jj/orion-monorepo/packages/shell/windows/integration
→ D:/tests/…/orion-monorepo/packages/…/integration
```

This behavior currently has to be expressed as a large Oh My Posh template expression in the theme configuration, using a fixed 52-character approximation. That experiment motivated [#7722](https://github.com/JanDeDobbeleer/oh-my-posh/issues/7722), which discusses a native, more general, cross-platform repository-aware Path style and the current lack of style-aware repository/path subparts.

UNC and other paths that the theme cannot align safely remain full rather than being guessed at.

## Linked worktrees

<!-- Add the linked-worktree capture here. -->

In a linked Git worktree, the Git bracket can optionally show the owning main-worktree path.

Oh My Posh does not currently expose that path, so the gist includes a PowerShell context helper that prototypes the missing behavior:

1. Walk upward to the linked-worktree `.git` indirection file.
2. Resolve its common repository.
3. Run `git worktree list --porcelain -z` only for a genuine linked worktree.
4. Cache the result for the PowerShell session.
5. Pass the main-worktree path to the theme through an environment variable.

This helper is the concrete workaround that a future lazy native template property would replace. The adjacent [#7721](https://github.com/JanDeDobbeleer/oh-my-posh/pull/7721) fixes a separate linked-worktree correctness issue in the existing `gitdir_format` option; the theme does not depend on that option.

## Try it

The provisional theme, optional PowerShell helper, and my complete profile reference are in this gist:

<https://gist.github.com/Gravifer/7b27c219fed8f79cbdf1a2d123fac312>

Download the reusable theme:

```powershell
$configDirectory = Join-Path $HOME '.config\oh-my-posh'
New-Item -ItemType Directory -Path $configDirectory -Force | Out-Null

Invoke-WebRequest `
    -Uri 'https://gist.githubusercontent.com/Gravifer/7b27c219fed8f79cbdf1a2d123fac312/raw/gravifer-tokyo.omp.json' `
    -OutFile (Join-Path $configDirectory 'gravifer-tokyo.omp.json')
```

Initialize Oh My Posh with it:

```powershell
$theme = Join-Path $HOME '.config\oh-my-posh\gravifer-tokyo.omp.json'
oh-my-posh init pwsh --config $theme | Invoke-Expression
```

For the optional linked-main-worktree display, also download and source the helper immediately after OMP initialization:

```powershell
Invoke-WebRequest `
    -Uri 'https://gist.githubusercontent.com/Gravifer/7b27c219fed8f79cbdf1a2d123fac312/raw/gravifer-tokyo.context.ps1' `
    -OutFile (Join-Path $configDirectory 'gravifer-tokyo.context.ps1')

. (Join-Path $configDirectory 'gravifer-tokyo.context.ps1')
```

The helper is PowerShell-specific and owns the global `Set-PoshContext` hook for that shell session. Its implementation is included precisely to demonstrate the bridge currently required for linked-main-worktree data.

## Requirements and current scope

- Tested with Oh My Posh 29.36.0.
- PowerShell 7 for the optional context helper.
- A Nerd Font.
- Git for Git repositories and linked-worktree information.
- Jujutsu when using the JJ segment.
- Windows/PowerShell-first path behavior; this is not presented as a universal cross-platform policy.
- The 52-character path target is currently an opinionated theme constant.
- Status-enabled Git and JJ segments perform their normal repository queries.
- The linked-worktree helper pays for one cold Git query per linked worktree and PowerShell session, then reuses its cached result.

The theme works on released Oh My Posh today. The open upstream work above describes refinements and possible native replacements, not prerequisites.

## Related upstream work

- [#7720 — expose Jujutsu Change ID prefix and rest](https://github.com/JanDeDobbeleer/oh-my-posh/pull/7720): future split-color Change ID presentation; not required by the current theme.
- [#7721 — support `gitdir_format` in linked worktrees](https://github.com/JanDeDobbeleer/oh-my-posh/pull/7721): adjacent linked-worktree correctness discovered during this work; not used by the current path expression.
- [#7722 — repository-aware semantic Path shortening](https://github.com/JanDeDobbeleer/oh-my-posh/issues/7722): generalizes the behavior prototyped by the theme's large template expression.

I would especially welcome feedback from people who use nested repositories, monorepos, linked worktrees, or colocated Git and Jujutsu:

- Which path landmarks remain useful across platforms?
- Does one combined SCM bracket stay clearer than independent Git and JJ segments?
- Would separately formatable pre-repository, repository, and repository-relative path pieces be useful in your own themes?
