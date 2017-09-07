# frozen_string_literal: true

module Pages
  class Operations
    attr_accessor :page

    def initialize(page)
      @page = page
    end

    def have_title?(title)
      page.has_xpath?('//h1', text: title)
    end

    def table_rows
      page.all('table#operations tbody tr')
    end

    def operation_row(title)
      table_rows.find { |row| row.all('td')[0].has_link?(title) }
    end

    def have_operation?(options)
      row = operation_row(options[:title])

      row.present? &&
        check_status(row, options) &&
        check_assignment(row, options) &&
        check_button(row, options)
    end

    def check_status(row, options)
      (options[:status].blank? || row.all('td')[1].text == options[:status])
    end

    def check_assignment(row, options)
      (options[:assignment].blank? ||
        row.all('td')[2].text == options[:assignment])
    end

    def check_button(row, options)
      (options[:button_text].blank? || has_button?(row, options[:button_text]))
    end

    def has_button?(row, button_text)
      form = row.all('td')[4].find('form')
      form.has_button?(button_text)
    end
  end
end
