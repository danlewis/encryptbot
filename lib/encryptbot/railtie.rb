class EncryptbotRailtie < Rails::Railtie
  config.before_configuration do
    Encryptbot.configure
  end

  rake_tasks do
    load "tasks/encryptbot.rake"
  end
end