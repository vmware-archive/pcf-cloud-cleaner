## Error when running `docker run` results in the following error

```
$docker run -it -v $(pwd):/the-cleaner -w /the-cleaner ubuntu /bin/bash

docker: invalid reference format: repository name must be lowercase.
```

### Fix
when running on mac make sure `pwd` path does not contain any spaces.  Uppercase characters are ok because mac is not case sensitive but a space or special character type will result in this error
```
$ pwd
/Users/morty/time crystal/pcf-cloud-cleaner/AWS

mv /Users/morty/time\ crystal /Users/morty/time-crystal
```

