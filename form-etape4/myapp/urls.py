from django.urls import path
from .views import PersonListView, PersonCreateView

urlpatterns = [
    path('', PersonListView.as_view(), name='person_list'),
    path('create/', PersonCreateView.as_view(), name='person_create'),
]
