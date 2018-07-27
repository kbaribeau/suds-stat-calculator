require 'csv'
require 'yaml'
require_relative 'stat_downloader'
require_relative 'pool_scraper'
require_relative 'stats_calculator/team_stats'
require_relative 'stats_calculator/reported_game'

class Runner
  def run(league_id)
    pool_info = PoolScraper.new.scrape_pools(league_id)
    raw_csv = StatDownloader.new.download(league_id)

    # strip off the UTF BOM bytes from beginning of string
    league_csv_string = raw_csv[3...raw_csv.length]

    games_played = CSV.parse(league_csv_string,
                             { headers: :first_row,
                               force_quotes: true,
                               quote_char: '"'})

    team_stat_entries = {}
    all_teams = pool_info['Round 1']['A'] + pool_info['Round 1']['B']
    all_teams.each do |team_name|
      team_stat_entries[team_name] = TeamStats.new(team_name)
    end

    games_played.each do |game_csv_row|
      round = game_csv_row['stage']
      next if round.match?(/Playoffs/) || round.match(/Exhibition/)
      pools_for_round = pool_info[round]
      a_pool_teams = pools_for_round['A']
      b_pool_teams = pools_for_round['B']
      c_pool_teams = pools_for_round['C']
      d_pool_teams = pools_for_round['D']

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

    team_stat_entries.values.sort_by(&:league_points).reverse.each do |stat|
      p stat
    end
  end
end

Runner.new.run(ARGV[0])
