require 'mechanize'
require_relative 'login_with_mechanize'

class StatDownloader
  include LoginWithMechanize

  def download(league_id)
    mech = Mechanize.new
    login(mech)
    download_game_results_csv(mech, league_id)
  end

  private

  def download_game_results_csv(mech, league_id)
    schedule_admin_url = "https://saskatoonultimate.org/e/admin/#{league_id}/schedule"
    schedule_admin_page = mech.get(schedule_admin_url)
    file = schedule_admin_page.links_with(text: 'Export').first.click

    file.content
  end
end
