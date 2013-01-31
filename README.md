NAP
===

A toy parser for Python-like language 

Building
--------

You must have cc, lemon(http://www.hwaci.com/sw/lemon/) and re2c(re2c.org) installed. Type

     $ make

to build.

Usage
-----

     $ ./nap sample.nap

It can parse something like this:

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
