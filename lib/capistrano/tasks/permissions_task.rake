namespace :permissions do
  task :set_images do
    on roles(:web) do |host|
      #within "#{deploy_to}/current/public" do
        info "Setting permissions in images"
        execute "chmod 777 #{deploy_to}/current/public/images"
        execute "chmod 777 #{deploy_to}/current/public/images/*"
      #end
    end
  end
end
