-- binfloat.lua: A pure Lua implementation for encoding/decoding IEEE754 floating numbers, tested with Lua5.2 to Lua5.4
-- This code assumes little endian data encoding ("Intel byte order").

-- convert 8 bytes binary string encoding an IEEE754 double precision floating point number to a Lua number
function bin2double(data)
  local a,b,c,d,e,f,g,h = data:byte(1, 8);
  local bt = function(val, m) return math.floor(val / m) % 2 end
  local sign = bt(h, 128)

  if ((h % 128) == 0) and (g == 0) and (f == 0) and (e == 0) and (d == 0) and (c == 0) and (b == 0) and (a == 0) then
    return (-1)^sign * 0.0
  end

  local gr = g % 16
  local exp = (h % 128) * 16 + (g - gr) / 16

  if exp == 2047 then
    return (-1)^sign * math.huge;
  end

  local frac = 1 + bt(gr,8)/2 + bt(gr,4)/4 + bt(gr,2)/8 + bt(gr,1)/16

  for i=1,8 do
    frac = frac + bt(f,2^(8-i))/2^(4+i)
  end
  for i=1,8 do
    frac = frac + bt(e,2^(8-i))/2^(12+i)
  end
  for i=1,8 do
    frac = frac + bt(d,2^(8-i))/2^(20+i)
  end
  for i=1,8 do
    frac = frac + bt(c,2^(8-i))/2^(28+i)
  end
  for i=1,8 do
    frac = frac + bt(b,2^(8-i))/2^(36+i)
  end
  for i=1,8 do
    frac = frac + bt(a,2^(8-i))/2^(44+i)
  end

  return (-1)^sign * frac * 2^(exp-1023)
end


-- convert 4 bytes binary string encoding an IEEE754 single precision floating point number to a Lua number
function bin2single(data)
  local a,b,c,d = data:byte(1, 4);
  local bt = function(val, m) return math.floor(val / m) % 2 end
  local sign = bt(d, 128)

  if ((d % 128) == 0) and (c == 0) and (b == 0) and (a == 0) then
    return (-1)^sign * 0.0
  end

  local cr = c % 128
  local exp = (d % 128) * 2 + (c - cr) / 128

  if exp == 255 then
    return (-1)^sign * math.huge;
  end

  local frac = 1 + bt(cr,64)/2 + bt(cr,32)/4 + bt(cr,16)/8 + bt(cr,8)/16 + bt(cr,4)/32 + bt(cr,2)/64 + bt(cr,1)/128
  for i=1,8 do
    frac = frac + bt(b,2^(8-i))/2^(7+i)
  end
  for i=1,8 do
    frac = frac + bt(a,2^(8-i))/2^(15+i)
  end

  return (-1)^sign * frac * 2^(exp-127)
end


-- split floating pointnumber into sign, exponent and mantissa
local function floatsplit(n)
  local s = 0 -- sign
  local e = 0 -- exponent
  local f = n -- fraction
  local bs = ""; -- fraction as bit string

  if n<0.0 then s = 1; f = -n; end
  if n==0 then return s, e, f, bs; end
  while f>=2.0 do e=e+1 f=f/2.0; end
  while f<1.0 do e=e-1 f=f*2.0; end

  local br = f - 1.0;
  while (br > 0) do
    br = br * 2;
    if br >= 1.0 then
      br = br - 1.0;
      bs = bs .. "1";
    else
      bs = bs .. "0";
    end
  end

  return s,e,f,bs
end

-- convert number into 8 byte double precision floating point number
function double2bin(num)
  if (num == 0.0) then return string.char(0, 0, 0, 0, 0, 0, 0, 0) end
  if (num == -0.0) then return string.char(0, 0, 0, 0, 0, 0, 0, 128) end

  local sign, exponent, fraction, mantis = floatsplit(num)
  exponent = exponent + 1023;
  mantis = mantis .. string.rep("0", 52-string.len(mantis))
  mantis = mantis:sub(1,52)
  local mantisnum = tonumber(mantis, 2)

  local b1 = sign*128 + math.floor(exponent / 16)
  local b2 = math.floor(exponent % 16) * 16 + math.floor(mantisnum / 2^48)
  mantisnum = mantisnum % 2^48
  local b3 = math.floor(mantisnum / 2^40)
  mantisnum = mantisnum % 2^40
  local b4 = math.floor(mantisnum / 2^32)
  mantisnum = mantisnum % 2^32
  local b5 = math.floor(mantisnum / 2^24)
  mantisnum = mantisnum % 2^24
  local b6 = math.floor(mantisnum / 2^16)
  mantisnum = mantisnum % 2^16
  local b7 = math.floor(mantisnum / 2^8)
  mantisnum = mantisnum % 2^8
  local b8 = math.floor(mantisnum + 0.5)

  return string.char(b8,b7,b6,b5,b4,b3,b2,b1)
end
