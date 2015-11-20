# idk-verifier

[![Build Status](https://travis-ci.org/binary-koan/idk-verifier.svg)](https://travis-ci.org/binary-koan/idk-verifier)

A toy mathematics programming language with static assertions.

## Getting Started

IDK files are written with the extension `.idk`. They consist of a set
of mathematical expressions, optionally with variables, and assertions about
what conditions must be true.

Variables are defined using `expect` statements.

```
expect x where x > 0, x <= 100
```

Boolean operators are also supported (`AND` and `OR`)

```
expect x where x > 0 && x <= 100
```

Operations are then performed on the variables.

```
y = x * 2 + 100
```

And then assertions are written to verifiy the output values.

```
assert x >= 0 && x <= 100 && x > (-1), x < 101
assert y => 100 &&  y <= 300
```

Programs can be verified by running `bin/idk-verifier <program-path>`.
