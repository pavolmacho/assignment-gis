<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="WebApplication1.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.2/jquery.min.js"></script>
    <script src='https://api.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.js'></script>
    <link href='https://api.mapbox.com/mapbox-gl-js/v0.26.0/mapbox-gl.css' rel='stylesheet' />
    

</head>
<body>

    <style>
.coordinates {
    background: rgba(0,0,0,0.5);
    color: #fff;
    position: absolute;
    bottom: 10px;
    left: 10px;
    padding:5px 10px;
    margin: 0;
    font-size: 11px;
    line-height: 18px;
    border-radius: 3px;
    display: none;
}
</style>

    <div id='map' style='z-index: 1; left: 400px; top: 0; bottom: 0; right: 0; position: absolute;width:100%;'>
    </div>
    <form id="form1" runat="server">
    <div id="posit"><asp:Label ID="Label2" runat="server" Font-Size="20pt" Text="Vyber okres na zobrazenie:"></asp:Label>
        </div>
    <asp:DropDownList ID="DropDownList1" runat="server" Font-Size="18pt" OnSelectedIndexChanged="DropDownList1_SelectedIndexChanged" Width="357px">
            
        </asp:DropDownList>
    
    
    <pre id='coordinates' class='coordinates'></pre>
    <script type="text/javascript">
        mapboxgl.accessToken = 'pk.eyJ1IjoicGF2b2wiLCJhIjoiY2l1NDJhcWhtMDAwcDJvbXBsYzB2d2tkMyJ9.mpzCBxBF4x7YwvsBe99OcA';

     
    var map = new mapboxgl.Map({
        container: 'map',
        style: 'mapbox://styles/mapbox/streets-v8',
        center: [18.602282705593552, 48.21746197560785],
        zoom: 8
    });

    var isDragging;
    var isCursorOverPoint;
    var coordinates = document.getElementById('coordinates');
    var canvas = map.getCanvasContainer();
    var geojson = {
        "type": "FeatureCollection",
        "features": [{
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [18.602282705593552 , 48.21746197560785]
            }
        }]
    };

    function mouseDown() {
        if (!isCursorOverPoint) return;

        isDragging = true;

        // Set a cursor indicator
        canvas.style.cursor = 'grab';

        // Mouse events
        map.on('mousemove', onMove);
        map.on('mouseup', onUp);
    }

    function onMove(e) {
        if (!isDragging) return;
        var coords = e.lngLat;

        // Set a UI indicator for dragging.
        canvas.style.cursor = 'grabbing';

        // Update the Point feature in `geojson` coordinates
        // and call setData to the source layer `point` on it.
        geojson.features[0].geometry.coordinates = [coords.lng, coords.lat];
        map.getSource('point1').setData(geojson);
    }

    function onUp(e) {
        if (!isDragging) return;
        var coords = e.lngLat;

        // Print the coordinates of where the point had
        // finished being dragged to on the map.
        coordinates.style.display = 'block';
        coordinates.innerHTML = 'Longitude: ' + coords.lng + '<br />Latitude: ' + coords.lat;
        canvas.style.cursor = '';
        isDragging = false;
        Geojson_f4_1();
    }
    

    map.on('load', function () {
        map.addSource('point1', {
            "type": "geojson",
            "data": geojson
        });

        map.addLayer({
            "id": "point1",
            "type": "circle",
            "source": "point1",
            "paint": {
                "circle-radius": 10,
                "circle-color": "#3887be"
            }
        });

        // If a feature is found on map movement,
        // set a flag to permit a mousedown events.
        map.on('mousemove', function (e) {
            var features = map.queryRenderedFeatures(e.point, { layers: ['point1'] });

            // Change point and cursor style as a UI indicator
            // and set a flag to enable other mouse events.
            if (features.length) {
                map.setPaintProperty('point1', 'circle-color', '#3bb2d0');
                canvas.style.cursor = 'move';
                isCursorOverPoint = true;
                map.dragPan.disable();
            } else {
                map.setPaintProperty('point1', 'circle-color', '#3887be');
                canvas.style.cursor = '';
                isCursorOverPoint = false;
                map.dragPan.enable();
            }
        });

        // Set `true` to dispatch the event before other functions call it. This
        // is necessary for disabling the default map dragging behaviour.
        map.on('mousedown', mouseDown, true);
    });
      
    
    map.on('click', function (e) {
        var features = map.queryRenderedFeatures(e.point, { layers: ['markers'] });

        if (!features.length) {
            return;
        }

        var feature = features[0];

        // Populate the popup and set its coordinates
        // based on the feature found.
        var popup = new mapboxgl.Popup()
            .setLngLat(feature.geometry.coordinates)
            .setHTML("Your current position")
            .addTo(map);
    });

    
  
        
        ////////
   

    function Geojson_f1_1(position) {

       map.addSource("markers", {
            "type": "geojson",
            "data": {
                "type": "FeatureCollection",
                "features": [{
                    "type": "Feature",
                    "geometry": {
                        "type": "Point",
                        "coordinates": [position.coords.longitude , position.coords.latitude]
                    }, 
                    "properties": {
                     
                        "icon": "marker-15"
                     

                    }
                }]
            }
        });
        
        map.addLayer({
            "id": "markers",
            "source": "markers",
            "type": "symbol",
            "layout": {                
                "icon-image": "marker-15",             
                "text-field": "{title}",               
                "text-offset": [0, 0.6],
                "text-anchor": "top"
            }
        });
    
        $.ajax({
            type: "POST",
            async: true,
            processData: true,
            cache: false,
            url: 'WebForm1.aspx/GetDataSet',
            data: '{"x":"' + position.coords.latitude + '","y":"' + position.coords.longitude + '"}',
            contentType: 'application/json; charset=utf-8',
            dataType: "json",
            
            success: function (data) {
                try {
                    var geo = JSON.parse(data.d);
                    var geojson = jQuery.parseJSON(data.d);
                                      
                    map.addSource("points", {
                        "type": "geojson",
                        "data":
                            geo

                    });
                        map.addLayer({
                            'id': 'points',
                            'type': 'fill',
                            'source': 'points',
                            'layout': {},
                            'paint': {
                                'fill-color': '#088',
                                'fill-opacity': 0.8
                            }
                        });
                                           
                }
                catch (err) {
                    alert(err);
                
                 }
            },
            error: function (err) {
                
                alert(err.statusText);
            
                
            }
        });
        
    }
    
    var x = document.getElementById("posit");

    function getLocation() {
        if (navigator.geolocation) {
           navigator.geolocation.getCurrentPosition(Geojson_f1_1);
            
        } else {
            x.innerHTML = "Geolocation is not supported by this browser.";
            }
    }
    
    function Geojson_f2_1() {

        var answer = document.getElementById("DropDownList1");
        var res = answer[answer.selectedIndex].value.split(".");
        clear("lines");
        $.ajax({
            type: "POST",
            async: true,
            processData: true,
            cache: false,
            url: 'WebForm1.aspx/GetDataSet2',
            data: '{"okr":"' + res[1] + '"}',
            contentType: 'application/json; charset=utf-8',
            dataType: "json",

            success: function (data) {
                try {
                    var geo = JSON.parse(data.d);
                    var geojson = jQuery.parseJSON(data.d);
                    

                    
                    map.addSource("lines", {
                        "type": "geojson",
                        "data": {
                            "type": "FeatureCollection",
                            "features":[{
                                "type": "Feature",
                                "geometry":

                       geo
                            }]
                        }
                    });
                    map.addLayer({
                        "id": "lines",
                        "type": "line",
                        "source": "lines",
                        "layout": {
                            "line-join": "round",
                            "line-cap": "round"
                        },
                        "paint": {
                            "line-color": "#888",
                            "line-width": 6
                        }
                    });
                    
                }
                catch (err) {
                    alert(err);

                }
            },
            error: function (err) {

                alert(err.statusText);


            }
        });

    }
         
    function Geojson_f3_1() {
        var answer = document.getElementById("DropDownList1");
        var res = answer[answer.selectedIndex].value.split(".");
        clear("poly");
        $.ajax({
            type: "POST",
            async: true,
            processData: true,
            cache: false,
            url: 'WebForm1.aspx/GetDataSet3',
            data: '{"okr":"' + res[1] + '"}',
            contentType: 'application/json; charset=utf-8',
            dataType: "json",

            success: function (data) {
                try {
                    var geo = JSON.parse(data.d);
                    var geojson = jQuery.parseJSON(data.d);
                    map.addSource("poly", {
                        "type": "geojson",
                        "data": 
                            geo                         
                        
                    });
                   map.addLayer({
                        'id': 'poly',
                        'type': 'fill',
                        'source': 'poly',
                        'layout': {},
                        'paint': {
                            'fill-color': '#088',
                            'fill-opacity': 0.8
                        }
                    });
                }
                catch (err) {
                    alert(err);

                }
            },
            error: function (err) {

                alert(err.statusText);


            }
        });

    }

    function Geojson_f4_1() {
        clear("parking");
        $.ajax({
            type: "POST",
            async: true,
            processData: true,
            cache: false,
            url: 'WebForm1.aspx/GetDataSet4',
            data: '{"x":"' + geojson.features[0].geometry.coordinates + '"}',
            contentType: 'application/json; charset=utf-8',
            dataType: "json",

            success: function (data) {
                try {
                    var geo = JSON.parse(data.d);
                    var geojson = jQuery.parseJSON(data.d);
                    
                    map.addSource("parking", {
                        "type": "geojson",
                        "data":
                            geo
                    });
                    map.addLayer({
                        "id": "parking",
                        "source": "parking",
                        "type": "symbol",
                        "layout": {
                            "icon-image": "marker-15",
                            "text-field": "{title}",
                            "text-offset": [0, 0.6],
                            "text-anchor": "top"
                        }
                    });
                    
                    
                }
                catch (err) {
                    alert(err);

                }
            },
            error: function (err) {

                alert(err.statusText);


            }
        });

    }

    function clear(layer) {

        if (map.getLayer(layer) != undefined) {
            map.removeSource(layer)
            
            map.removeLayer(layer);
            
        };

    }

    function func1() {
         getLocation();
    }
    function func2() {
        Geojson_f2_1();
        Geojson_f3_1();
    }


    
    </script>
        <br />
        <br />
    <div>
                &nbsp;&nbsp;&nbsp;&nbsp;
                <button type="button" runat="server"  onclick="func2()" >Zobraz okres</button>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br />
                <br />
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true">

        </asp:ScriptManager>
    
                <br />
                <asp:Label ID="Label3" runat="server" Text="Aktuálna poloha:" Font-Size="20pt"></asp:Label>
    
    </div>
        <p>
&nbsp;&nbsp;&nbsp;&nbsp;
                <button type="button" runat="server"  onclick="func1()">Zobraz</button>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </p>
        <p>
                &nbsp;</p>
        
    </form>
</body>
</html>
