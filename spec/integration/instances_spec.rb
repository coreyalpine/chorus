require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Instances", :database_integration do
  context "adding a data source" do
    before do
      login(users(:admin))
      visit("#/instances")
      click_button "Add Data Source"
    end

    def select_and_do_within(value)
      page.should have_xpath('//select[@id="data_sources"]/option[4]')
      find(".instance_new.dialog").should have_content("Data Source Type")
      page.find("#data_sources-button span.ui-selectmenu-text").should have_content("Select one")
      select_item("select.data_sources", value)
      page.find("#data_sources-button span.ui-selectmenu-text").should have_no_content("Select one")
      within ".data_sources_form.#{value}" do
        yield
      end
    end

    it "creates a gpdb instance" do
      within_modal do
        select_and_do_within "register_existing_greenplum" do
          fill_in 'name', :with => "new_gpdb_instance"
          fill_in 'host', :with => WEBPATH['gpdb_instance_db']['gpdb_host']
          fill_in 'port', :with => WEBPATH['gpdb_instance_db']['gpdb_port']
          fill_in 'dbUsername', :with => WEBPATH['gpdb_instance_db']['gpdb_user']
          fill_in 'dbPassword', :with => WEBPATH['gpdb_instance_db']['gpdb_pass']
        end
        click_button "Add Data Source"
      end

      find(".gpdb_instance ul").should have_content("new_gpdb_instance")
    end

    it "creates an hadoop instance" do
      within_modal do
        select_and_do_within "register_existing_hadoop" do
          fill_in 'name', :with => "new_hadoop_instance"
          fill_in 'host', :with => WEBPATH['hadoop_instance_db']['host']
          fill_in 'port', :with => WEBPATH['hadoop_instance_db']['port']
          fill_in 'username', :with => WEBPATH['hadoop_instance_db']['username']
          fill_in 'groupList', :with => WEBPATH['hadoop_instance_db']['group_list']
        end
        click_button "Add Data Source"
      end

      find(".hadoop_instance ul").should have_content("new_hadoop_instance")
    end
  end

  context "importing a hadoop file into an external table" do
    let(:hadoop_instance) { hadoop_instances(:real) }

    before do
      admin = users(:admin)
      admin.owned_workspaces.create!({:name => "integration_with_sandbox", :sandbox => InstanceIntegration.real_database.schemas.first, :public => true}, :without_protection => true)

      any_instance_of(ExternalTable) do |table|
        stub(table).save { true }
      end

      login(admin)
    end

    it 'creates an external table', :hdfs_integration => true do
      pending "there seems to be some kind of backend error in the test setup"
      visit "#/hadoop_instances/#{hadoop_instance.to_param}/browse"
      click_link '2_lines.csv'
      click_link 'Create as an external table'
      within_modal do
        fill_in 'tableName', :with => 'new_external_table'
        click_button 'Create External Table'
      end
      click_link 'new_external_table'
      page.should have_content 'Sandbox Table - HDFS External'
    end

    after do
      dataset = Dataset.find_by_name('new_external_table')
      dataset.destroy if dataset
    end
  end
end