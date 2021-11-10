# Instructions to repo maintainer

In order to make this you'll need  Docker and reprepro installed on your machine. It isn't required to be using Debian.  

`repo/conf/distributions` contains `SignWith` which has the fingerprint of the GPG key that is needed to sign this repository. It is a must to import it's private key before doing anything.
`repo/conf/distributions` also contains the seperate branches for this repo. Currently we only provide stable.   

To make this on your machine, do the following:  

```shell
./docker-build.sh v0.3.15+popura1 stable
```

in that example, we're building popura version `v0.3.15+popura1` to repository "branch" `stable`.   

If a bug fix was made and it was packaging related (i.e. the actual popura version didn't go up) do: 

```shell
./docker-build.sh v0.3.15+popura1 stable 2
```
  
if that last option wasn't mentioned it would default to 1. Keep incrementing it as you face and fix issues with packaging.  

The docker image is [holy-build-box](https://github.com/phusion/holy-build-box).
