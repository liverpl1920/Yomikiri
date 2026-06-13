FactoryBot.define do
  factory :genre do
    association :user
    sequence(:name) { |n| "ジャンル#{n}" }
  end
end
