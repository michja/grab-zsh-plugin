# grab-zsh-plugin
A zsh plugin for quickly grabbing files.

Teach grab about a file `galias foo ~/files/foo.tar`.  
Then grab that file from anywhere `grab foo`.  
Also works with web resources e.g. `grab foo http://mysite.com/foo.tar`

## Commands
`galias <alias> <file>` Teach grab about a file - accepts relative paths  
`gunalias <alias>` Remove an alias  
`grab <alias>` Grab a file  
`glist` Show all known aliases  
  
## Dependencies
Requires `jq` 
