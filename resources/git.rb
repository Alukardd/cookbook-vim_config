actions :create

attribute :repository, :kind_of => String, :name_attribute => true
attribute :reference, :kind_of => String, :default => "master"