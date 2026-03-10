Rails.application.config.to_prepare do
  Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/models"))
end
