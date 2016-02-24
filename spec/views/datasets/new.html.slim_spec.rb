require 'rails_helper'

RSpec.describe "datasets/new", type: :view do
  before(:each) do
    assign(:dataset, Dataset.new(
      :title => "MyString",
      :csv_data => "MyText"
    ))
  end

  it "renders new dataset form" do
    render

    assert_select "form[action=?][method=?]", datasets_path, "post" do

      assert_select "input#dataset_title[name=?]", "dataset[title]"

      assert_select "select#dataset_transformer[name=?]", "dataset[transformer]"

      assert_select "textarea#dataset_csv_data[name=?]", "dataset[csv_data]"
    end
  end
end
