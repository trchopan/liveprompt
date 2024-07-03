defmodule Const do
  values = [
    youtube_introduction_video: "https://www.youtube.com/watch?v=EWS77VEta1Y"
  ]

  for {key, value} <- values do
    def encode(unquote(key)), do: unquote(value)
    def decode(unquote(value)), do: unquote(key)
  end
end
