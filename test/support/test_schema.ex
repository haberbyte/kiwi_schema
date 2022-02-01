defmodule TestSchema do
  defmodule Enum do
    use KiwiSchema, type: :enum

    field(:A, 100)
    field(:B, 200)
  end

  defmodule EnumStruct do
    use KiwiSchema, type: :struct

    field(:x, type: Enum)
    field(:y, array: true, type: Enum)
  end

  defmodule BoolStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :bool)
  end

  defmodule ByteStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :byte)
  end

  defmodule IntStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :int)
  end

  defmodule UintStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :uint)
  end

  defmodule FloatStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :float)
  end

  defmodule StringStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :string)
  end

  defmodule CompoundStruct do
    use KiwiSchema, type: :struct

    field(:x, type: :uint)
    field(:y, type: :uint)
  end

  defmodule NestedStruct do
    use KiwiSchema, type: :struct

    field(:a, type: :uint)
    field(:b, type: CompoundStruct)
    field(:c, type: :uint)
  end

  defmodule BoolArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :bool)
  end

  defmodule ByteArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :byte)
  end

  defmodule IntArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :int)
  end

  defmodule UintArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :uint)
  end

  defmodule FloatArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :float)
  end

  defmodule StringArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :string)
  end

  defmodule CompoundArrayStruct do
    use KiwiSchema, type: :struct

    field(:x, array: true, type: :uint)
    field(:y, array: true, type: :uint)
  end

  defmodule BoolMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :bool)
  end

  defmodule ByteMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :byte)
  end

  defmodule IntMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :int)
  end

  defmodule UintMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :uint)
  end

  defmodule FloatMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :float)
  end

  defmodule StringMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :string)
  end

  defmodule CompoundMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: :uint)
    field(:y, 2, type: :uint)
  end

  defmodule NestedMessage do
    use KiwiSchema, type: :message

    field(:a, 1, type: :uint)
    field(:b, 2, type: CompoundMessage)
    field(:c, 3, type: :uint)
  end

  defmodule BoolArrayMessage do
    use KiwiSchema, type: :message

    field(:x, 1, array: true, type: :bool)
  end

  defmodule RecursiveMessage do
    use KiwiSchema, type: :message

    field(:x, 1, type: RecursiveMessage)
  end
end
