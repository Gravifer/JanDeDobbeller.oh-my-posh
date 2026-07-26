# Gist comment

Gravifer Tokyo is still a provisional working theme. Screenshots, behavior notes, installation context, and the upstream improvements it motivated are documented in the [Oh My Posh Themes Discussion](https://github.com/JanDeDobbeleer/oh-my-posh/discussions/7723).

# PR #7720 context

The theme that motivated this API split is documented in [Gravifer Tokyo](https://github.com/JanDeDobbeleer/oh-my-posh/discussions/7723). It currently uses the backward-compatible combined `.ChangeID`; after this API is released, it can style the shortest unique prefix and the minimum-length remainder independently without changing the displayed identifier.

# PR #7721 context

The linked-worktree workflow in which this issue was discovered is demonstrated by [Gravifer Tokyo](https://github.com/JanDeDobbeleer/oh-my-posh/discussions/7723). The theme does not itself use `gitdir_format`; this is real-world context for the linked-worktree behavior that exposed the inconsistency.

# Issue #7722 evidence

[Gravifer Tokyo](https://github.com/JanDeDobbeleer/oh-my-posh/discussions/7723) is a running prototype of this path policy. Its repository-aware shortening currently has to be expressed as a large Oh My Posh configuration template with a fixed 52-character approximation. The Discussion includes Git-only, JJ-only, colocated, and linked-worktree examples.

This is offered as implementation evidence, not as the desired native algorithm: the proposed style should remain more general and cross-platform than the theme's Windows-first policy. The prototype also confirms that `.Segments.Git.Dir` and `.RelativeDir` expose the raw split while the selected Path style transforms only `.Path`.

# Future native MainWorktree PR motivation

The optional PowerShell helper demonstrated in [Gravifer Tokyo](https://github.com/JanDeDobbeleer/oh-my-posh/discussions/7723) is the concrete workaround this property replaces. It discovers linked-worktree indirection, runs `git worktree list --porcelain -z`, caches the result for the shell session, and passes it through an environment variable; the native property moves that work behind lazy template access and repository-scoped caching.
