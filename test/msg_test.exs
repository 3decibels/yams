defmodule YamsTest do
  use ExUnit.Case


  test "decode protobuf length" do
    assert Yams.Server.Connection.decode_protobuf_length(<<172, 2>>) == {300, ""}
    assert Yams.Server.Connection.decode_protobuf_length(
      <<172, 2, 84, 101, 115, 116, 32, 115, 116, 114, 105, 110, 103>>) == {300, "Test string"}
  end

  test "base128 decode to unsigned integer" do
    assert Yams.Server.Connection.decode_base128_int(<<127::7>>) == 127
    assert Yams.Server.Connection.decode_base128_int(<<1::7, 0::7>>) == 128
    assert Yams.Server.Connection.decode_base128_int(<<1::7, 22::7>>) == 150
    assert Yams.Server.Connection.decode_base128_int(<<2::7, 44::7>>) == 300
  end

end
