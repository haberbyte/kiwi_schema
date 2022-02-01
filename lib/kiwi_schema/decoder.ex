defmodule KiwiSchema.Decoder do
  @moduledoc false

  def decode(module, buffer) do
    module.decode(buffer)
  end
end
