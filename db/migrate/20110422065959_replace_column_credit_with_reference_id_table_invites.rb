class ReplaceColumnCreditWithReferenceIdTableInvites < ActiveRecord::Migration
  def self.up
    remove_column :invites, :credit
    add_column :invites , :reference_id ,:integer
  end

  def self.down
    remove_column :invites, :reference_id
  end
end
