require 'rails_helper'

RSpec.describe "datasets/edit", type: :view do
  before(:each) do
    @dataset = assign(:dataset, Dataset.create!(
      :title => "MyString",
      :csv_data => "MyText"
    ))
  end

  it "renders the edit dataset form" do
    render

    assert_select "form[action=?][method=?]", dataset_path(@dataset), "post" do

      assert_select "input#dataset_title[name=?]", "dataset[title]"

      assert_select "select#dataset_transformer[name=?]", "dataset[transformer]"

      assert_select "textarea#dataset_csv_data[name=?]", "dataset[csv_data]"
    end
  end
end
