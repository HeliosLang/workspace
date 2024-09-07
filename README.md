## Helios Workspace

This repo provides a workspace in which local updates in the various Helios repos can co-exist, be tested against each other, and which you can use in your downstream projects for trying updates to helios.  ***It's made for contributors like you.***

It uses `pnpm` to resolve the inter-repo dependencies within the workspace.

### Setup

 1. Start by [installing `pnpm`](https://pnpm.io/installation).

  2. Then, run :
      ```
      ./setup.sh
      ```
      ... to clone all of the HeliosLang repos here.

  3. Finally, run 
      ```
      pmpm install
      ``` 
      ... to install all the dependencies for all the workspace packages.  It runs some builds and tests automatically, but trust us: it's installing all the dependencies for all 24 workspace packages.
      
      `pnpm i` also works.

### Day-to-Day

See further guidance below on doing setup for your forked repos.  For day-to-day activities:

#### Build all Helios modules:

```
pnpm run build-all
```

This runs all the build scripts including unit tests in parallel, across all these repos.

#### Check the status of all repos

```
./gsall
```

This uses the short form of `git status`, across all these repos, to summarize the status of any new or changed files.

#### Review all your changes

```
./gdall
```

This runs `git diff` across all these repos for visibility of the particular changes you have made.

#### Check for updates

```
./refresh-all
```

This uses `git pull` to receive any updates from the origin or from your fork - again, across all the repos.  Look out for any ERROR indicating you might be out of sync.

### Contributing

Your contributions make Helios better 💜

 1. Fork any of the [HeliosLang repos at Github](https://github.com/HeliosLang) and optionally add a `helios-` prefix to your fork name.  Or choose another prefix in your `.fork-config`.

 2. Copy `.fork-config.example` to `.fork-config` and edit the details there.

 3. Finally, run: 
     ```
     ./forked-repos
     ```
  ... which will iterate all the HeliosLang repos and perform `git remote add ...` commands to add a remote named `fork` (or whatever remote name you configure) to each repo you have forked.

Submit Github PRs in the usual way, starting by pushing changes to your fork.

### Testing your changes

#### Linking to these Helios workspace packages

If you use `npm` for your Helios-using project, you can `npm link` in the usual way if you like, to develop your code along with any refinements to Helios.  

**If you are using `pnpm`** in your downstream project:
```
pnpm add ../../path/to/this/helios/‹repoName›
```
This connects your code to the named dependency.  Repeat for any other Helios repositories you want to bring into your project from this workspace.

With that linking arranged, every time you run your project code, it will use any updates you've saved to any of these Helios repos.

#### Add unit tests

If you're adding any functionality to a Helios package, please include a unit test if possible.

#### Running test builds

Please ensure you run test builds before submitting a PR.  

```
pnpm run build-all
```

This command will run all the builds in parallel, including any unit tests.  

#### Versioning

Please don't include version-number changes in your PRs.  

Please use a separate branch (possibly `main`) in your forked repo for isolated versioning, if you need to use your github version as a direct dependency, merging your PR branch into that separate versioning branch.

### More about this repo

See the `./setup.sh` script