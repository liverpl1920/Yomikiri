FactoryBot.define do
  factory :book do
    association :user
    title { '実践的なRailsアプリケーション開発' }
    author { '山田太郎' }
    genre { '技術書' }
    total_pages { 300 }
    target_pages { 300 }
    current_page { 0 }
    deadline { Date.current + 14 }
    extension_count { 0 }
    completed_at { nil }
  end
end
