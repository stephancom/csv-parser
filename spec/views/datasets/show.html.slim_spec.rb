require 'rails_helper'

RSpec.describe "datasets/show", type: :view do
  before(:each) do
    @csv_data = random_csv(5, 8)
    @dataset = assign(:dataset, Dataset.create!(
      :title => "Title",
      :csv_data => @csv_data
    ))
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(@csv_data)
    assert_select "textarea", :text => @csv_data, :count => 1
  end
end
