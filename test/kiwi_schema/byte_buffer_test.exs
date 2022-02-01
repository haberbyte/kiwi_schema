defmodule KiwiSchema.ByteBufferTest do
  use ExUnit.Case
  doctest KiwiSchema.ByteBuffer

  alias KiwiSchema.ByteBuffer

  test "write_byte" do
    buf = buffer()
    buf |> ByteBuffer.write_byte(0)
    assert ByteBuffer.data(buf) == <<0>>

    buf = buffer()
    buf |> ByteBuffer.write_byte(1)
    assert ByteBuffer.data(buf) == <<1>>

    buf = buffer()
    buf |> ByteBuffer.write_byte(254)
    assert ByteBuffer.data(buf) == <<254>>

    buf = buffer()
    buf |> ByteBuffer.write_byte(255)
    assert ByteBuffer.data(buf) == <<255>>

    buf = buffer()
    buf |> ByteBuffer.write_byte(256)
    assert ByteBuffer.data(buf) == <<0>>
  end

  test "read_var_float" do
    assert buffer(<<0>>) |> ByteBuffer.read_var_float() == 0.0

    assert buffer(<<133, 242, 210, 237>>) |> ByteBuffer.read_var_float() |> Float.round(3) ==
             123.456

    assert buffer(<<133, 243, 210, 237>>) |> ByteBuffer.read_var_float() |> Float.round(3) ==
             -123.456
  end

  test "write_var_float" do
    buf = buffer()
    buf |> ByteBuffer.write_var_float(0.0)
    assert ByteBuffer.data(buf) == <<0>>

    buf = buffer()
    buf |> ByteBuffer.write_var_float(-0.0)
    assert ByteBuffer.data(buf) == <<0>>

    buf = buffer()
    buf |> ByteBuffer.write_var_float(123.456)
    assert ByteBuffer.data(buf) == <<133, 242, 210, 237>>

    buf = buffer()
    buf |> ByteBuffer.write_var_float(-123.456)
    assert ByteBuffer.data(buf) == <<133, 243, 210, 237>>

    buf = buffer()
    buf |> ByteBuffer.write_var_float(1.0e-40)
    assert ByteBuffer.data(buf) == <<0>>
  end

  test "write_var_int" do
    buf = buffer()
    buf |> ByteBuffer.write_var_int(0)
    assert ByteBuffer.data(buf) == <<0>>

    buf = buffer()
    buf |> ByteBuffer.write_var_int(-1)
    assert ByteBuffer.data(buf) == <<1>>

    buf = buffer()
    buf |> ByteBuffer.write_var_int(1)
    assert ByteBuffer.data(buf) == <<2>>

    buf = buffer()
    buf |> ByteBuffer.write_var_int(2_147_483_647)
    assert ByteBuffer.data(buf) == <<254, 255, 255, 255, 15>>

    buf = buffer()
    buf |> ByteBuffer.write_var_int(-2_147_483_648)
    assert ByteBuffer.data(buf) == <<255, 255, 255, 255, 15>>
  end

  test "write_var_uint" do
    buf = buffer()
    buf |> ByteBuffer.write_var_uint(0)
    assert ByteBuffer.data(buf) == <<0>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(1)
    assert ByteBuffer.data(buf) == <<1>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(2)
    assert ByteBuffer.data(buf) == <<2>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(100)
    assert ByteBuffer.data(buf) == <<100>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(127)
    assert ByteBuffer.data(buf) == <<127>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(128)
    assert ByteBuffer.data(buf) == <<128, 1>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(131_069)
    assert ByteBuffer.data(buf) == <<253, 255, 7>>

    buf = buffer()
    buf |> ByteBuffer.write_var_uint(4_294_967_295)
    assert ByteBuffer.data(buf) == <<255, 255, 255, 255, 15>>
  end

  test "read_string" do
    assert_raise MatchError, fn ->
      buffer(<<>>) |> ByteBuffer.read_string()
    end

    assert buffer(<<0>>) |> ByteBuffer.read_string() == ""
    assert buffer(<<97, 0>>) |> ByteBuffer.read_string() == "a"
    assert buffer(<<97, 98, 99, 0>>) |> ByteBuffer.read_string() == "abc"
    assert buffer(<<240, 159, 141, 149, 0>>) |> ByteBuffer.read_string() == "🍕"
    assert buffer(<<97, 237, 160, 188, 99, 0>>) |> ByteBuffer.read_string() == "a\xED\xA0\xBCc"
  end

  test "write_sequence" do
    buf = buffer()
    buf |> ByteBuffer.write_var_float(0.0)
    buf |> ByteBuffer.write_var_float(123.456)
    buf |> ByteBuffer.write_string("🍕")
    buf |> ByteBuffer.write_var_uint(123_456_789)

    assert ByteBuffer.data(buf) ==
             <<0, 133, 242, 210, 237, 240, 159, 141, 149, 0, 149, 154, 239, 58>>
  end

  defp buffer(bytes \\ <<>>) do
    ByteBuffer.new(bytes)
  end
end
