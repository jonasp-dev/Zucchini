defmodule ZucchiniTest do
  use ExUnit.Case
  doctest Zucchini

  test "greets the world" do
    assert Zucchini.hello() == :world
  end
end
