# KiwiSchema

This is an Elixir implementation of the [Kiwi Message Format](https://github.com/evanw/kiwi/).

Define the schema by using the KiwiSchema module:

```elixir
defmodule MySchema do
  defmodule Message do
    use KiwiSchema, type: :message

    field(:num, 1, type: :uint)
    field(:points, 2, array: true, type: Point)
    field(:zoom, 3, type: :float)
  end

  defmodule Point do
    use KiwiSchema, type: :struct

    field(:x, type: :float)
    field(:y, type: :float)
  end
end
```

Encoding and decoding now works like this:

```elixir
# encode the input
input = %{num: 123, points: [%{x: 123.45}, y: 3.1, %{x: 0, y: 0.34}]}
buffer = KiwiSchema.encode(MySchema.Message.new(input))

KiwiSchema.ByteBuffer.data(buffer) # <<1, ...>>

# decode binary data
data = <<1, 4, ....>>
message = KiwiSchema.decode(MySchema.Message, KiwiSchema.ByteBuffer.new(data))
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kiwi_schema` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kiwi_schema, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/kiwi_schema>.

