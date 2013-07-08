require 'spec_helper'

describe 'Model' do
  before(:each) do
    ## black magic: set @@cql_client to nil before each test
    Cql::Model.class_variable_set(:@@cql_client,nil)
    ## black magic: end
    @client = double('Client')
    Cql::Client.stub(:connect).and_return(@client)
  end

  it 'create client with default configs' do
    Cql::Client.should_receive(:connect).with({'server' => 'localhost'})
    Cql::Model.cql_client
  end

  it 'allows to set default configs' do
    Cql::Model.default_config = {'server' => 'super_host'}
    Cql::Client.should_receive(:connect).with({'server' => 'super_host'})
    Cql::Model.cql_client
  end
end