class Material::StorageCondition < ActiveRecord::Base
  def self.table_name_prefix
    'material_'
  end
end
