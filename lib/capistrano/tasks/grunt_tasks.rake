namespace :grunt do
  task :build do
    on roles(:web) do |host|
      within "#{deploy_to}/current/" do
        system("admin/grunt concurrent:lessServer")
      end
    end
  end
end
