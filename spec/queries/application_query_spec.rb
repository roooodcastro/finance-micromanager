# frozen_string_literal: true

RSpec.describe ApplicationQuery, type: :query do
  let(:params_test_query_class) do
    Class.new(described_class) do
      bind :uuid_param,        'uuid'
      bind :string_param,      'string'
      bind :integer_param,     'int'
      bind :float_param,       'float'
      bind :datetime_param,    'datetime'
      bind :array_param,       'int', array: true
      bind :proc_param,        'string'
      bind :default_int,       'int', default: 2
      bind :default_proc,      'string', default: -> { 'test' }

      def base_query
        <<~SQL.squish
          SELECT * FROM table
          WHERE
            uuid_param = @uuid_param
            AND string_param = @string_param
            AND integer_param = @integer_param
            AND float_param = @float_param
            AND datetime_param = @datetime_param
            AND array_param IN (@array_param)
            AND proc_param = @proc_param
            AND default_int = @default_int
            AND default_proc = @default_proc
        SQL
      end
    end
  end

  describe '#results' do
    subject { params_test_query_class.run(params) }

    let(:params) do
      {
        uuid_param:     SecureRandom.uuid,
        string_param:   'one',
        integer_param:  2,
        float_param:    42.0,
        datetime_param: Time.zone.parse('2007-02-10 15:30:45'),
        array_param:    [1, 2, 3],
        proc_param:     -> { 'proc' }
      }
    end

    let(:expected_params) { params.values[0..4] + ['{1,2,3}', 'proc', 2, 'test'] }
    let(:expected_result) { [{ field1: 1, field2: 'lorem' }] }

    let(:expected_query) do
      <<~SQL.squish
        SELECT * FROM table
        WHERE
          uuid_param = $1
          AND string_param = $2
          AND integer_param = $3
          AND float_param = $4
          AND datetime_param = $5
          AND array_param IN (ANY ($6))
          AND proc_param = $7
          AND default_int = $8
          AND default_proc = $9
      SQL
    end

    before do
      allow(params_test_query_class).to receive(:name).and_return('ParamsTestQueryClass')

      allow(ApplicationRecord.connection)
        .to receive(:exec_query)
        .with(expected_query, 'ParamsTestQueryClass', expected_params)
        .and_return(expected_result)
    end

    it { is_expected.to eq expected_result }
  end

  describe '.wrapper_class' do
    subject(:results) { wrapper_test_query_class.run }

    let(:test_wrapper_class) { Struct.new('TestWrapper', :name, :email) }

    let(:wrapper_test_query_class) do
      Class.new(ApplicationQuery) do
        def wrapper_class
          TestWrapperClass
        end

        def base_query
          'SELECT * FROM table'
        end
      end
    end

    let(:expected_result) do
      [
        { name: 'First', email: 'first@email.com' },
        { name: 'Second', email: 'second@email.com' }
      ]
    end

    before do
      allow(wrapper_test_query_class).to receive(:name).and_return('WrapperTestQueryClass')

      stub_const('TestWrapperClass', test_wrapper_class)

      allow(ApplicationRecord.connection)
        .to receive(:exec_query)
        .with('SELECT * FROM table', 'WrapperTestQueryClass', [])
        .and_return(expected_result)
    end

    it 'results are all wrapped in the wrapper class' do
      expect(results.count).to eq(2)
      expect(results).to all(be_an_instance_of(test_wrapper_class))
      expect(results.first.name).to eq 'First'
      expect(results.first.email).to eq 'first@email.com'
    end
  end
end
