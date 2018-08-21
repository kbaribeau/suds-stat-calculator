require 'yaml'
require_relative 'stat_downloader'
require_relative 'pool_scraper'
require_relative 'standings_calculator'

class Runner
  def run(league_id)
    pool_info = PoolScraper.new.scrape_pools(league_id)
    raw_csv = StatDownloader.new.download(league_id)

    results = StandingsCalculator.new.calculate_standings(pool_info, raw_csv)

    results.each do |stat|
      p stat
    end
  end
end

Runner.new.run(ARGV[0])
