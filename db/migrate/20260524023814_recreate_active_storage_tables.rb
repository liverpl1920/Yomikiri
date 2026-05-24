# frozen_string_literal: true

# Active Storage テーブルを再作成する。
# 以前の DropActiveStorageTables (20260412060806) で削除されたテーブルを復元。
class RecreateActiveStorageTables < ActiveRecord::Migration[7.2]
  def change
    # active_storage_blobs
    create_table :active_storage_blobs do |t|
      t.string   :key,          null: false
      t.string   :filename,     null: false
      t.string   :content_type
      t.text     :metadata
      t.string   :service_name, null: false
      t.bigint   :byte_size,    null: false
      t.string   :checksum

      t.datetime :created_at, null: false
    end
    add_index :active_storage_blobs, [:key], unique: true

    # active_storage_attachments
    create_table :active_storage_attachments do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false
      t.references :blob,     null: false

      t.datetime :created_at, null: false
    end
    add_index :active_storage_attachments,
              %i[record_type record_id name blob_id],
              unique: true,
              name: :index_active_storage_attachments_uniqueness
    add_foreign_key :active_storage_attachments,
                    :active_storage_blobs,
                    column: :blob_id

    # active_storage_variant_records
    create_table :active_storage_variant_records do |t|
      t.belongs_to :blob,                      null: false, index: false
      t.string     :variation_digest,           null: false
    end
    add_index :active_storage_variant_records,
              %i[blob_id variation_digest],
              unique: true,
              name: :index_active_storage_variant_records_uniqueness
    add_foreign_key :active_storage_variant_records,
                    :active_storage_blobs,
                    column: :blob_id
  end
end
