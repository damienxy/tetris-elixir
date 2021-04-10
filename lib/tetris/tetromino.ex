defmodule Tetris.Tetromino do
  # structure definition
  # returns a Map with some restrictions (e.g. enforcing keys)
  defstruct shape: :l, rotation: 0, location: {3, 0} 

  # aliasing Tetris.Point and Tetris.Points so they can be referred to as `Point`
  alias Tetris.{Point, Points}

  # struct so that you can call `new` on the module instead of __struct__
  def new(options \\ []) do
    __struct__(options)
  end

  # returns a tetromino with a random shape, but with default location and rotation
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
    |> Points.move(tetro.location)
  end

  def points(%{shape: :l} = tetro) do
    [
            {2,1},
            {2,2},
            {2,3},{3,3}
    ]
  end

  def points(%{shape: :j} = tetro) do
    [
                  {3,1},
                  {3,2},
            {2,3},{3,3}
          
    ]
  end

  def points(%{shape: :s} = tetro) do
    [
      
            {2,2},{3,2},
      {1,3},{2,3},
      
    ]
  end

  def points(%{shape: :z} = tetro) do
    [
     
      {1,2},{2,2},
            {2,3},{3,3}
      
    ]
  end

   def points(%{shape: :i} = tetro) do
    [
            {2,1},
            {2,2},
            {2,3},
            {2,4}
    ]
  end

  def points(%{shape: :o} = tetro) do
    [

            {2,2},{3,2},
            {2,3},{3,3}

    ]
  end

  def points(%{shape: :t} = tetro) do
    [
      
      {1,2},{2,2},{3,2},
            {2,3}
    ]
  end

  # def points(%{shape} = tetro) do
  #   [
  #     {1,1},{2,1},{3,1},{4,1}
  #     {1,2},{2,2},{3,2},{4,2}
  #     {1,3},{2,3},{3,3},{4,3}
  #     {1,4},{2,4},{3,3},{4,4}
  #   ]
  # end

  # defp defines private functions

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