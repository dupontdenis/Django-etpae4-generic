# ================================
# Script d'installation Étape 4 Django (Generic Views)
#  — Projet pédagogique
# À lancer dans PowerShell : .\setup-etape4.ps1
# ================================

Write-Host "=== Création du projet Django Étape 4 ==="

# 1. Création du dossier
New-Item -ItemType Directory -Force -Name "form-etape4"
Set-Location "form-etape4"

# 2. Environnement virtuel
Write-Host "=== Création du venv ==="
python -m venv .venv
.\.venv\Scripts\activate

# 3. Installation Django
Write-Host "=== Installation Django ==="
pip install django

# 4. Création du projet
Write-Host "=== django-admin startproject form ==="
django-admin startproject form .

# 5. Création de l'app
Write-Host "=== python manage.py startapp myapp ==="
python manage.py startapp myapp


Write-Host "=== Configuration settings.py ==="

$settings = "form\settings.py"

# Lire tout le fichier
$content = Get-Content $settings

# Vérifier si myapp est déjà présent
if ($content -match "'myapp'") {
    Write-Host "myapp est déjà présent dans INSTALLED_APPS."
}
else {
    # Chercher exactement la ligne INSTALLED_APPS = [
    $index = -1

    for ($i = 0; $i -lt $content.Count; $i++) {
        if ($content[$i] -match "^\s*INSTALLED_APPS\s*=\s*\[") {
            $index = $i
            break
        }
    }

    if ($index -eq -1) {
        Write-Host "ERREUR : INSTALLED_APPS n'a pas été trouvé."
    }
    else {
        # Convertir en liste modifiable
        $list = [System.Collections.Generic.List[string]]::new()
        $list.AddRange([string[]]$content)

        # Ajouter myapp juste après INSTALLED_APPS = [
        $list.Insert($index + 1, "    'myapp',")

        # Sauvegarder
        $list | Set-Content $settings

        Write-Host "myapp a été ajouté dans INSTALLED_APPS."
    }
}


# 7. Création du modèle Person
Write-Host "=== Création du modèle Person ==="
@"
from django.db import models

class Person(models.Model):
    first_name = models.CharField(max_length=100)
    last_name = models.CharField(max_length=100)

    def __str__(self):
        return f"{self.first_name} {self.last_name}"
"@ | Set-Content "myapp\models.py"

# 8. Création du ModelForm
Write-Host "=== Création du ModelForm ==="
@"
from django import forms
from .models import Person

class PersonForm(forms.ModelForm):
    class Meta:
        model = Person
        fields = ['first_name', 'last_name']
"@ | Set-Content "myapp\forms.py"

# 9. Création des vues Generic Views
Write-Host "=== Création des vues GenericView ==="
@"
from django.views.generic import ListView, CreateView
from django.urls import reverse_lazy
from .models import Person

class PersonListView(ListView):
    model = Person
    template_name = 'myapp/person_list.html'
    context_object_name = 'persons'

class PersonCreateView(CreateView):
    model = Person
    fields = ['first_name', 'last_name']
    template_name = 'myapp/person_create.html'
    success_url = reverse_lazy('person_list')
"@ | Set-Content "myapp\views.py"

# 10. URLs de l'app Generic Views
Write-Host "=== Création des URLs GenericView ==="
@"
from django.urls import path
from .views import PersonListView, PersonCreateView

urlpatterns = [
    path('', PersonListView.as_view(), name='person_list'),
    path('create/', PersonCreateView.as_view(), name='person_create'),
]
"@ | Set-Content "myapp\urls.py"

# 11. Inclusion des URLs dans form/urls.py
Write-Host "=== Inclusion des URLs dans form/urls.py ==="
@"
from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('myapp.urls')),
]
"@ | Set-Content "form\urls.py"

# 12. Templates
Write-Host "=== Création des templates ==="
New-Item -ItemType Directory -Force -Path "myapp\templates\myapp"

@"
<h1>Liste des personnes</h1>

<ul>
{% for p in persons %}
    <li>{{ p.first_name }} {{ p.last_name }}</li>
{% endfor %}
</ul>

<a href="/create/">Ajouter une personne</a>
"@ | Set-Content "myapp\templates\myapp\person_list.html"

@"
<h1>Créer une personne</h1>

<form method="POST">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Créer</button>
</form>

<a href="/">Retour</a>
"@ | Set-Content "myapp\templates\myapp\person_create.html"

# 13. Migrations
Write-Host "=== Migration ==="
python manage.py makemigrations
python manage.py migrate

# 14. Création du .gitignore
Write-Host "=== Création du .gitignore ==="
@"
.venv/
db.sqlite3
__pycache__/
*.pyc
.DS_Store
"@ | Set-Content ".gitignore"

# 15. Génération requirements.txt
Write-Host "=== Génération requirements.txt ==="
pip freeze > requirements.txt

Write-Host "=== Projet Étape 4 prêt ! ==="
Write-Host "Lancez : python manage.py runserver"