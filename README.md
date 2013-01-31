NAP
===

A toy parser for Python-like language 

Building
--------

You will need to have the following packages installed:

C compiler (edit first lines in Makefile if your compiler is not 'cc')

lemon(http://www.hwaci.com/sw/lemon/)

re2c(http://re2c.org)

Type

     $ make

to build.

Usage
-----

     $ ./nap sample.nap

It can parse something like this:

```
class a(b):
    pass
    def __constructor__(int p1, float p2) returns string as:
        pass

class c(d, e, f):
    x = y
    z = 42
    def __constructor__(int p1, float p2) returns string as:
        pass
    class subclass():
        d = 88
        def subclass_func() returns void as:
            pass

def g() returns int as:
  pass
```

But it's really unusable, it's just a sample
