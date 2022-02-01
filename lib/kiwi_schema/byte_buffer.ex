defmodule KiwiSchema.ByteBuffer do
  @moduledoc """
  Documentation ....
  """

  use Bitwise

  def new(bytes \\ <<>>) do
    case :file.open(bytes, [:ram, :binary, :read, :write]) do
      {:ok, device} -> device
      _other -> raise "Could not create byte buffer"
    end
  end

  def data(device) do
    :file.position(device, 0)
    IO.binread(device, :all)
  end

  def read_byte(device) do
    <<byte::size(8)>> = IO.binread(device, 1)
    byte
  end

  def write_byte(device, byte) do
    IO.binwrite(device, <<byte::size(8)>>)
  end

  def write_bytes(device, bytes) do
    IO.binwrite(device, bytes)
  end

  def read_bytes(device, count) do
    IO.binread(device, count)
  end

  def read_bool(device) do
    IO.binread(device, 1) == <<1>>
  end

  def write_bool(device, value) do
    if value do
      write_byte(device, 1)
    else
      write_byte(device, 0)
    end
  end

  def read_var_int(device) do
    value = read_var_uint(device) ||| 0

    if (value &&& 1) != 0 do
      ~~~(value >>> 1)
    else
      value >>> 1
    end
  end

  def read_var_uint(device) do
    read_var_uint(device, 0, 0)
  end

  defp read_var_uint(device, result, shift) do
    byte = read_byte(device)

    result = result ||| (byte &&& 127) <<< shift
    shift = shift + 7

    if (byte &&& 128) == 0 || shift >= 35 do
      result
    else
      read_var_uint(device, result, shift)
    end
  end

  def write_var_int(device, value) do
    write_var_uint(device, bxor(value <<< 1, value >>> 31))
  end

  def write_var_uint(device, value) do
    byte = value &&& 127
    value = value >>> 7

    if value == 0 do
      write_byte(device, byte)
    else
      write_byte(device, byte ||| 128)
      write_var_uint(device, value)
    end
  end

  def read_var_float(device) do
    first = read_byte(device)

    if first == 0 do
      0
    else
      <<second, third, fourth>> = read_bytes(device, 3)

      bits = first ||| second <<< 8 ||| third <<< 16 ||| fourth <<< 24
      bits = bits <<< 23 ||| bits >>> 9

      # Reinterpret as a floating-point number
      <<num::float-32>> = <<bits::size(32)>>
      num
    end
  end

  def write_var_float(device, number) do
    # Reinterpret as 32 bit integer
    <<bits::size(32)>> = <<number::float-32>>

    # Move the exponent to the first 8 bits
    bits = bits >>> 23 ||| bits <<< 9

    # Optimization: use a single byte to store zero and denormals (check for an exponent of 0)
    if (bits &&& 255) == 0 do
      write_byte(device, 0)
    else
      # Endian-independent 32-bit write

      write_bytes(device, <<bits::little-32>>)
    end
  end

  def read_string(device) do
    read_string(device, "")
  end

  defp read_string(device, result) do
    byte = read_byte(device)

    if byte == 0 do
      result
    else
      read_string(device, result <> <<byte>>)
    end
  end

  def write_string(device, string) do
    IO.binwrite(device, string <> <<0>>)
  end
end
