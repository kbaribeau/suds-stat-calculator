class TeamStats
  attr_accessor :team_name
  attr_accessor :a_pool_wins, :a_pool_losses, :a_pool_ties
  attr_accessor :b_pool_wins, :b_pool_losses, :b_pool_ties
  attr_accessor :c_pool_wins, :c_pool_losses, :c_pool_ties
  attr_accessor :d_pool_wins, :d_pool_losses, :d_pool_ties
  attr_accessor :total_spirit, :total_reported_games

  def initialize(team_name)
    @team_name = team_name

    @a_pool_wins = 0
    @a_pool_losses = 0
    @a_pool_ties = 0

    @b_pool_wins = 0
    @b_pool_losses = 0
    @b_pool_ties = 0

    @c_pool_wins = 0
    @c_pool_losses = 0
    @c_pool_ties = 0

    @d_pool_wins = 0
    @d_pool_losses = 0
    @d_pool_ties = 0

    @total_spirit = 0

    @total_reported_games = 0
  end

  def average_spirit_score
    total_spirit / total_reported_games.to_f
  end

  def league_points
    # From Wendy's Spreadsheet: =(B5*24)+(C5*12)+(D5*18)
    # Losses are worth 1/2 the points of a win, ties are worth 3/4
    total = @a_pool_wins * 24 + @a_pool_losses * 12 + @a_pool_ties * 18 +
      @b_pool_wins * 12 + @b_pool_losses * 6 + @b_pool_ties * 9 +
      @c_pool_wins * 6 + @c_pool_losses * 3 + @c_pool_ties * 4.5 +
      @d_pool_wins * 3 + @d_pool_losses * 0 + @d_pool_ties * 2.25

    total
  end

  def inspect
    a_pool_stats = "#{a_pool_wins},#{a_pool_losses},#{a_pool_ties}"
    b_pool_stats = "#{b_pool_wins},#{b_pool_losses},#{b_pool_ties}"
    c_pool_stats = "#{c_pool_wins},#{c_pool_losses},#{c_pool_ties}"
    d_pool_stats = "#{d_pool_wins},#{d_pool_losses},#{d_pool_ties}"
    "#{team_name},#{a_pool_stats},#{b_pool_stats},#{c_pool_stats},#{d_pool_stats},#{league_points},#{average_spirit_score}"
  end
end
