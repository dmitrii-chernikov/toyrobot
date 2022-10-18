defmodule ToyRobot.Robot do
  alias ToyRobot.{Robot, Utilities}

  @enforce_keys [:x, :y, :dir]
  defstruct [x: nil, y: nil, dir: nil]

  def place(x, y, dir) do
    %Robot{x: x, y: y, dir: dir}
  end

  def move(robot) do
    # (0, 0) is the SOUTH WEST corner.
    # 0 is "NORTH", 1 is "EAST", 2 is "SOUTH"
    case robot.dir do
      0 -> %Robot{robot | y: robot.y + 1}
      1 -> %Robot{robot | x: robot.x + 1}
      2 -> %Robot{robot | y: robot.y - 1}
      3 -> %Robot{robot | x: robot.x - 1}
    end
  end

  def left(robot) do
    fn_left = fn dir ->
      if dir == 0, do: 3, else: dir - 1
    end

    turn(robot, fn_left)
  end

  def right(robot) do
    fn_right = fn dir ->
      if dir == 3, do: 0, else: dir + 1
    end

    turn(robot, fn_right)
  end

  def report(robot) do
    side = Utilities.value_to_dir(robot.dir)

    msg = [
      "The robot is currently at",
      "(#{robot.x}, #{robot.y}) and it's",
      "facing #{side}."
    ]

    Enum.join(msg, " ")
  end

  defp turn(robot, fn_turn) do
    %Robot{robot | dir: fn_turn.(robot.dir)}
  end
end
