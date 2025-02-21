# from django.db.models.signals import pre_save
# from django.utils.text import slugify
from django.db import models
from django.core.urlresolvers import reverse
from django.conf import settings
import os
from os.path import basename


##############################  HANDLERS  #################################

def user_directory_path(instance, filename):
    '''File upload handler. Sets upload to path to /MEDIAROOT/user/{{username}}/{{filename}}'''
    return 'user/{0}/{1}'.format(instance.user, filename)



##############################  MODELS  #################################

class UPerson(models.Model):
    '''User for User Profile Stuff. Inherits Auth from Django Auth Model
    Look at BaseUserManager to figure out password'''
    user = models.ForeignKey(settings.AUTH_USER_MODEL)
    creation_date = models.DateTimeField(auto_now_add=True, auto_now=False)  # only when created, never overwritten
    info = models.CharField(verbose_name='Song Title', max_length=255, blank=False)

    def __unicode__(self):
        return '{}'.format(self.user)



class UMusic(models.Model):
    '''Table to store Song Information'''
    user = models.ForeignKey(settings.AUTH_USER_MODEL)
    creation_date = models.DateTimeField(auto_now_add=True, auto_now=False)  # only when created, never overwritten
    last_updated = models.DateTimeField(auto_now_add=False, auto_now=True)  # can be saved over
    song_title = models.CharField(verbose_name='Song Title', max_length=255, blank=False)
    song_json = models.TextField()
    song_seed = models.TextField()

    def __unicode__(self):
        return '{}'.format(self.user)

    def get_absolute_url(self):
        return reverse('u:USong', kwargs={'song_id': self.id})



class UMedia(models.Model):
    '''Table to store uploaded file'''
    user = models.ForeignKey(settings.AUTH_USER_MODEL)
    song = models.ManyToManyField(UMusic) # i think this can be deleted
    creation_date = models.DateTimeField(auto_now_add=True, auto_now=False)
    song_file = models.FileField(upload_to=user_directory_path)

    def get_absolute_url(self):
        return self.song_file.path

    def __unicode__(self):
        return '{}'.format(self.user)

    def label(self):
        return '{}'.format(basename(os.path.splitext(self.song_file.name)[0]))


### Slug function
# def pre_save_post_signal_receiver(sender, instance, *args, **kwargs):
#     slug = slugify('{}'.format(basename(os.path.splitext(instance.song_file.name)[0])))
#     exists = UMedia.objects.filter(slug=slug).exists()
#     if exists:
#         slug = '{0}-{1}'.format(slug, instance.id)
#     instance.slug = slug
#
# pre_save.connect(pre_save_post_signal_receiver, sender=UMedia)
