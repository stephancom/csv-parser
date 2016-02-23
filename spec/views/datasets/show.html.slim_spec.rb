require 'rails_helper'

RSpec.describe "datasets/show", type: :view do
  before(:each) do
    @csv_data = random_csv(5, 8)
    @dataset = assign(:dataset, Dataset.create!(
      :title => "Title",
      :transformer => 'stock_item',
      :csv_data => @csv_data
    ))
  end

  it "renders attributes" do
    render
    expect(rendered).to match(/Title/)
    expect(rendered).to match(/Stock Item/)
    expect(rendered).to match(@csv_data)
    assert_select "textarea", :text => @csv_data, :count => 1
  end

  it "renders a table with the right count of rows and columns" do
    render
    assert_select "table>thead>tr", count: 1
    assert_select "table>thead>tr>th", count: 5
    assert_select "table>tbody>tr", count: 8
    assert_select "table>tbody>tr>td", count: 5*8
  end
end
