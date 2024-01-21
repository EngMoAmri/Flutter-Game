var gameWidth = 820.0;
var gameHeight = 1600.0;

// TODO foreach level
const horizontalItemsCount = 9;
const verticalItemsCount = 9;

var itemGutter = gameWidth * 0.015;
var itemSize =
    (gameWidth - (itemGutter * verticalItemsCount)) / horizontalItemsCount;
