#!/usr/bin/env nu
let tmpfile = mktemp ocr-XXXXXX.png
try {
  spectacle -br -n -o $tmpfile o+e>| ignore
  if (open $tmpfile | is-empty) {
    notify-send "OCR" "Capture annulée"
  } else {
    tesseract $tmpfile stdout | wl-copy
    notify-send "OCR" "Texte copié dans le presse-papier"
  }
} catch {|err|
  notify-send "OCR" $"Capture échouée: ($err.msg)"
}
rm $tmpfile
