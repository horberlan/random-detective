defmodule Utils.GeneralUtils do
  def inspect_highlight(game_state, label) do
    IO.inspect(game_state,
      label: label,
      syntax_colors: [
        atom: :cyan,
        string: :green,
        integer: :yellow,
        number: :yellow,
        float: :magenta
      ]
    )
  end
end
