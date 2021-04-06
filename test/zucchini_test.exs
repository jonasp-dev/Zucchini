defmodule ZucchiniTest do
  use ExUnit.Case

  doctest Zucchini

  describe "Zucchini module functions:" do

    setup do
      Zucchini.start(:testQueue)
      [job: Zucchini.Job.create_job(Zucchini.ExampleWorker, :add, [2, 3])]
    end

    test "start/1 returns :ok on success" do
      assert :ok == Zucchini.start(:queue)
    end

    test "start/1 returns :error on failure" do
      assert :error == Zucchini.start(:testQueue)
    end

    test "start/2 starts the correct number of workers" do
      # UNIMPLEMENTED
      assert :ok == :ok
    end

    test "async/2 returns " do
      # UNIMPLEMENTED
      assert :ok == :ok
    end
  end

  describe "Job module functions:" do

    test "verify_task/3 returns true when function and arity exists" do
      assert true == Zucchini.Job.verify_task(__MODULE__, :test_function, 3)
      assert true == Zucchini.Job.verify_task(__MODULE__, :test_function, 2)
    end

    test "verify_task/3 returns false when function and arity exists" do
      assert false == Zucchini.Job.verify_task(__MODULE__, :test_function, 0)
      assert false == Zucchini.Job.verify_task(__MODULE__, :test_function, 0)
      assert false == Zucchini.Job.verify_task(__MODULE__, :noexistent_function, 3)
    end

    test "create_job/2 returns a job struct containing the correct task when existing function is passed in" do
      %Zucchini.Job{task: task} = Zucchini.Job.create_job(&__MODULE__.test_function/3, [0, 0, 0])
      %Zucchini.Job{task: task_with_2_args} = Zucchini.Job.create_job(&__MODULE__.test_function/3, [0, 0])
      assert {ZucchiniTest, :test_function, [0, 0, 0]} == task
      assert {ZucchiniTest, :test_function, [0, 0]} == task_with_2_args
    end

    test "create_job/2 returns an error atom on non existent function" do
      assert :error == Zucchini.Job.create_job(&__MODULE__.noexistent_function/3, [0, 0, 0])
    end

    test "create_job/2 returns an error atom on existing function but incorrect arity" do
      assert :error == Zucchini.Job.create_job(&__MODULE__.test_function/3, [0])
    end

    test "create_job/3 returns a job struct containing the correct task when existing function is passed in" do
      %Zucchini.Job{task: task} = Zucchini.Job.create_job(__MODULE__, :test_function, [0, 0, 0])
      %Zucchini.Job{task: task_with_2_args} = Zucchini.Job.create_job(__MODULE__, :test_function, [0, 0])
      assert {ZucchiniTest, :test_function, [0, 0, 0]} == task
      assert {ZucchiniTest, :test_function, [0, 0]} == task_with_2_args
    end

    test "create_job/3 returns an error atom on existing function but incorrect arity" do
      assert :error == Zucchini.Job.create_job(__MODULE__, :test_function, [0])
    end

    test "create_job/3 returns an error atom on non existent function" do
      assert :error == Zucchini.Job.create_job(__MODULE__, :noexistent_function, [0, 0, 0])
    end

  end

  def test_function(a, b, c \\ 2) do
    [a, b, c]
  end

end
