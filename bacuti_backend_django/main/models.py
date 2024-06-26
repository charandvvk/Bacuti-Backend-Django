from django.db import models

# Create your models here.
class Products(models.Model):
    product_id = models.UUIDField(primary_key=True)
    name = models.TextField()

    class Meta:
        managed = False
        db_table = 'products'


class Subassemblies(models.Model):
    subassembly_id = models.UUIDField(primary_key=True)
    product = models.ForeignKey(Products, models.DO_NOTHING)
    subassembly_parent = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    name = models.TextField()
    quantity = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'subassemblies'


class Components(models.Model):
    component_id = models.UUIDField(primary_key=True)
    product = models.ForeignKey('Products', models.DO_NOTHING)
    subassembly_parent = models.ForeignKey('Subassemblies', models.DO_NOTHING, blank=True, null=True)
    name = models.TextField()
    quantity = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'components'


class Emissions(models.Model):
    emission_id = models.AutoField(primary_key=True)
    component = models.ForeignKey(Components, models.DO_NOTHING)
    month = models.TextField(blank=True, null=True)
    category = models.TextField(blank=True, null=True)
    pef_total = models.IntegerField()
    scope_1 = models.IntegerField()
    scope_2 = models.IntegerField()
    scope_3 = models.IntegerField()
    category_1 = models.IntegerField()
    category_5 = models.IntegerField()
    category_12 = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'emissions'