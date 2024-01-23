double maxLength = 500.0;
var gameWidth = 500.0;
var gameHeight = 500.0;
const maxItemInRowAndCol = 8;
const horizontalItemsCount = 8;
const verticalItemsCount = 8;

var itemGutterRatio = 0.001;
var itemGutter = gameWidth * itemGutterRatio;
var itemSize = (horizontalItemsCount > verticalItemsCount)
    ? (gameWidth - (itemGutter * verticalItemsCount)) / horizontalItemsCount
    : (gameWidth - (itemGutter * horizontalItemsCount)) / verticalItemsCount;
