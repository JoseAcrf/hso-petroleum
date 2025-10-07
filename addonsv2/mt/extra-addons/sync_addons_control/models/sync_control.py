from odoo import models, fields
import subprocess

class SyncControl(models.Model):
    _name = 'sync.control'
    _description = 'Sincronizador de módulos desde GitHub'

    name = fields.Char(default='Sincronizador')

    def sync_modules(self):
        repo_path = '/opt/odoo/hso-logistics'
        addons_path = '/mnt/extra-addons'

        subprocess.run(['git', '-C', repo_path, 'pull'])
        subprocess.run(['rsync', '-a', '--delete', f'{repo_path}/addonsv2/mt/extra-addons/', addons_path])
