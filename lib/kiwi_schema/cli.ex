defmodule KiwiSchema.CLI do
  alias KiwiSchema.{ByteBuffer, FieldProps, MessageProps}

  def main([] = _args) do
    {:ok, bin} = File.read("mapasm.bkiwi")

    buffer = ByteBuffer.new(bin)
    definition_count = ByteBuffer.read_var_uint(buffer)

    definitions =
      for i <- 0..definition_count, i > 0 do
        name = ByteBuffer.read_string(buffer)
        kind = ByteBuffer.read_byte(buffer)
        field_count = ByteBuffer.read_var_uint(buffer)

        field_props =
          for i <- 0..field_count, i > 0 do
            name = ByteBuffer.read_string(buffer)

            %FieldProps{
              name: name,
              name_atom: String.to_atom(name),
              type: ByteBuffer.read_var_int(buffer),
              array?: ByteBuffer.read_bool(buffer),
              index: ByteBuffer.read_var_uint(buffer)
            }
          end

        %MessageProps{type: kind_to_atom(kind), name: name, field_props: field_props}
      end

    custom_types =
      definitions
      |> Enum.with_index(0)
      |> Enum.reduce(%{}, fn {definition, type_id}, acc ->
        Map.put(acc, type_id, definition.name)
      end)

    Enum.each(definitions, fn definition ->
      IO.puts("defmodule #{definition.name} do")
      IO.puts("  use KiwiSchema, type: :#{definition.type}")
      IO.puts("")

      Enum.each(definition.field_props, fn field_props ->
        cond do
          definition.type == :enum ->
            IO.puts("  field(:#{field_props.name}, #{field_props.index})")

          definition.type == :message && field_props.array? == true ->
            IO.puts(
              "  field(:#{field_props.name}, #{field_props.index}, array: true, type: #{type_to_arg(field_props.type, custom_types)})"
            )

          definition.type == :message ->
            IO.puts(
              "  field(:#{field_props.name}, #{field_props.index}, type: #{type_to_arg(field_props.type, custom_types)})"
            )

          field_props.array? == true ->
            IO.puts(
              "  field(:#{field_props.name}, array: true, type: #{type_to_arg(field_props.type, custom_types)})"
            )

          true ->
            IO.puts(
              "  field(:#{field_props.name}, type: #{type_to_arg(field_props.type, custom_types)})"
            )
        end
      end)

      IO.puts("end")
      IO.puts("")
    end)
  end

  defp kind_to_atom(kind) do
    case kind do
      0 -> :enum
      1 -> :struct
      2 -> :message
      _ -> raise("Unknown kind: #{inspect(kind)}")
    end
  end

  defp type_to_arg(type, custom_types) do
    case type do
      -1 -> ":bool"
      -2 -> ":byte"
      -3 -> ":int"
      -4 -> ":uint"
      -5 -> ":float"
      -6 -> ":string"
      type_id -> type_id_to_name(type_id, custom_types)
    end
  end

  defp type_id_to_name(type_id, custom_types) do
    name = custom_types[type_id]

    if is_nil(name) do
      raise("Unknown type: #{inspect(type_id)}")
    else
      name
    end
  end
end
