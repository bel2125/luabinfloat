function bin2double(data)
  local a,b,c,d,e,f,g,h = data:byte(1, 8);
  local bt = function(val, m) return math.floor(val / m) % 2 end
  local sign = bt(h, 128)
  local gr = g % 16
  local exp = (h % 128) * 16 + (g - gr) / 16
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
    frac = frac + bt(a,2^(8-i))/2^(42+i)
  end

  return (-1)^sign * frac * 2^(exp-1023)
end
