# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe ProcessTemplatesController, type: :controller do
    routes { RailsWorkflow::Engine.routes }

    let(:valid_attributes) do
      { title: 'First Test project' }
    end

    let(:invalid_attributes) do
      skip('Add a hash of attributes invalid for your model')
    end

    let(:valid_session) { {} }

    describe 'GET index' do
      it 'assigns all process_templates as @process_templates' do
        process_template = ProcessTemplate.create! valid_attributes
        get :index, {}, valid_session
        expect(assigns(:process_templates)).to eq([process_template])
      end
    end

    describe 'GET show' do
      it 'assigns the requested process_template as @process_template' do
        process_template = ProcessTemplate.create! valid_attributes
        get :show, { id: process_template.to_param }, valid_session
        expect(assigns(:process_template)).to eq(process_template)
      end
    end

    describe 'GET new' do
      it 'assigns a new process_template as @process_template' do
        get :new, {}, valid_session
        expect(assigns(:process_template)).to be_a_new(ProcessTemplate)
      end
    end

    describe 'GET edit' do
      it 'assigns the requested process_template as @process_template' do
        process_template = ProcessTemplate.create! valid_attributes
        get :edit, { id: process_template.to_param }, valid_session
        expect(assigns(:process_template)).to eq(process_template)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new WfProcessTemplate' do
          expect do
            post :create, { process_template: valid_attributes }, valid_session
          end.to change(ProcessTemplate, :count).by(1)
        end

        it 'assigns a newly created process_template as @process_template' do
          post :create, { process_template: valid_attributes }, valid_session, use_route: :workflow
          expect(assigns(:process_template)).to be_a(ProcessTemplate)
          expect(assigns(:process_template)).to be_persisted
        end

        it 'redirects to the created process_template' do
          post :create, { process_template: valid_attributes }, valid_session
          expect(response).to redirect_to(process_template_operation_templates_path(ProcessTemplate.last))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved process_template as @process_template' do
          post :create, { process_template: invalid_attributes }, valid_session
          expect(assigns(:process_template)).to be_a_new(ProcessTemplate)
        end

        it "re-renders the 'new' template" do
          post :create, { process_template: invalid_attributes }, valid_session
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        let(:new_attributes) do
          skip('Add a hash of attributes valid for your model')
        end

        it 'updates the requested process_template' do
          process_template = ProcessTemplate.create! valid_attributes
          put :update, { id: process_template.to_param, process_template: new_attributes }, valid_session
          process_template.reload
          skip('Add assertions for updated state')
        end

        it 'assigns the requested process_template as @process_template' do
          process_template = ProcessTemplate.create! valid_attributes
          put :update, { id: process_template.to_param, process_template: valid_attributes }, valid_session
          expect(assigns(:process_template)).to eq(process_template)
        end

        it 'redirects to the process_template' do
          process_template = ProcessTemplate.create! valid_attributes
          put :update, { id: process_template.to_param, process_template: valid_attributes }, valid_session
          expect(response).to redirect_to(process_template)
        end
      end

      describe 'with invalid params' do
        it 'assigns the process_template as @process_template' do
          process_template = ProcessTemplate.create! valid_attributes
          put :update, { id: process_template.to_param, process_template: invalid_attributes }, valid_session
          expect(assigns(:process_template)).to eq(process_template)
        end

        it "re-renders the 'edit' template" do
          process_template = ProcessTemplate.create! valid_attributes
          put :update, { id: process_template .to_param, process_template: invalid_attributes }, valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested process_template' do
        process_template = ProcessTemplate.create! valid_attributes
        expect do
          delete :destroy, { id: process_template.to_param }, valid_session
        end.to change(ProcessTemplate, :count).by(-1)
      end

      it 'redirects to the process_templates list' do
        process_template = ProcessTemplate.create! valid_attributes
        delete :destroy, { id: process_template.to_param }, valid_session
        expect(response).to redirect_to(process_templates_url)
      end
    end
  end
end
