defmodule ToyRobot do
  def read(argv) do
    file_path =
      if argv, do: argv, else: ""

    File.read!(file_path)
    |> String.split("\r\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&valid_command?/1)
  end

  def execute(commands) do
    place_index =
      Enum.find_index(
        commands,
        &get_place_args/1
      )

    place_and_after =
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
      place_and_after,
      %{x: nil, y: nil, dir: nil},
      &process_command/2
    )
  end

  defp get_place_args(command) do
    if !String.starts_with?(command, "PLACE ") do
      nil
    else
      args =
        String.split(command, " ")
        |> List.last()
        |> String.split(",")

      x = parse_exact_integer(Enum.at(args, 0))
      y = parse_exact_integer(Enum.at(args, 1))
      dir = dir_to_value(Enum.at(args, 2))

      cond do
        !valid_coord?(x) -> nil
        !valid_coord?(y) -> nil
        !dir -> nil
        true -> {x, y, dir}
      end
    end
  end

  defp valid_command?(command) do
    args = get_place_args(command)

    cond do
      args -> true
      command == "MOVE" -> true
      command == "LEFT" -> true
      command == "RIGHT" -> true
      command == "REPORT" -> true
      true -> false
    end
  end

  defp process_command(command, robot) do
    args = get_place_args(command)

    cond do
      args -> place(args)
      command == "MOVE" -> move(robot)
      command == "LEFT" -> left(robot)
      command == "RIGHT" -> right(robot)
      command == "REPORT" -> report(robot)
      true -> robot
    end
  end

  defp place(args) do
    {x, y, dir} = args

    %{x: x, y: y, dir: dir}
  end

  defp move(robot) do
    # (0, 0) is the SOUTH WEST corner.
    # 0 is "NORTH", 1 is "EAST", 2 is "SOUTH"
    case robot[:dir] do
      0 -> set_coord(robot, :y, robot[:y] + 1)
      1 -> set_coord(robot, :x, robot[:x] + 1)
      2 -> set_coord(robot, :y, robot[:y] - 1)
      3 -> set_coord(robot, :x, robot[:x] - 1)
    end
  end

  defp left(robot) do
    current = robot[:dir]

    new =
      if current == 0, do: 3, else: current - 1

    Map.replace!(robot, :dir, new)
  end

  defp right(robot) do
    current = robot[:dir]

    new =
      if current == 3, do: 0, else: current + 1

    Map.replace!(robot, :dir, new)
  end

  defp report(robot) do
    msg = [
      "The robot is currently at",
      "(#{robot[:x]}, #{robot[:y]}) and it's",
      "facing #{value_to_dir(robot[:dir])}."
    ]

    IO.puts(Enum.join(msg, " "))
    robot
  end

  defp set_coord(robot, key, value) do
    if valid_coord?(value) do
      %{robot | key => value}
    else
      robot
    end
  end

  # TODO: use or remove
  """
  defp start_loop(robot) do
    fn_start = fn -> loop(robot) end
    {:ok, pid} = Task.start(fn_start)

    IO.puts("Server: started, #inspect(pid)}.")
    Process.register(pid, :server_loop)
    pid
  end

  defp loop(robot) do
    receive do
      {:place, args} ->
        loop(place(args))

      :move ->
        loop(move(robot))

      :left ->
        loop(left(robot))

      :right ->
        loop(right(robot))

      {:report} ->
        report(robot)
        loop(robot)
    end
  end
  """

  defp dir_to_value(convertible) do
    case convertible do
      "NORTH" -> 0
      "EAST" -> 1
      "SOUTH" -> 2
      "WEST" -> 3
      _ -> nil
    end
  end

  defp value_to_dir(convertible) do
    case convertible do
      0 -> "NORTH"
      1 -> "EAST"
      2 -> "SOUTH"
      3 -> "WEST"
      _ -> nil
    end
  end

  defp valid_coord?(coord) do
    if coord in 0..4, do: true, else: false
  end

  defp parse_exact_integer(parsable) do
    if !is_bitstring(parsable) do
      :error
    else
      case Integer.parse(parsable) do
        {value, ""} -> value
        _any -> :error
      end
    end
  end
end
