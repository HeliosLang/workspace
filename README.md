## Helios Workspace

This repo provides a workspace in which local development in the various Helios repos can co-exist.

It uses `pnpm` to resolve the inter-repo dependencies within the workspace.

### Setup

First, [Install `pnpm`](https://pnpm.io/installation).

Then, run `./setup.sh` to clone all of the HeliosLang repos here.

Then, run `pmpm i` to install all the dependencies for all the workspace packages.


### Day-to-Day

See below for guidance on setting up your forked repos.  For day-to-day activities:

#### Build all Helios modules

`pnpm run -r --sort build`

This will run all the build scripts including unit tests in parallel. 

#### Check the status of all repos

`./gsall`

This uses the short form of `git status`, across all these repos, to summarize the status of any uncommitted files

#### Check for updates

`./refresh-all`

This uses `git pull` to receive any updates from the origin or from your fork, across all the repos.  Look out for any ERROR indicating you might be out of sync.



### Contributing

Your contributions makes Helios better 💜.  Fork any of the [HeliosLang repos at GIthub](https://github.com/HeliosLang) and optionally add a `helios-` prefix to your fork name.  Or another prefix you choose in your `.fork-config`.

Copy `.fork-config.example` to `.fork-config` and edit the details there.

Finally, run `./forked-repos`, which will iterate all the HeliosLang repos and perform `git remote add ...` commands to add a remote `fork` (or whatever origin-name you configure) to each repo you have forked.

Submit Github PRs in the usual way, starting by pushing changes to your fork.

### Testing your changes

#### Linking to these Helios workspace packages

If you use `npm` for your Helios-using project, you can `npm link` in the usual way if you like, to develop your code along with any refinements to Helios.  

If you use `pnpm` in your Helios-using project, the `pnpm add ../../path/to/helios/cbor` (and/or to any other sub-repo(s)) will connect your code to this workspace. 

With that linking arranged, every time you run your code, it will use any updates you've saved to any of these Helios repos.

#### Add unit tests

If you're adding any functionality to a Helios package, please include a unit test if possible.

#### Running test builds

Please ensure you run test builds before submitting a PR.  

`pnpm run build-all`

This command will run all the builds in parallel, including any unit tests.  

#### Versioning

Please don't include version-number changes in your PRs.  

Please use a separate branch (possibly `main`) in your forked repo for isolated versioning, if you need to use your github version as a direct dependency, merging your PR branch into that separate versioning branch.


### More about this repo

See the `./setup.sh` script