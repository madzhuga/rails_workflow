# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe OperationTemplatesController, type: :controller do
    routes { RailsWorkflow::Engine.routes }

    before :each do
      @template = create :process_template
    end

    let(:valid_attributes) do
      {
        title: 'First Test project',
        process_template_id: @template.id,
        type: 'RailsWorkflow::OperationTemplate'
      }
    end

    let(:invalid_attributes) do
      skip('Add a hash of attributes invalid for your model')
    end

    let(:valid_session) {}

    describe 'GET index' do
      it 'assigns all operation_templates as @operation_templates' do
        operation_template = OperationTemplate.create! valid_attributes

        get :index, { process_template_id: @template.id }, valid_session, use_route: :workflow
        expect(assigns(:operation_templates)).to eq([operation_template])
      end
    end

    describe 'GET show' do
      it 'assigns the requested operation_template as @operation_template' do
        operation_template = OperationTemplate.create! valid_attributes

        get :show, {
          process_template_id: @template.id,
          id: operation_template.to_param
        }, valid_session, use_route: :workflow

        expect(assigns(:operation_template)).to eq(operation_template)
      end
    end

    describe 'GET new' do
      it 'assigns a new operation_template as @operation_template' do
        template = create(:process_template)

        get :new, { process_template_id: template.id }, valid_session, use_route: :workflow
        expect(assigns(:operation_template)).to be_a_new(OperationTemplate)
      end
    end

    describe 'GET edit' do
      it 'assigns the requested operation_template as @operation_template' do
        operation_template = OperationTemplate.create! valid_attributes
        get :edit, {
          process_template_id: @template.id,
          id: operation_template.to_param
        }, valid_session, use_route: :workflow
        expect(assigns(:operation_template)).to eq(operation_template)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new OperationTemplate' do
          expect do
            post :create, {
              process_template_id: @template.id,
              operation_template: valid_attributes
            }, valid_session, use_route: :workflow
          end.to change(OperationTemplate, :count).by(1)

          expect(@template.operations.count).to eq 1
        end

        it 'creates a new CustomOperationTemplate' do
          attrs = valid_attributes
          attrs[:type] = 'RailsWorkflow::CustomOperationTemplate'
          expect do
            post :create, {
              process_template_id: @template.id,
              operation_template: valid_attributes
            }, valid_session, use_route: :workflow
          end.to change(RailsWorkflow::CustomOperationTemplate, :count).by(1)
        end

        it 'assigns a newly created operation_template as @operation_template' do
          post :create, {
            process_template_id: @template.id,
            operation_template: valid_attributes
          }, valid_session, use_route: :workflow

          # expect(assigns(:operation_template)).to be_a(OperationTemplate)
          # expect(assigns(:operation_template)).to be_persisted
        end

        it 'redirects to the created operation_template' do
          post :create, {
            process_template_id: @template.id,
            operation_template: valid_attributes
          }, valid_session, use_route: :workflow
          expect(response).to redirect_to(process_template_operation_templates_path(@template.id))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved operation_template as @operation_template' do
          post :create, { operation_template: invalid_attributes }, valid_session, use_route: :workflow
          expect(assigns(:operation_template)).to be_a_new(OperationTemplate)
        end

        it "re-renders the 'new' template" do
          post :create, { operation_template: invalid_attributes }, valid_session, use_route: :workflow
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        let(:new_attributes) do
          skip('Add a hash of attributes valid for your model')
        end

        it 'updates the requested operation_template' do
          operation_template = OperationTemplate.create! valid_attributes
          put :update, { id: operation_template.to_param, operation_template: new_attributes }, valid_session, use_route: :workflow
          operation_template.reload
          skip('Add assertions for updated state')
        end

        it 'assigns the requested operation_template as @operation_template' do
          operation_template = OperationTemplate.create! valid_attributes

          put :update, { process_template_id: @template.id,
                         id: operation_template.to_param,
                         operation_template: valid_attributes },
              valid_session, use_route: :workflow

          # expect(assigns(:operations)).to eq([operation_template])
        end

        it 'redirects to the operation_template' do
          operation_template = OperationTemplate.create! valid_attributes

          put :update, {
            process_template_id: @template.id,
            id: operation_template.to_param,
            operation_template: valid_attributes
          }, valid_session, use_route: :workflow

          expect(response).to redirect_to(process_template_operation_templates_path(@template.id))
        end
      end

      describe 'with invalid params' do
        it 'assigns the operation_template as @operation_template' do
          operation_template = OperationTemplate.create! valid_attributes
          put :update, { id: operation_template.to_param, operation_template: invalid_attributes }, valid_session, use_route: :workflow
          expect(assigns(:operation_template)).to eq(operation_template)
        end

        it "re-renders the 'edit' template" do
          operation_template = OperationTemplate.create! valid_attributes
          put :update, { id: operation_template.to_param, operation_template: invalid_attributes }, valid_session, use_route: :workflow
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested operation_template' do
        operation_template = OperationTemplate.create! valid_attributes
        expect do
          delete :destroy, {
            process_template_id: operation_template.process_template.id,
            id: operation_template.to_param
          }, valid_session, use_route: :workflow
        end.to change(OperationTemplate, :count).by(-1)
      end

      it 'redirects to the operation_templates list' do
        operation_template = OperationTemplate.create! valid_attributes
        delete :destroy, {
          process_template_id: @template.id,
          id: operation_template.to_param
        }, valid_session, use_route: :workflow
        expect(response).to redirect_to(process_template_operation_templates_path(@template))
      end
    end
  end
end
