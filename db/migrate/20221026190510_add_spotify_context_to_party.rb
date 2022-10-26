class AddSpotifyContextToParty < ActiveRecord::Migration[7.0]
  def change
    add_column :parties, :context_uri, :string
    add_column :parties, :uri,         :string
    add_column :parties, :position,    :integer
  end
end
