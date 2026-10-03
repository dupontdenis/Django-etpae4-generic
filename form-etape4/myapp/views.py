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
