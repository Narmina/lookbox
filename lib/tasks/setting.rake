namespace :settings do

  desc "add locales to database"
  task :add_locales => :environment do
    existed_locales_list = Locale.all.pluck(:locale)
    Locale::DEFAULT_LIST.each do |loc|
      next if existed_locales_list.include? loc[:locale]
      Locale.create(locale: loc[:locale], name: loc[:name])
    end
  end

  desc "make locales visible/invisible"
  task :locales_visibility => :environment do
    return unless ENV['VISIBLE']
    locales = ENV['LOCALES'] ? Locale.where(locale: ENV['LOCALES'].split(',')) : Locale.all
    locales.each {|loc| loc.update(visible: ENV['VISIBLE']) }
  end

end