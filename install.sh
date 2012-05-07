#!/usr/bin/env python
import os
import sys
import shutil
from os import path
from optparse import OptionParser
import ConfigParser
from glob import glob

HOME=os.getenv('HOME')
BASH_IT=path.join(HOME, '.bash_it')
BASH_PROFILE = path.join(HOME, '.bash_profile')

def confirm(prompt=None, default=False):
    """
    Prompt the user for yes or no input.

    Returns True or False
    """
    if prompt is None:
        prompt = 'Confirm'

    if default:
        prompt = '%s [%s/%s]: ' % (prompt, 'Y', 'n')
    else:
        prompt = '%s [%s/%s]: ' % (prompt, 'y', 'N')
        
    while True:
        ans = raw_input(prompt)
        if not ans:
            return default
        elif ans.lower() == 'y':
            return True
        elif ans.lower() == 'n':
            return False
        else:            
            print 'Please enter y or n.'
            continue          

def ask(prompt, values, default=None):
    for i, v in enumerate(values):
        prompt += '\n  %d. %s' % (i + 1, v)

    prompt += '\n  Choice #?'

    if default:
        prompt += ' [%s]' % default

    prompt += ': '

    min = 1
    max = len(values)
    options = range(min, max + 1)

    while True:
        ans = raw_input(prompt)
        if not ans:
            return default

        try:
            ans = int(ans)
        except ValueError:
            print('Please enter a number %d-%d' % (min, max))
            prompt = '#?: '
            continue

        if ans in options:
            return values[ans - 1]
        else:
            print('Please enter a number %d-%d' % (min, max))
            prompt = '#?: '


def is_bash_it_installed():
    if path.exists(BASH_PROFILE):
        f = open(BASH_PROFILE, 'r')
        installed = '$BASH_IT' in f.read()
        f.close()
        return installed
    return False

class Configurator(object):
    def __init__(self, config, prompt):
        self.config = config
        self.prompt = prompt        

    def getbool(self, key, default=False):
        section, key = key.split('.', 1)
        if self.config.has_option(section, key):            
            val = self.config.getboolean(section, key)
        else:
            val = default

        return val

    def get(self, key, default=None):    
        section, key = key.split('.', 1)
        if self.config.has_option(section, key):            
            val = self.config.get(section, key)
        else:
            val = default

        return val

    def set(self, key, value):
        section, key = key.split('.', 1)
        if not self.config.has_section(section):
            self.config.add_section(section)

        self.config.set(section, key, value)

    def confirm(self, key, question, default=False):
        val = self.getbool(key, default)
        if self.prompt:
            val = confirm(question, val)

        if val:
            self.set(key, 'yes')
        else:
            self.set(key, 'no')
        return val

    def ask(self, key, question, values, default=None):
        val = self.get(key, default)

        if self.prompt:
            val = ask(question, values, val)

        self.set(key, val)
        return val


def main(configfile=None, prompt=True):
    config = ConfigParser.RawConfigParser()
    if configfile:        
        config.read(configfile)

    conf = Configurator(config, prompt)

    if is_bash_it_installed():        
        print('Bash-it already installed, running configurator...')
    else:
        profile_name = path.basename(BASH_PROFILE)
        if conf.confirm('bash-it.install', 'Do you want to install bash-it into your %s?' % profile_name):
            print('Installing bash-it into %s...' % profile_name)
            if path.exists(BASH_PROFILE) and conf.confirm('bash-it.backup', 'Do you want to back up your %s?' % profile_name, True):
                shutil.copy(BASH_PROFILE, BASH_PROFILE + '.bak')
                print("Your original .bash_profile has been backed up to %s.bak" % profile_name)

            shutil.copyfile(path.join(BASH_IT, 'template/bash_profile.template.bash'), BASH_PROFILE)

            print("Copied the template .bash_profile into %s, edit this file to customize bash-it" % BASH_PROFILE)


    jekyll_config = path.join(HOME, '.jekyllconfig')
    if path.exists(jekyll_config):
        print('Jekyll config already installed.')
    elif conf.confirm('jekyll.install', 'Do you use Jekyll? (If you don\'t know what Jekyll is, answer "n")'):
        shutil.copyfile(path.join(BASH_IT, 'template/jekyllconfig.template.bash'), jekyll_config)
        print("Copied the template .jekyllconfig to %s. Edit this file to customize bash-it for using the Jekyll plugins" % jekyll_config)

    for name, type in [('alias', 'aliases'), ('plugin', 'plugins'), ('completion', 'completion')]:
        resp = conf.ask('%s.install' % type, 'Would you like to enable all, some, or no %s? Some of these may make bash slower to start up (especially completion)' % type, values=['all', 'some', 'none'], default='all')
        install_dir = path.join(BASH_IT, type, 'enabled')

        if resp in ['all', 'some'] and not path.exists(install_dir):
            os.makedirs(install_dir)

        if resp in ['all', 'none']:
            config.remove_section(type)
            conf.set(type + '.install', resp)

        for filename in glob(path.join(BASH_IT, type, 'available', '*')):
            plugin_filename = path.basename(filename)
            if plugin_filename.startswith('_'):
                continue

            plugin_name, _ = plugin_filename.split('.', 1)

            install_file = path.join(install_dir, plugin_filename)
            conf_key = '.'.join([type, plugin_name])

            if resp == 'all' or (resp == 'some' and 
                conf.confirm(conf_key, 'Would you like to enable the %s %s' % (plugin_name, name))):
                if path.exists(install_file):
                    os.remove(install_file)

                os.symlink(filename, install_file)
                print('  Installed %s %s' % (plugin_name, name))
            elif path.exists(install_file):
                os.remove(install_file)
                print('  Removed %s %s' % (plugin_name, name))

    if conf.prompt:
        if confirm('Would you like to save your install preferences?'):
            filename = configfile or 'pref.ini'
            ans = raw_input('Where would you like to save to? [%s]:' % filename)
            if not ans:
                ans = filename

            ans = path.join(BASH_IT, ans)

            f = open(ans, 'w')
            config.write(f)
            f.close()
            print('Saved preferences to %s' % ans)


if __name__ == '__main__':    
    parser = OptionParser()
    parser.add_option('-c', '--config', dest='config',
                      help='Config file to use', metavar="FILE")
    parser.add_option('-n', '--no-prompt', dest='no_prompt', action='store_true',
                      help='Install without prompting.')

    (options, args) = parser.parse_args()

    if options.no_prompt and not options.config:
        parser.abort('You must supply a config to use without prompting.')

    try:
        main(options.config, not options.no_prompt)
    except KeyboardInterrupt:
        print('\nCancelled by keyboard.')
