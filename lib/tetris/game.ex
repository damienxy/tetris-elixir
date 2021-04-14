defmodule Tetris.Game do
  defstruct [:tetro, points: [], score: 0, junkyard: %{}]
  alias Tetris.{Points, Tetromino}

  def new do
    __struct__()
    |> new_tetromino
  end

  def move_data(game, move_fn) do
    old = game.tetro
    new = game.tetro |> move_fn.()
    valid = new 
      |> Tetromino.show 
      |> Points.valid?

    {old, new, valid}
  end

  def move(game, move_fn) do
    {old, new, valid} = move_data(game, move_fn)
    moved = Tetromino.maybe_move(old, new, valid)
    %{game | tetro: moved}
    |> show
  end

    def down(game) do
    {old, new, valid} = move_data(game, &Tetromino.down/1)
    move_down_or_merge(game, old, new, valid)
  end

  def move_down_or_merge(game, _old, new, true=_valid) do
    %{game | tetro: new}
    |> show
  end
  def move_down_or_merge(game, old, _new, false=_valid) do
    game
    |> merge(old)
    |> new_tetromino
  end

  def merge(game, old) do
    game
  end

  def left(game), do: game |> move(&Tetromino.left/1) |> show
  
  def right(game), do: game |> move(&Tetromino.right/1) |> show

  def rotate(game), do: game |> move(&Tetromino.rotate/1) |> show

  def new_tetromino(game) do
    %{game | tetro: Tetromino.new_random()}
    |> show
  end

  def show(game) do
    %{game | points: Tetromino.show(game.tetro)}
  end

end