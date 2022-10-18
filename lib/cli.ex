defmodule ToyRobot.CLI do
  def main([path]) do
    ToyRobot.Simulation.read(path)
    |> ToyRobot.Simulation.execute()
  end

  def main(_) do
    IO.puts("Usage: robot file_name")
  end
end
