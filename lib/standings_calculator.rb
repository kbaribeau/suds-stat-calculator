require 'csv'
require_relative 'stats_calculator/team_stats'
require_relative 'stats_calculator/reported_game'

class StandingsCalculator
  def calculate_standings(pool_info, raw_csv)
    league_csv_string = raw_csv[3...raw_csv.length]

    games_played = CSV.parse(league_csv_string,
                             { headers: :first_row,
                               force_quotes: true,
                               quote_char: '"'})

    team_stat_entries = {}
    all_teams = pool_info.values.map { |round| round.values }.flatten.uniq
    all_teams.each do |team_name|
      team_stat_entries[team_name] = TeamStats.new(team_name)
    end

    games_played.each do |game_csv_row|
      round = game_csv_row['stage']
      next if round.match?(/Playoff/) || round.match(/Exhibition/)
      pools_for_round = pool_info[round]
      a_pool_teams = pools_for_round['A']
      b_pool_teams = pools_for_round['B']
      c_pool_teams = pools_for_round['C']
      d_pool_teams = pools_for_round['D']

      a_pool_teams = all_teams if a_pool_teams.nil?

      reported_game = ReportedGame.new(game_csv_row)

      if a_pool_teams.include?(reported_game.home_team) && a_pool_teams.include?(reported_game.away_team)
        # TODO: have reported_game return a hash of points to be awarded
        # The team names can be used as keys, and point values are values
        # that hash can be passed to team_stat_entries,(or a new wrapper around team_stat_entries)
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
      elsif !c_pool_teams.nil? && c_pool_teams.include?(reported_game.home_team) && c_pool_teams.include?(reported_game.away_team)
        if reported_game.tie?
          team_stat_entries[reported_game.winning_team].c_pool_ties += 1
          team_stat_entries[reported_game.losing_team].c_pool_ties += 1
        else
          team_stat_entries[reported_game.winning_team].c_pool_wins += 1
          team_stat_entries[reported_game.losing_team].c_pool_losses += 1
        end
      elsif !d_pool_teams.nil? && d_pool_teams.include?(reported_game.home_team) && d_pool_teams.include?(reported_game.away_team)
        if reported_game.tie?
          team_stat_entries[reported_game.winning_team].d_pool_ties += 1
          team_stat_entries[reported_game.losing_team].d_pool_ties += 1
        else
          team_stat_entries[reported_game.winning_team].d_pool_wins += 1
          team_stat_entries[reported_game.losing_team].d_pool_losses += 1
        end
      else
        # Do nothing, crossover games are worth nothing
      end

      team_stat_entries[reported_game.home_team].total_spirit += reported_game.home_team_spirit
      team_stat_entries[reported_game.away_team].total_spirit += reported_game.away_team_spirit

      team_stat_entries[reported_game.home_team].total_reported_games += 1 if reported_game.away_team_reported?
      team_stat_entries[reported_game.away_team].total_reported_games += 1 if reported_game.home_team_reported?
    end

    team_stat_entries.values.sort_by(&:league_points).reverse
  end
end
