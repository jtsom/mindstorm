Mindstorm::Application.routes.draw do

  namespace :api, defaults: {format: 'json'} do
    resources :competitions do
      resources :qualifications
      resources :finals
      resources :teams do
        resources :qualifications
        resources :finals
        resources :robot_scores
      end
    end
  end

  get "sessions/new"

  resources :finals
  resources :qualifications
  resources :sessions
  resources :competitions

  resources :teams do
    resources :finals
    resources :qualifications
    resources :project_scores
    resources :robot_scores
    resources :corevalue_scores
  end

  get 'login', :to => 'sessions#new', :as => :login
  get 'logout', :to => 'sessions#destroy', :as => :logout

  get 'standings', :to =>  'teams#standings'
  get 'textstandings', :to => 'teams#text_standings'
  
  #map.standings 'standings', :controller => 'teams', :action => 'standings'
  get 'results', :to  => 'teams#results'
  #map.results 'results', :controller => 'teams', :action => 'results'
  get 'all_teams', :to => 'teams#all_teams'

  post 'teams/upload', :to => 'teams#upload'
  post 'teams/matchupload', :to => 'teams#matchupload'

  get 'sendresults/:id', :to => 'teams#sendresults', :as => :sendresults

  root :to  => 'sessions#new'


end
