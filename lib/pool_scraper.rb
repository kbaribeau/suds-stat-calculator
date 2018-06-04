require 'mechanize'

class PoolScraper
  include LoginWithMechanize

  def scrape_pools(league_id)
    mech = Mechanize.new
    login(mech)

    schedule_admin_url = "https://saskatoonultimate.org/e/admin/#{league_id}/schedule"
    schedule_admin_page = mech.get(schedule_admin_url)

    possible_round_header_elements = schedule_admin_page.search('.main-content-inner .spacer1-top h4.subtitled')
    round_header_elements = possible_round_header_elements.reject do |maybe_round_element|
      # "Teams" is a header on the page where you can configure which teams are
      # in the league. This isn't what we want, we're looking for the per-round
      # config
      #
      # The /exhibition/ is meant to ignore any round containing only exhibition games (this usually happens at the beginning of the season,
      # and sometimes during the first/last weeks of playoffs)
      [/teams/, /exhibition/].any? do |pattern|
        pattern.match?(maybe_round_element.text.strip.downcase)
      end
    end

    pools = {}
    round_header_elements.each do |element|
      round_name = element.text.strip
      pools[round_name] = {}
      edit_pools_url = element.next_element.css('.icon-edit').attr('href').value
      edit_pools_page = mech.get(edit_pools_url)
      edit_pools_page.css('.pool').each do |pool_element|
        next if pool_element.attributes['class'].value.match?(/hide/) # skip "unplaced teams", which should be hidden
        pool_name = pool_element.children.css('.spacer-half').children.find { |c| c.name == 'input' }.attributes['value'].text # Yuck
        next if pool_name.match?(/(New Pool)/)
        pool_name = pool_name.split(' Pool').first # Strip off everything after the word "Pool". Ex: A Pool (Round 2) -> A
        teams = pool_element.css('ul.pool-teams li').map { |elem| elem.text.strip }

        pools[round_name][pool_name] = teams
      end
    end

    pools
  end
end

