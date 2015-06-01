# heineken

[![Build Status](https://travis-ci.org/khanage/heineken.svg?branch=master)](https://travis-ci.org/khanage/heineken)

A general build tool for haskell projects inspired by leiningen. It is intended to be useful for the automation of all project creation tedium, as well as eventually integrate with cloud deployments.

It is intended that this will support arbitrary plugins in the future.

# Usage
## New

Run 'hein new <proj name>' will:
 * create a subdirectory under the current one
 * create a cabal sandbox
 * initialise cabal
 * cabal build
 * create a git repo
 * create an initial commit
 * run your project (which defaults to printing the proj name)
 
You can also specify additional dependencies by prefixing them with a plus, e.g. `hein new webtest +scotty` will add scotty as a dependency to your build.

# Installation

This assumes you have a recent cabal installed for your platform.

 * cabal update
 * cabal install hein
 * hein new project +dependency
