binfloat = require "binfloat"

difference_detected = false
testcount = 100000

function testnumber(n, encode, decode, expected_len, tolerance)
  local bin = encode(n)
  if #bin ~= expected_len then
    error("Did not return the expected length: " .. tostring(n))
  end
  local r = decode(bin);
  local d = math.abs(r-n)

  if d > tolerance then
    if (not difference_detected) then
      difference_detected = true;
      print("Difference in encoding/decoding detected");
    end
    print(string.format("%.16f", n), string.format("%.16f", r), string.format("%.2g",d), string.format("%.2g",tolerance), bin:byte(1,8));
  end
end


function testdouble(num)
  local tolerance = math.max(math.abs(num/(2^52)), 2.2250739e-308)
  -- tolerance = 0.0 --<< Lua internally uses "double". A tolerance of 0.0 will work
  return testnumber(num, binfloat.encode_double, binfloat.decode_double, 8, tolerance)
end


function testsingle(num)
  local tolerance = math.max(math.abs(num/(2^23)), 1.1755e-38)
  return testnumber(num, binfloat.encode_single, binfloat.decode_single, 4, tolerance)
end


function testhalf(num)
  if math.abs(num) < 65500 then
    local tolerance = math.max(math.abs(num/(2^10)), 6.105e-5)
    return testnumber(num, binfloat.encode_half, binfloat.decode_half, 2, tolerance)
  end
end


function testall()
  print("Starting test for double precision using " .. testcount .. " numbers");
  testdouble(0.0);
  for c = 1,testcount do
    local n = math.random()
    testdouble(c)
    testdouble(n)
    testdouble(c*n)
    testdouble(-c/n)
  end
  print("Starting test for single precision");
  testsingle(0.0)
  for c = 1,testcount do
    local n = math.random()
    testsingle(c)
    testsingle(n)
    testsingle(c*n)
    testsingle(-c/n)
  end
  print("Starting test for half precision");
  testhalf(0.0)
  for c = 1,testcount do
    local n = math.random()
    testhalf(c)
    testhalf(n)
    testhalf(c*n)
    testhalf(-c/n)
  end
  if (not difference_detected) then
    print("Test OK");
  else
    print("Test failed");
  end
  print("Test completed");
end

-- run the test
testall();
