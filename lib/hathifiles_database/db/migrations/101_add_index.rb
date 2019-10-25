require 'sequel'
require 'hathifiles_database/constants'
include HathifilesDatabase::Constants

Sequel.extension :migration

# Add indexes after importing data
Sequel.migration do
  up do
    alter_table(MAINTABLE) do
      add_index [:htid],  unique: true
      MAINTABLE_INDEXES.each do |col|
        add_index [col]
      end
    end

    FOREIGN_TABLES.values.each do |table|
      alter_table(table) do
        add_foreign_key [:htid], MAINTABLE, key: :htid, on_delete: :cascade
        add_index [:value]
      end
    end
  end

end