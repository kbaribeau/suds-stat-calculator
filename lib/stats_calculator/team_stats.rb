class TeamStats
  attr_accessor :team_name
  attr_accessor :a_pool_wins, :a_pool_losses, :a_pool_ties
  attr_accessor :b_pool_wins, :b_pool_losses, :b_pool_ties
  attr_accessor :c_pool_wins, :c_pool_losses, :c_pool_ties
  attr_accessor :crossover_points, :total_spirit, :total_reported_games

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

    @crossover_points = 0

    @total_spirit = 0

    @total_reported_games = 0
  end

  def average_spirit_score
    total_spirit / total_reported_games.to_f
  end

  def league_points
    total = @a_pool_wins * 9 + @a_pool_losses * 6 + @a_pool_ties * 4.5 +
      @b_pool_wins * 6 + @b_pool_losses * 3 + @b_pool_ties * 3 +
      @c_pool_wins * 3 + @c_pool_losses * 1 + @c_pool_ties * 1.5 +
      @crossover_points

    total
  end

  def inspect
    a_pool_stats = "#{a_pool_wins},#{a_pool_losses},#{a_pool_ties}"
    b_pool_stats = "#{b_pool_wins},#{b_pool_losses},#{b_pool_ties}"
    c_pool_stats = "#{c_pool_wins},#{c_pool_losses},#{c_pool_ties}"
    "#{team_name},#{a_pool_stats},#{b_pool_stats},#{c_pool_stats},#{crossover_points},#{league_points},#{average_spirit_score}"
  end
end
