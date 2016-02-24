require 'rails_helper'

describe VisitorsController, type: :controller do
  describe 'get #index' do
    let(:valid_session) { {} }

    it 'should redirect to datasets#index' do
      get :index, {}, valid_session
      expect(response).to redirect_to(datasets_path)
    end
  end
end