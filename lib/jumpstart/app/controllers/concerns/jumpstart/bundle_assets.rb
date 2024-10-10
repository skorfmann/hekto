module Jumpstart::BundleAssets
  # Automatically compiles assets if yarn build commands aren't running

  extend ActiveSupport::Concern

  included do
    before_action :ensure_assets_bundled, if: -> { Rails.env.development? }
  end

  private

  def ensure_assets_bundled
    if ["application.js", "application.css"].any? { |path| !asset_precompiled?(path) }
      system("bin/yarn run build && bin/yarn run build:css")
    end
  end

  # Try Propshaft first, fallback to Sprockets
  def asset_precompiled?(path)
    if Rails.application.assets.respond_to?(:load_path)
      Rails.application.assets.load_path.find(path)
    elsif Rails.application.respond_to?(:asset_precompiled?)
      Rails.application.asset_precompiled?(path)
    end
  end
end
