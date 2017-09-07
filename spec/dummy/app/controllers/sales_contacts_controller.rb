# frozen_string_literal: true

class SalesContactsController < InheritedResources::Base
  def create
    create! do |success, _failure|
      success.html do
        # that may be not better way to create process because if process will not be created
        # resource (sales contact) will still be created in the system
        # so it may be better to create process in the same transaction
        # if you need them both to be created or both crashed
        RailsWorkflow::ProcessManager
          .start_process(
            18,
            resource: resource,
            url_path: :edit_sales_contact_path,
            url_params: [resource]
          )
        redirect_to sales_contacts_path
      end
    end
  end

  def update
    update! do |success, _failure|
      success.html do
        if current_operation && (params['commit'] == 'Complete')
          current_operation.complete
        end

        redirect_to sales_contacts_path
      end
    end
  end

  private

  def sales_contact_params
    params.require(:sales_contact).permit(:message, :email)
  end
end
