from django.urls import path
from . import views

urlpatterns = [
    path('column/<str:emission_type>/', views.column_view),
    path('table/', views.table_view),
    path('pie/', views.pie_view),
]
