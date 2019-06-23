require 'formation/form'

RSpec.describe Formation::Form do
  after { Object.send(:remove_const, :SomeForm) if defined?(SomeForm) }
  let(:resource) { double(attributes: {}) }

  describe '.new' do
    it 'returns the form instance' do
      SomeForm = Class.new(Formation::Form)

      form = SomeForm.new(resource)

      expect(form).to be_kind_of SomeForm
    end

    it 'assigns form attributes with values passed as second argument' do
      SomeForm =
        Class.new(Formation::Form) do
          attribute :phone_number
          attribute :full_name
        end

      form =
        SomeForm.new({ full_name: 'Joe Smith', phone_number: '0000000000' })

      expect(form.full_name).to eq 'Joe Smith'
      expect(form.phone_number).to eq '0000000000'
    end

    it 'handles both symbols and strings as attribute keys' do
      SomeForm =
        Class.new(Formation::Form) do
          attribute :phone_number
          attribute :full_name
        end

      form =
        SomeForm.new(
          resource,
          { 'full_name' => 'Joe Smith', 'phone_number' => '0000000000' }
        )

      # expect(form.full_name).to eq "Joe Smith"
      expect(form.phone_number).to eq '0000000000'
    end

    context 'Second parameter is an ActionController::Parameters object' do
      it 'treats ActionController::Parameters as regular hash' do
        SomeForm =
          Class.new(Formation::Form) do
            attribute :first_name
            attribute :last_name
          end

        strong_parameters =
          ActionController::Parameters.new(
            { 'first_name' => 'joe', 'last_name' => 'smith' }
          )

        form = SomeForm.new(resource, strong_parameters)

        expect(form.first_name).to eq 'joe'
        expect(form.last_name).to eq 'smith'
      end
    end

    context 'if only parameter is ActionController::Parameters object' do
      it 'treats ActionController::Parameters as regular hash' do
        SomeForm =
          Class.new(Formation::Form) do
            attribute :first_name
            attribute :last_name
          end

        strong_parameters =
          ActionController::Parameters.new(
            { 'first_name' => 'joe', 'last_name' => 'smith' }
          )

        form = SomeForm.new(strong_parameters)

        expect(form.first_name).to eq 'joe'
        expect(form.last_name).to eq 'smith'
      end
    end

    it 'can be initialized without providing resource' do
      SomeForm = Class.new(Formation::Form)

      form = SomeForm.new

      expect(form).to be_kind_of(SomeForm)
    end

    context 'when resource exists' do
      context 'when resource responds to #attributes' do
        it 'assigns merged attributes from resource and passed as argument' do
          SomeForm =
            Class.new(Formation::Form) do
              attribute :first_name
              attribute :last_name
            end
          resource =
            double(attributes: { first_name: 'Jack', last_name: 'Black' })

          form = SomeForm.new(resource, { first_name: 'Tony' })

          expect(form.first_name).to eq 'Tony'
          expect(form.last_name).to eq 'Black'
        end
      end

      context 'when resource does not responds to #attributes' do
        it 'assigns merged attributes from resource public method and passed as argument' do
          SomeForm =
            Class.new(Formation::Form) do
              attribute :first_name
              attribute :last_name
            end
          resource = double(first_name: 'Jack', last_name: 'Black')

          form = SomeForm.new(resource, { first_name: 'Tony' })

          expect(form.first_name).to eq 'Tony'
          expect(form.last_name).to eq 'Black'
        end
      end
    end
  end

  describe '#save' do
    context 'when form is valid' do
      it 'requires #persist method to be implemented' do
        SomeForm = Class.new(Formation::Form)

        form = SomeForm.new(resource)

        expect { form.save }.to raise_error NotImplementedError,
                    '#persist has to be implemented'
      end

      it 'returns result of #persist method' do
        SomeForm =
          Class.new(Formation::Form) do
            private

            def persist
              10
            end
          end

        form = SomeForm.new(resource)
        result = form.save

        expect(result).to eq 10
      end
    end

    context 'when form is invalid' do
      it 'does not call #persist' do
        SomeForm = Class.new(Formation::Form)

        form = SomeForm.new(resource)
        expect(form).to receive(:valid?) { false }
        expect(form).not_to receive(:persist)

        form.save
      end

      it 'returns false' do
        SomeForm = Class.new(Formation::Form)

        form = SomeForm.new(resource)
        allow(form).to receive(:valid?) { false }

        expect(form.save).to eq false
      end
    end
  end

  describe '#save!' do
    context '#save returned falsey value' do
      it 'returns Formation::Form::Invalid exception' do
        SomeForm =
          Class.new(Formation::Form) do
            private

            def persist
              10
            end
          end
        form = SomeForm.new(resource)
        allow(form).to receive(:save) { false }

        expect { form.save! }.to raise_error Formation::Form::Invalid
      end
    end

    context '#save returned truthy value' do
      it 'returns value returned from #save' do
        SomeForm =
          Class.new(Formation::Form) do
            private

            def persist
              10
            end
          end
        form = SomeForm.new(resource)

        expect(form.save!).to eq 10
      end
    end
  end

  describe '#persisted?' do
    context 'resource is nil' do
      it 'returns false' do
        SomeForm = Class.new(Formation::Form)

        form = SomeForm.new

        expect(form.persisted?).to eq false
      end
    end

    context 'resource is not nil' do
      context 'when resource responds to #persisted?' do
        it 'returns resource#persisted?' do
          SomeForm = Class.new(Formation::Form)

          form_1 = SomeForm.new(double(attributes: {}, persisted?: true))
          form_2 = SomeForm.new(double(attributes: {}, persisted?: false))

          expect(form_1.persisted?).to eq true
          expect(form_2.persisted?).to eq false
        end
      end

      context 'when resource does not respond to #persisted?' do
        it 'returns false' do
          SomeForm = Class.new(Formation::Form)

          form = SomeForm.new(resource)

          expect(form.persisted?).to eq false
        end
      end
    end
  end

  describe '#to_model' do
    it 'returns itself' do
      SomeForm = Class.new(Formation::Form)

      form = SomeForm.new(resource)

      expect(form.to_model).to eq form
    end
  end

  describe '#to_partial_path' do
    it 'returns nil' do
      SomeForm = Class.new(Formation::Form)

      form = SomeForm.new(resource)

      expect(form.to_partial_path).to eq nil
    end
  end

  describe '#to_key' do
    it 'returns nil' do
      SomeForm = Class.new(Formation::Form)

      form = SomeForm.new(resource)

      expect(form.to_key).to eq nil
    end
  end

  describe '#to_param' do
    context 'resource exists' do
      context 'resource responds to #to_param' do
        it 'returns resource#to_param' do
          SomeForm = Class.new(Formation::Form)
          resource = double(attributes: {}, to_param: 100)

          form = SomeForm.new(resource)

          expect(form.to_param).to eq 100
        end
      end
    end

    context 'resource does not exist' do
      it 'returns nil' do
        SomeForm = Class.new(Formation::Form)

        form = SomeForm.new

        expect(form.to_param).to eq nil
      end
    end
  end

  describe '#model_name' do
    context 'resource given, resource responds to #model_name, and param_key is not defined' do
      it "returns object's model name param_key, route_key and singular_route_key" do
        SomeForm = Class.new(Formation::Form)
        resource =
          double(
            attributes: {},
            model_name:
              double(
                param_key: 'resource_key',
                route_key: 'resource_keys',
                singular_route_key: 'resource_key'
              )
          )

        form = SomeForm.new(resource)
        result = form.model_name

        expect(result).to have_attributes(
          param_key: 'resource_key',
          route_key: 'resource_keys',
          singular_route_key: 'resource_key'
        )
      end
    end

    context 'param_key is defined' do
      it 'returns param_key, route_key and singular_route_key derived from param key' do
        SomeForm = Class.new(Formation::Form) { param_key 'test_key' }

        resource =
          double(
            attributes: {},
            model_name:
              double(
                param_key: 'resource_key',
                route_key: 'resource_keys',
                singular_route_key: 'resource_key'
              )
          )

        form = SomeForm.new(resource)
        result = form.model_name

        expect(result).to have_attributes(
          param_key: 'test_key',
          route_key: 'test_keys',
          singular_route_key: 'test_key'
        )
      end
    end

    context 'resource does not exist and param_key is not defined' do
      it 'raises NoParamKey' do
        SomeForm = Class.new(Formation::Form)

        form = SomeForm.new

        expect { form.model_name }.to raise_error(Formation::Form::NoParamKey)
      end
    end

    context 'resource does not exist and param_key is defined' do
      it 'returns param_key, route_key and singular_route_key derived from param key' do
        SomeForm = Class.new(Formation::Form) { param_key 'test_key' }

        form = SomeForm.new
        result = form.model_name

        expect(result).to have_attributes(
          param_key: 'test_key',
          route_key: 'test_keys',
          singular_route_key: 'test_key'
        )
      end
    end
  end

  describe '#attributes' do
    context 'no value given' do
      it "returns a hash of form's attributes" do
        SomeForm =
          Class.new(Formation::Form) do
            attribute :first_name
            attribute :last_name
          end

        form = SomeForm.new(resource)

        expect(form.attributes).to eq ({ first_name: nil, last_name: nil })
      end
    end

    context 'Value given' do
      it "returns a hash of form's attributes" do
        SomeForm =
          Class.new(Formation::Form) do
            attribute :first_name
            attribute :last_name
          end

        form = SomeForm.new(resource, { last_name: 'smith' })

        expect(form.attributes).to eq ({ first_name: nil, last_name: 'smith' })
      end
    end
  end

  describe '#resource' do
    it 'returns passed in object' do
      SomeForm = Class.new(Formation::Form)

      form = SomeForm.new(resource)
      expect(form.resource).to be resource
    end
  end
end
