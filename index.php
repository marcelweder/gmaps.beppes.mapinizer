<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no">
    <meta name="robots" content="noindex, nofollow">
    <link href="/location/css/app.maps2013v1.min.css" type="text/css" rel="stylesheet">
    <script src="//maps.googleapis.com/maps/api/js?sensor=false&amp;libraries=drawing,panoramio,weather" type="text/javascript"></script>
    <script src="/js/libs/jquery-1.8.3.min.js" type="text/javascript"></script>
  </head>
  <body>
    <div id="map-canvas" style="width:100%; height:100%"></div>
    <div id="map-directions" class="hide">
      <div class="close"><strong>&times;</strong></div>
      <div id="map-directions-results"></div>
    </div>
    <div id="map-control" class="hide">
      <div class="btn-group btn-group-vertical">
        <button title="Zurück ..." data-mapcontrol="reset" class="btn btn-mini"><img src="/location/icons/maps-bubble-avatar.png" alt=""></button>
        <button title="Panoramio" data-mapcontrol="panoramio" class="btn btn-mini"><i class="icon-picture"></i></button>
        <button title="Radwege (Labels: on)" data-mapcontrol="bicycling" class="btn btn-mini"><i class="icon-play-circle"></i></button>
        <button title="Wetter (Zoom: 0-12)" data-mapcontrol="weather" class="btn btn-mini"><i class="icon-tint"></i></button>
        <button title="Transit (Labels: on) *cities that supports this" data-mapcontrol="transit" class="btn btn-mini"><i class="icon-eye-open"></i></button>
        <button title="Verkehr (Labels: on)" data-mapcontrol="traffic" class="btn btn-mini"><i class="icon-road"></i></button>
        <button title="Wolken (Zoom: 0-6)" data-mapcontrol="cloud" class="btn btn-mini"><i class="icon-asterisk"></i></button>
      </div>
    </div>
    <script src="/location/js/app.maps2013v2.min.js"></script>
  </body>
</html>