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
Usage: gh my [issues|prs|reviews|workload|deployments] [options]
  issues:      list issues in your personal repositories
  prs:         list PRs in your persional repositories
  reviews:     list PRs where you've been asked for a review
  workload:    list PRs and issues where you are the assignee
  deployments: list deployments awaiting action

Listing deployments needs more filters
  -o : the organisation (e.g. -o my-company)
  -t : the topic  (e.g. -o my-terraform-repos)
  -r : a specific repository, but why not use gh run list instead?

```

```
bsh ❯ gh my issues
Num  Title                  Who     URL                                                          When
#1   能增加Apple芯片支持吗？  binge6  https://github.com/quotidian-ennui/homebrew-zulufx/issues/1  2 years ago
```

> I have ignored the above issue since it was raised, I don't have a Mac any more, and certainly not one that is M1/M2 etc. If someone wants to add in arm64 support for zulufx then please do so, and comment on this issue! I'm a little bit embarrassed that I've never dealt with it.

### deployments

Because of https://github.com/quotidian-ennui/gh-my/issues/2 you can now list deployments that are waiting for someone to approve them (perhaps you're doing something like this : https://warman.io/blog/2023/03/fixing-automating-terraform-with-github-actions/). The usage model is geared towards you filtering either explicitly by repository (in which case you can probably do `gh run list -r <repo> -s "waiting"` instead, but is present for completeness) or by organisation + topic.

```
bsh ❯ gh my deployments -o telus-agcg -t tpm-demeter
Repo                                   ID           Env            Actionable  URL                                                                        When
telus-agcg/tpm-demeter-terraform-test  14505914355  main-approval  false       https://github.com/telus-agcg/tpm-demeter-terraform-test/runs/14505914355  2 days ago

bsh ❯ gh my deployments -r telus-agcg/retro-cdc
Repo                  ID           Env                  Actionable  URL                                                       When
telus-agcg/retro-cdc  14542657594  production-approval  true        https://github.com/telus-agcg/retro-cdc/runs/14542657594  6 hours ago
```

## License

See [LICENSE](./LICENSE)
