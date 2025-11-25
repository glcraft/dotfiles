def completion_ollama_run_think [] {
  ["true" "false" "high" "medium" "low"]
}
def completion_ollama_models [] {
  ollama list | from ssv | get NAME
}
def completion_ollama_running_models [] {
  ollama ps | from ssv | get NAME
}
def completion_ollama_online_models [text?:string] {
  # let text = $text | default ""
  # http get $"https://www.ollama.com/search?o=($text)" | hq "{found:div[title] | [{value: span, description: p}]}" | from json | get found | select value description
   
  # let text = (if ($text | is-not-empty) {
  #   $text | str substring 0..(commandline get-cursor) 
  # } else {
  #   ""
  # })
  let text = commandline get-cursor | into string 
  [$text]
}
# Run a model
export extern "ollama run" [
  --dimensions:int                    # Truncate output embeddings to specified dimension (embedding models only)
  --format:string                     # Response format (e.g. json)
  --help(-h)                          # help for run
  --hidethinking                      # Hide thinking output (if provided)
  --insecure                          # Use an insecure registry
  --keepalive:string                  # Duration to keep a model loaded (e.g. 5m)
  --nowordwrap                        # Don't wrap words to the next line automatically
  --think:string@completion_ollama_run_think # Enable thinking mode: true/false or high/medium/low for supported models
  --truncate                          # For embedding models: truncate inputs exceeding context length (default: true). Set --truncate=false to error instead
  --verbose                           # Show timings for response
  model:string@completion_ollama_models      # Model to run with
  prompt?:string
]
# Remove a model
export extern "ollama rm" [
  --help(-h)                          # help for remove
  model:string@completion_ollama_models      # Model to run with
]
# Remove a model
export extern "ollama stop" [
  --help(-h)                             # help for stop
  model:string@completion_ollama_running_models # Model to stop
]
# Show information for a model
export extern "ollama show" [
  --help(-h)     # help for show
  --license      # Show license of a model
  --modelfile    # Show Modelfile of a model
  --parameters   # Show parameters of a model
  --system       # Show system message of a model
  --template     # Show template of a model
  --verbose(-v)  # Show detailed model information
  model:string@completion_ollama_models      # Model to show
]
# Pull a model from a registry
export extern "ollama pull" [
  --help(-h)   # help for pull
  --insecure   # Use an insecure registry
  model:string@completion_ollama_online_models
]
