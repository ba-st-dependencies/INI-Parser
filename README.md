# INI Parser

A fork of [INI Parser](https://github.com/ctSkennerton/INI-Parser) to be used as a dependency in [ba-st](https://github.com/ba-st) for GS/64 & Pharo.

The `upstream` branch is supposed to track the changes in the `master` branch of [ctSkennerton/INI-Parser](https://github.com/juliendectSkennertonlplanque/INI-Parser)

The `release-candidate` is the branch where our changes land before releasing a version.

[![Unit Tests](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/unit-tests.yml/badge.svg)](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/unit-tests.yml/badge.svg)
[![GS64 - Unit Tests](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/unit-tests-gs64.yml/badge.svg)](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/unit-tests-gs64.yml)
[![Coverage Status](https://codecov.io/github/ba-st-dependencies/INI-Parser/coverage.svg?branch=release-candidate)](https://codecov.io/gh/ba-st-dependencies/INI-Parser/branch/release-candidate)

[![Baseline Groups](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/loading-groups.yml/badge.svg)](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/loading-groups.yml)
[![GS64 Components](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/loading-gs64-components.yml/badge.svg)](https://github.com/ba-st-dependencies/INI-Parser/actions/workflows/loading-gs64-components.yml)

[![GitHub release](https://img.shields.io/github/release/ba-st-dependencies/INI-Parser.svg)](https://github.com/ba-st-dependencies/INI-Parser/releases/latest)
[![Pharo 8.0](https://img.shields.io/badge/Pharo-8.0-informational)](https://pharo.org)
[![Pharo 9.0](https://img.shields.io/badge/Pharo-9.0-informational)](https://pharo.org)
[![Pharo 10](https://img.shields.io/badge/Pharo-10-informational)](https://pharo.org)
[![Pharo 11](https://img.shields.io/badge/Pharo-11-informational)](https://pharo.org)

[![GS64 3.7.0](https://img.shields.io/badge/GS64-3.7.0-informational)](https://gemtalksystems.com/products/gs64/)

A parser for [INI configuration files](https://en.wikipedia.org/wiki/INI_file).

This is a simple parser for files with the following format:

```ini
globalKey = value
; This is a comment
# This is also a comment

[Section]
key = value
key2 = value2

[Another Section]
key = value
key2 = value2
```

Only single line values are currently supported.

Parsing returns a two level dictionary.

```smalltalk
parser := IniReader on: iniReadStream.
data := parser parse.
```

---

The parsing code is a derivative work of the [NeoJSON](https://github.com/svenvc/NeoJSON)
parser by [Sven Van Caekenberghe](https://github.com/svenvc) under the MIT license.
