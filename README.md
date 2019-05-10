# Simple Git Server

A simple git server. Created for 42 Hercules: Apples of Hesperides. 

## Usage

 1. Create a VM via VirtualBox. Perform the configuration (or the equivalent) found in alpine-setup.txt
 2. Run `sh apples.sh <port-of-your-choice>`
 
Once this is complete:

 - `gitserver new` creates a new remote repository on the server
 - `gitserver ls` lists the existing repositories on the server
 - `git clone gitserver:/repos/repo-name  [local-path]` clones a remote repository
 - `ssh gitserver` will ssh into the remote repo storage so that the remotes can be managed directly
 
## Note of warning for those doing 42 Hercules Apples of Hesperides in the future

The eval page expects an implementation in which you have pushed your public key. This surprised my evaluators as well.
 
## Credits

All code is written by me.
