# frozen_string_literal: true

require 'rails_helper'

feature 'Process Template' do
  scenario 'User creates new template' do
    visit '/workflow/config'

    click_link 'Add Process Template'
    expect(page).to have_text('New Process Template')
  end
end
