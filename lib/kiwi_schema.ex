defmodule KiwiSchema do
  @moduledoc """
  Documentation for `KiwiSchema`.
  """

  defmacro __using__(opts) do
    quote location: :keep do
      import KiwiSchema.DSL, only: [field: 3, field: 2]
      Module.register_attribute(__MODULE__, :fields, accumulate: true)

      @options unquote(opts)
      @before_compile KiwiSchema.DSL

      def new(value) do
        struct(__MODULE__, value)
      end

      def encode(struct), do: KiwiSchema.Encoder.encode(struct)
    end
  end

  defdelegate encode(struct), to: KiwiSchema.Encoder
  defdelegate decode(module, buffer), to: KiwiSchema.Decoder
end
