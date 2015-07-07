
namespace :swagger do
  task :rebuild do
    on roles(:web) do |host|
      within "#{deploy_to}/current/" do
        execute :rake, 'swagger:docs', "RAILS_ENV='production'"
      end
    end
  end


  task :symlinkui do
    on roles(:web) do
      within "#{deploy_to}" do
        execute :ln, '-s' ,'/var/www/swaggerui/', deploy_to + '/current/public/api'
      end
    end
  end
end

