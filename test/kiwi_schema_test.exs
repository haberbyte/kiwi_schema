defmodule KiwiSchemaTest do
  use ExUnit.Case

  alias KiwiSchema.ByteBuffer

  describe "enums" do
    test "defines value lookup by key functions" do
      assert TestSchema.Enum.value(:A) == 100
      assert TestSchema.Enum.value(:B) == 200

      assert TestSchema.Enum.value("A") == 100
      assert TestSchema.Enum.value("B") == 200
    end

    test "defines key lookup by value functions" do
      assert TestSchema.Enum.key(100) == "A"
      assert TestSchema.Enum.key(200) == "B"
    end
  end

  describe "struct enum" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.EnumStruct.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.EnumStruct, ByteBuffer.new(output))
        assert decoded == TestSchema.EnumStruct.new(input)
      end

      check.(%{x: "A", y: ["A"]}, <<100, 1, 100>>)
      check.(%{x: "B", y: ["B", "A"]}, <<200, 1, 2, 200, 1, 100>>)
    end
  end

  describe "struct bool" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.BoolStruct.new(x: input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.BoolStruct, ByteBuffer.new(output))
        assert decoded == %TestSchema.BoolStruct{x: input}
      end

      check.(false, <<0>>)
      check.(true, <<1>>)
    end
  end

  describe "struct byte" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.ByteStruct.new(x: input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.ByteStruct, ByteBuffer.new(output))
        assert decoded == %TestSchema.ByteStruct{x: input}
      end

      check.(0x00, <<0x00>>)
      check.(0x01, <<0x01>>)
      check.(0x7F, <<0x7F>>)
      check.(0x80, <<0x80>>)
      check.(0xFF, <<0xFF>>)
    end
  end

  describe "struct uint" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.UintStruct.new(x: input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.UintStruct, ByteBuffer.new(output))
        assert decoded == %TestSchema.UintStruct{x: input}
      end

      check.(0x00, <<0x00>>)
      check.(0x01, <<0x01>>)
      check.(0x7F, <<0x7F>>)
      check.(0x80, <<0x80, 0x01>>)
      check.(0x81, <<0x81, 0x01>>)
      check.(0x100, <<0x80, 0x02>>)
      check.(0x101, <<0x81, 0x02>>)
      check.(0x17F, <<0xFF, 0x02>>)
      check.(0x180, <<0x80, 0x03>>)
      check.(0x1FF, <<0xFF, 0x03>>)
      check.(0x200, <<0x80, 0x04>>)
      check.(0x7FFF, <<0xFF, 0xFF, 0x01>>)
      check.(0x8000, <<0x80, 0x80, 0x02>>)
      check.(0x7FFFFFFF, <<0xFF, 0xFF, 0xFF, 0xFF, 0x07>>)
      check.(0x80000000, <<0x80, 0x80, 0x80, 0x80, 0x08>>)
    end
  end

  describe "struct int" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.IntStruct.new(x: input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.IntStruct, ByteBuffer.new(output))
        assert decoded == %TestSchema.IntStruct{x: input}
      end

      check.(0x00, <<0x00>>)
      check.(-0x01, <<0x01>>)
      check.(0x01, <<0x02>>)
      check.(-0x02, <<0x03>>)
      check.(0x02, <<0x04>>)
      check.(-0x3F, <<0x7D>>)
      check.(0x3F, <<0x7E>>)
      check.(-0x40, <<0x7F>>)
      check.(0x40, <<0x80, 0x01>>)
      check.(-0x3FFF, <<0xFD, 0xFF, 0x01>>)
      check.(0x3FFF, <<0xFE, 0xFF, 0x01>>)
      check.(-0x4000, <<0xFF, 0xFF, 0x01>>)
      check.(0x4000, <<0x80, 0x80, 0x02>>)
      check.(-0x3FFFFFFF, <<0xFD, 0xFF, 0xFF, 0xFF, 0x07>>)
      check.(0x3FFFFFFF, <<0xFE, 0xFF, 0xFF, 0xFF, 0x07>>)
      check.(-0x40000000, <<0xFF, 0xFF, 0xFF, 0xFF, 0x07>>)
      check.(0x40000000, <<0x80, 0x80, 0x80, 0x80, 0x08>>)
      check.(-0x7FFFFFFF, <<0xFD, 0xFF, 0xFF, 0xFF, 0x0F>>)
      check.(0x7FFFFFFF, <<0xFE, 0xFF, 0xFF, 0xFF, 0x0F>>)
      check.(-0x80000000, <<0xFF, 0xFF, 0xFF, 0xFF, 0x0F>>)
    end
  end

  describe "struct float" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.FloatStruct.new(x: input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.FloatStruct, ByteBuffer.new(output))
        assert decoded == %TestSchema.FloatStruct{x: input}
      end

      check.(0, <<0>>)
      check.(1, <<127, 0, 0, 0>>)
      check.(-1, <<127, 1, 0, 0>>)
      check.(3.1415927410125732, <<128, 182, 31, 146>>)
      check.(-3.1415927410125732, <<128, 183, 31, 146>>)
      # check.(Infinity, <<255, 0, 0, 0>>)
      # check.(-Infinity, <<255, 1, 0, 0>>)
      # check.(NaN, <<255, 0, 0, 128>>)
    end
  end

  describe "struct string" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.StringStruct.new(x: input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.StringStruct, ByteBuffer.new(output))
        assert decoded == %TestSchema.StringStruct{x: input}
      end

      check.("", <<0>>)
      check.("abc", <<97, 98, 99, 0>>)
      check.("🙉🙈🙊", <<240, 159, 153, 137, 240, 159, 153, 136, 240, 159, 153, 138, 0>>)
    end
  end

  describe "struct compound" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.CompoundStruct.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.CompoundStruct, ByteBuffer.new(output))
        assert decoded == TestSchema.CompoundStruct.new(input)
      end

      check.(%{x: 0, y: 0}, <<0, 0>>)
      check.(%{x: 1, y: 2}, <<1, 2>>)
      check.(%{x: 12345, y: 54321}, <<185, 96, 177, 168, 3>>)
    end
  end

  describe "struct nested" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.NestedStruct.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.NestedStruct, ByteBuffer.new(output))
        assert decoded == TestSchema.NestedStruct.new(input)
      end

      check.(%{a: 0, b: %TestSchema.CompoundStruct{x: 0, y: 0}, c: 0}, <<0, 0, 0, 0>>)
      check.(%{a: 1, b: %TestSchema.CompoundStruct{x: 2, y: 3}, c: 4}, <<1, 2, 3, 4>>)

      check.(
        %{a: 534, b: %TestSchema.CompoundStruct{x: 12345, y: 54321}, c: 321},
        <<150, 4, 185, 96, 177, 168, 3, 193, 2>>
      )
    end
  end

  describe "struct byte array" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.ByteArrayStruct.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.ByteArrayStruct, ByteBuffer.new(output))
        assert decoded == TestSchema.ByteArrayStruct.new(input)
      end

      check.(%{x: []}, <<0>>)
      check.(%{x: [4, 5, 6]}, <<3, 4, 5, 6>>)
    end
  end

  describe "struct bool array" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.BoolArrayStruct.new(%{x: input}))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.BoolArrayStruct, ByteBuffer.new(output))
        assert decoded == TestSchema.BoolArrayStruct.new(%{x: input})
      end

      check.([], <<0>>)
      check.([true, false], <<2, 1, 0>>)
    end
  end

  # TODO: float array, uint array, etc.

  describe "message bool" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.BoolMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.BoolMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.BoolMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: false}, <<1, 0, 0>>)
      check.(%{x: true}, <<1, 1, 0>>)
    end
  end

  describe "message int" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.IntMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.IntMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.IntMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: 12_345_678}, <<1, 156, 133, 227, 11, 0>>)
    end
  end

  describe "message uint" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.UintMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.UintMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.UintMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: 12_345_678}, <<1, 206, 194, 241, 5, 0>>)
    end
  end

  describe "message float" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.FloatMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.FloatMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.FloatMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: 3.1415927410125732}, <<1, 128, 182, 31, 146, 0>>)
    end
  end

  describe "message string" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.StringMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.StringMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.StringMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: ""}, <<1, 0, 0>>)
      check.(%{x: "🙉🙈🙊"}, <<1, 240, 159, 153, 137, 240, 159, 153, 136, 240, 159, 153, 138, 0, 0>>)
    end
  end

  describe "message compound" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.CompoundMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.CompoundMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.CompoundMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: 123}, <<1, 123, 0>>)
      check.(%{y: 234}, <<2, 234, 1, 0>>)
      check.(%{x: 123, y: 234}, <<1, 123, 2, 234, 1, 0>>)
      check.(%{y: 234, x: 123}, <<1, 123, 2, 234, 1, 0>>)
    end
  end

  describe "message nested" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.NestedMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.NestedMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.NestedMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{a: 123, c: 234}, <<1, 123, 3, 234, 1, 0>>)
      check.(%{b: %TestSchema.CompoundMessage{x: 5, y: 6}}, <<2, 1, 5, 2, 6, 0, 0>>)
      check.(%{b: %TestSchema.CompoundMessage{x: 5}, c: 123}, <<2, 1, 5, 0, 3, 123, 0>>)

      check.(
        %{c: 123, b: %TestSchema.CompoundMessage{x: 5, y: 6}, a: 234},
        <<1, 234, 1, 2, 1, 5, 2, 6, 0, 3, 123, 0>>
      )
    end
  end

  describe "message bool array" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.BoolArrayMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.BoolArrayMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.BoolArrayMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: []}, <<1, 0, 0>>)
      check.(%{x: [true, false]}, <<1, 2, 1, 0, 0>>)
    end
  end

  describe "recursive message" do
    test "encode/decode" do
      check = fn input, output ->
        encoded = KiwiSchema.encode(TestSchema.RecursiveMessage.new(input))
        assert ByteBuffer.data(encoded) == output

        decoded = KiwiSchema.decode(TestSchema.RecursiveMessage, ByteBuffer.new(output))
        assert decoded == TestSchema.RecursiveMessage.new(input)
      end

      check.(%{}, <<0>>)
      check.(%{x: %TestSchema.RecursiveMessage{}}, <<1, 0, 0>>)

      check.(
        %{x: %TestSchema.RecursiveMessage{x: %TestSchema.RecursiveMessage{}}},
        <<1, 1, 0, 0, 0>>
      )
    end
  end
end
