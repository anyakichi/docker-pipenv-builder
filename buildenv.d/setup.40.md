Change into the project directory.

```
$ [[ -e Pipfile ]] || cd $(basename -s .git "${GIT_REPO}")
```
