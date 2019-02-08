class Locale < ActiveRecord::Base

  DEFAULT_LIST = [ {locale: 'en', name: 'English'}, {locale: 'de', name: 'Deutsch'}, {locale: 'ru', name: 'Русский'},
                   {locale: 'ua', name: 'Українська'}, {locale: 'es', name: 'Español'} ]

  def self.list
    @locales ||= self.where(visible: true)
  end

  def self.locales_set
    self.list.collect{|loc| [loc.name, loc.id]}
  end

  def self.default_locale
    self.list.find_by_locale(I18n.default_locale.to_s)
  end

  def self.routes_locales
     self.list.map(&:locale).join('|')
  end

end
