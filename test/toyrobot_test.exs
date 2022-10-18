defmodule ToyRobot.Test do
  alias ToyRobot.{Robot, Simulation}
  use ExUnit.Case

  setup do
    IO.puts("==========")
    :ok
  end

  test "reading a file" do
    proper = Simulation.read("assets/proper")

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
  end

  test "invalid PLACE commands" do
    commands = [
      "PLACE A,0,C",
      "PLACE 3,3,ASDF",
      "PLACE 1,B,WEST",
      "PLACE 1,0,",
      "PLACE 5,0,NORTH",
      "PLACE 3,3",
      "PLACE 2, 0,EAST",
      "PLACE 2,2,WEST",
      "PLACE 2, 0,EAST",
      "PLACE 1,3, SOUTH",
      "PLACE 1 3 WEST",
      "place 4,4,WEST",
      "PLACE 4,4,west",
      "REPORT"
    ]

    robot = Simulation.execute(commands)

    assert robot == %Robot{x: 2, y: 2, dir: 3}
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
      "REPORT"
    ]

    robot = Simulation.execute(commands)

    assert robot == %Robot{x: 3, y: 2, dir: 1}
  end

  test "no valid placement command" do
    no_place = [
      "LEFT",
      "MOVE",
      "RIGHT",
      "REPORT"
    ]

    misplaced = Simulation.execute(no_place)
    expected = %Robot{x: nil, y: nil, dir: nil}

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

    left = Simulation.execute(counter_cw)

    assert left == %Robot{x: 2, y: 2, dir: 0}

    cw = [
      "PLACE 2,2,WEST",
      "RIGHT",
      "REPORT",
      "RIGHT",
      "RIGHT",
      "RIGHT",
      "REPORT"
    ]

    right = Simulation.execute(cw)

    assert right == %Robot{x: 2, y: 2, dir: 3}
  end

  test "trying to move off the table" do
    top_left =
      Simulation.execute([
        "PLACE 0,4,NORTH",
        "MOVE",
        "LEFT",
        "MOVE",
        "REPORT"
      ])

    assert top_left == %Robot{x: 0, y: 4, dir: 3}

    bottom_right =
      Simulation.execute([
        "PLACE 4,0,SOUTH",
        "MOVE",
        "LEFT",
        "MOVE",
        "REPORT"
      ])

    assert bottom_right == %Robot{x: 4, y: 0, dir: 1}
  end

  test "invalid table dimensions" do
    commands = [
      # bottom left corner
      "PLACE 0,0,SOUTH",
      "REPORT"
    ]

    no_robot = %Robot{x: nil, y: nil, dir: nil}
    no_x = Simulation.execute(commands, 0, 1)

    assert no_x == no_robot

    no_y = Simulation.execute(commands, 4, -2)

    assert no_y == no_robot

    no_both = Simulation.execute(commands, 0, -2)

    assert no_both == no_robot
  end

  test "other board sizes" do
    commands = [
      # bottom left corner
      "PLACE 0,0,EAST",
      "MOVE",
      "MOVE",
      "MOVE",
      "MOVE",
      "MOVE",
      "REPORT"
    ]

    one_by_one = Simulation.execute(commands, 1, 1)

    assert one_by_one == %Robot{x: 0, y: 0, dir: 1}

    rect = Simulation.execute(commands, 3, 1)

    assert rect == %Robot{x: 2, y: 0, dir: 1}

    six_by_six = Simulation.execute(commands, 6, 6)

    assert six_by_six == %Robot{x: 5, y: 0, dir: 1}
  end
end
