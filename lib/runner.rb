require 'csv'
require 'yaml'
require_relative 'stat_downloader'
require_relative 'stats_calculator/team_stats'
require_relative 'stats_calculator/reported_game'

event_file_path = ARGV[0]
league_id = ARGV[1]

event_yaml = YAML.load_file(event_file_path)

raw_csv = StatDownloader.new.download(league_id)
# strip off the UTF BOM bytes from beginning of string
league_csv_string = raw_csv[3...raw_csv.length]

games_played = CSV.parse(league_csv_string,
                         { headers: :first_row,
                           force_quotes: true,
                           quote_char: '"'})

team_stat_entries = {}
all_teams = event_yaml['Round 1']['A'] + event_yaml['Round 1']['B']
all_teams.each do |team_name|
  team_stat_entries[team_name] = TeamStats.new(team_name)
end

games_played.each do |game_csv_row|
  round = game_csv_row['stage']
  next if round == 'Playoffs' || round == 'Exhibition Games'
  pools_for_round = event_yaml[round]
  a_pool_teams = pools_for_round['A']
  b_pool_teams = pools_for_round['B']
  c_pool_teams = pools_for_round['C']

  reported_game = ReportedGame.new(game_csv_row)

  if a_pool_teams.include?(reported_game.home_team) && a_pool_teams.include?(reported_game.away_team)
    if reported_game.tie?
      team_stat_entries[reported_game.winning_team].a_pool_ties += 1
      team_stat_entries[reported_game.losing_team].a_pool_ties += 1
    else
      team_stat_entries[reported_game.winning_team].a_pool_wins += 1
      team_stat_entries[reported_game.losing_team].a_pool_losses += 1
    end
  elsif b_pool_teams.include?(reported_game.home_team) && b_pool_teams.include?(reported_game.away_team)
    if reported_game.tie?
      team_stat_entries[reported_game.winning_team].b_pool_ties += 1
      team_stat_entries[reported_game.losing_team].b_pool_ties += 1
    else
      team_stat_entries[reported_game.winning_team].b_pool_wins += 1
      team_stat_entries[reported_game.losing_team].b_pool_losses += 1
    end
  elsif c_pool_teams.include?(reported_game.home_team) && c_pool_teams.include?(reported_game.away_team)
    if reported_game.tie?
      team_stat_entries[reported_game.winning_team].c_pool_ties += 1
      team_stat_entries[reported_game.losing_team].c_pool_ties += 1
    else
      team_stat_entries[reported_game.winning_team].c_pool_wins += 1
      team_stat_entries[reported_game.losing_team].c_pool_losses += 1
    end
  else
    # Do nothing, crossover games are worth nothing

    # OR... do something with crossover games
    # [reported_game.home_team, reported_game.away_team].each do |team|
    #   if reported_game.winning_team == team
    #     # winning team gets A pool points
    #     team_stat_entries[reported_game.winning_team].crossover_points += 6
    #   elsif reported_game.losing_team == team
    #     # losing team gets B pool losing points
    #     team_stat_entries[reported_game.losing_team].crossover_points += 1
    #   else
    #     # on a crossover tie, both teams get points as if it were an A pool game
    #     team_stat_entries[reported_game.winning_team].crossover_points += 3
    #     team_stat_entries[reported_game.losing_team].crossover_points += 3
    #   end
    # end
  end

  team_stat_entries[reported_game.home_team].total_spirit += reported_game.home_team_spirit
  team_stat_entries[reported_game.away_team].total_spirit += reported_game.away_team_spirit

  team_stat_entries[reported_game.home_team].total_reported_games += 1 if reported_game.away_team_reported?
  team_stat_entries[reported_game.away_team].total_reported_games += 1 if reported_game.home_team_reported?
end

team_stat_entries.values.sort_by(&:league_points).reverse.each do |stat|
  p stat
end
