defmodule MsgTest do
  use ExUnit.Case

  test "base128 decode" do
    assert Msg.Server.Connection.protobuf_bitstring_to_int(<<0::1, 0::1, 0::1, 0::1, 0::1, 1::1, 0::1,
      0::1, 1::1, 0::1, 1::1, 1::1, 0::1, 0::1>>) == 300
  end

  test "decode protobuf length" do
    assert Msg.Server.Connection.decode_protobuf_length(<<1::1, 0::1, 1::1, 0::1, 1::1, 1::1, 0::1, 0::1,
      0::1, 0::1, 0::1, 0::1, 0::1, 0::1, 1::1, 0::1>>) == {300, ""}
  end

end
