# gh-my

I was messing around with the graph api, and this was the result because who wants to navigate a web UI when you have a terminal. If like me, you don't pay much attention to issues raised on your public repos, then this is marginally useful

This is an extension for [GitHub CLI](https://cli.github.com/) that just lists any issues/prs raised in your personal repos. Since it's all GraphQL you can also list any PRs where you have been asked for a review which does extend past your own personal repositories.

## Installation

Prerequisites:
 * [GitHub CLI](https://cli.github.com/) is already installed and authenticated

To install this extension:

```
gh extension install quotidian-ennui/gh-my
```

## Usage

```
Usage: gh my [issues|prs|reviews]
  issues:  list issues in your personal repositories
  prs:     list pull requests in your persional repositories
  reviews: list reviews
```

```
bsh ❯ gh my issues
Num  Title                  Who     URL                                                          When
#1   能增加Apple芯片支持吗？  binge6  https://github.com/quotidian-ennui/homebrew-zulufx/issues/1  2 years ago
```

> I have ignored the above issue since it was raised, I don't have a Mac any more, and certainly not one that is M1/M2 etc. If someone wants to add in arm64 support for zulufx then please do so, and comment on this issue! I'm a little bit embarrassed that I've never dealt with it.

## License

See [LICENSE](./LICENSE)
