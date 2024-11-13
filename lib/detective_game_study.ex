defmodule DetectiveGameStudy do
  defstruct victim: %{name: ""}, suspect: %{name: ""}, witness: %{statement: ""}

  @cities ["City Park", "Downtown Alley", "Beachside"]
  @relationships ["Friend", "Neighbor", "Family member"]

  @statements ["I saw nothing.", "I was at home.", "I don't know what you're talking about."]
  @alibi ["Solid alibi", "Shaky alibi", "No alibi"]

  @clue ["Suspicious footprint", "Torn piece of fabric", "Mysterious letter"]
  _insight = ["Points to a suspect", "Leads to a new location", "Reveals a hidden motive"]

  @spec start_game(any(), any()) :: any()
  def start_game(victim_name, suspect_name) do
    _suspects = %{
      "Suspect A" => %{city: Enum.random(@cities), relationship: Enum.random(@relationships)},
      "Suspect B" => %{city: Enum.random(@cities), relationship: Enum.random(@relationships)},
      "Suspect C" => %{city: Enum.random(@cities), relationship: Enum.random(@relationships)}
    }

    case_data = %DetectiveGameStudy{
      victim: %{name: victim_name},
      suspect: %{name: suspect_name}
    }

    IO.puts("Welcome to the Detective Game!\nYour victim is: #{victim_name}")

    %{
      case_file: %{
        victim: case_data.victim.name,
        location: Enum.random(@cities),
        clues: []
      },
      leads: [
        %{name: "Witness", statement: Enum.random(@statements)},
        %{name: "Suspect", alibi: Enum.random(@alibi), statement: Enum.random(@statements)}
      ]
    }
    |> play()
  end

  def play(game_state) do
    IO.inspect(game_state, label: "Game State")

    IO.gets(IO.ANSI.green() <> "What would you like to do? (investigate) > " <> IO.ANSI.reset())
    |> String.trim()
    |> String.downcase()
    |> case do
      "investigate" ->
        investigate(game_state)

      "question" ->
        question(game_state)

      "accuse" ->
        accuse(game_state)

      "exit" ->
        IO.puts("Goodbye!")
        :ok

      _ ->
        IO.puts("Invalid command. Try again.")
        play(game_state)
    end
  end

  defp investigate(game_state) do
    # ao investigar gera um clue novo
    new_clue = Enum.random(@clue)

    put_in(game_state[:case_file][:clues], [new_clue | game_state[:case_file][:clues]])
    |> play()

    IO.puts(IO.ANSI.red() <> "Discovered: #{new_clue}" <> IO.ANSI.reset())
  end

  defp question(game_state) do
    lead = Enum.random(game_state[:leads])
    IO.puts("Statement from #{lead[:name]}: #{lead[:statement]}")

    updated_leads =
      Enum.map(game_state[:leads], fn current_lead ->
        if current_lead[:name] == lead[:name] do
          %{current_lead | statement: Enum.random(@statements)}
        else
          current_lead
        end
      end)

    play(%{game_state | leads: updated_leads})
  end

  defp accuse(game_state) do
    suspect = Enum.random(game_state[:leads])
    # todo remove this dirt way 🗑️
    if Enum.random([true, false]) do
      IO.puts("Accusation against #{suspect[:name]}: **SUCCESS**. Case closed!")
    else
      IO.puts("Accusation against #{suspect[:name]}: **FAILURE**. Continue investigating.")
      play(game_state)
    end
  end
end

# eg
# DetectiveGameStudy.start_game("joão", "maria")
