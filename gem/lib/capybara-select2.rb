require "capybara-select2/version"
require 'capybara/selectors/tag_selector'
require 'rspec/core'

module Capybara
  module Select2
    def finished_all_ajax_requests?
      page.evaluate_script('jQuery.active').zero?
    end
    
    def select2(value, xpath: nil, css: nil, from: nil, search: nil)
      select2_container = case
      when xpath
        find(:xpath, xpath)
      when css
        find(:css, css)
      when from
        find("label", text: from)
          .find(:xpath, '..')
          .find(".select2-container")
      else
        raise ArgumentError, "None of xpath, css, nor from given"
      end

      # Open select2 field
      if select2_container.has_selector?(".select2-selection")
        # select2 version 4.0
        select2_container.find(".select2-selection").click
      elsif select2_container.has_selector?(".select2-choice")
        select2_container.find(".select2-choice").click
      else
        select2_container.find(".select2-choices").click
      end

      body = find(:xpath, "//body")

      # Enter into the search box.
      drop_container = case
      when search
        body
          .find(".select2-container--open input.select2-search__field")
          .send_keys(value)
        loop until finished_all_ajax_requests?
        ".select2-results"
      when find(:xpath, "//body").has_selector?(".select2-dropdown")
        # select2 version 4.0
        ".select2-dropdown"
      else
        ".select2-drop"
      end

      [value].flatten.each do |val|
        results_selector = if body.has_selector?("#{drop_container} li.select2-results__option")
          # select2 version 4.0
          "li.select2-results__option"
        else
          "li.select2-result-selectable"
        end
        
        body
          .find("#{drop_container} #{results_selector}", text: value)
          .click
      end
    end
  end
end

RSpec.configure do |config|
  config.include Capybara::Select2
  config.include Capybara::Selectors::TagSelector
end
