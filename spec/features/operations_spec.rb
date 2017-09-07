# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/pages/operations.rb'

feature 'Workflow Operations' do
  scenario 'User assigns operations' do
    create :regular_user

    given_current_user_role_is 'admin'
    given_a_process('user_operation_template')

    visit '/workflow/operations'
    operations_page = Pages::Operations.new(page)

    expect(operations_page.have_title?('Operations')).to be true

    expect(operations_page.have_operation?(
             title: 'Regular User Operation',
             status: 'Waiting'
    )).to be true

    expect(operations_page.have_operation?(
             title: 'Admin Operation',
             status: 'Waiting',
             assignment: 'Admin',
             button_text: 'Start'
    )).to be true
  end
end
