require 'spec_helper'

describe ActiveModel::Serializer::CanCan::Abilities do
  let(:user) { User.first }
  let(:category) { Category.first }

  class MockAbility
    include CanCan::Ability

    def initialize(user)
      can :manage, Category
      cannot :read, Category
    end
  end

  describe '.abilities' do
    let(:serializer) do
      Class.new(ActiveModel::Serializer) do
        attributes :id
        abilities :restful, :foo
        def current_ability
          MockAbility.new(nil)
        end

        def can_foo?
          true
        end
      end
    end

    let(:category_serializer) { serializer.new(category, scope: user) }

    context 'serializable_hash' do
      subject { category_serializer.serializable_hash }
      its(:keys) { should eq [:id, :abilities] }
    end

    context 'abilities key' do
      subject { category_serializer.serializable_hash[:abilities] }
      its([:restful]) { should be_nil }
      its([:update]) { should be_true }
      its([:show]) { should be_false }
      its([:foo]) { should be_true }
    end
  end
end
