defmodule MsgTest do
  use ExUnit.Case


  test "decode protobuf length" do
    assert Msg.Server.Connection.decode_protobuf_length(<<172, 2>>) == {300, ""}
  end

  test "base128 decode to unsigned integer" do
    assert Msg.Server.Connection.protobuf_bitstring_to_int(<<127::7>>) == 127
    assert Msg.Server.Connection.protobuf_bitstring_to_int(<<1::7, 0::7>>) == 128
    assert Msg.Server.Connection.protobuf_bitstring_to_int(<<1::7, 22::7>>) == 150
    assert Msg.Server.Connection.protobuf_bitstring_to_int(<<2::7, 44::7>>) == 300
  end

end
