defmodule KiwiSchema.DSL do
  @doc """
  Define a field in the message module.
  """
  defmacro field(name, index, options \\ []) do
    quote do
      @fields {unquote(name), unquote(index), unquote(options)}
    end
  end

  alias KiwiSchema.{MessageProps, FieldProps}

  # Registered as the @before_compile callback for modules that call "use KiwiSchema".
  defmacro __before_compile__(env) do
    fields = Module.get_attribute(env.module, :fields)
    options = Module.get_attribute(env.module, :options)

    unless Enum.member?([:enum, :struct, :message], options[:type]) do
      raise "Unknown type '#{options[:type]}' for #{env.module}"
    end

    msg_props = generate_message_props(env.module, fields, options)

    quote do
      alias KiwiSchema.ByteBuffer

      unquote(gen_defstruct(msg_props))
      unquote(KiwiSchema.DSL.Enum.quoted_enum_functions(msg_props))
      unquote(KiwiSchema.DSL.Struct.quoted_struct_functions(msg_props))
      unquote(KiwiSchema.DSL.Message.quoted_message_functions(msg_props))
    end
  end

  defp generate_message_props(module, fields, options) do
    name = Atom.to_string(module) |> String.split(".") |> List.last()
    type = Keyword.get(options, :type)

    field_props =
      case type do
        :enum ->
          fields
          |> Enum.reverse()
          |> Enum.map(fn
            {name, index, opts} ->
              field_props(name, index, opts)
          end)

        :struct ->
          fields
          |> Enum.reverse()
          |> Enum.with_index(1)
          |> Enum.map(fn
            {{name, opts, _}, index} ->
              field_props(name, index, opts)
          end)

        :message ->
          fields
          |> Enum.reverse()
          |> Enum.map(fn
            {name, index, opts} ->
              field_props(name, index, opts)
          end)
      end

    %MessageProps{name: name, type: type, field_props: field_props}
  end

  defp field_props(name, index, opts) do
    %FieldProps{
      index: index,
      name: Atom.to_string(name),
      name_atom: name,
      type: Keyword.get(opts, :type),
      array?: Keyword.get(opts, :array) == true
    }
  end

  defp gen_defstruct(%MessageProps{} = message_props) do
    struct_opts =
      for prop <- message_props.field_props,
          do: {prop.name_atom, nil}

    quote do
      defstruct unquote(Macro.escape(struct_opts))
    end
  end
end
