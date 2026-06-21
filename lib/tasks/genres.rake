# frozen_string_literal: true

namespace :genres do
  desc "既存ユーザーにデフォルトジャンルを設定する"
  task setup_defaults: :environment do
    User.find_each do |user|
      created_count = 0
      User::DEFAULT_GENRES.each do |name|
        genre = user.genres.find_or_initialize_by(name: name)
        if genre.new_record?
          genre.save!
          created_count += 1
        end
      end
      if created_count > 0
        puts "User #{user.email}: #{created_count} genres created"
      end
    end
  end
end
