var screenWidth = 500.0;
var screenHeight = 500.0;
var minZoom = 1.0;
var maxZoom = 1.5;

var itemGutterRatio = 0.001;
var itemGutter = screenWidth * itemGutterRatio;
var itemSize = (screenWidth - (itemGutter * 9)) /
    9 /* this is just to equal the swap game */;
