# Documentation deployment guide

Travis CI is configured to automatically build and deploy documentation for the
Gini Vision Library in the following cases:

* The `BUILD_DOCS` environment variable is set to `true`
* The commit is **not** a pull request
* The commit is tagged (there is a tag that points to the save commit)

## Deployment

The documentation for Gini Vision is pushed to Github Pages (the `gh-pages` branch).
It can then also be accessed from "http://developer.gini.net/gini-vision-lib-ios/docs/index.html",
but that URL just links back to the GitHub Pages.

## Building docs

Building the documentation is a two stage process:

* Building the API reference with `jazzy`
* Building the guides and static pages with `Sphinx`

### Building the API reference

The `jazzy` build command can be found in `build-documentation-api.sh`. After it does
its magic, the result is saved in `Documentation/Api`

### Building the guides

Running the `deploy-documentation.sh` will both generate the docs, and push them to GitHub Pages.
All the files `Sphinx` needs are located in the `Documentation` folder.

**Note:** For new releases, the Changelog probably needs to be updated. You can find it in `Documentation/source/Changelog.rst`.
Open it and add another entry for the new version and add short descriptions of all the included changes.

#### Installing dependencies

Since `deploy-documentation.sh` is designed to work within a Travis job, it will automatically try to install dependencies.
There dependencies are described in the `requirements.txt`.

#### Running Sphinx

Conveniently enough, the `Documentation` directory contains a Makefile that takes care of building the docs. Just run `make html` to generate docs in a HTML form.

#### Pushing to GitHub Pages

Next, the script will clone the `gh-pages` branch and push the new docs there. For the sake of simplicity, the branch will be cloned inside the working tree, in the `gh-pages` directory. Then, the `Api` and `docs` directories that were generated previously, will be copied in the `api` and `docs` directories, respectively, inside the GibHub Pages repository. Then, the changes will be pushed to GibHub under the "Travis CI" name.

## Travis-CI dependencies

As already mentioned, the `push-documentation` script is meant to run within Travis CI, and thus, has some dependencies on it. Namely, it uses several environment variables. While it is definitely possible to run the docs scripts locally, you need to make sure to set those variables. Here they are:

* TRAVIS_PULL_REQUEST - _the pull request that originated this build. This is used to make sure docs deployment is NOT triggered for pull requests_
* TRAVIS_TAG - _set to the name of the tag pointing to the commit being built. This is used to make sure the commit is tagged and should trigger a docs deployment_
* TRAVIS_BRANCH - _The branch being build. Only used for logging - doesn't have to be substituted for local runs_
* DOC_PUSH_TOKEN - _The GitHub token used to authenticate the command that pushes the docs to the gh-pages branch_

By far the most important is the GitHub token. If you want to run the script locally, either generate a working token from your GitHub account or substitute the HTTPS link with an SSH one (provided you have a valid ssh key for pushing to GitHub). 
