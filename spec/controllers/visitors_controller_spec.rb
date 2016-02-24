require 'rails_helper'

describe VisitorsController, type: :controller do
  describe 'get #index' do
    let(:valid_session) { {} }

    it 'should redirect to datasets#index' do
      get :index, {}, valid_session
      expect(response.status).to eq(200)
    end
  end
end