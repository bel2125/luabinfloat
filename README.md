# luabinfloat
Conversion of floating point numbers to and from binary data in pure Lua


Implementation
---

This is a pure Lua implementation for encoding/decoding IEEE754 floating numbers, tested with Lua5.2 to Lua5.4.
It has no external dependencies.

The function `decode_single(data)` converts a 4 bytes string `data` containing little endian IEEE754 encoded single precision floating numbers into a Lua number.

The function `decode_double(data)` converts an 8 bytes string `data` containing little endian IEEE754 single precision encoded floating numbers into a Lua number.

Example: 
```Lua
one = binfloat.decode_single(string.char(0,0,128,63))`
```
Example using a binary file `data.bin` containing two float numbers:
```Lua
  f = io.open("data.bin", "rb");
  data = f:read("*all");
  f:close();
  print(binfloat.decode_single(data:sub(1,4)))
  print(binfloat.decode_single(data:sub(5,8)))
```


Byte order
---

The code assumes little endian data encoding ("Intel byte order").
In case you have big endian data ("Network byte order"), turn the order of bytes:
function | little endian | big endian
--|--|--
`decode_single(data)` | `local a,b,c,d = data:byte(1, 4);` | `local d,c,b,a = data:byte(1, 4);`  
`decode_double(data)` | `local a,b,c,d,e,f,g,h = data:byte(1, 8);` | `local h,g,f,e,d,c,b,a = data:byte(1, 8);`  

Would it be possible to add a parameter to indicate byte order? 
It would be easy, but I never needed it. If someone needs it, write a GitLab issue and I will do it.


References
---

- https://en.wikipedia.org/wiki/Single-precision_floating-point_format
- https://www.binaryconvert.com/result_float.html?hexadecimal=3F800000
- https://en.wikipedia.org/wiki/Double-precision_floating-point_format
- https://www.binaryconvert.com/result_double.html?decimal=049046050051052053054055056057069049048
