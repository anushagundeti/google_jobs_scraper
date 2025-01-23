class CreateJobFetchers < ActiveRecord::Migration[7.0]
  def change
    create_table :job_fetchers do |t|

      t.timestamps
    end
  end
end
