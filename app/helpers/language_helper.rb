module LanguageHelper
  LANGUAGES = {
    de: 'German',
    "es-co": 'Spanish (Columbia)',
    en: 'English',
    fr: 'French',
    nl: 'Dutch'
  }

  def language_options
    LANGUAGES.slice(*I18n.available_locales).invert.to_a
  end
end
