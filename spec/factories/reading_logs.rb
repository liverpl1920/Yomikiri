FactoryBot.define do
  factory :reading_log do
    association :book
    pages_read { 10 }
    read_at { Date.current }
  end
end
