require 'rspec'
require 'standings_calculator'

RSpec.describe StandingsCalculator do
  CSV_HEADER = '   "id","start_date","start_time","end_date","end_time","home_team","away_team","home_score","away_score","reported_at","division","stage","field","field_number","home_spirit_rules","home_spirit_fouls","home_spirit_fairness","home_spirit_attitude","home_spirit_communication","home_Comments","home_game_report_total","away_spirit_rules","away_spirit_fouls","away_spirit_fairness","away_spirit_attitude","away_spirit_communication","away_Comments","away_game_report_total"'
  context 'stat calculations' do
    def csv_line(home_team, away_team, home_score, away_score, round, home_spirit, away_spirit)
      "\"\",\"\",\"\",\"\",\"\",\"#{home_team}\",\"#{away_team}\",\"#{home_score}\",\"#{away_score}\",\"\",\"\",\"#{round}\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"#{home_spirit}\",\"\",\"\",\"\",\"\",\"\",\"\",\"#{away_spirit}\""
    end

    it 'awards league points to a teams from the a pool' do
      pool_info = {"Round 1"=>{"A"=>["a team 1", "a team 2"], "B"=>["b team 1", "b team 2"]}}
      raw_csv = "#{CSV_HEADER}\n" + csv_line('a team 1', 'a team 2', 15, 13, 'Round 1', 12, 12)

      runner = StandingsCalculator.new
      result = runner.calculate_standings(pool_info, raw_csv)
      first_place_team = result.first
      second_place_team = result[1]

      expect(first_place_team.team_name).to eq('a team 1')
      expect(first_place_team.league_points).to eq(24)
      expect(second_place_team.team_name).to eq('a team 2')
      expect(second_place_team.league_points).to eq(12)
    end
  end
end
