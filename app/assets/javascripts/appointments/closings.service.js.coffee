angular.module('calendarApp')

.service 'Closings', ['restmod', (restmod)->
  restmod.model('/admin/closings')
]
