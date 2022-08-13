## About Project

- This script was made to facilitate the import of several keys for a version of java on your machine.

<img align="" width="100%" height="100%" src="images/output.jpg">

## How use

- In the folder of that project, run the command.
```bash
 ./install_certs.sh -j "/home/claudio/.sdkman/candidates/java/17.0.4-oracle/lib/security/cacerts" -k "./keysPath"
```

| Flag | flag meaning                                     |
|------|--------------------------------------------------|
| -j   | java cacerts path                                |
| -k   | folder where the keys to be imported are located |

