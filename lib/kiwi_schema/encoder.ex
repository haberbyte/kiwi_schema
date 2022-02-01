defmodule KiwiSchema.Encoder do
  @moduledoc false

  alias KiwiSchema.ByteBuffer

  def encode(%mod{} = struct) do
    mod.encode(struct, ByteBuffer.new())
  end
end
