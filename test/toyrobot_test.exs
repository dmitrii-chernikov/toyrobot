defmodule ToyRobot.Test do
  use ExUnit.Case

  setup do
    IO.puts("==========")
    :ok
  end

  test "reading a file" do
    proper = ToyRobot.read("assets/proper")

    proper_expected = [
      "PLACE 0,0,NORTH",
      "MOVE",
      "RIGHT",
      "MOVE",
      "LEFT",
      "MOVE",
      "REPORT"
    ]

    assert proper == proper_expected

    cleaned = ToyRobot.read("assets/commands")

    cleaned_expected = [
      "MOVE",
      "LEFT",
      "RIGHT",
      "PLACE 2,2,WEST",
      "RIGHT",
      "REPORT",
      "PLACE 4,4,NORTH",
      "REPORT"
    ]

    assert cleaned == cleaned_expected
  end

  test "invalid PLACE commands" do
    commands = [
      "PLACE 1,0,",
      "PLACE 5,0,NORTH",
      "PLACE 3,3",
      "PLACE 2, 0,EAST",
      "PLACE 2,2,WEST",
      "PLACE 2, 0,EAST",
      "PLACE 1,3, SOUTH",
      "PLACE 1 3 WEST",
      "REPORT"
    ]

    robot = ToyRobot.execute(commands)

    assert robot == %{x: 2, y: 2, dir: 3}
  end

  test "placing, turning, moving" do
    # any commands before placement are ignored
    commands = [
      "MOVE",
      "LEFT",
      "PLACE 2,2,WEST",
      "RIGHT",
      "RIGHT",
      "MOVE",
      "REPORT",
    ]

    robot = ToyRobot.execute(commands)

    assert robot == %{x: 3, y: 2, dir: 1}
  end

  test "no valid placement command" do
    no_place = [
      "LEFT",
      "MOVE",
      "RIGHT",
      "REPORT"
    ]

    misplaced = ToyRobot.execute(no_place)
    expected = %{x: nil, y: nil, dir: nil}

    assert misplaced == expected
  end

  test "spinning in both directions" do
    counter_cw = [
      "PLACE 2,2,NORTH",
      "LEFT",
      "REPORT",
      "LEFT",
      "LEFT",
      "LEFT",
      "REPORT"
    ]

    left = ToyRobot.execute(counter_cw)

    assert left == %{x: 2, y: 2, dir: 0}

    cw = [
      "PLACE 2,2,WEST",
      "RIGHT",
      "REPORT",
      "RIGHT",
      "RIGHT",
      "RIGHT",
      "REPORT"
    ]

    right = ToyRobot.execute(cw)

    assert right == %{x: 2, y: 2, dir: 3}
  end

  test "trying to move off the table" do
    commands = [
      # top left corner
      "PLACE 0,4,NORTH",
      "MOVE",
      "LEFT",
      "MOVE",
      "REPORT"
    ]

    robot = ToyRobot.execute(commands)

    assert robot == %{x: 0, y: 4, dir: 3}
  end
end
