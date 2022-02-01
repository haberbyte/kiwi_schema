defmodule KiwiSchema.DSL.Enum do
  @moduledoc false

  alias KiwiSchema.MessageProps

  def quoted_enum_functions(%MessageProps{type: :enum, field_props: props}) do
    Enum.map(props, fn prop ->
      quote do
        def value(unquote(prop.name_atom)), do: unquote(prop.index)
        def value(unquote(prop.name)), do: unquote(prop.index)

        def key(unquote(prop.index)), do: unquote(prop.name)
      end
    end) ++
      [
        quote do
          def encode(input, byte_buffer) do
            ByteBuffer.write_var_uint(byte_buffer, value(input))
          end

          def decode(byte_buffer) do
            key(ByteBuffer.read_var_uint(byte_buffer))
          end
        end
      ]
  end

  def quoted_enum_functions(_), do: nil
end
