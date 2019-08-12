RSpec.describe ConsumerContentRouter do
  it 'should pass data to interactor' do
    stub_interactor_call

    router = ConsumerContentRouter.call(
      project: request_attrs[:project],
      template: request_attrs[:template],
      content: request_attrs
    )

    expect(router).to eq(true)
  end

  it 'should fail if project attr not defined' do
    args = {
      template: request_attrs[:template],
      content: request_attrs
    }

    expect { ConsumerContentRouter.call(args) }.to raise_error(KeyError)
  end

  it 'should fail if project has a false name' do
    wrong_project_name = 'HeСalledMeWrong1'

    args = {
      project: wrong_project_name,
      template: request_attrs[:template],
      content: request_attrs
    }

    expect { ConsumerContentRouter.call(args) }.to raise_error(NameError)
  end

  private

    def request_attrs
      {
        project: 'TestBuddy',
        template: 'default',
        sharing_type: 'false_sharing_type',
        resource_type: 'test',
        resource_id: 1,
        template_body: picture_template_body # rspec helpers
      }
    end

    def stub_interactor_call
      allow(Project::TestBuddy::DefaultTemplate::DrawCover)
        .to receive(:call).and_return(true)
    end
end
