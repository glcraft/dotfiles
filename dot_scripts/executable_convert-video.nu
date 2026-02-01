#!/usr/bin/env nu
#
def find-good-path [file ext] {
  
  let out_path = $"($file | path dirname)/($file | path parse | get stem).($ext)"
  if ($out_path | path exists | not $in) {
    return $out_path
  }
  mut counter = 1
  loop {
    let out_path = $"($file | path dirname)/($file | path parse | get stem)_($counter).($ext)"
    if ($out_path | path exists | not $in) {
      return $out_path
    }
    $counter += 1
  }
}

def main [
  encoder:string
  extension:string
  ...files
] {
  let additional = match $encoder {
    "libx265" => [-pix_fmt yuv420p -c:v libx265 -crf '28' -preset medium]
    _ => [-c:v $encoder]
  }
  $files | each {|file|
    if not ($file | path exists) {
      return
    }
    let out_path = find-good-path $file $extension
    ffmpeg -i $file ...$additional -fs 50M $out_path
  }
}
