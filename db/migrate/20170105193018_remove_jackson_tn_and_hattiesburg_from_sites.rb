class RemoveJacksonTnAndHattiesburgFromSites < ActiveRecord::Migration
  def change
    Site.where(name: ['Hattiesburg', 'Jackson TN']).destroy_all
  end
end
