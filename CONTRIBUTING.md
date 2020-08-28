<!-- SPD-License-Identifer: ${#LICENSE}  -->
<!-- COPYRIGHT 2020 - FREIGHTTRUST AND CLEARING CORPORATION, ALL RIGHTS RESERVED -->

# Contributing

> This document is inspired by
> [elasticsearch/CONTRIBUTING.md](https://github.com/elastic/elasticsearch/blob/master/CONTRIBUTING.md)

Adding a `CONTRIBUTING.md` to a Github repository enables a link to that file in
the pull request or create an issue page. This document should guide potential
contributors toward making a successful and meaningful impact on the project,
and can save maintainers time and hassle caused by improper pull requests and
issues. You can learn more about the features that are enabled by Github when
this file is present
[here](https://help.github.com/articles/setting-guidelines-for-repository-contributors/).

## How to contribute

There are many ways to contribute, from writing tutorials or blog posts,
improving the documentation,
[submitting Github issues](https://help.github.com/articles/creating-an-issue/),
bug reports, feature requests and writing code.

## License

Please [SEE LICENSE](#LICENSE)

## Bug reports

If you think you've found a bug in the software, first make sure you're testing
against the _latest_ version of the software -- your issue may have been fixed
already. If it's not, please check out the issues list on Github and search for
similar issues that have already been opened. If there are no issues then please
[submit a Github issue](https://help.github.com/articles/creating-an-issue/).

If you can provide a small test case it would greatly help the reproduction of a
bug, as well as a a screenshot, and any other information you can provide.

## Feature Requests

If there are features that do not exist yet, we are definitely open to feature
requests and detailed proposals.
[Open an issue](https://help.github.com/articles/creating-an-issue/) on our
Github which describes the feature or proposal in detail, answer questions like
why? how?

## Contributing Code and Documentation Changes

Bug fixes, patches and new features are welcome. Please find or open an issue
about it first. Talk about what exactly want to do, someone may already be
working on it, or there might be some issues that you need to be aware of before
implementing the fix.

There are many ways to fix a problem and it is important to find the best
approach before writing a ton of code.

##### Documentation Changes

For small documentation changes and fixes, these can be done quickly following
this video guide on
[how to contribute to Open Source in 1 minute on Github](https://www.youtube.com/watch?v=kRYk1-yKwWs).

### Forking the repository

[How to fork a repository](https://help.github.com/articles/fork-a-repo/).

### Submitting changes

1. Review & Test changes
   - If the code changed, then test it. If documentation changed, then preview
     the rendered Markdown.
2. Commiting
   - Follow the [Conventional Commits](CONVENTIONAL_COMMITS.md) guidelines to
     create a commit message.
3. Sign the CLA
   - Make sure you've signed the repository's Contributor License Agreement. We
     are not asking you to assign copyright to us, but to give us the right to
     distribute your code without restriction. We ask this of all contributors
     in order to assure our users of the origin and continuing existence of the
     code. You only need to sign the CLA once.
4. Submit a pull request
   - Push local changes to your forked repository and make a pull request.
     Follow the [Convention Commits](CONVENTIONAL_COMMITS.md) guidelines for
     naming Github pull requests and what to put in the body.

## Building

Follow the build process is outlined in [BUILDING.md](BUILDING.md) to create a
build.

## Releasing

Follow the release process is outlined in [RELEASING.md](RELEASING.md) to create
a release.
