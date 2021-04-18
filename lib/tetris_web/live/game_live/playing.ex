defmodule TetrisWeb.GameLive.Playing do
  use TetrisWeb, :live_view
  alias Tetris.Game

  # the mount sets up the initial data for a live view
  # the socket contains the entire info for the state for the live view
  def mount(_params, _session, socket) do
    # this makes sure the socket is connected before starting the timer
    if connected?(socket) do
      # trigger tick events
      :timer.send_interval(500, :tick)
    end
    {:ok, socket |> new_game}
  end

  # reducers related to render

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
      <div class="tetris-game-over">
        <div class="tetris-game-over-heading">Game over!</div>
        <button class="tetris-play-button" phx-click="restart">Play again</button>
      </div>
    <% end %>
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

  # reducers related to handling events

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

  def toggle_pause(%{assigns: %{game: game}} = socket) do
    assign(socket, game: Game.toggle_pause(game))
  end

  def maybe_end_game(%{assigns: %{game: %{game_over: true}}} = socket) do
    socket
    |> push_redirect(to: "/game/over?score=#{socket.assigns.game.score}")
  end
  def maybe_end_game(socket), do: socket

  def handle_info(:tick, socket) do
    {:noreply, socket |> down} 
  end

  def handle_event("restart", _, socket) do
    {:noreply, socket |> new_game}
  end

  def handle_event("keystroke", %{"key" => "ArrowDown"}, socket) do
    {:noreply, socket |> down}
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
    {:noreply, socket |> toggle_pause}
  end
  def handle_event("keystroke", _, socket) do
    {:noreply, socket}
  end
end