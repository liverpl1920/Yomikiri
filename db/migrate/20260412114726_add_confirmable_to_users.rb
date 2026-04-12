class AddConfirmableToUsers < ActiveRecord::Migration[7.2]
  def change
    # マイグレーション内で User モデル定数を直接参照しない（モデル変更に対する堅牢性のため）
    migration_user = Class.new(ActiveRecord::Base) do
      self.table_name = :users
    end

    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string
    add_index :users, :confirmation_token, unique: true

    # 既存ユーザーを確認済みとして扱う（ロックアウト防止）
    reversible do |dir|
      dir.up { migration_user.update_all('confirmed_at = created_at') }
    end
  end
end
