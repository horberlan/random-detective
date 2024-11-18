defmodule DetectiveGame do
  @moduledoc """
    iex> DetectiveGame.start_game("João", "Maria")
  """
  defstruct victim: %{name: ""}, suspects: [], witness: %{statement: ""}, progress: 0

  @locations ["City Park", "Downtown Alley", "B'eachside"]
  @relationships ["Friend", "Neighbor", "Family member"]
  @statements ["I saw nothing.", "I was at home.", "I don't know what you're talking about."]
  @alibis ["Solid alibi", "Shaky alibi", "No alibi"]
  @clues ["Suspicious footprint", "Torn piece of fabric", "Mysterious letter"]
  @insights ["Points to a suspect", "Leads to a new location", "Reveals a hidden motive"]

  @valid_commands ["investigate", "question", "accuse", "analyze", "exit"]

  @action_progression %{
    "investigate" => 10,
    "question" => 5,
    "analyze" => 15,
    "min_to_accuse" => 40
  }

  Faker.start()

  # todo change main_suspect_name logic, to the most avalueted suspect, initial value can be nil
  def start_game(victim_name, main_suspect_name) do
    suspects =
      Enum.map(1..3, fn _ ->
        %{
          "name" => Faker.Person.name(),
          "city" => Faker.Address.city(),
          "relationship" => Enum.random(@relationships)
        }
      end)

    suspects =
      if Enum.any?(suspects, fn suspect -> suspect["name"] == main_suspect_name end) do
        suspects
      else
        [create_person_by_name(main_suspect_name) | suspects]
      end

    case_data = %DetectiveGame{
      victim: %{name: victim_name},
      suspects: suspects,
      progress: 0
    }

    IO.puts(
      "Welcome to the Detective Game 🎲🕵️‍♂️ \n you are investigating the murder of #{victim_name}."
    )

    %{
      case_file: %{
        victim: case_data.victim.name,
        location: Enum.random(@locations),
        clues: []
      },
      leads: [
        %{
          name: "Witness",
          statement: Enum.random(@statements),
          role: "Witness"
        },
        %{
          role: "Main Suspect",
          name: main_suspect_name,
          alibi: Enum.random(@alibis),
          statement: Enum.random(@statements)
        }
      ],
      suspects: suspects,
      progress: case_data.progress
    }
    |> DetectiveGame.Log.start_game_log()
    |> play()
  end

  def play(game_state) do
    inspect_highlight(game_state, "Actual Information")

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
          DetectiveGame.Log.log_exit(game_state)
          :ok

        _ ->
          apply(__MODULE__, String.to_atom(action), [game_state])
      end
    else
      IO.puts("Invalid command!")
      IO.inspect(@valid_commands, label: "valid commands")
      play(game_state)
    end
  end

  def investigate(game_state) do
    new_clue = Enum.random(@clues)

    IO.puts(IO.ANSI.red() <> "Discovered: #{new_clue}" <> IO.ANSI.reset())

    put_in(game_state[:case_file][:clues], [new_clue | game_state[:case_file][:clues]])
    |> update_progress(@action_progression["investigate"])
    |> play()
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

    %{game_state | leads: updated_leads}
    |> update_progress(@action_progression["question"])
    |> play()
  end

  def analyze(game_state) do
    IO.puts("Analyzing clues...")

    IO.puts(
      case game_state[:case_file][:clues] do
        [] -> "No clues to analyze."
        clues -> "New insight: #{Enum.random(clues)} => #{Enum.random(@insights)}"
      end
    )

    update_progress(game_state, @action_progression["analyze"]) |> play()
  end

  def accuse(game_state) do
    if game_state.progress < @action_progression["min_to_accuse"] do
      IO.puts("You need more clues and information before making an accusation.")
      play(game_state)
    else
      inspect_highlight(Enum.with_index(game_state.suspects), "suspects")

      game_state.suspects
      |> Scribe.print(data: [{"Name", "name"}, {"Relationship", "relationship"}])

      accuse_suspect_by_index(game_state)
    end
  end

  defp accuse_suspect_by_index(game_state) do
    IO.puts("Enter the number of the suspect you want to accuse:")

    case IO.gets("> ") |> String.trim() |> Integer.parse() do
      {index, ""} when index >= 1 and index <= length(game_state.suspects) ->
        suspect = Enum.at(game_state.suspects, index - 1)

        if Enum.random([true, false]) do
          DetectiveGame.Log.log_victory(game_state)

          IO.puts(
            IO.ANSI.green() <>
              "Accusation against #{suspect["name"]}: **SUCCESS**. Case closed!" <>
              IO.ANSI.reset()
          )
        else
          DetectiveGame.Log.log_defeat(game_state)

          IO.puts(
            IO.ANSI.red() <>
              "Accusation against #{suspect["name"]}: **FAILURE**. Continue investigating." <>
              IO.ANSI.reset()
          )

          play(game_state)
        end

      _ ->
        IO.puts("Invalid selection. Please try again.")
        accuse(game_state)
    end
  end

  defp get_input do
    commands = Enum.join(@valid_commands, ", ")

    IO.gets(
      IO.ANSI.light_green() <>
        "What would you like to do? (#{commands}) > " <>
        IO.ANSI.reset()
    )
  end

  def create_person_by_name(name) do
    %{
      "name" => name,
      "city" => Faker.Address.city(),
      "relationship" => Enum.random(@relationships)
    }
  end

  defp update_progress(game_state, value) do
    new_progress = game_state.progress + value
    %{game_state | progress: min(new_progress, 100)}
  end

  defp inspect_highlight(game_state, label) do
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
