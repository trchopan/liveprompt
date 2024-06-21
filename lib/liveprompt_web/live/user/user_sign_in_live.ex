defmodule LivepromptWeb.UserSignInLive do
  use LivepromptWeb, :live_component

  def render(assigns) do
    ~H"""
    <button
      id="sign-in-with-google-button"
      phx-hook="SignIn"
      class="btn btn-primary btn-sm"
      type="button"
      onclick="window.signInWithGoogle()"
    >
      Sign In
    </button>
    """
  end
end
