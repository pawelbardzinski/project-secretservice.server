namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action do
      on roles(:web) do
        execute "/etc/init.d/apache2 #{action.to_s}"
      end
    end
  end
end