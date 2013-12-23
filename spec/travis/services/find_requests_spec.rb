require 'spec_helper'

describe Travis::Services::FindRequests do
  include Support::ActiveRecord

  let(:repo)    { Factory(:repository, :owner_name => 'travis-ci', :name => 'travis-core') }
  let!(:request)  { Factory(:request, :repository => repo) }
  let!(:newer_request)  { Factory(:request, :repository => repo) }
  let(:service) { described_class.new(stub('user'), params) }

  attr_reader :params

  describe 'run' do
    it 'finds recent requests when older_than is not given' do
      @params = { :repository_id => repo.id }
      service.run.should == [newer_request, request]
    end

    it 'finds requests older than the given id' do
      @params = { :repository_id => repo.id, :older_than => newer_request.id }
      service.run.should == [request]
    end

    it 'does not find anything if repository_id is missing' do
      @params = { }
      service.run.should == Request.none
    end

    it 'scopes to the given repository_id' do
      @params = { :repository_id => repo.id }
      Factory(:request, :repository => Factory(:repository))
      service.run.should == [newer_request, request]
    end

    it 'returns an empty request scope when the repository could not be found' do
      @params = { :repository_id => repo.id + 1 }
      service.run.should == Request.none
    end
  end
end
