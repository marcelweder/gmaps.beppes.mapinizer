# BeppesMapinizer - A Simple JavaScript Controller for Google Maps (API)

Just my work that I use on my own website.

Learn more about Google Maps JavaScript API v3
https://developers.google.com/maps/documentation/javascript/

# Requirements

* jQuery 1.8+
* Twitter Bootstrap v2.3.0+
  * LESS
    * variables.less
    * mixins.less
    * button-groups.less
    * buttons.less
    * forms.less
    * sprites.less
  * Glyphicons 
    * img/glyphicons-halflings.png
    * img/glyphicons-halflings-white.png
* Modern Browser

**Hands up! See also https://github.com/twitter/bootstrap/wiki/License.**

# Preparation

1. If you do need it, use a preprocoessor toolkit to compile the LESS files. (for example: folder ```css```, name ```app.maps2013.min.css```)
2. If you do need it, use a preprocoessor toolkit to compile the COFFEE files. (for example: folder ```js```, name ```app.maps2013.min.js```)
3. If you do need it, use a preprocoessor toolkit to compile the JADE files. (for example: ```root```, name ```index.html``` or ```index.php```)
4. Open up the application in your browser and control your map

# Usage

Feel free. Change markers configuration in the CoffeeScript file, or make the changes directly in the compiled JavaScript file. What you want. Hand's up! After next updates the changes are lost! Copy this code and make your own controller.

The easy way: Configure the 'class' caller in the CoffeeScript file:

    ###
    Create Class
    ###
    mapMe = new BeppesMapinizer "map-canvas", "map-directions-results", 
      'mapCfg': 
        'zoom': 13
      'mapCoordinates': # map start center 
        'center':
          'latitude': 47.421816
          'longitude': 9.599476
      'panoramioCfg':
        'tag': 'rheintal'
    # ... 

# Copyright & License

Copyright (c) 2013 Marcel A. Weder <m.a.weder@gmail.com>  
Licensed under the WTFPL license:
http://www.wtfpl.net/
