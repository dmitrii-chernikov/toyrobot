defmodule ToyRobot.Table do
  @enforce_keys [:x, :y]
  defstruct [x: nil, y: nil]

  def valid_coords?(table, x, y) do
    valid_x?(table, x) && valid_y?(table, y)
  end

  defp valid_x?(table, checkable) do
    valid?(table, checkable, :x)
  end

  defp valid_y?(table, checkable) do
    valid?(table, checkable, :y)
  end

  defp valid?(table, checkable, key) do
    size = Map.fetch!(table, key)

    cond do
      size <= 0 -> false
      checkable not in 0..(size - 1) -> false
      true -> true
    end
  end
end
