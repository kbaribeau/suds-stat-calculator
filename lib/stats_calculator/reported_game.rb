class ReportedGame
  def initialize(parsed_csv_row)
    @parsed_csv_row = parsed_csv_row
  end

  def winning_team
    if @parsed_csv_row['home_score'].to_i > @parsed_csv_row['away_score'].to_i
      @parsed_csv_row['home_team']
    else
      @parsed_csv_row['away_team']
    end
  end

  def losing_team
    if @parsed_csv_row['home_score'].to_i > @parsed_csv_row['away_score'].to_i
      @parsed_csv_row['away_team']
    else
      @parsed_csv_row['home_team']
    end
  end

  def home_team
    @parsed_csv_row['home_team']
  end

  def away_team
    @parsed_csv_row['away_team']
  end

  def home_team_spirit
    return 0.0 if raw_away_team_spirit == ''
    raw_home_team_spirit.to_f
  end

  def away_team_spirit
    return 0.0 if raw_home_team_spirit == ''
    raw_away_team_spirit.to_f
  end

  def raw_home_team_spirit
    @parsed_csv_row['home_game_report_total']
  end

  def raw_away_team_spirit
    @parsed_csv_row['away_game_report_total']
  end

  def home_team_reported?
    raw_away_team_spirit != ''
  end

  def away_team_reported?
    raw_home_team_spirit != ''
  end

  def tie?
    @parsed_csv_row['home_score'] == @parsed_csv_row['away_score']
  end
end
