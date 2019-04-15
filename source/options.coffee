# @Author 程巍巍
# @Mail   littocats@gmail.com
# @Create 2019-04-14 13:48:12
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
program = require 'commander'

program
  .version '1.0.0'
  .usage '[svgdir]'
  .option '-o, --output <string>', 'output file'
  .option '-f, --filter [string]', 'RegExp, only process matched svg file'
  .parse process.argv

cwd = do process.cwd

# 检参数
output = program.output
filter = program.filter || /(.+)\.svg$/i
svgdir = program.args[0]

output = path.resolve cwd, output if output
svgdir = path.resolve cwd, svgdir if svgdir

throw new Error "--output option is required." if not output
throw new Error "svgdir is required" if not svgdir

throw new Error "svgdir is not found." if not fs.existsSync svgdir
stat = fs.statSync svgdir
throw new Error "svgdir is not a dir: #{svgdir}" if not stat.isDirectory()

filter = new RegExp filter

exports.output = output
exports.svgdir = svgdir;
exports.regexp = filter;
exports.filter = (file)-> filter.test path.basename file