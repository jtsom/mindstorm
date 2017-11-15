class AddSendEmailFlagToCompetitions < ActiveRecord::Migration[5.1]
  def change
    add_column :competitions, :send_email, :boolean, default: false
  end
end
