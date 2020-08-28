<!-- SPD-License-Identifer: ${#LICENSE}  -->
<!-- COPYRIGHT 2020 - FREIGHTTRUST AND CLEARING CORPORATION, ALL RIGHTS RESERVED -->

# Versioning

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in
[BCP 14](https://tools.ietf.org/html/bcp14)
[RFC2119](https://tools.ietf.org/html/rfc2119)
[RFC8174](https://tools.ietf.org/html/rfc8174) when, and only when, they appear
in all capitals, as shown here.

## Introduction

This document is to describe how a project is to version its releases

It also describes standardized tooling around manipulating the version

## Semver

A project MUST use Semantic Versioning [semver](https://semver.org). Build
metadata MAY NOT be used in a project. Build metadata SHOULD be ignored.

A Basic summary of Semantic Versioning taken from:
[semver.org](https://semver.org)

### Semver Types

#### Regular

^(0|[1-9]\d\\\\\\\\\\*).(0|[1-9]\d\\\\\\\\\\*).(0|[1-9]\d\\\\\\\\\\*)(-(0|[1-9]\d\\\\\\\\\\*|\d\\\\\\\\\\*[a-zA-Z-][0-9a-za-z-])(.(0|[1-9]\d|\d\\\\\\\\\\*[a-zA-Z-][0-9a-za-z-])))?(+[0-9a-zA-Z-]+(.[0-9a-zA-Z-]+)\\\\\\\\\\\*)?\\\\\\$
^(0|[1-9]\d\\\\\*).(0|[1-9]\d\\\\\*).(0|[1-9]\d\\\\\*)(-(0|[1-9]\d\\\\\*|\d\\\\\*[a-zA-Z-][0-9a-za-z-])(.(0|[1-9]\d|\d\\\\\*[a-zA-Z-][0-9a-za-z-])))?(+[0-9a-zA-Z-]+(.[0-9a-zA-Z-]+)\\\\\\*)?\$

#### LTS

(?nx)^ (?0|[1-9]\d\\\\\*). (?0|[1-9]\d\\\\\*). (?0|[1-9]\d\\\\\*) (? -(?
((0|[1-9]\d\\\\\*|\d\\\\\*[A-Z-a-z-][\da-za-z-]))(.(0|[1-9]\d|\d\\\\\*[A-Za-z-][\da-za-z-]))
) )? (? +(?[\dA-Za-z-]+(.[\dA-Za-z-])) )?\$

### Summary:

Given a version number MAJOR.MINOR.PATCH, increment the:

MAJOR version when you make incompatible API changes, MINOR version when you add
functionality in a backwards-compatible manner, and PATCH version when you make
backwards-compatible bug fixes. Additional labels for pre-release and build
metadata are available as extensions to the MAJOR.MINOR.PATCH format.
