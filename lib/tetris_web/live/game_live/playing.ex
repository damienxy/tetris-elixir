defmodule TetrisWeb.GameLive.Playing do
  use TetrisWeb, :live_view
  alias Tetris.Game

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(500, :tick)
    end

    socket = 
      socket 
      |> new_game
      |> add_highscore

    {:ok, socket}
  end

  # width and height of the svg are calculated by assuming that 
  # the board will have 10 columns and 20 rows
  defp render_board(assigns) do
    tetromino_size = 30
    ~L"""
    <svg width="<%= 10 * tetromino_size %>" height="<%= 20 * tetromino_size %>">
      <rect width="<%= 10 * tetromino_size %>" height="<%= 20 * tetromino_size %>" style="fill:#121212;" />
      <%= render_points(assigns, tetromino_size) %>
      <%= render_preview(assigns, tetromino_size) %>
    </svg>
    """
  end

  defp render_preview(assigns, size) do
    ~L"""
    <%= for {x, y, shape} <- @game.preview do %>
      <rect
        width="<%= size %>" height="<%= size %>"
        x="<%= (x - 1) * size %>"
        y="<%= (y - 1) * size %>"
        style="fill:grey;"
        stroke="black"
        opacity="0.3"
      />
    <% end %>
    """
  end

  defp render_points(assigns, size) do
    ~L"""
    <%= for {x, y, shape} <- @game.points ++ Game.junkyard_points(@game) do %>
      <rect
        width="<%= size %>" height="<%= size %>"
        x="<%= (x - 1) * size %>"
        y="<%= (y - 1) * size %>"
        style="fill:<%= color(shape) %>;"
        stroke="black"
      />
      <polyline
        opacity="0.1"
        points="
          <%= ((x - 1) * size + 1) %>,<%= ((y - 1) * size + 1) %> 
          <%= ((x - 1) * size + size)%>,<%= ((y - 1) * size + 1) %> 
          <%= ((x - 1) * size + size)%>,<%= ((y - 1) * size + size) %>
        "
      />
    <% end %>
    """
  end

  defp render_game_over(assigns) do
    ~L"""
    <%= if @game.game_over do %>
      <div class="tetris-overlay">
        <div class="tetris-game-over-heading">Game over!</div>
        <button class="tetris-play-button" phx-click="restart">Play again</button>
      </div>
    <% end %>
    """
  end

  defp render_pause(assigns) do
    ~L"""
    <%= if @game.pause do %>
      <div class="tetris-overlay">
        <div class="tetris-pause-heading">Paused</div>
      </div>
    <% end %>
    """
  end

  defp render_highscore(assigns) do
    ~L"""
      <table>
        <tr><th class="tetris-th">Highscore</th></tr>
        <%= for score <- @highscore do %>
          <tr><td class="tetris-td"><%= score %></td></tr>
        <% end %>
      </table>
    """
  end

  defp color(:l), do: "royalblue"
  defp color(:j), do: "limegreen"
  defp color(:s), do: "cyan"
  defp color(:z), do: "darkviolet"
  defp color(:o), do: "red"
  defp color(:i), do: "yellow"
  defp color(:t), do: "orange"
  
  defp new_game(socket) do
    assign(socket, game: Game.new())
  end

  defp add_highscore(socket) do
    assign(socket, highscore: [])
  end

  def rotate(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.rotate(game))
  end

  def left(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.left(game))
  end

  def right(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.right(game))
  end

  def down(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.down(game))
  end

  def drop(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.drop(game))
  end

  def move_down(socket, move_fn) do
    socket
    |> move_fn.()
    |> maybe_update_highscore
  end

  def toggle_pause(%{assigns: %{game: %{game_over: true}}} = socket), do: socket
  def toggle_pause(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.toggle_pause(game))
  end

  defp maybe_update_highscore(%{assigns: %{game: game}} = socket) do
    cond do
      game.game_over == false -> socket
      game.score == 0 -> socket
      true -> update_highscore(socket)
    end
  end

  defp update_highscore(%{assigns: %{game: game}} = socket) do
    socket 
    |> push_event("updateHighscore", %{score: game.score})
  end

  def handle_info(:tick, %{assigns: %{game: game}} = socket)
    when game.game_over == true
    when game.pause == true,
    do: {:noreply, socket}
  
  def handle_info(:tick, socket) do
    {:noreply, socket |> move_down(&down/1)} 
  end

  def handle_event("restart", _, socket) do
    {:noreply, socket |> new_game}
  end

  def handle_event("pause", _, socket) do
    {:noreply, socket |> toggle_pause}
  end

  def handle_event("keystroke", _, %{assigns: %{game: game}} = socket)
    when game.game_over == true
    when game.pause == true,
    do: {:noreply, socket}

  def handle_event("keystroke", %{"key" => "ArrowDown"}, socket) do
    {:noreply, socket |> move_down(&down/1)}
  end
  def handle_event("keystroke", %{"key" => "ArrowUp"}, socket) do
    {:noreply, socket |> rotate}
  end
  def handle_event("keystroke", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, socket |> left}
  end
  def handle_event("keystroke", %{"key" => "ArrowRight"}, socket) do
    {:noreply, socket |> right}
  end
  def handle_event("keystroke", %{"key" => " "}, socket) do
    {:noreply, socket |> move_down(&drop/1)}
  end
  def handle_event("keystroke", _, socket) do
    {:noreply, socket}
  end

  def handle_event("loadHighscore", %{"highscore" => highscore}, socket) do
    {:noreply, assign(socket, highscore: highscore)}
  end
end