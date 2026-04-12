class AddConfirmableToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true

    # 既存ユーザーを確認済みとして扱う（ロックアウト防止）
    reversible do |dir|
      dir.up { User.update_all('confirmed_at = created_at') }
    end
  end
end
