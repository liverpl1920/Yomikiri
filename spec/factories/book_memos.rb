FactoryBot.define do
  factory :book_memo do
    association :book
    content { '読書中のメモです。' }
  end
end
