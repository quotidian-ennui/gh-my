# gh-my

I was messing around with the graph api, and this was the result because who wants to navigate a web UI when you have a terminal. If like me, you don't pay much attention to issues raised on your public repos, then this is marginally useful

This is an extension for [GitHub CLI](https://cli.github.com/) that just lists any issues/prs raised in your personal repos along with some handy queries that I've found useful.

## Installation

Prerequisites:
 - [GitHub CLI](https://cli.github.com/) is already installed and authenticated
 - [`jq`](https://stedolan.github.io/jq/) is installed
 - `column` which is a standard linux tool; already present in _git+bash_ on windows; via _util-linux_ on ubuntu.
 - `date` needs to support the `--date "14 days ago"` style option.

To install this extension:

```
gh extension install quotidian-ennui/gh-my
```

## Usage

```
Usage: gh my [deployments|failures|help|issues|notifs|prs|report|reviews|vulns|workload] [options]
  issues      : list issues in your personal repositories
  prs         : list PRs in your persional repositories
  reviews     : list PRs where you've been asked for a review
  workload    : list PRs and issues where you are the assignee
  deployments : list deployments awaiting action on the default branch
  report      : show all the issues & prs you've been involved in the last 14 days
                (because you have to tell people what you've done)
  notifs      : list unread notifications
  failures    : show workflow failures in your personal repositories in the last 14 days
  vulns       : show vulnerability alerts from dependabot in your personal repositories

'reviews' can have its output in JSON format
  -j : output each row as a JSON object.
       This is useful if you want to script & pipe the output.
       (--jsonlines is also accepted)

'deployments' needs more filters
  -o : the organisation (e.g. -o my-company)
  -t : the topic  (e.g. -t my-terraform-repos)
  -r : a specific repository, but why not use gh run list instead?

'report' uses 'date' so any gnu date string is valid
  -d : the date string (default is "14 days ago")
  -q : omit the table headers
  -a : use 'author' instead of 'involves'
  -v : everything involving your user (e.g. where you're a CODEOWNER)

'failures' uses 'date' so any gnu date string is valid
  -d : the date string (default is "14 days ago")

'notifs' can also mark them as read
  -n : the ID to mark as read (-n 7235590448)
  -a : Mark all notifications as read

'vulns' can have more filters
  -o : the owner (e.g. -o my-company | -o my-user)
       default is whatever 'gh config get user -h github.com' returns
       ** Viewing security alerts implies permissions
```

```
bsh ❯ gh my issues
Num  Title                  Who     URL                                                          When
#1   能增加Apple芯片支持吗？  binge6  https://github.com/quotidian-ennui/homebrew-zulufx/issues/1  2 years ago
```

> I have ignored the above issue since it was raised, I don't have a Mac any more, and certainly not one that is M1/M2 etc. If someone wants to add in arm64 support for zulufx then please do so, and comment on this issue! I'm a little bit embarrassed that I've never dealt with it.

### deployments

Because of https://github.com/quotidian-ennui/gh-my/issues/2 you can now list deployments that are waiting for someone to approve them (perhaps you're doing something like this : https://warman.io/blog/2023/03/fixing-automating-terraform-with-github-actions/). The usage model is geared towards you filtering either explicitly by repository (in which case you can probably do `gh run list -R <repo> -s "waiting"` instead, but is present for completeness) or by organisation + topic.

```
bsh ❯ gh my deployments -o telus-agcg -t tpm-demeter
ID          URL                                                                               Branch  Repo                                   Env            Actionable  When
5357752484  https://github.com/telus-agcg/tpm-demeter-terraform-test/actions/runs/5357752484  main    telus-agcg/tpm-demeter-terraform-test  main-approval  false       3 days ago

bsh ❯ gh my deployments -r telus-agcg/retro-cdc
ID          URL                                                              Branch  When
5388868900  https://github.com/telus-agcg/retro-cdc/actions/runs/5388868900  main    3 hours ago
```

## License

See [LICENSE](./LICENSE)
