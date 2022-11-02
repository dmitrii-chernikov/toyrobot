defmodule ToyRobot.Test do
  alias ToyRobot.{Robot, Simulation, TableState}
  use ExUnit.Case

  setup do
    IO.puts("==========")
    TableState.start()
    :ok
  end

  test "reading a file" do
    proper = Simulation.read!("assets/proper")

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
      "PLACE 0,1,2,EAST",
      "PLACE 2, 0,EAST",
      "PLACE 2d,2,WEST",
      "PLACE 2, 0,EAST",
      "PLACE 1,3, SOUTH",
      "PLACE 1 3 WEST",
      "place 4,4,WEST",
      "PLACE 4,4,west",
      "REPORT"
    ]

    Simulation.execute(commands, :bad_place)
    assert TableState.get(:bad_place) == nil
  end

  test "valid commands before placement" do
    # any commands before placement are ignored
    commands = [
      "MOVE",
      "LEFT",
      "REPORT",
      "PLACE 2,2,WEST",
      "RIGHT",
      "RIGHT",
      "MOVE",
      "REPORT"
    ]

    expected = %Robot{x: 3, y: 2, dir: 1}

    Simulation.execute(commands, :before)
    assert TableState.get(:before) == expected
  end

  test "valid and invalid commands" do
    commands = [
      "fjls",
      "  adkd",
      "",
      "  ",
      "111",
      "    MOVE",
      "  LEFT",
      "  PLACE 5,0,NORTH",
      "  Place 0,0,EAST",
      "RIGHT",
      "PLACE 2, 0,EAST",
      "PLACE 1,3, SOUTH",
      # valid placement command (after .trim())
      "  PLACE 2,2,WEST",
      "    RIGHT",
      "    REPORT",
      "PLACE 4,4,NORTH",
      "4321",
      "REPORT"
    ]

    expected = %Robot{x: 2, y: 2, dir: 0}

    Simulation.execute(commands, :and_bad)
    assert TableState.get(:and_bad) == expected
  end

  test "no valid placement command" do
    commands = [
      "LEFT",
      "MOVE",
      "RIGHT",
      "REPORT"
    ]

    Simulation.execute(commands, :no_placement)
    assert TableState.get(:no_placement) == nil
  end

  test "spinning in both directions" do
    commands = %{
      spin_left: [
        "PLACE 2,2,NORTH",
        "LEFT",
        "REPORT",
        "LEFT",
        "LEFT",
        "LEFT",
        "REPORT"
      ],
      spin_right: [
        "PLACE 1,1,WEST",
        "RIGHT",
        "REPORT",
        "RIGHT",
        "RIGHT",
        "RIGHT",
        "REPORT"
      ]
    }

    Enum.each(commands, &execute/1)

    results = %{
      spin_left: %Robot{x: 2, y: 2, dir: 0},
      spin_right: %Robot{x: 1, y: 1, dir: 3}
    }

    Enum.each(results, &assert_get/1)
  end

  test "trying to move off the table" do
    commands = %{
      # northwest
      nw: [
        "PLACE 0,4,NORTH",
        "MOVE",
        "LEFT",
        "MOVE",
        "REPORT"
      ],
      # southeast
      se: [
        "PLACE 4,0,SOUTH",
        "MOVE",
        "LEFT",
        "MOVE",
        "REPORT"
      ]
    }

    Enum.each(commands, &execute/1)

    results = %{
      nw: %Robot{x: 0, y: 4, dir: 3},
      se: %Robot{x: 4, y: 0, dir: 1}
    }

    Enum.each(results, &assert_get/1)
  end

  test "robots fall off when the table shrinks" do
    commands = %{
      top: ["PLACE 0,4,NORTH"],
      right: ["PLACE 4,0,EAST"]
    }

    Enum.each(commands, &execute/1)

    robot_top = %Robot{x: 0, y: 4, dir: 0}
    robot_right = %Robot{x: 4, y: 0, dir: 1}
    sizes = {{5, 5}, {5, 4}, {4, 4}}

    results = {
      {%{x: 5, y: 5}, robot_top, robot_right},
      {%{x: 5, y: 4}, nil, robot_right},
      {%{x: 4, y: 4}, nil, nil}
    }

    fn_each = fn index ->
      {x, y} = elem(sizes, index)
      {size, top, right} = elem(results, index)

      TableState.resize(x, y)
      assert TableState.dimensions() == size
      assert TableState.get(:top) == top
      assert TableState.get(:right) == right
    end

    Enum.each(0..2, fn_each)
  end

  test "invalid table dimensions" do
    commands = [
      # bottom left corner
      "PLACE 0,0,SOUTH",
      "REPORT"
    ]

    sizes = {{0, 1}, {4, 0}, {0, 0}}

    results = {
      {%{x: 0, y: 1}, :no_x, nil},
      {%{x: 4, y: 0}, :no_y, nil},
      {%{x: 0, y: 0}, :no_x_y, nil}
    }

    fn_each = fn index ->
      {x, y} = elem(sizes, index)
      {size, id, robot} = elem(results, index)

      TableState.resize(x, y)
      assert TableState.dimensions() == size
      Simulation.execute(commands, id)
      assert TableState.get(id) == robot
    end

    Enum.each(0..2, fn_each)
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

    sizes = {{1, 1}, {3, 1}, {6, 6}}
    one_tile = %Robot{x: 0, y: 0, dir: 1}
    three_tiles = %Robot{x: 2, y: 0, dir: 1}
    six_by_six = %Robot{x: 5, y: 0, dir: 1}

    results = {
      {%{x: 1, y: 1}, :one_tile, one_tile},
      {%{x: 3, y: 1}, :three_tiles, three_tiles},
      {%{x: 6, y: 6}, :six_by_six, six_by_six}
    }

    fn_each = fn index ->
      {x, y} = elem(sizes, index)
      {size, id, robot} = elem(results, index)

      TableState.resize(x, y)
      assert TableState.dimensions() == size
      Simulation.execute(commands, id)
      assert TableState.get(id) == robot
      TableState.remove(id)
    end

    Enum.each(0..2, fn_each)
  end

  test "sending N lists to the same robot" do
    lists = {
      ["PLACE 0,0,EAST", "MOVE"],
      ["LEFT", "MOVE"],
      ["MOVE", "REPORT"]
    }

    results = {
      %Robot{x: 1, y: 0, dir: 1},
      %Robot{x: 1, y: 1, dir: 0},
      %Robot{x: 1, y: 2, dir: 0}
    }

    fn_each = fn index ->
      commands = elem(lists, index)
      expected = elem(results, index)

      Simulation.execute(commands, :n_lists)
      assert TableState.get(:n_lists) == expected
    end

    Enum.each(0..2, fn_each)
  end

  defp assert_get({key, value}) do
    assert TableState.get(key) == value
  end

  defp execute({key, value}) do
    Simulation.execute(value, key)
  end
end
