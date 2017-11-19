# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.coffee.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on('mouseenter', '.pictures-list .picture-block, .pictures-list .look-picture-block', -> $(this).find('.picture-action').show()
).on('mouseleave', '.pictures-list .picture-block, .pictures-list .look-picture-block', -> $(this).find('.picture-action').hide()
).on('click', '#rotate_image', ->
  angle = parseInt($('#picture_rotation').val()) || 0
  angle = (angle + 90) % 360
  $('.fileinput-preview.thumbnail').removeClass("rotate0 rotate90 rotate180 rotate270").addClass("rotate" + angle)
  $('#picture_rotation').val(angle)
  return false
).on('change.bs.fileinput', '.fileinput', ->
  if $('#picture_title').val() == ''
    $('#picture_title').val($('input[type=file]').val().split('\\').pop().split('.').shift().replace(/_/g, ' '))
).on('click', '.picture-show .btn-left, .picture-show .btn-right, .btn-back-pictures', (e)->
  $('#picture-modal-' + $(this).attr('data-picture-id')).modal('hide')
  $('#modal-form').modal('hide')
  return true
)

ready = ->
  $('.show-picture-image').elevateZoom({
      zoomType				: "lens",
      lensShape : "round",
      lensSize    : 150
  })

  return

$(document).ready(ready)
$(document).on('page:load', ready)




