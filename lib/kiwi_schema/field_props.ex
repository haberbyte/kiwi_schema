defmodule KiwiSchema.FieldProps do
  @moduledoc false

  defstruct index: nil,
            name: nil,
            name_atom: nil,
            type: nil,
            array?: false,
            deprecated?: false
end
