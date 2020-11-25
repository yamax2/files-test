## commands
* console: `dip cc`
* web: `dip web`, open files-test.localhost
* sh: `dip sh`
* rubocop: `dip rubocop`  

## test

generate file:
```
timeout 1 sh -c 'cat /dev/urandom | base64' > dump.txt
time curl -X PUT 11.10.79.4:3000/upload -F 'files[]=@dump.txt' -F 'files[]=@dump2.txt'
```
