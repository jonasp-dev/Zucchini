defmodule ZucchiniTest do
  use ExUnit.Case
  alias Zucchini.{Job,Queue}

  doctest Zucchini

  test "initialize queue and enqueue something" do
    Zucchini.Queues.start_queue(%{name: "testqueue"})
    
    assert :ok == :ok
  end
end
