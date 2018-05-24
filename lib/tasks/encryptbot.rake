namespace :encryptbot do
  
  desc "Add certificate"
  task add_cert: :environment do
    Encryptbot::Cert.new.add
  end

end