require 'sinatra'
require 'json'


# Lire les articles depuis le fichier JSON
def read_article
    if File.exist?("articles.json")  # Charger les données existantes
        JSON.parse(File.read("articles.json"), symbolize_names: true)
    else # Ou créer un tableau vide
        []
    end
end

# Écrire les articles dans le fichier JSON
def write_article(articles)
    File.open("articles.json", "w") do |file|
        file.write(JSON.pretty_generate(articles))
    end
end

# Page d'accueil avec la liste des articles
get '/' do
    @articles = read_article

    erb :index
end

# Afficher la page de création d'un article
get '/creer_article' do
    erb :create
end

# Créer un article
post '/article' do
    articles = read_article

    nouvel_article = {
        id: articles.empty? ? 1 : articles.last[:id] + 1,
        titre: params[:titre],
        contenu: params[:contenu] 
    }

    articles << nouvel_article # Ajouter les nouvelles données
    write_article(articles)

    redirect '/'
end

# Afficher la page de modification d'un article
get '/modifier_article/:id' do
    @articles = read_article

    @article = @articles.find { |a| a[:id] == params[:id].to_i}

    erb :edit
end

# Mettre à jour un article
post '/mise_a_jour/:id' do
    articles = read_article

    article = articles.find { |a| a[:id] == params[:id].to_i}

    if article
        article[:titre] = params[:titre]
        article[:contenu] = params[:contenu]
        write_article(articles)
    end

    redirect '/'
end

# Supprimer un article
post '/supprimer/:id' do
    articles = read_article

    articles.reject! { |a| a[:id] == params[:id].to_i }
    write_article(articles)

    redirect '/'
end

# Afficher un article en détail
get '/article/:id' do
    @articles = read_article
    @article = @articles.find { |a| a[:id] == params[:id].to_i }

    erb :article
end

# Ajouter un commentaire
post '/article/:id/commentaire' do
    articles = read_article
    article = articles.find { |a| a[:id] == params[:id].to_i }
  
    if article
      commentaire = {
        auteur: params[:auteur],
        contenu: params[:contenu],
        date: Time.now.strftime("%d/%m/%Y %H:%M")
      }
  
      # Ajouter le commentaire dans l'article
      article[:commentaires] ||= [] # S'assurer que la clé existe
      article[:commentaires] << commentaire
  
      write_article(articles)
    end
  
    redirect "/article/#{params[:id]}"
end
  

# Afficher le formulaire de modification d'un commentaire
get '/article/:id/modifier_commentaire/:index' do
    @articles = read_article
    @article = @articles.find { |a| a[:id] == params[:id].to_i }
  
    @index = params[:index].to_i
    @commentaire = @article[:commentaires][@index]
  
    erb :edit_com
end

# Mettre à jour un commentaire
post '/article/:id/mise_a_jour_commentaire/:index' do
    articles = read_article
    article = articles.find { |a| a[:id] == params[:id].to_i }
  
    if article
      index = params[:index].to_i
      if article[:commentaires] && article[:commentaires][index]
        article[:commentaires][index][:auteur] = params[:auteur]
        article[:commentaires][index][:contenu] = params[:contenu]
        write_article(articles)
      end
    end
  
    redirect "/article/#{params[:id]}"
end

# Supprimer un commentaire
post '/article/:id/supprimer_commentaire/:index' do
    articles = read_article
    article = articles.find { |a| a[:id] == params[:id].to_i }
  
    if article
      index = params[:index].to_i
      if article[:commentaires] && article[:commentaires][index]
        article[:commentaires].delete_at(index)
        write_article(articles)
      end
    end
  
    redirect "/article/#{params[:id]}"
end