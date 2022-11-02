defmodule ToyRobot.CLI do
  def main([path]) do
    ToyRobot.TableState.start()

    ToyRobot.Simulation.read!(path)
    |> ToyRobot.Simulation.execute(:default)
  end

  def main(_) do
    IO.puts("Usage: robot file_name")
  end
end
