angular.module("admin.resources").factory 'EnterpriseResource', ($resource) ->
  ignoredAttrs = ->
    ["$$hashKey", "producer", "package", "producerError", "packageError", "status"]

  $resource('/admin/enterprises/:id/:action.json', {}, {
    'index':
      method: 'GET'
      isArray: true
    'update':
      method: 'PUT'
    'removeLogo':
      method: 'DELETE'
      params:
        action: 'remove_logo'
    'removePromoImage':
      method: 'DELETE'
      params:
        action: 'remove_promo_image'
  })
