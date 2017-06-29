ActionController::Routing::Routes.draw do |map|
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.my_peer_portfolio  '/my_peer_portfolio', :controller => 'my', :action => 'my_peer_portfolio'
  map.my_performance_summary  '/my_performance_summary', :controller => 'my', :action => 'my_performance_summary'
  map.market_my_funds '/market_my_funds', :controller => 'my', :action => 'market_my_funds'

  
  map.resources :users
  map.resources :reviews, :collection => {:initiate => :post, :report => :get, :get_universes => :get}
  
  map.get_universes "get_universes/:fund_id", :controller => "reviews", :action => "get_universes"
  
  map.resource :session
  map.resource :user_session
	map.resources :set_of_sets
	map.resources :elem_of_sets

  map.add_fund_to_portfolio 'portfolio/add/:id', :controller => "portfolio", :action => "create"
  map.remove_fund_from_portfolio 'portfolio/remove/:id', :controller => "portfolio", :action => "destroy"
  map.my_funds "/my_funds", :controller => "my", :action => "my_funds"
  # map.my_fund 'my_funds/:id', :controller => "funds", :action => "show"
  map.my_fund 'my_funds/:id.:format', :controller => "funds", :action => "show"

  # activities
  map.activities '/activity', :controller => 'activity', :action => 'index'
  map.update_my_fund_activity '/update_my_fund_activity', :controller => 'activity', :action => 'update_my_fund_activity'
  map.create_report '/create_report', :controller => 'activity', :action => 'create_report'
  map.view_fund '/view_fund', :controller => 'activity', :action => 'view_fund'
  # map.resources :funds, :only => [:show]
	
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "my", :action=> "landing"
  map.root :controller => "my", :action => "index"
  map.update_my_funds "/update_my_funds", :controller => "my", :action => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
