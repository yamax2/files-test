## commands
* console: `dip cc`
* web: `dip web`, open files-test.localhost
* sh: `dip sh`
* rubocop: `dip rubocop`  

## test

generate file:
```
timeout 1 sh -c 'cat /dev/urandom | base64' > dump.txt
curl -X PUT files-test.localhost/upload --data-binary "@dump.txt"
```
