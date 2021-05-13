defmodule TetrisWeb.GameLive do
  use TetrisWeb, :live_view
  alias Tetris.Game

  def mount(_params, _session, socket) do
    socket = 
      socket 
      |> initialize
      |> new_game

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

  defp render_level(assigns) do
    ~L"""
    <div class="tetris-level">Level: <%= @game.level %></div>
    <form class="tetris-level-form" phx-change="level" phx-hook="Level" id="level">
      <%= if @game.game_over or @game.pause do %>
        <select name="level" class="tetris-level-select">
      <% else %>
        <select disabled name="level" class="tetris-level-select-disabled">
      <% end %>
        <%= for num <- 1..10 |> Enum.to_list do %>
          <%= if @start_level == num do %>
            <option selected value="<%= num %>"><%= num %></option>
          <% else %>
            <option value="<%= num %>"><%= num %></option>
          <% end %> 
        <% end %>
      </select>
    </form>
    """
  end

  defp render_highscore(assigns) do
    placeholders = List.duplicate('-', 5)  
    ~L"""
    <div class="tetris-highscore" phx-hook="Highscore" id="highscore">
      <table>
        <tr><th class="tetris-th">Highscore</th></tr>
        <%= if !!@highscore do %>
          <%= for score <- @highscore ++ placeholders |> Enum.take(5) do %>
            <tr><td class="tetris-td"><%= score %></td></tr>
          <% end %>
        <% end %>
      </table>
    </div>
    """
  end

  defp color(:l), do: "royalblue"
  defp color(:j), do: "limegreen"
  defp color(:s), do: "cyan"
  defp color(:z), do: "darkviolet"
  defp color(:o), do: "red"
  defp color(:i), do: "yellow"
  defp color(:t), do: "orange"

  defp initialize(socket) do
    assign(socket, highscore: [], start_level: 1, timer: set_timer(500))
  end

  defp new_game(%{assigns: %{start_level: start_level}} = socket) do
    game = Game.new |> Game.set_level_and_speed(start_level)
    assign(socket, game: game)
  end

  defp set_timer(interval), do: :erlang.send_after(interval,  self(), :tick)

  defp cancel_timer(timer), do: :erlang.cancel_timer(timer)
  
  defp update_timer(%{assigns: %{timer: timer, game: %{interval: interval}}} = socket) do
    timer |> cancel_timer
    new_timer = set_timer(interval)
    assign(socket, timer: new_timer)
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
    |> update_timer
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

  defp update_start_level(socket, level) do
    socket
    |> push_event("updateLevel", %{level: level})
  end

  def handle_info(:tick, %{assigns: %{game: game}} = socket)
    when game.game_over == true
    when game.pause == true,
    do: {:noreply, socket}
  
  def handle_info(:tick, socket) do
    {:noreply, socket |> move_down(&down/1)} 
  end

  def handle_event("restart", _, socket) do
    {:noreply, socket |> new_game |> update_timer}
  end

  def handle_event("pause", _, socket) do
    {:noreply, socket |> toggle_pause |> update_timer}
  end

  def handle_event("level", %{"level" => level}, socket) do
    {:noreply, socket |> update_start_level(level)}
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

  def handle_event("loadLevel", %{"level" => level}, %{assigns: %{game: game}} = socket) do
    updated_game =  Game.set_level_and_speed(game, level)
    {:noreply, assign(socket, start_level: level, game: updated_game)}
  end
end