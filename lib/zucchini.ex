defmodule Zucchini do
  @moduledoc """
  Documentation for `Zucchini`.
  """

  @type queue_name :: String.t | atom | {:global, String.t | atom}
  @type task :: {atom, [arg :: term]}

end
