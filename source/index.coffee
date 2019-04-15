# @Author 程巍巍
# @Mail   littocats@gmail.com
# @Create 2019-04-14 13:46:49
# 
# Copyright 2019-04-14 程巍巍
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

fs = require 'fs-extra'
path = require 'path'
child_process = require 'child_process'
Writable = require('stream').Writable

SvgIcons2SvgFont = require 'svgicons2svgfont'
svg2ttf = require 'svg2ttf'
ttf2woff = require 'ttf2woff'

options = require './options'

# 
resolveName = (file)->
  matches = file.match options.regexp
  return matches[1] if matches and matches[1]
  return file.replace(/\..+$/, '')
    .replace /[._@$!%^&*()+=?\s]+/, '-'

# 找到目录下满足 filter 的文件
# 不递规，因为可能会引起命名冲突
findSvgs = (dir)->
  fs.readdir(dir)
  .then (files)-> files.filter options.filter
  .then (files)-> files.map (file)->
    file: path.resolve dir, file
    name: resolveName file

class FontStream extends Writable
  constructor: ()->
    super()
    @buffers = []
    @metadata = {}
    @code = 0xe400
    @name = "SIF#{Math.random().toString(36).slice(2)}"
    @font = new SvgIcons2SvgFont(
      fontName: @name
      normalize: true
      fontHeight: 1000
    )

    @font.pipe @

FontStream::_write = (chunk, enc, done)->
  @buffers.push chunk
  process.nextTick done

FontStream::append = ({file, name})->
  glyph = fs.createReadStream file
  @code += 32
  
  glyph.metadata = @metadata[name] =
    unicode: [String.fromCodePoint @code]
    name: name
    code: @code

  @font.write glyph

FontStream::next = ()-> new Promise (resolve, reject)=>
  @on 'finish', ()=> resolve 
    name: @name
    metadata: @metadata
    buffer: Buffer.concat @buffers

  @on 'error', (error)=> reject error

  do @font.end

generateStyleSheet = (name, metadata, buffer)-> """
@font-face {
  font-family: '#{name}';
  src: url('data:application/x-font-woff;charset=utf-8;base64,#{
    Buffer.from(buffer).toString('base64')
  }') format('woff');
}
icon.font {
  font-family: "#{name}" !important;
  font-size: 16px;
  font-style: normal;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  display: flex;
  align-content: center;
}
#{
Object.values(metadata).map ({name, unicode, code})-> """
icon.font.#{name}::before {
  content: "\\#{code.toString(16)}";
}
"""
.join '\n'
}
"""

findSvgs options.svgdir
.then (files)->
  fontStream = new FontStream
  files.forEach (file)-> fontStream.append file
  return fontStream.next()
.then ({buffer, metadata, name})->
  ttf = svg2ttf buffer.toString(), {}
  woff = ttf2woff ttf.buffer, {}
  generateStyleSheet name, metadata, woff.buffer
.then (style)->
  fs.writeFile options.output, style