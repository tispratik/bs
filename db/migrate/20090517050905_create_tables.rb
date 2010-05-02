class CreateTables < ActiveRecord::Migration
  def self.up
    
    create_table :projects do |t|
      t.string :name
      t.string :alias, :limit => 25
      t.string :permalink, :limit => 20
      t.integer :status
      t.string :description, :limit => 3000
      t.boolean :is_public
      t.text :objectives
      t.boolean :use_ssl
      t.datetime :created_at      
    end
    
    add_index :projects, :permalink, :unique => true
    
    create_table :project_roles do |t|
      t.references :project
      t.references :user
      t.string :name
    end
    
    add_index :project_roles, :user_id
    add_index :project_roles, :project_id
    
    create_table :calendars do |t|
      t.references :calendarable, :polymorphic => true
      t.string :name
    end
    
    add_index :calendars, :calendarable_id
    
    create_table :events do |t|
      t.references :calendar
      t.references :event_series
      t.string :summary
      t.string :location
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :all_day
      
      t.integer :created_by
      t.timestamps
    end
    
    add_index :events, :calendar_id

    create_table :event_invitees do |t|
      t.references :event
      t.references :user
    end
    
    create_table :wiki_pages do |t|
      t.references :project
      t.string :title
      t.text :content
      t.datetime :deleted_at
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
    
    add_index :wiki_pages, :project_id
    add_index :wiki_pages, :created_by
    
    create_table :versions do |t|
      t.belongs_to :versioned, :polymorphic => true
      t.belongs_to :user, :polymorphic => true
      t.string :user_name
      t.text :changes
      t.integer :number
      t.string :tag
      t.timestamps
    end
    
    add_index :versions, [:versioned_id, :versioned_type]
    add_index :versions, [:user_id, :user_type]
    add_index :versions, :user_name
    add_index :versions, :number
    add_index :versions, :tag
    add_index :versions, :created_at
    
    create_table :articles do |t|
      t.references :project
      t.string :title
      t.string :citation_source
      t.string :citation_author
      t.date :citation_date
      t.text :content
      t.integer :created_by
      t.integer :updated_by
      t.boolean :delta, :default => true, :null => false
      t.timestamps
    end
    
    add_index :articles, :project_id
    add_index :articles, :created_by
    
    create_table :tasks do |t|
      t.references :project
      t.string :name
      t.string :alias, :limit => 25
      t.string :description, :limit => 3000
      t.integer :assign_to
      t.date :due_date
      t.integer :task_type
      t.integer :priority
      t.integer :status
      t.datetime :deleted_at
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
    
    add_index :tasks, :project_id
    add_index :tasks, :created_by
    add_index :tasks, :updated_by
    add_index :tasks, :assign_to
    add_index :tasks, :due_date
    
    create_table :comments do |t|
      t.references :commentable, :polymorphic => true
      t.boolean :is_spam
      t.integer :parent_id
      t.text :message
      t.integer :created_by
      t.datetime :created_at
      t.string :source
    end
    
    add_index :comments, :created_by
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
    
    create_table :tags do |t|
      t.references :taggable, :polymorphic => true
      t.string :name
      t.references :project
      t.timestamps
    end
    
    add_index :tags, :taggable_id
    
    create_table :assets do |t|
      t.references :attachable, :polymorphic => true
      t.string :data_file_name
      t.integer :version
      t.integer :status
      t.string :data_content_type
      t.string :data_file_size
      t.string :orig_name
      t.integer :created_by
      t.integer :updated_by
      t.integer :checkout_by
      t.datetime :checkout_on
      t.timestamps
    end
    
    add_index :assets, :attachable_id
    
    create_table :project_invitations do |t|
      t.references :project
      t.references :user
      t.boolean :confirmed, :default => false
      t.timestamps
    end
    
    add_index :project_invitations, [:project_id, :user_id], :unique => true
    
    create_table :filters do |t|
      t.string :filter_name
      t.string :display_name
      t.string :filter_param
      t.integer :sort_order
    end
    
    create_table :filter_params do |t|
      t.string :filter_param
      t.string :disp_value
      t.string :internal_param
      t.string :internal_value
      t.integer :sort_order
    end

    create_table :event_series do |t|
      t.references :calendar
      t.string :summary
      t.string :location
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :all_day
      t.string  :repeat_frequency
      t.integer :repeat_interval
      t.integer :repeat_until_count
      t.date    :repeat_until_date
      t.string  :on_wdays
      t.text    :invitees
      
      t.datetime :processed_at
      t.integer :created_by
      t.timestamps
    end
  end
end
