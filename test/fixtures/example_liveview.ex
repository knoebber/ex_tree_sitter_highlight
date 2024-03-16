defmodule PurpleWeb.BoardLive.Index do
  @moduledoc """
  Live view for viewing/managing user's boards.
  """

  alias Purple.Board
  import PurpleWeb.BoardLive.Helpers
  use PurpleWeb, :live_view

  def apply_action(socket, :index, _) do
    assign(socket, :editable_board, nil)
  end

  def apply_action(socket, :edit, %{"id" => id}) do
    assign(socket, :editable_board, Board.get_user_board!(id))
  end

  def apply_action(socket, :create, _) do
    new_board = %Board.UserBoard{tags: []}

    socket
    |> assign(:editable_board, new_board)
    |> assign(:user_boards, [new_board | socket.assigns.user_boards])
  end

  defp assign_data(socket) do
    user_boards = Board.list_user_boards(socket.assigns.current_user.id)

    socket
    |> assign(:page_title, "Boards")
    |> assign(:user_boards, user_boards)
  end

  @impl Phoenix.LiveView
  def mount(_, _, socket) do
    {:ok, assign_side_nav(socket)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _, socket) do
    {
      :noreply,
      socket
      |> assign_data()
      |> apply_action(socket.assigns.live_action, params)
    }
  end

  @impl Phoenix.LiveView
  def handle_event("delete", %{"id" => id}, socket) do
    Board.delete_user_board!(id)

    {
      :noreply,
      socket
      |> assign_data()
      |> assign_side_nav()
      |> put_flash(:info, "Deleted board")
    }
  end

  @impl Phoenix.LiveView
  def handle_info({:saved_board, _id}, socket) do
    {
      :noreply,
      socket
      |> push_patch(to: ~p"/board", replace: true)
      |> put_flash(:info, "Board saved")
    }
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <h1 class="mb-2">
      <%= @page_title %>
      <.link navigate={~p"/board/new"}>
        ➕
      </.link>
    </h1>
    <div class="mb-2"></div>
    <div class="columns-1 lg:columns-2 h-100">
      <.section :for={user_board <- @user_boards} class="mb-2 h-100 break-inside-avoid">
        <div class="bg-purple-300 p-2 flex gap-2 items-end">
          <h2>
            <.link :if={user_board.id != nil} navigate={~p"/board/#{user_board.id}"}>
              <%= user_board.name %>
            </.link>
            <span :if={user_board.id == nil}>New Board</span>
          </h2>
          <%= if @editable_board && @editable_board.id == user_board.id do %>
            <.link patch={~p"/board"} replace={true}>Cancel</.link>
          <% else %>
            <.link patch={~p"/board/#{user_board}/edit"} replace={true}>✏️</.link>
          <% end %>
          <span>|</span>
          <.link
            href="#"
            phx-click="delete"
            phx-value-id={user_board.id}
            data-confirm="Are you sure want to delete this board?"
          >
            ❌
          </.link>
        </div>
        <%= if @editable_board && @editable_board.id == user_board.id do %>
          <div class="m-2 p-2 border border-purple-500 bg-purple-50 rounded">
            <.live_component
              module={PurpleWeb.BoardLive.UserBoardForm}
              id={user_board.id || :new}
              user_board={user_board}
              action={@live_action}
              current_user={@current_user}
            />
          </div>
        <% else %>
          <div class="mb-2 p-4">
            <%= if length(user_board.tags) == 0 do %>
              No tags
            <% else %>
              <div class="flex flex-wrap gap-1">
                <code :for={tag <- user_board.tags} class="inline">#<%= tag.name %></code>
              </div>
            <% end %>
          </div>
        <% end %>
      </.section>
    </div>
    """
  end
end
