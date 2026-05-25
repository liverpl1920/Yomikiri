FactoryBot.define do
  factory :book_memo do
    association :book
    content { '読書中のメモです。' }

    trait :with_page_number do
      page_number { '100-120' }
    end
  end
end
