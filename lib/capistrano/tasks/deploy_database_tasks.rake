
namespace :deploy do
  task :database do
    on roles(:web) do |host|
      within "#{deploy_to}/current/" do
        execute :rake, 'db:migrate', "RAILS_ENV='production'"
      end
    end
  end
end