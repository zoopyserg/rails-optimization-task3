if defined?(Bullet)
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
  Bullet.add_footer = true

  # Add more configurations as needed
  # Bullet.add_whitelist :type => :n_plus_one_query, :class_name => "Post", :association => :comments
end
