defmodule ToyRobot.CLI do
  def main(argv) do
    ToyRobot.read(Enum.at(argv, 0))
    |> ToyRobot.execute()
  end
end
