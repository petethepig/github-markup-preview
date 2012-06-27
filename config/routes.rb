GitHubMarkupPreview::Application.routes.draw do
  root :to => 'home#index'
  match '/render' => 'home#renderr', :via => :post
  match '/readme' => 'home#readme', :via => :get
end
