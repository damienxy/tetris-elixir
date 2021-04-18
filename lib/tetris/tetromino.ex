defmodule Tetris.Tetromino do
  defstruct shape: :l, rotation: 0, location: {3, -4} 
  alias Tetris.{Point, Points}

  def new_random do
    new(shape: random_shape())
  end

  def right(tetro) do
    %{tetro | location: Point.right(tetro.location)}
  end

  def left(tetro) do
    %{tetro | location: Point.left(tetro.location)}
  end

  def down(tetro) do
    %{tetro | location: Point.down(tetro.location)}
  end

  def rotate(tetro) do
    %{tetro | rotation: rotate_degrees(tetro.rotation)}
  end

  def show(tetro) do
    tetro
    |> points
    |> Points.rotate(tetro.rotation, grid(tetro.shape))
    |> Points.move(tetro.location)
    |> Points.add_shape(tetro.shape)
  end

  def maybe_move(_old, new, true=_valid), do: new
  def maybe_move(old, _new, false=_valid), do: old

  defp new(options \\ []) do
    __struct__(options)
  end

  defp points(%{shape: :l}) do
    [
            {2,1},
            {2,2},
            {2,3},{3,3}

    ]
  end

  defp points(%{shape: :j}) do
    [
                  {3,1},
                  {3,2},
            {2,3},{3,3}
          
    ]
  end

  defp points(%{shape: :s}) do
    [
      
            {2,2},{3,2},
      {1,3},{2,3},
      
    ]
  end

  defp points(%{shape: :z}) do
    [
     
      {1,2},{2,2},
            {2,3},{3,3}
      
    ]
  end

   defp points(%{shape: :i}) do
    [

      {1,2},{2,2},{3,2},{4,2}


    ]
  end

  defp points(%{shape: :o}) do
    [

            {2,2},{3,2},
            {2,3},{3,3}

    ]
  end

  defp points(%{shape: :t}) do
    [
      
      {1,2},{2,2},{3,2},
            {2,3}
    ]
  end

  # defp defines private functions

  defp grid(shape) when shape in [:i, :o] do 5 end
  defp grid(shape), do: 4

  defp color(:l), do: "royalblue"
  defp color(:j), do: "limegreen"
  defp color(:s), do: "cyan"
  defp color(:z), do: "darkviolet"
  defp color(:o), do: "red"
  defp color(:i), do: "yellow"
  defp color(:t), do: "orange"

  defp random_shape do
    ~w[i t o l j z s]a
    |> Enum.random
  end

  defp rotate_degrees(270) do
    0
  end

  defp rotate_degrees(n) do 
    n + 90
  end
end