$(document).on('click', '.picture-block', ->
  chbox = $(this).find('.category-picture-chbox')
  image_opacity = 1
  is_checked = chbox.is(':checked')
  if is_checked
    image_opacity = 0.5
    $(this).find('.picture-action .glyphicon').removeClass('glyphicon-remove').addClass('glyphicon-ok')
  $(this).css({ opacity: image_opacity })
  chbox.prop('checked', !is_checked)
  return
)
.on('click', '.add-picture-block', ->
  chbox = $(this).find('.category-picture-chbox')
  is_checked = chbox.is(':checked')
  if is_checked
    $(this).find('.picture-action').hide()
  else
    $(this).find('.picture-action').show()
  chbox.prop('checked', !is_checked)
  return
)