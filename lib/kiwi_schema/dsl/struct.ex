defmodule KiwiSchema.DSL.Struct do
  @moduledoc false

  alias KiwiSchema.{FieldProps, MessageProps}

  def quoted_struct_functions(%MessageProps{type: :struct, field_props: fields}) do
    encode_field_instructions = Enum.map(fields, &gen_encode_field_code/1)
    decode_field_instructions = Enum.map(fields, &gen_decode_field_code/1)

    quote do
      def encode(message, byte_buffer) do
        unquote_splicing(encode_field_instructions)

        byte_buffer
      end

      def decode(byte_buffer) do
        result = %__MODULE__{}
        unquote_splicing(decode_field_instructions)
        result
      end
    end
  end

  def quoted_struct_functions(_), do: nil

  defp gen_encode_field_code(%FieldProps{array?: true} = field) do
    code =
      case field.type do
        :bool ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              ByteBuffer.write_bool(byte_buffer, value)
            end)
          end

        :byte ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              ByteBuffer.write_byte(byte_buffer, value)
            end)
          end

        :int ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              ByteBuffer.write_var_int(byte_buffer, value)
            end)
          end

        :uint ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              ByteBuffer.write_var_uint(byte_buffer, value)
            end)
          end

        :float ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              ByteBuffer.write_var_float(byte_buffer, value)
            end)
          end

        :string ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              ByteBuffer.write_string(byte_buffer, value)
            end)
          end

        _ ->
          quote do
            ByteBuffer.write_var_uint(byte_buffer, length(value))

            Enum.each(value, fn value ->
              unquote(field.type).encode(value, byte_buffer)
            end)
          end
      end

    quote do
      value = Map.get(message, unquote(field.name_atom))

      if !is_nil(value) do
        unquote(code)
      else
        raise "Missing required field: '#{unquote(field.name)}'"
      end
    end
  end

  defp gen_encode_field_code(%FieldProps{} = field) do
    code =
      case field.type do
        :bool ->
          quote(do: ByteBuffer.write_bool(byte_buffer, value))

        :byte ->
          quote(do: ByteBuffer.write_byte(byte_buffer, value))

        :int ->
          quote(do: ByteBuffer.write_var_int(byte_buffer, value))

        :uint ->
          quote(do: ByteBuffer.write_var_uint(byte_buffer, value))

        :float ->
          quote(do: ByteBuffer.write_var_float(byte_buffer, value))

        :string ->
          quote(do: ByteBuffer.write_string(byte_buffer, value))

        _ ->
          quote(do: unquote(field.type).encode(value, byte_buffer))
      end

    quote do
      value = Map.get(message, unquote(field.name_atom))

      if !is_nil(value) do
        unquote(code)
      else
        raise "Missing required field: '#{unquote(field.name)}'"
      end
    end
  end

  defp gen_decode_field_code(%FieldProps{array?: true} = field) do
    code =
      case field.type do
        :bool ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              ByteBuffer.read_bool(byte_buffer)
            end
          end

        :byte ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              ByteBuffer.read_byte(byte_buffer)
            end
          end

        :int ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              ByteBuffer.read_var_int(byte_buffer)
            end
          end

        :uint ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              ByteBuffer.read_var_uint(byte_buffer)
            end
          end

        :float ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              ByteBuffer.read_var_float(byte_buffer)
            end
          end

        :string ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              ByteBuffer.read_string(byte_buffer)
            end
          end

        _ ->
          quote do
            for i <- 0..ByteBuffer.read_var_uint(byte_buffer), i > 0 do
              unquote(field.type).decode(byte_buffer)
            end
          end
      end

    quote do
      result = %{result | unquote(field.name_atom) => unquote(code)}
    end
  end

  defp gen_decode_field_code(%FieldProps{} = field) do
    code =
      case field.type do
        :bool ->
          quote(do: ByteBuffer.read_bool(byte_buffer))

        :byte ->
          quote(do: ByteBuffer.read_byte(byte_buffer))

        :int ->
          quote(do: ByteBuffer.read_var_int(byte_buffer))

        :uint ->
          quote(do: ByteBuffer.read_var_uint(byte_buffer))

        :float ->
          quote(do: ByteBuffer.read_var_float(byte_buffer))

        :string ->
          quote(do: ByteBuffer.read_string(byte_buffer))

        _ ->
          quote(do: unquote(field.type).decode(byte_buffer))
      end

    quote do
      result = %{result | unquote(field.name_atom) => unquote(code)}
    end
  end
end
