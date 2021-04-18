defmodule Tetris.Game do
  defstruct [:tetro, points: [], preview: [], score: 0, junkyard: %{}, game_over: false, pause: false]
  alias Tetris.{Points, Tetromino}

  def new do
    __struct__()
    |> new_tetromino
  end

  def down(game) do
    {old, new, valid} = move_data(game, &Tetromino.down/1)
    move_down_or_merge(game, old, new, valid)
  end

  def left(game), do: game |> move(&Tetromino.left/1) |> show
  
  def right(game), do: game |> move(&Tetromino.right/1) |> show

  def rotate(game), do: game |> move(&Tetromino.rotate/1) |> show

  def drop(game), do: game |> merge_and_next(game.preview)

  def toggle_pause(game), do: %{game | pause: !game.pause}

  def junkyard_points(game) do
    game.junkyard
    |> Enum.map(fn {{x, y}, shape} -> {x, y, shape} end)
  end

  defp move_data(game, move_fn) do
    old = game.tetro
    new = game.tetro |> move_fn.()
    valid = new 
      |> Tetromino.show 
      |> Points.valid?(game.junkyard)

    {old, new, valid}
  end

  defp move(game, move_fn) do
    {old, new, valid} = move_data(game, move_fn)
    moved = Tetromino.maybe_move(old, new, valid)
    %{game | tetro: moved}
    |> show
  end

  defp move_down_or_merge(game, _old, new, true=_valid) do
    %{game | tetro: new}
    |> show
  end
  defp move_down_or_merge(game, old, _new, false=_valid) do
    game
    |> merge_and_next(Tetromino.show(old))
  end

  defp merge_and_next(game, points) do
    game
    |> merge(points)
    |> new_tetromino
    |> check_game_over
  end

  defp merge(game, points) do
    new_junkyard =
      points
      |> Enum.map(fn {x, y, shape} -> {{x, y}, shape} end)
      |> Enum.into(game.junkyard)
    
    %{game | junkyard: new_junkyard}
    |> collapse_rows
  end

  defp collapse_rows(game) do
    rows = get_complete_rows(game)

    game 
    |> absorb(rows) 
    |> score_rows(rows)
  end

  defp get_complete_rows(game) do
    game.junkyard
    |> Map.keys
    |> Enum.group_by(&elem(&1, 1))
    |> Enum.filter(fn {_y, list} -> length(list) == 10 end)
    |> Enum.map(fn {y, _list} -> y end)
  end

  defp absorb(game, []), do: game
  defp absorb(game, [y|ys]), do: remove_row(game, y) |> absorb(ys)

  defp remove_row(game, row) do
    new_junkyard = 
      game.junkyard
      |> Enum.reject(fn {{_x, y}, _shape} -> y == row end)
      |> Enum.map(fn {{x, y}, shape} -> {{x, maybe_move_y(y, row)}, shape} end)
      |> Map.new
    
    %{game | junkyard: new_junkyard}
  end

  defp maybe_move_y(y, row) when y < row, do: y + 1
  defp maybe_move_y(y, _row), do: y

  defp score_rows(game, rows) do
    new_score =
      :math.pow(length(rows), 2) 
      |> round 
      |> Kernel.*(100)

    increment_score(game, new_score)
  end

  defp new_tetromino(game) do
    %{game | tetro: Tetromino.new_random()}
    |> show
  end

  defp show(game) do
    new_points = Tetromino.show(game.tetro)
    %{game | 
      points: new_points, 
      preview: add_preview(game, new_points)}
  end

  defp add_preview(game, points) do
    find_lowest_preview(game, points)
  end
  
  defp find_lowest_preview(game, points) do
    {moved_down, valid} = move_one_down(game, points)

    if !valid do
      points
    else
      shape = points |> Points.get_shape
      new_points = moved_down |> Points.add_shape(shape)
      find_lowest_preview(game, new_points)
    end
  end

  defp move_one_down(game, points) do
    moved_down = points |> Points.move_one_down
    valid = moved_down |> Points.valid?(game.junkyard)

    {moved_down, valid}
  end

  defp increment_score(game, value) do
    %{game | score: game.score + value}
  end

  defp check_game_over(game) do
    continue_game =
      game.tetro
      |> Tetromino.show
      |> Points.valid?(game.junkyard)

    %{game | game_over: !continue_game}
  end
end