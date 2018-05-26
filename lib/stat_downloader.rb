require 'mechanize'

class StatDownloader
  def download(league_id)
    mech = Mechanize.new
    login(mech)
    download_game_results_csv(mech)
  end

  private

  def login(mech)
    config = YAML.load_file('config.yml')
    username = config['admin_credentials']['username']
    password = config['admin_credentials']['password']

    mech.get('http://saskatoonultimate.org') do |login_page|
      login_form_action = 'https://saskatoon.usetopscore.com/signin?original_domain=saskatoonultimate.org'
      login = login_page.form_with(action: login_form_action) do |login|
        login.field_with(id: 'signin_email').value = username
        login.field_with(id: 'signin_password').value = password

        login.submit
      end
    end
  end

  def download_game_results_csv(mech)
    schedule_admin_url = "https://saskatoonultimate.org/e/admin/#{league_id}/schedule"
    schedule_admin_page = mech.get(schedule_admin_url)
    file = schedule_admin_page.links_with(text: 'Export').first.click

    file.content
  end
end
