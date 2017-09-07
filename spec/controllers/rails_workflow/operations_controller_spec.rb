# frozen_string_literal: true

require 'rails_helper'

module RailsWorkflow
  RSpec.describe OperationsController, type: :controller do
    routes { RailsWorkflow::Engine.routes }

    let(:valid_attributes) do
      skip('Add a hash of attributes valid for your model')
    end

    let(:invalid_attributes) do
      skip('Add a hash of attributes invalid for your model')
    end

    let(:valid_session) { {} }

    describe 'GET index' do
      it 'assigns all wf_operations as @wf_operations' do
        wf_operation = Operation.create! valid_attributes
        get :index, {}, valid_session
        expect(assigns(:operations)).to eq([wf_operation])
      end
    end

    describe 'GET show' do
      it 'assigns the requested wf_operation as @wf_operation' do
        wf_operation = Operation.create! valid_attributes
        get :show, { id: wf_operation.to_param }, valid_session
        expect(assigns(:operations)).to eq(wf_operation)
      end
    end

    describe 'GET new' do
      # it "assigns a new operation as operation" do
      #   process = create(:process)
      #
      #   get :new, {process_id: process.id}, valid_session, use_route: [:workflow, :processes]
      #   expect(assigns(:operation)).to be_a_new(Operation)
      # end
    end

    describe 'GET edit' do
      it 'assigns the requested wf_operation as @wf_operation' do
        wf_operation = Operation.create! valid_attributes
        get :edit, { id: wf_operation.to_param }, valid_session
        expect(assigns(:operations)).to eq(wf_operation)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new WfOperation' do
          expect do
            post :create, { operations: valid_attributes }, valid_session
          end.to change(Operation, :count).by(1)
        end

        it 'assigns a newly created wf_operation as @wf_operation' do
          post :create, { operations: valid_attributes }, valid_session
          expect(assigns(:operations)).to be_a(Operation)
          expect(assigns(:operations)).to be_persisted
        end

        it 'redirects to the created wf_operation' do
          post :create, { operations: valid_attributes }, valid_session
          expect(response).to redirect_to(Operation.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved wf_operation as @wf_operation' do
          post :create, { operations: invalid_attributes }, valid_session
          expect(assigns(:operations)).to be_a_new(Operation)
        end

        it "re-renders the 'new' template" do
          post :create, { operations: invalid_attributes }, valid_session
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        let(:new_attributes) do
          skip('Add a hash of attributes valid for your model')
        end

        it 'updates the requested wf_operation' do
          wf_operation = Operation.create! valid_attributes
          put :update, { id: wf_operation.to_param, operations: new_attributes }, valid_session
          wf_operation.reload
          skip('Add assertions for updated state')
        end

        it 'assigns the requested wf_operation as @wf_operation' do
          wf_operation = Operation.create! valid_attributes
          put :update, { id: wf_operation.to_param, operations: valid_attributes }, valid_session
          expect(assigns(:operations)).to eq(wf_operation)
        end

        it 'redirects to the wf_operation' do
          wf_operation = Operation.create! valid_attributes
          put :update, { id: wf_operation.to_param, operations: valid_attributes }, valid_session
          expect(response).to redirect_to(wf_operation)
        end
      end

      describe 'with invalid params' do
        it 'assigns the wf_operation as @wf_operation' do
          wf_operation = Operation.create! valid_attributes
          put :update, { id: wf_operation.to_param, operations: invalid_attributes }, valid_session
          expect(assigns(:operations)).to eq(wf_operation)
        end

        it "re-renders the 'edit' template" do
          wf_operation = Operation.create! valid_attributes
          put :update, { id: wf_operation.to_param, operations: invalid_attributes }, valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested wf_operation' do
        wf_operation = Operation.create! valid_attributes
        expect do
          delete :destroy, { id: wf_operation.to_param }, valid_session
        end.to change(Operation, :count).by(-1)
      end

      it 'redirects to the wf_operations list' do
        wf_operation = Operation.create! valid_attributes
        delete :destroy, { id: wf_operation.to_param }, valid_session
        expect(response).to redirect_to(wf_operations_url)
      end
    end
  end
end
