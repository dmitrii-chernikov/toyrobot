defmodule ToyRobot.Simulation do
  alias ToyRobot.{Robot, Table, Utilities}

  def read(path) do
    # TODO: use instead of File.Read!() or remove
    #File.stream!(path)
    #|> Stream.map(&String.trim/1)

    File.read!(path)
    |> String.split("\r\n")
    |> Enum.map(&String.trim/1)
  end

  def execute(commands, size_x \\ 5, size_y \\ 5) do
    # TODO: use with File.Stream!() or remove
    """
    table = %Table{x: size_x, y: size_y}
    robot = %Robot{x: nil, y: nil, dir: nil}

    fn_drop_while = fn line ->
      !get_place_args(line, table)
    end

    fn_scan = fn e, acc ->
      process_command(e, acc, table)
    end

    commands
    |> Stream.drop_while(fn_drop_while)
    |> Stream.scan(robot, fn_scan)
    |> Stream.run()
    """

    table = %Table{x: size_x, y: size_y}

    place_index =
      Enum.find_index(
        commands,
        fn e -> get_place_args(e, table) end
      )

    commands_place_and_after =
      unless place_index do
        []
      else
        Enum.slice(
          commands,
          place_index..Enum.count(commands)
        )
      end

    # TODO: are multiple valid placements allowed?
    Enum.reduce(
      commands_place_and_after,
      %Robot{x: nil, y: nil, dir: nil},
      fn e, acc -> process_command(e, acc, table) end
    )
  end

  defp get_place_args(command, table) do
    if !String.starts_with?(command, "PLACE ") do
      nil
    else
      args =
        String.split(command, " ")
        |> List.last()
        |> String.split(",")

      x = Utilities.parse_exact_integer(Enum.at(args, 0))
      y = Utilities.parse_exact_integer(Enum.at(args, 1))
      dir = Utilities.dir_to_value(Enum.at(args, 2))

      cond do
        !Table.valid_coords?(table, x, y) -> nil
        !dir -> nil
        true -> {x, y, dir}
      end
    end
  end

  defp process_command(command, robot, table) do
    args = get_place_args(command, table)

    cond do
      args ->
        {x, y, dir} = args

        Robot.place(x, y, dir)

      command == "MOVE" ->
        moved = Robot.move(robot)

        if Table.valid_coords?(table, moved.x, moved.y) do
          moved
        else
          robot
        end

      command == "REPORT" ->
        IO.puts(Robot.report(robot))
        robot

      command == "LEFT" -> Robot.left(robot)
      command == "RIGHT" -> Robot.right(robot)
      true -> robot
    end
  end
end
