defmodule RldLiveViewStudioWeb.CustomComponents do
  use Phoenix.Component

  embed_templates("icons/*")

  attr(:spinning, :boolean, default: false)
  def moon_icon(assigns)

  attr(:points, :integer, required: true)
  def star_icon(assigns)

  attr(:minutes, :integer)
  attr(:expiration, :integer, default: 24)
  slot(:legal)
  slot(:inner_block, required: true)

  def promo(assigns) do
    # assigns = assign(assigns, :minutes, assigns.expiration * 60)

    # if :minutes is declared as an optional attribute. And if a :minutes value isn't passed to the promo component,
    # only then do you want to assign one.
    # Here's how to do that using assign_new:
    assigns = assign_new(assigns, :minutes, fn -> assigns.expiration * 60 end)

    ~H"""
    <div class="promo">
      <div class="deal">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="expiration">
        Deal expires in <%= @expiration %> hours
        (<%= @minutes %> minutes)
      </div>
      <div class="legal">
        <%= render_slot(@legal) %>
      </div>
    </div>
    """
  end

  attr(:label, :string, required: true)
  attr(:class, :string, default: nil)
  attr(:rest, :global)

  def badge(assigns) do
    ~H"""
    <span
      class={["inline-flex items-center gap-0.5 rounded-full
            bg-gray-300 px-3 py-0.5 text-sm font-medium
            text-gray-800 hover:cursor-pointer",
            @class]} {@rest}>
      <%= @label %>
      <Heroicons.x_mark class="w-3 h-3 text-gray-600" />
    </span>
    """
  end
end
