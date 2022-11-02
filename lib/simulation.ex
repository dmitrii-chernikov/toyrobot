defmodule ToyRobot.Simulation do
  alias ToyRobot.{Utilities, TableState}

  def read!(path) do
    # TODO: use instead of File.Read!() or remove
    #File.stream!(path)

    File.read!(path)
    |> String.split("\r\n")
  end

  def execute(commands, id, delay \\ 0) do
    fn_each = fn e ->
      Process.sleep(delay)
      execute_command(String.trim(e), id)
    end

    Enum.each(commands, fn_each)
    # TODO: use with File.Stream!() or remove
    """
    commands
    |> Stream.map(&String.trim/1)
    |> Stream.each(fn_each)
    |> Stream.run()
    """
  end

  # does not check whether X and Y are out of bounds
  defp get_place_args(command) do
    args =
      String.split(command, " ")
      |> List.last()
      |> String.split(",")

    {
      Utilities.parse_exact_integer(Enum.at(args, 0)),
      Utilities.parse_exact_integer(Enum.at(args, 1)),
      Utilities.dir_to_value(Enum.at(args, 2))
    }
  end

  defp execute_command(command, id) do
    cond do
      String.starts_with?(command, "PLACE ") ->
        {x, y, dir} = get_place_args(command)

        TableState.place(id, x, y, dir)

      command == "MOVE" ->
        TableState.move(id)

      command == "REPORT" ->
        execute_command_report(id)

      command == "LEFT" ->
        TableState.left(id)

      command == "RIGHT" ->
        TableState.right(id)

      true ->
        nil
    end
  end

  defp execute_command_report(id) do
    robot = TableState.get(id)

    if robot do
      ToyRobot.Robot.report(robot, id)
    end
  end
end
