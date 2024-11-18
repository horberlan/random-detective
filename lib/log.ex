defmodule DetectiveGame.Log do

  @log_file "game_log.log"

  @moduledoc """
  logging in #{@log_file}
  """

  defp write_to_log(message) do
    File.write(@log_file, "#{message}\n", [:append])
  end

  def start_game_log(game_state) do
    write_to_log("New game started")
    log_game_state(game_state)
    game_state
  end

  def log_game_state(game_state) do
    write_to_log("Game state: #{inspect(game_state)}")
  end

  def log_victory(game_state) do
    write_to_log("Victory! Game state: #{inspect(game_state)}")
  end

  def log_defeat(game_state) do
    write_to_log("Defeat! Game state: #{inspect(game_state)}")
  end

  def log_exit(game_state) do
    write_to_log("Exit! Game state: #{inspect(game_state)}")
  end
end
