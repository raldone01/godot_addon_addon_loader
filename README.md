# addon_loader Godot addon

This addon allows you to easily disable and enable other addons without opening the project settings.
It can also reload individual addons for quick development.

## Installation

```bash
cd <godot_project_dir>
cd addons
git submodule add git@github.com:raldone01/godot_addon_addon_loader.git addon_loader
cd addon_loader
git checkout v1.0.0
```

`Project -> Project Settings -> Plugins -> addon_loader -> Enable`

Autoloads are a bit janky so you may need to restart the editor for errors to go away.

## Licensing

This addon is licensed under the MIT license. See [LICENSE](LICENSE.md) for more information.
