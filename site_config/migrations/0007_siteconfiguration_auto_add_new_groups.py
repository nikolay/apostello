# -*- coding: utf-8 -*-
# Generated by Django 1.10.1 on 2016-09-23 17:34
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [("apostello", "0013_keyword_linked_groups"), ("site_config", "0006_auto_20160531_1955")]

    operations = [
        migrations.AddField(
            model_name="siteconfiguration",
            name="auto_add_new_groups",
            field=models.ManyToManyField(
                blank=True,
                help_text="Any brand new people will be added to the groups selected here",
                to="apostello.RecipientGroup",
            ),
        )
    ]
