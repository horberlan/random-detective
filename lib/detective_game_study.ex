defmodule DetectiveGameStudy do
  defstruct victim: %{name: ""}, suspects: [], witness: %{statement: ""}, progress: 0

  @locations ["City Park", "Downtown Alley", "B'eachside"]
  @relationships ["Friend", "Neighbor", "Family member"]

  @statements ["I saw nothing.", "I was at home.", "I don't know what you're talking about."]
  @alibis ["Solid alibi", "Shaky alibi", "No alibi"]

  @clues ["Suspicious footprint", "Torn piece of fabric", "Mysterious letter"]
  @insights ["Points to a suspect", "Leads to a new location", "Reveals a hidden motive"]
  @valid_commands ["investigate", "question", "accuse", "analyze", "exit"]

  @spec start_game(String.t(), String.t()) :: any()
  def start_game(victim_name, main_suspect_name) do
    suspects = [
      %{
        "name" => "Suspect A",
        "city" => Enum.random(@locations),
        "relationship" => Enum.random(@relationships)
      },
      %{
        "name" => "Suspect B",
        "city" => Enum.random(@locations),
        "relationship" => Enum.random(@relationships)
      },
      %{
        "name" => "Suspect C",
        "city" => Enum.random(@locations),
        "relationship" => Enum.random(@relationships)
      }
    ]

    suspects =
      if Enum.any?(suspects, fn suspect -> suspect["name"] == main_suspect_name end) do
        suspects
      else
        [
          %{
            "name" => main_suspect_name,
            "city" => Enum.random(@locations),
            "relationship" => Enum.random(@relationships)
          }
          | suspects
        ]
      end

    case_data = %DetectiveGameStudy{
      victim: %{name: victim_name},
      suspects: suspects
    }

    IO.puts(
      "Welcome to the Detective Game 🎲🕵️‍♂️ \n Sua investigação será sobre o assasinatio de: #{victim_name}, apicultor da cidade."
    )

    %{
      case_file: %{
        victim: case_data.victim.name,
        location: Enum.random(@locations),
        clues: []
      },
      leads: [
        %{name: "Witness", statement: Enum.random(@statements)},
        %{
          role: "Main Suspect",
          name: main_suspect_name,
          alibi: Enum.random(@alibis),
          statement: Enum.random(@statements)
        }
      ],
      suspects: suspects
    }
    |> play()
  end

  def play(game_state) do
    IO.inspect(game_state,
      label: "Actual Information",
      syntax_colors: [atom: :cyan, string: :green, integer: :yellow, float: :magenta]
    )

    get_input()
    |> String.trim()
    |> String.downcase()
    |> do_action(game_state)
  end

  defp do_action(action, game_state) do
    if action in @valid_commands do
      case action do
        "exit" ->
          IO.puts("Goodbye!")
          :ok

        _ ->
          apply(__MODULE__, String.to_atom(action), [game_state])
      end
    else
      IO.puts("Invalid command!")
    end
  end

  def investigate(game_state) do
    new_clue = Enum.random(@clues)

    updated_game_state =
      put_in(game_state[:case_file][:clues], [new_clue | game_state[:case_file][:clues]])

    IO.puts(IO.ANSI.red() <> "Discovered: #{new_clue}" <> IO.ANSI.reset())
    play(updated_game_state)
  end

  def question(game_state) do
    lead = Enum.random(game_state[:leads])

    IO.puts(
      IO.ANSI.yellow() <> "Statement from #{lead[:name]}: #{lead[:statement]}" <> IO.ANSI.reset()
    )

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

  def accuse(game_state) do
    suspect = Enum.random(game_state[:suspects])
    # todo: define valid_accusation based in progress

    if Enum.random([true, false]) do
      IO.puts(
        IO.ANSI.green() <>
          "Accusation against #{suspect["name"]}: **SUCCESS**. Case closed!" <> IO.ANSI.reset()
      )
    else
      IO.puts(
        IO.ANSI.red() <>
          "Accusation against #{suspect["name"]}: **FAILURE**. Continue investigating." <>
          IO.ANSI.reset()
      )

      play(game_state)
    end
  end

  def analyze(game_state) do
    IO.puts("Analyzing clues...")

    IO.puts(
      case game_state[:case_file][:clues] do
        [] -> "No clues to analyze."
        clues -> "New insight: #{Enum.random(clues)} => #{Enum.random(@insights)}"
      end
    )

    play(game_state)
  end

  defp get_input do
    IO.gets(
      IO.ANSI.light_green() <>
        "What would you like to do? (investigate, question, accuse, analyze, or exit) > " <>
        IO.ANSI.reset()
    )
  end
end

# Usage:
# DetectiveGameStudy.start_game("João", "Maria")
