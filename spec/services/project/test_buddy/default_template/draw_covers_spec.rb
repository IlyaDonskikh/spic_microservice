RSpec.describe Project::TestBuddy::DefaultTemplate::DrawCovers do
  it 'should create file jpg' do
    obj = Project::TestBuddy::DefaultTemplate::DrawCovers.call(
      content: [
        { 'title' => 'Hello',
          'teams' => [
            { 'name' => 'Mike', 'score' => 8, 'total' => {'won' => 0, 'lost' => { 'today' => 5 }}},
            { 'name' => 'Bob', 'score' => 8, 'total' => {'won' => 6, 'lost' => { 'today' => 6 }}},
          ]
        }
      ]
    )

    p obj.failure?
    p obj.message

    expect(obj).to eq('text')
  end
end
