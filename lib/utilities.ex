defmodule ToyRobot.Utilities do
  def dir_to_value(convertible) do
    case convertible do
      "NORTH" -> 0
      "EAST" -> 1
      "SOUTH" -> 2
      "WEST" -> 3
      _ -> nil
    end
  end

  def value_to_dir(convertible) do
    case convertible do
      0 -> "NORTH"
      1 -> "EAST"
      2 -> "SOUTH"
      3 -> "WEST"
      _ -> nil
    end
  end

  def parse_exact_integer(parsable) do
    try do
      case Integer.parse(parsable) do
        {value, ""} -> value
        _ -> nil
      end
    rescue
      _ -> nil
    end
  end
end
