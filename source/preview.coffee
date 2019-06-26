# 生成 svgfont 的预览

module.exports = (style, metadata)->"""
<!DOCTYPE html>
<html>
<head>
<title>SVG Font Preview</title>
<style type="text/css">
#{style}
</style>
<style type="text/css">
body {
  margin: 0px;
  padding: 0px;
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

.item {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin: 8px;

  width: 256px;
}

.item .name {
  margin-right: 11px;
  flex: 0.5;
  text-align: right;
}

.item .icon {
  font-size: 48px;
  line-height: 48px;
  width: 48px;
  height: 48px;

  color: black;
}
</style>
</head>
<body>
#{
Object.values(metadata).map ({name})-> """
<div class="item">
  <div class="name">#{name}</div>
  <icon class="icon font #{name}"></icon>
</div>
"""
.join ''
}
</body>
</html>
"""