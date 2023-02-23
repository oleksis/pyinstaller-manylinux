[![Test](https://github.com/oleksis/pyinstaller-manylinux/workflows/Test/badge.svg)](https://github.com/oleksis/pyinstaller-manylinux/actions/workflows/test.yml)
[![Build](https://github.com/oleksis/pyinstaller-manylinux/actions/workflows/build.yml/badge.svg)](https://github.com/oleksis/pyinstaller-manylinux/actions/workflows/build.yml)

# pyinstaller-manylinux-2.28
PyInstaller ManyLinux 2.28 Docker Action based on [AlmaLinux](https://github.com/pypa/manylinux) 8.7 (Stone Smilodon)"

This action run [PyInstaller](https://www.pyinstaller.org/) using docker image from [pypa/manylinux repository](https://quay.io/repository/pypa/manylinux_2_28_x86_64)

## Inputs
`pyinstaller-params`

**Required** List of parameters for pyinstaller

## Example usage
```yaml
uses: oleksis/pyinstaller-manylinux@v2.2.1
with:
  pyinstaller-params: "['-c', '-F', '--icon=assets/image.ico', '--exclude-module=test', '--name=app-binary', 'app_module/__main__.py']"
```

See more in [test.yml](.github/workflows/test.yml)

## How to use the Dockerfile
- Build the image *pyinstaller-manylinux-2.28*
```bash
docker build -t pyinstaller-manylinux-2.28 -f ./Dockerfile .
```
- Create bundle app using pyinstaller in the docker image
```bash
docker run --name pyinstaller-manylinux-2.28 \
            -it -d \
            --workdir /src \
            -v $(pwd):/src \
            pyinstaller-manylinux-2.28 \
            -c -F --name=app tests/app.py
```
- View the logs in the docker container
```bash   
docker logs --tail 1000 -f pyinstaller-manylinux-2.28
```
- New container with **interactive terminal typing** using bash
```bash
docker run --name pyinstaller-pyenv \
            -it \
            --entrypoint bash \
            --workdir /src \
            -v $(pwd):/src \
            pyinstaller-manylinux-2.28
```
- Start the new container using interactive bash
```bash
docker start -i pyinstaller-pyenv

[root@882bd364e3fe src]# pyenv versions
* 3.8.15 (set by /root/.pyenv/version)
```
- Run the app in the local machine
```bash
./dist/app
Hello out there 👋
```

## How to use Github Container Registry
[Github Packages](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [pyinstaller-manylinux](https://github.com/oleksis/pyinstaller-manylinux/pkgs/container/pyinstaller-manylinux)

## Notes

1. This action can execute **`setup.sh`** if it exists in the repository, before installing the requirements (**`requirements.txt`**)
2. Use [pyenv](https://github.com/pyenv/pyenv) in ManyLinux to have Python builded with `--enable-shared`.
   Some project we need add **crypto binary library** using PyInstaller `--add-binary libcryt.so.2:.`
```bash
cp /usr/local/lib/libcrypt.so.2 .
```

## Releases
PyInstaller ManyLinux 2.28 Docker Action [v2.2.1](https://github.com/oleksis/pyinstaller-manylinux/releases/tag/v2.2.1)
- This action run PyInstaller using docker image (AlmaLinux 8.7 based) from [pypa/manylinux repository](https://quay.io/repository/pypa/manylinux_2_28_x86_64)
- Python 3.8

PyInstaller ManyLinux 2.24 Docker Action [v2.1.2](https://github.com/oleksis/pyinstaller-manylinux/releases/tag/v2.1.2)
- This action run PyInstaller using docker image (Debian 9 based) from [pypa/manylinux repository](https://quay.io/repository/pypa/manylinux_2_24_x86_64)
- Python 3.6

PyInstaller ManyLinux 2014 Docker Action [v1.0.0](https://github.com/oleksis/pyinstaller-manylinux/releases/tag/v1)
- This action run PyInstaller using docker image (Centos 7 based) from [pypa/manylinux repository](https://quay.io/repository/pypa/manylinux2014_x86_64)
- Python 3.6
