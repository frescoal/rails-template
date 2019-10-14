# Rails Templates

Pour générer des application rails avec la configuration par défaut de Wavemind basé sur les
[Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

## Procédure

Voici la procédure pour créer une nouvelle application 

### Choix du modèle

Pour avoir la configuration de base de rails 5.2+ avec Bootstrap, Simple form, devise et les gem de debug

```bash
rails new \
  --database postgresql \
  --webpack \
  -m https://raw.githubusercontent.com/frescoal/rails-template/master/devise.rb \
  NOM_DE_L_APP
```

### .env
Définir les accès à la base de données dans le ficher ```.env``` 
```
DEV_DB_NAME='MA_BASE_DE_DONNEE_dev'
DEV_DB_USERNAME='root'
DEV_DB_PASSWORD='root'

TEST_DB_NAME='MA_BASE_DE_DONNEE_test'
TEST_DB_USERNAME='root'
TEST_DB_PASSWORD='root'
```

### Migrer la base de donnée
une fois la base de données configurée lancer la commande pour créer et initialiser la base de données
```
rails db:create
rails db:migrate
```

### git flow
Tout le long du développement utiliser ```git flow``` pour créer les branches et effectuer les merges etc.
Voir la [Documentation](https://wavemind.atlassian.net/wiki/spaces/DEV/pages/1577455/Git)

A chaque fin de feature créer une pull Request et mettre @Alain Fresco comme verificateur

:warning: Pas de merge sur ```develop``` sans validation de la pull Request


