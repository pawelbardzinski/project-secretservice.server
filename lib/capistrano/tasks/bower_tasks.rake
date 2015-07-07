namespace :bower do
  task :install do
    on roles(:web) do |host|
      within "#{deploy_to}/current/" do
        system("admin/bower install")
      end
    end
  end
end