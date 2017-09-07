# frozen_string_literal: true

class LeadsController < InheritedResources::Base
  private

    def lead_params
      params.require(:lead).permit(:sales_contact_id, :offer, :name)
    end
end
