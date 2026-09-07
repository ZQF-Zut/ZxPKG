# Registry

my custom vcpkg/xrepo registry

## Usage

### vcpkg

`vcpkg.json`

```json
{
  "name": "zxpkg-test",
  "version": "1.0",
  "dependencies": [
    "zqf-zut-zxjson"
  ],
  "vcpkg-configuration": {
    "default-registry": {
      "kind": "git",
      "repository": "https://github.com/Microsoft/vcpkg",
      "baseline": "29ff5b8131d0c6c8fcb8fbaef35992f0d507cd7c"
    },
    "registries": [
      {
        "kind": "git",
        "repository": "https://github.com/Dir-A/Registry.git",
        "baseline": "0a2858823b43f7945763faa5f1f39e7b859b5de5",
        "packages": [
          "zqf-*"
        ]
      }
    ]
  }
}
```

### xrepo

[WIP]
## Note
### vcpkg

#### get vcpkg

```shell
git clone https://github.com/microsoft/vcpkg.git --depth=1 .vcpkg
cd .vcpkg
bootstrap-vcpkg.bat
```

#### update versions database

- Windows
```shell
.\.vcpkg\vcpkg.exe --x-builtin-ports-root=./ports --x-builtin-registry-versions-dir=./versions x-add-version --all --verbose
```

- Unix
```shell
.\.vcpkg\vcpkg --x-builtin-ports-root=./ports --x-builtin-registry-versions-dir=./versions x-add-version --all --verbose
```

#### testing port

- Windows
```shell
.\.vcpkg\vcpkg.exe install zqf-cmake-modules --overlay-ports=ports --x-install-root=.build/installed --downloads-root=.build/downloads --x-buildtrees-root=.build/buildtrees --x-packages-root=.build/packages
```

- Unix
```shell
.\.vcpkg\vcpkg install zqf-cmake-modules --overlay-ports=ports --x-install-root=.build/installed --downloads-root=.build/downloads --x-buildtrees-root=.build/buildtrees --x-packages-root=.build/packages
```

