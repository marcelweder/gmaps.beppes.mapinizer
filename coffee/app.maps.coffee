###
Google Maps App, aka BeppesMapinizer // jshint ;debug;
Author: Marcel A. Weder

###

"use strict" 

google  = window.google
$       = window.jQuery

markersContainer = []
markers = [
  'marker': null
  'latitude': 47.411993
  'longitude': 9.625236
  'icon': '/location/icons/maps-marker-home.png',
  'zIndex': 100
  'trigger': false # open infowin
]

$beppeto = $('<input type="text" id="beppeto" value="Chur/GR, Bahnhof" placeholder="...">')

$travelmode = $('<select id="travelmode"><option value="TRANSIT">Transit</option><option value="BICYCLING">Fahrrad</option><option value="WALKING">Zu Fuss</option></select>')

$viewporter = $('<input type="checkbox" id="preserveViewport" title="Ganze Route anzeigen">')

$beppefrom = $('<div><div class="infowindow-content"><form class="form" id="routeplaner" onsubmit="return window.beppe.calcRoute(); return false;"></form></div></div>')

class BeppesMapinizer

  ###
  constructor
  @param string canvas The id of map container (html element)
  @param string results The id of result container (html element)
  @param mixed options
  @return void
  ###
  constructor: (@canvas, @results, @options) ->

    @defaults =
      'panoramio': false
      'weather': false
      'bicycling': false
      'cloud': false
      'transit': false
      'traffic': false

    @options = $.extend @defaults, @options || {}

    @map = null
    @mapOptions = 
      'scrollwheel': false
      'zoom': 15
      'mapTypeControl': true
    @mapControl = null

    @directions = null
    @directionsOptions = {}
    @directionsService = null
    @directionsOptions =
      'hideRouteList': false,
      'preserveViewport': true
      'suppressMarkers': false
      'draggable': true
      'polylineOptions': 
        'strokeColor': '#00ccff'
        'strokeWeight': 5
        'strokeOpacity': 0.8

    @resultsRouter = null
    @resultsRouterContent = null

    @infoWinVisible = false
    @infoWin = null

    @panoramio = null
    @panoramioWidget = !!window.panoramio    
    @panoramioCfg = 
      'tag': 'heerbrugg'
      'suppressInfoWindows': @panoramioWidget
      #'userId': '875924'

    @weather = null
    @bicycling = null
    @cloud = null
    @transit = null
    @traffic = null 

    @routeLocked = false

    @mapCoordinates =
      'center': {'latitude': 47.414455, 'longitude': 9.617414}
      'moi': {'latitude': 47.411993, 'longitude': 9.625236}
      'centerLatLan': null
      'moiLatLan': null

  ###
  setupMap
  @return void
  ###
  setupMap: () ->    
    that = @

    if @options.mapCoordinates
      $.extend @mapCoordinates, @options.mapCoordinates

    @mapCoordinates.centerLatLan = new google.maps.LatLng(@mapCoordinates.center.latitude, @mapCoordinates.center.longitude)
    @mapCoordinates.moiLatLan = new google.maps.LatLng(@mapCoordinates.moi.latitude, @mapCoordinates.moi.longitude)

    $.extend @mapOptions, 
      'mapTypeId': google.maps.MapTypeId.SATELLITE
      'mapTypeControlOptions': { 'style': google.maps.MapTypeControlStyle.DEFAULT }
      'center': @mapCoordinates.centerLatLan
    , @options.mapCfg || {}

    if @options.panoramioCfg
      $.extend @panoramioCfg, @options.panoramioCfg

    @map = new google.maps.Map @canvas, @mapOptions

    $mapControl = $('#map-control').show()
    $resultsRouter = $('#map-directions')
    $resultsRouterContent = $('#map-directions-results')

    @mapControl = $mapControl
    @resultsRouter = $resultsRouter
    @resultsRouterContent = $resultsRouterContent

    $resultsRouter.find('.close').on 'click', (e) ->
      e.preventDefault()

      $resultsRouter.hide()
      that.unsetDirections()

      $('#map-control').trigger 'activated'

      return false
    return

  ###
  stateInfoWin
  @param boolean state Toggle the visibilty flag
  @return void
  ###
  stateInfoWin: (state) ->
    state = state || null
    if state == null
      return @infoWinVisible
    @infoWinVisible = state
    return

  ###
  setupInfoWin
  @return void
  ###
  setupInfoWin: () ->
    that = @

    @infoWin =  new google.maps.InfoWindow
      'maxWidth': 500
      'disableAutoPan': false
      'pixelOffset': new google.maps.Size(8, -32)

    google.maps.event.addListener @infoWin, 'closeclick', ->
      that.infoWinVisible = false
      return

    return

  ###
  setupMarker
  @return void
  ###
  setupMarker: () ->
    that = @

    mapsMarker = (options) ->
      icon = if options.icon then new google.maps.MarkerImage(options.icon, new google.maps.Size(52, 56, 'px', 'px')) else null
      marker = new google.maps.Marker
        'animation': google.maps.Animation.DROP
        'icon': icon
        'title': options.title
        'zIndex': parseInt(options.zIndex, null)
        'position': new google.maps.LatLng options.latitude, options.longitude              

      marker.setMap that.map

      google.maps.event.addListener marker, 'click', ->

        if !that.infoWinVisible
          that.infoWin.setPosition this.getPosition()

          # special  
          request = that.resultsRouter.data('request')        
          if request
            $beppeto.attr 'value', request.destination
            $travelmode.find('option').removeAttr('selected').filter ->
              if $(this).val() == request.travelMode
                $(this).attr 'selected', 'selected'
              return true
            $viewporter.removeAttr('checked')
            if request.preserveViewport
              $viewporter.attr 'checked', 'checked'            

          $routeplaner = $beppefrom.find('#routeplaner').empty()

          $routeplaner.append '<label for="beppeto">Wohin geht die Reise?</label>'
          $routeplaner.append(
            $('<div class="control-group">').append(
              $('<div class="controls">').append(
                $('<div class="input-append">').append(
                  $beppeto, '<button class="btn" type="submit">Go!</button>'
                )
              )
            )
          )
          $routeplaner.append(
            $('<div class="control-group">').append(
              $('<div class="controls controls-row">').append(
                $travelmode.addClass('span6'), 
                $('<label class="checkbox span6">').text('Zoom').prepend($viewporter)
              )
            )
          )

          that.infoWin.setContent $beppefrom.html()
          that.infoWin.open that.map 
          that.infoWinVisible = true

        else
          that.infoWin.close()
          that.infoWinVisible = false

        return

      if options.trigger
        google.maps.event.trigger marker, 'click'

      markersContainer.push marker
      return

    mapsMarker options for options in markers
    return

  ###
  initDirections
  @return void
  ###
  initDirections: () ->
    @directionsService = new google.maps.DirectionsService()
    @directions = new google.maps.DirectionsRenderer @directionsOptions
    @results = document.getElementById @results || ""
    if @results  
      @directions.setPanel @results  
    return

  ###
  setDirections
  @return void
  ###
  setDirections: (opts) ->
    opts = opts || null
    @directions.setMap @map
    if opts
      @directions.setOptions opts
    return

  ###
  unsetDirections
  @return void
  ###
  unsetDirections: () ->
    @directions.setMap null
    return

  ###
  mapInitialize
  @return void
  ###
  mapInitialize: () ->
    @canvas = document.getElementById @canvas || ""
    if !@canvas
      return false

    @initDirections()
    @setupMap()
    @setupInfoWin()
    @setupMarker()

    if @options.panoramio
      @setPanoramino(@panoramioCfg) 

    if @options.weather
      @setWeather()

    if @options.cloud
      @setCloud()

    if @options.bicycling
      @setBicycling()

    if @options.transit
      @setTransit()

    if @options.traffic
      @setTraffic()

    return  

  ###
  calcRoute
  @return void
  ###
  calcRoute: () ->
    that = @

    @routeLocked = true

    preserveViewport = $('#preserveViewport').is(':checked')

    @setDirections({ 'preserveViewport': !preserveViewport })

    @mapControl.trigger 'deactivated'

    @unsetPanoramino() 
    @unsetWeather()
    @unsetCloud()
    @unsetBicycling()
    # @unsetTransit()
    @unsetTraffic()

    start      = @mapCoordinates.moiLatLan
    end        = $('#beppeto').val()
    travelmode = $('#travelmode').val() || 'DRIVING'

    request = 
      'origin': start
      'destination': end
      'waypoints': []
      'optimizeWaypoints': true
      'provideRouteAlternatives': true
      'travelMode': google.maps.TravelMode[travelmode]
      'unitSystem': google.maps.UnitSystem.METRIC

    if !request.destination.length
      $('#beppeto').focus()
      return false;

    that.resultsRouter.data 'request', { 'travelMode': request.travelMode, 'destination': request.destination, 'preserveViewport': preserveViewport }
    that.resultsRouterContent.empty()
    
    if travelmode == 'TRANSIT'
      # request.origin = 'Bahnhof, 9435 Heerbrugg, Schweiz';
      request.origin = new google.maps.LatLng(47.410387, 9.627245);
      request.waypoints = []; # on transit waypoints doesn't work!

    # console.log request

    @directionsService.route request, (response, status) ->

      if status == google.maps.DirectionsStatus.OK

        that.directions.setDirections response

        if markersContainer[0]
          google.maps.event.trigger markersContainer[0], 'click'

      else

        switch status
          when 'ZERO_RESULTS'
            that.resultsRouterContent.html 'No route could be found between the origin and destination.'
          when 'UNKNOWN_ERROR'
            that.resultsRouterContent.html 'A directions request could not be processed due to a server error. The request may succeed if you try again.'
          when 'REQUEST_DENIED'
            that.resultsRouterContent.html 'This webpage is not allowed to use the directions service.'
          when 'OVER_QUERY_LIMIT'
            that.resultsRouterContent.html 'The webpage has gone over the requests limit in too short a period of time.'
          when 'NOT_FOUND'
            that.resultsRouterContent.html 'At least one of the origin, destination, or waypoints could not be geocoded.'
          when 'INVALID_REQUEST'
            that.resultsRouterContent.html 'The DirectionsRequest provided was invalid.'
          else
            that.resultsRouterContent.html "There was an unknown error in your request. Requeststatus: " + status

      that.resultsRouter.show()
      return

    return


  ###
  MapLayers Helper (get/set/unset)
  ###

  ###
  PanoraminoLayer
  ###
  getPanoramino: () ->
    @panoramio

  setPanoramino: (opts) ->
    if !@getPanoramino() 
      @panoramio = new google.maps.panoramio.PanoramioLayer opts || @panoramioCfg
    @panoramio.setMap @map
    return

  unsetPanoramino: () ->
    if @getPanoramino() then @panoramio.setMap null
    return

  ###
  BicyclingLayer
  ###
  getBicycling: () ->
    @bicycling

  setBicycling: (opts) ->
    if !@getBicycling() 
      @bicycling = new google.maps.BicyclingLayer opts || {}
    @bicycling.setMap @map
    return

  unsetBicycling: () ->
    if @getBicycling() then @bicycling.setMap null
    return

  ###
  TransitLayer
  ###
  getTransit: () ->
    @transit

  setTransit: () ->
    if !@getTransit()
      @transit = new google.maps.TransitLayer()
    @transit.setMap @map
    return

  unsetTransit: () ->
    if @getTransit() then @transit.setMap null
    return

  ###
  TrafficLayer
  ###
  getTraffic: () ->
    @traffic

  setTraffic: () ->
    if !@getTraffic()
      @traffic = new google.maps.TrafficLayer()
    @traffic.setMap @map
    return

  unsetTraffic: () ->
    if @getTraffic() then @traffic.setMap null
    return

  ###
  WeatherLayer
  ###
  getWeather: () ->
    @weather

  setWeather: (opts) ->
    if !@getWeather()
      @weather = new google.maps.weather.WeatherLayer opts || {}
    @weather.setMap @map
    return

  unsetWeather: () ->
    if @getWeather() then @weather.setMap null
    return

  ###
  CloudLayer
  ###
  getCloud: () ->
    @cloud

  setCloud: () ->
    if !@getCloud()
      @cloud = new google.maps.weather.CloudLayer()
    @cloud.setMap @map
    return

  unsetCloud: () ->
    if @getCloud() then @cloud.setMap null
    return


  # Public: options
  getOptions: () ->
    @options

  getMap: () ->
    @map

  getCoordinates: () ->
    @mapCoordinates

###
Create Class
###
mapMe = new BeppesMapinizer "map-canvas", "map-directions-results", 
  'mapCfg': 
    'zoom': 13
  'mapCoordinates':
    'center':
      'latitude': 47.421816
      'longitude': 9.599476
  'panoramioCfg':
    'tag': 'rheintal'

###
Window Refs
###
window.beppe = window.beppe || {}

$.extend window.beppe, calcRoute: ->
  mapMe.calcRoute()
  return false

###
Run, you know ...
###
google.maps.event.addDomListener window, 'load', ->

  ###
  Try to communicate with parent window ...

  coffee:
  window.beppesFrameHelper = 
    addClass: (str) ->
      $mapsWrapper.addClass str
    removeClass: (str) ->
      $mapsWrapper.removeClass str 

  javascript:
  window.beppesFrameHelper = {
    addClass: function(str) {
      return $mapsWrapper.addClass(str);
    },
    removeClass: function(str) {
      return $mapsWrapper.removeClass(str);
    }
  };
  ###
  if window.parent
    try
      window.parent.beppesFrameHelper.addClass 'loaded'
    catch error
      sowhat = error

  mapMe.mapInitialize()

  btnCls = 'btn-inverse'
  options = mapMe.getOptions()

  toggleControl = (mapcontrol, activated) ->
    switch mapcontrol
      when "panoramio" 
        if activated then mapMe.unsetPanoramino() else mapMe.setPanoramino()
      when "bicycling" 
        if activated then mapMe.unsetBicycling() else mapMe.setBicycling()
      when "cloud" 
        if activated then mapMe.unsetCloud() else mapMe.setCloud()
      when "weather" 
        if activated then mapMe.unsetWeather() else mapMe.setWeather()
      when "traffic" 
        if activated then mapMe.unsetTraffic() else mapMe.setTraffic()
      when "transit" 
        if activated then mapMe.unsetTransit() else mapMe.setTransit()
    return

  ###
  Add event listener
  ###
  $('#map-control').on  

    'deactivated': ->
      $(this).find('.btn').addClass('disabled').attr 'disabled', 'disabled'
      return 

    'activated': ->
      $(this).find('.btn').removeClass('disabled').removeAttr 'disabled'
      $(this).find('.' + btnCls).each ->        
        toggleControl $(this).data('mapcontrol'), false
        return
      return


  $('#map-control .btn[data-mapcontrol]').each ->

    $this = $(this)
    mapcontrol = $this.data 'mapcontrol'
    
    if options[mapcontrol]
      $this.addClass(btnCls).find('i').addClass('icon-white')


    $this.on 'click', (e) ->

      e.preventDefault()

      if mapcontrol == 'reset'
        mapMe.getMap().panTo mapMe.getCoordinates().centerLatLan
        return false

      $this.toggleClass(btnCls).find('i').toggleClass('icon-white')

      activated = !$this.hasClass btnCls

      toggleControl mapcontrol, activated

      return false

  return
