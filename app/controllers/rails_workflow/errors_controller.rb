# frozen_string_literal: true

module RailsWorkflow
  class ErrorsController < ApplicationController
    def retry
      process = RailsWorkflow::Process.find(permitted_params[:process_id])

      if permitted_params[:operation_id].present?
        operation = Operation.find(permitted_params[:operation_id])
      end

      error = Error.find(permitted_params[:id])
      error.retry

      if operation.present?
        redirect_to process_operation_path(process, operation)
      else
        redirect_to process_path(process)
      end
    end

    protected

    def permitted_params
      params.permit(:process_id, :operation_id, :id)
    end
  end
end
