#!/usr/bin/env nu

def main [path:string] {
  if ($env | get -o HELIX_PANE | $in == null) {
    return
  }
  wezterm cli send-text $":open ($path)\r\n" --no-paste --pane-id $env.HELIX_PANE
  wezterm cli activate-pane --pane-id $env.HELIX_PANE
}
