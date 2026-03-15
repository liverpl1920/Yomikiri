FactoryBot.define do
  factory :book do
    association :user
    title { '実践的なRailsアプリケーション開発' }
    author { '山田太郎' }
    total_pages { 300 }
    target_pages { 300 }
    current_page { 0 }
    deadline { Date.today + 14 }
    status { :unread }
    extension_count { 0 }
    completed_at { nil }
  end
end
