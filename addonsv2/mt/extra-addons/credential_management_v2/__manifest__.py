{
    'name': 'Project List',
    'version': '1.0',
    'category': 'Productivity',
    'summary': 'Modulo para gestionar listas de proyectos con niveles de prioridad y etapas de producción.',
    'description': """
        Este módulo permite gestionar listas de proyectos con información de nombre, autor, descripción,
        niveles de prioridad y etapas de producción.
    """,
    'author': 'Tu Nombre',
    'website': 'http://www.tusitio.com',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
        'views/project_list_views.xml',
    ],
    'installable': True,
    'application': True,
    'auto_install': False,
}
