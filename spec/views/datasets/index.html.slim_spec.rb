require 'rails_helper'

RSpec.describe "datasets/index", type: :view do
  before(:each) do
    assign(:datasets, [
      Dataset.create!(
        :title => "Title",
        :csv_data => random_csv(4, 6)
      ),
      Dataset.create!(
        :title => "Title",
        :csv_data => random_csv(5, 8)
      )
    ])
  end

  it "renders a list of datasets" do
    render
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "4 fields and 6 rows".to_s, :count => 1
    assert_select "tr>td", :text => "5 fields and 8 rows".to_s, :count => 1
  end
end
