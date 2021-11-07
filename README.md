[![Test](https://github.com/oleksis/pyinstaller-manylinux/workflows/Test/badge.svg)](https://github.com/oleksis/pyinstaller-manylinux/actions/workflows/test.yml)

# pyinstaller-manylinux
PyInstaller ManyLinux 2.24 Docker Action

This action run [PyInstaller](https://www.pyinstaller.org/) using docker image from [pypa/manylinux repository](https://quay.io/repository/pypa/manylinux_2_24_x86_64)

## Inputs
`pyinstaller-params`

**Required** List of parameters for pyinstaller

## Example usage
```yaml
uses: oleksis/pyinstaller-manylinux@v2.1.2
with:
  pyinstaller-params: "['-c', '-F', '--icon=assets/image.ico', '--exclude-module=test', '--name=app-binary', 'app_module/__main__.py']"
```

See more in [test.yml](.github/workflows/test.yml)

## How to use the Dockerfile
- Build the image *pyinstaller-manylinux*
```bash
docker build -t pyinstaller-manylinux -f ./Dockerfile .
```
- Create bundle app using pyinstaller in the docker image
```bash
docker run --name pyinstaller-manylinux \
            -it -d \
            --workdir /src \
            -v $(pwd):/src \
            pyinstaller-manylinux \
            -c -F --name=app tests/app.py
```
- View the logs in the docker container
```bash   
docker logs pyinstaller-manylinux
```
- New container with **interactive terminal typing** using bash
```bash
docker run --name pyinstaller-pyenv \
            -it \
            --entrypoint bash \
            --workdir /src \
            -v $(pwd):/src \
            pyinstaller-manylinux
```
- Start the new container using interactive bash
```bash
docker start -i pyinstaller-pyenv

root@2ec766053649:/src# pyenv versions
  system
* 3.6.15 (set by /root/.pyenv/version)
```
- Run the app in the local machine
```bash
./dist/app
Hello out there 👋
```

## Notes

1. This action can execute **`setup.sh`** if it exists in the repository, before installing the requirements (**`requirements.txt`**)
2. Use [pyenv](https://github.com/pyenv/pyenv) in ManyLinux to have Python builded with `--enable-shared`.
   Some project we need add **crypto binary library** using PyInstaller `--add-binary libcryt.so.2:.`
```bash
cp /usr/local/lib/libcrypt.so.2 .
```
