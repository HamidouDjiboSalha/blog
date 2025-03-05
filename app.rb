require 'sinatra'
require 'json'


# Lire les articles depuis le fichier JSON
def lire_articles
    if File.exist?("articles.json")  # Charger les données existantes
        JSON.parse(File.read("articles.json"), symbolize_names: true)
    else # Ou créer un tableau vide
        []
    end
end

# Écrire les articles dans le fichier JSON
def ecrire_articles(articles)
    File.open("articles.json", "w") do |file|
        file.write(JSON.pretty_generate(articles))
    end
end

# Page d'accueil avec la liste des articles
get '/' do
    @articles = lire_articles

    erb :index
end

# Afficher la page de création d'un article
get '/creer_article' do
    erb :creer
end

# Créer un article
post '/article' do
    articles = lire_articles

    nouvel_article = {
        id: articles.empty? ? 1 : articles.last[:id] + 1,
        titre: params[:titre],
        contenu: params[:contenu] 
    }

    articles << nouvel_article # Ajouter les nouvelles données
    ecrire_articles(articles)

    redirect '/'
end

# Afficher la page de modification d'un article
get '/modifier_article/:id' do
    @articles = lire_articles

    @article = @articles.find { |a| a[:id] == params[:id].to_i}

    erb :modifier
end

# Mettre à jour un article
post '/mise_a_jour/:id' do
    articles = lire_articles

    article = articles.find { |a| a[:id] == params[:id].to_i}

    if article
        article[:titre] = params[:titre]
        article[:contenu] = params[:contenu]
        ecrire_articles(articles)
    end

    redirect '/'
end

# Supprimer un article
post '/supprimer/:id' do
    articles = lire_articles

    articles.reject! { |a| a[:id] == params[:id].to_i }
    ecrire_articles(articles)

    redirect '/'
end
